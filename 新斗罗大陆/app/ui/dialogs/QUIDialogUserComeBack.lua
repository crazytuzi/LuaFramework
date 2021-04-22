--
-- Author: Kumo
-- 老玩家回归界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUserComeBack = class("QUIDialogUserComeBack", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")

local QUIWidgetUserComeBackButton = import("..widgets.QUIWidgetUserComeBackButton")
local QUIWidgetUserComeBackItems = import("..widgets.QUIWidgetUserComeBackItems")
local QUIWidgetUserComeBackPrivilegeCell = import("..widgets.QUIWidgetUserComeBackPrivilegeCell")
local QUserComeBack = import("...network.models.QUserComeBack")

function QUIDialogUserComeBack:ctor(options)
    local ccbFile = "ccb/Dialog_ComeBack.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogUserComeBack.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:showWithMainPage()
    page:setManyUIVisible()

    self._curSelectBtnIndex = 1
    if options then 
        if options.selectIndex ~= nil then
            self._curSelectBtnIndex = options.selectIndex
        end
        if options.callback then
            self._callback = options.callback
        end
    end
    self._btnData = {}
	self._awardData = {}
	table.insert(self._btnData, {type = QUserComeBack.TYPE_AWARD, title = "免费送礼"})
	table.insert(self._btnData, {type = QUserComeBack.TYPE_FEATRUE, title = "玩法特权"})
	table.insert(self._btnData, {type = QUserComeBack.TYPE_PAY, title = "充值特惠"})
	table.insert(self._btnData, {type = QUserComeBack.TYPE_EXCHANGE, title = "超值特购"})

    self:_init()
end

function QUIDialogUserComeBack:_init()
    --切圖
    local size = self._ccbOwner.node_menu_bg_mask:getContentSize()
    local lyImageMask = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
    local ccclippingNode = CCClippingNode:create()
    lyImageMask:setPositionX(self._ccbOwner.node_menu_bg_mask:getPositionX())
    lyImageMask:setPositionY(self._ccbOwner.node_menu_bg_mask:getPositionY())
    lyImageMask:ignoreAnchorPointForPosition(self._ccbOwner.node_menu_bg_mask:isIgnoreAnchorPointForPosition())
    lyImageMask:setAnchorPoint(self._ccbOwner.node_menu_bg_mask:getAnchorPoint())
    ccclippingNode:setStencil(lyImageMask)
    ccclippingNode:setInverted(false)
    self._ccbOwner.sp_menu_bg:retain()
    self._ccbOwner.sp_menu_bg:removeFromParent()
    ccclippingNode:addChild(self._ccbOwner.sp_menu_bg)
    self._ccbOwner.node_menu_bg:addChild(ccclippingNode)
    self._ccbOwner.sp_menu_bg:release()
end

function QUIDialogUserComeBack:viewDidAppear()
    QUIDialogUserComeBack.super.viewDidAppear(self)
    self:addBackEvent(false)

    self._userComeBackProxy = cc.EventProxy.new(remote.userComeBack)
    self._userComeBackProxy:addEventListener(remote.userComeBack.UPDATE_USER_COMEBACK, handler(self, self.updateHandler))

    self:_initBtnListView()  
    self:_updateUIInfo()
end

function QUIDialogUserComeBack:viewWillDisappear()
    QUIDialogUserComeBack.super.viewWillDisappear(self)
    self:removeBackEvent()
    if self._userComeBackProxy ~= nil then
        self._userComeBackProxy:removeAllEventListeners()
        self._userComeBackProxy = nil
    end
    if self._schedulerCountDown then
        scheduler.unscheduleGlobal(self._schedulerCountDown)
        self._schedulerCountDown = nil
    end

    if self._awardListView then
        self._awardListView:clear()
        self._awardListView:unscheduleUpdate()
        self._awardListView = nil
    end
end 

function QUIDialogUserComeBack:_updateUIInfo()
    -- 和时间有关的数据
    self:_updateTime()
    if self._schedulerCountDown then
        scheduler.unscheduleGlobal(self._schedulerCountDown)
        self._schedulerCountDown = nil
    end
    self._schedulerCountDown = scheduler.scheduleGlobal(function ()
        self:_updateTime()
    end, 1)
end

function QUIDialogUserComeBack:_updateTime()
    local isOvertime, dayInt, timeStr = remote.userComeBack:updateTime()
    if not isOvertime then
        self._ccbOwner.tf_countdown:setString(timeStr)
        self._ccbOwner.tf_day:setString(dayInt)
    else
        if self._schedulerCountDown then
            scheduler.unscheduleGlobal(self._schedulerCountDown)
            self._schedulerCountDown = nil
        end
        self._ccbOwner.tf_countdown:setString("00:00:00")
        self._ccbOwner.tf_day:setString("0")

        self:popSelf()
        app.tip:floatTip("活动已结束")
    end
end

function QUIDialogUserComeBack:_initBtnListView()
    if not self._btnListView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local item = list:getItemFromCache()
                local data = self._btnData[index]
                if not item then
                    item = QUIWidgetUserComeBackButton.new()
                    isCacheNode = false
                end
                item:setInfo(data)
                info.item = item
                info.size = item:getContentSize()

                list:registerBtnHandler(index, "btn_click", handler(self, self._onClickBtnItem))
                
                if self._curSelectBtnIndex == index then
                    item:setSelect(true)
                else
                    item:setSelect(false)
                end
                return isCacheNode
            end,
            headIndex = self._curSelectBtnIndex,
            spaceY = 3,
            enableShadow = true,
            ignoreCanDrag = true,
            totalNumber = #self._btnData,
        }  
        self._btnListView = QListView.new(self._ccbOwner.node_menu_list_view, cfg)
    else
        self._btnListView:reload({totalNumber = #self._btnData})
    end
   
    if #self._btnData > 0 then
        self:refreshContent()
    end
end

function QUIDialogUserComeBack:_onClickBtnItem( x, y, touchNode, listView )
    app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()

    if self._curSelectBtnIndex and self._curSelectBtnIndex ~= touchIndex then
        local oldItem = listView:getItemByIndex(self._curSelectBtnIndex)
        if oldItem then
            oldItem:setSelect(false)
        end
    end

    local item = listView:getItemByIndex(touchIndex)
    if item then
        item:setSelect(true)
    end

    if self._curSelectBtnIndex ~= touchIndex then
        self._curSelectBtnIndex = touchIndex
        self:getOptions().selectIndex = touchIndex
        self:refreshContent()
    end
end

function QUIDialogUserComeBack:refreshContent()
    local isOpened = remote.userComeBack:getIsOpen()
    if isOpened then
        self._oldSelectInfo = self._selectInfo
        local info = self._btnData[self._curSelectBtnIndex]
        if not info then return end
        self._selectInfo = info
        self:_updateAwardsData()
    else
        self:_onTriggerClose()
    end
end

function QUIDialogUserComeBack:_updateAwardsData()
    self._ccbOwner.content_sheet_layout:setVisible(true)
    self._ccbOwner.tf_tips:setVisible(false)

    local configs = remote.userComeBack:getDataByType(self._selectInfo.type)
    if self._selectInfo.type == remote.userComeBack.TYPE_AWARD then
        self._awardData = self:_getAwardsData(configs)
        self:_initAwardListView()
    elseif self._selectInfo.type == remote.userComeBack.TYPE_EXCHANGE then
        self._awardData = self:_getExchangeData(configs)
        self._ccbOwner.tf_tips:setVisible(true)
        self._ccbOwner.tf_tips:setString("（超值特购购买次数每日重置）")
        self:_initAwardListView()
    elseif self._selectInfo.type == remote.userComeBack.TYPE_PAY then
        self._awardData = self:_getPayData(configs)
        self._ccbOwner.tf_tips:setVisible(true)
        self._ccbOwner.tf_tips:setString("（充值特惠充值次数每日不重置）")
        self:_initAwardListView()
    elseif self._selectInfo.type == remote.userComeBack.TYPE_FEATRUE then
        self._awardData = self:_getFeatureData(configs)
        self:_initPrivilegeView()
    end
end

function QUIDialogUserComeBack:_initAwardListView()
    self._ccbOwner.node_normal:setVisible(true)
    self._ccbOwner.node_special:setVisible(false)

    if not self._awardListView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local item = list:getItemFromCache()
                local data = self._awardData[index]
                if not item then
                    item = QUIWidgetUserComeBackItems.new()
                    isCacheNode = false
                end
                item:setInfo(data, self)
                info.item = item
                info.size = item:getContentSize()

                list:registerTouchHandler(index, "onTouchListView")
                list:registerBtnHandler(index, "btn_ok", "_onTriggerOK", nil, true)
                list:registerBtnHandler(index, "btn_go", "_onTriggerOK", nil, true)
                return isCacheNode
            end,
            spaceY = 3,
            enableShadow = true,
            ignoreCanDrag = true,
            totalNumber = #self._awardData,
        }  
        self._awardListView = QListView.new(self._ccbOwner.content_sheet_layout, cfg)
    else
        if self._oldSelectInfo and self._oldSelectInfo.type == self._selectInfo.type then
            self._awardListView:refreshData()
        else
            self._awardListView:reload({totalNumber = #self._awardData, isClear = true})
        end
    end
end

function QUIDialogUserComeBack:getContentListView()
    return self._awardListView
end

function QUIDialogUserComeBack:_initPrivilegeView()
    self._ccbOwner.node_normal:setVisible(false)
    self._ccbOwner.node_special:setVisible(true)

    if not q.isEmpty(self._awardData) then
        for index, value in ipairs(self._awardData) do
            local node  = self._ccbOwner["node_item_"..index]
            if node then
                node:removeAllChildren()
                local widget = QUIWidgetUserComeBackPrivilegeCell.new({data = value})
                node:addChild(widget)
            end
        end
    end
end

function QUIDialogUserComeBack:_getAwardsData(configs)
    local data = {}
    local loginDay = remote.userComeBack:getUserComeBackLoginDays()
    local totalDay = remote.userComeBack:getUserComeBackDurationDays()
    for _,v in ipairs(configs) do
        if v.day <= totalDay then
            local isGet = remote.userComeBack:checkLoginRewardInfoById(v.id)
            local isCanGet = v.day <= loginDay
            table.insert(data, {config = v, typeName = self._selectInfo.type, isGet = isGet, isCanGet = isCanGet})
        end
    end
    table.sort(data, function (a,b)
        if a.isGet ~= b.isGet then
            return not a.isGet
        end
        if a.isCanGet ~= b.isCanGet then
            return a.isCanGet
        end
        if a.config.day ~= b.config.day then
            return a.config.day < b.config.day
        end
        if a.config.special_type ~= b.config.special_type then
            return a.config.special_type < b.config.special_type
        end
        return a.config.id < b.config.id
    end)
    return data
end

function QUIDialogUserComeBack:_getExchangeData(configs)
    local data = {}
    for _,v in ipairs(configs) do
        local count = remote.userComeBack:getExchangeCountById(v.id)
        local totalCount = v.oneday_exchange_num
        table.insert(data, {config = v, typeName = self._selectInfo.type, count = count, totalCount = totalCount})
    end
    table.sort(data, function (a,b)
        local _countA = a.totalCount - a.count
        local _countB = b.totalCount - b.count
        if (_countA > 0) ~= (_countB > 0) then
            return _countA > 0
        end
        if a.config.show_discount ~= b.config.show_discount then
            return a.config.show_discount < b.config.show_discount
        end
        if a.config.exchange_much ~= b.config.exchange_much then
            return a.config.exchange_much < b.config.exchange_much
        end
        if a.config.exchange_show ~= b.config.exchange_show then
            return a.config.exchange_show < b.config.exchange_show
        end
        return a.config.id < b.config.id
    end)
    return data
end

function QUIDialogUserComeBack:_getPayData(configs)
    local data = {}
    local dailyMaxRecharge = remote.userComeBack:getDailyMaxRecharge()
    local dailyTotalRecharge = remote.userComeBack:getDailyTotalRecharge()
    for _,v in ipairs(configs) do
        local isGet = remote.userComeBack:checkRechargeRewardInfoById(v.id)
        local isCanGet = false
        if v.chongzhi_leixing == 1 then
            isCanGet = dailyMaxRecharge >= v.chongzhi_jine
        else
            isCanGet = dailyTotalRecharge >= v.chongzhi_jine
        end
        table.insert(data, {config = v, typeName = self._selectInfo.type, isGet = isGet, isCanGet = isCanGet})
    end
    table.sort(data, function (a,b)
        if a.isGet ~= b.isGet then
            return not a.isGet
        end
        if a.isCanGet ~= b.isCanGet then
            return a.isCanGet
        end
        if a.config.chongzhi_jine ~= b.config.chongzhi_jine then
            return a.config.chongzhi_jine < b.config.chongzhi_jine
        end
        return a.config.id < b.config.id
    end)
    return data
end

function QUIDialogUserComeBack:_getFeatureData(configs)
    local data = {}
    for _,v in ipairs(configs) do
        table.insert(data, {config = v, typeName = self._selectInfo.type})
    end
    table.sort(data, function (a,b)
        return a.config.id < b.config.id
    end)
    return data
end

function QUIDialogUserComeBack:updateHandler(e)
    self:refreshContent()

    self:_initBtnListView()
end

-- function QUIDialogUserComeBack:_redTipsChange(e)
--     self._btnListView:refreshData()
-- end

function QUIDialogUserComeBack:onTriggerBackHandler(tag)
    self:_onTriggerBack()
end

function QUIDialogUserComeBack:onTriggerHomeHandler(tag)
    self:_onTriggerHome()
end

-- 对话框退出
function QUIDialogUserComeBack:_onTriggerBack(tag, menuItem)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    if self._callback then
        self._callback()
    end
end

-- 对话框退出
function QUIDialogUserComeBack:_onTriggerHome(tag, menuItem)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    if self._callback then
        self._callback()
    end
end

-- 关闭对话框
function QUIDialogUserComeBack:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end  
    if e then
        app.sound:playSound("common_close")
    end
    self:playEffectOut()
end

function QUIDialogUserComeBack:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
    if self._callback then
        self._callback()
    end
end


return QUIDialogUserComeBack