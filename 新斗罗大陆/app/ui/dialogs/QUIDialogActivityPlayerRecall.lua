-- @Author: xurui
-- @Date:   2019-07-02 15:41:57
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-07-18 11:30:14
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityPlayerRecall = class("QUIDialogActivityPlayerRecall", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetPlayerRecallButton = import("..widgets.QUIWidgetPlayerRecallButton")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")

function QUIDialogActivityPlayerRecall:ctor(options)
	local ccbFile = "ccb/Dialog_activity_playerRecall_New.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogActivityPlayerRecall.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page:setScalingVisible(true)
    page.topBar:showWithMainPage()

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
        self._curSelectBtnIndex = options.selectIndex
    end

    self._curSelectBtnIndex = self._curSelectBtnIndex or 1
    self._btnData = {}
    self._awardData = {}
    table.insert(self._btnData, {type = remote.playerRecall.TYPE_AWARD, title = "登录福利", className = "QPlayerRecallAwardUtil"
        , spTips = QResPath("activity_playerReturn_zi")[1],titleTable = {
        {oType = "font", content = "荣荣给您准备了丰厚的奖励，登录即可获得限时称号，连续登录还有大量钻石哦~", size = 20, color = COLORS.j},
    }})
    table.insert(self._btnData, {type = remote.playerRecall.TYPE_FEATRUE, title = "回归特惠", className = "QPlayerRecallFeatrueUtil"
        , spTips = QResPath("activity_playerReturn_zi")[2], titleTable = {
        {oType = "font", content = "魂师大人，这里可以充值获得大量稀有的奖励（",size = 20, color = COLORS.j},
        {oType = "font", content = "每日不重置奖励", size = 20,color = COLORS.M},
        {oType = "font", content = "），充值可以与别的活动叠加，千万不可错过哦~",size = 20, color = COLORS.j},
    }})
    table.insert(self._btnData, {type = remote.playerRecall.TYPE_PAY, title = "回归贩售", className = "QPlayerRecallPayUtil"
        , spTips = QResPath("activity_playerReturn_zi")[3], titleTable = {
        {oType = "font", content = "魂师大人，这里可以低折扣购买大量奖励（",size = 20, color = COLORS.j},
        {oType = "font", content = "每日重置购买次数", size = 20,color = COLORS.M},
        {oType = "font", content = "），甚至会出售很多稀有道具哦~",size = 20, color = COLORS.j},
    }})
    table.insert(self._btnData, {type = remote.playerRecall.TYPE_BUFF, title = "回归加成", className = "QPlayerRecallBuffUtil"
        , spTips = QResPath("activity_playerReturn_zi")[4], titleTable = {
        {oType = "font", content = "魂师大人，您获得了",size = 20, color = COLORS.j},
        {oType = "font", content = "回归特权", size = 20,color = COLORS.M},
        {oType = "font", content = "，可以在下列玩法中获得",size = 20, color = COLORS.j},
        {oType = "font", content = "特殊的加成或奖励", size = 20,color = COLORS.M},
        {oType = "font", content = "，活动结束后，buff消失~",size = 20, color = COLORS.j},
    }})
    table.insert(self._btnData, {type = remote.playerRecall.TYPE_TASK, title = "回归任务", className = "QPlayerRecallTaskUtil"
        , spTips = QResPath("activity_playerReturn_zi")[5], titleTable = {
        {oType = "font", content = "完成回归任务可以获得大量的奖励哦~",size = 20, color = COLORS.j},
    }})
end

function QUIDialogActivityPlayerRecall:viewDidAppear()
	QUIDialogActivityPlayerRecall.super.viewDidAppear(self)

    remote.playerRecall:playerComeBackGetInfoRequest()
    
    self:initBtnListView()

	self:_init()

    self:_updateTime()

    self:refreshContent()

	self:addBackEvent(false)

    self._playerRecallProxy = cc.EventProxy.new(remote.playerRecall)
    self._playerRecallProxy:addEventListener(remote.playerRecall.EVENT_UPDATE, handler(self, self._eventHandler))
end

function QUIDialogActivityPlayerRecall:viewWillDisappear()
  	QUIDialogActivityPlayerRecall.super.viewWillDisappear(self)

	self:removeBackEvent()

    self._playerRecallProxy:removeAllEventListeners()

    if self._schedulerCountDown then
        scheduler.unscheduleGlobal(self._schedulerCountDown)
        self._schedulerCountDown = nil
    end
end

function QUIDialogActivityPlayerRecall:_eventHandler(event)
    print("QUIDialogActivityPlayerRecall:_eventHandler() ", event.name)
    if event.name == remote.playerRecall.EVENT_UPDATE then
        if self._contentUtil and self._contentUtil.update then
            self._contentUtil:update()
        end
        self:initBtnListView()
    end
end

function QUIDialogActivityPlayerRecall:_init()
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


function QUIDialogActivityPlayerRecall:refreshContent()
    self:setTitleStr()
    self:setContentInfo()
end

function QUIDialogActivityPlayerRecall:initBtnListView()
    if not self._btnListView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local item = list:getItemFromCache()
                local data = self._btnData[index]
                if not item then
                    item = QUIWidgetPlayerRecallButton.new()
                    isCacheNode = false 
                end
                item:setInfo(data)
                info.item = item
                info.size = item:getContentSize()

                list:registerBtnHandler(index,"btn_click", handler(self, self._onClickBtnItem))
                
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
            -- topShadow = self._ccbOwner.buttonTopShadow,
            -- bottomShadow = self._ccbOwner.buttonBottomShadow ,
            ignoreCanDrag = true,
            totalNumber = #self._btnData,
        }  
        self._btnListView = QListView.new(self._ccbOwner.node_menu_list_view, cfg)
    else
        self._btnListView:reload({totalNumber = #self._btnData})
    end
end

function QUIDialogActivityPlayerRecall:_onClickBtnItem( x, y, touchNode, listView )
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

function QUIDialogActivityPlayerRecall:setTitleStr()
    -- if self._titleText ~= nil then
    --     self._titleText:removeFromParent()
    --     self._titleText = nil
    -- end

    -- self._titleText = QRichText.new(nil, 360)
    -- self._titleText:setAnchorPoint(ccp(0, 0.5))
    -- self._ccbOwner.node_desc:addChild(self._titleText)
    -- if self._btnData[self._curSelectBtnIndex] then
    --     local strs = clone(self._btnData[self._curSelectBtnIndex].titleTable)
    --     self._titleText:setString(strs)
    -- end

    QSetDisplayFrameByPath(self._ccbOwner.sp_desc_tips, self._btnData[self._curSelectBtnIndex].spTips)

end

function QUIDialogActivityPlayerRecall:_updateTime()
    if self._schedulerCountDown then
        scheduler.unscheduleGlobal(self._schedulerCountDown)
        self._schedulerCountDown = nil
    end

    local endTime = remote.playerRecall:getInfo().end_at/1000
    local timeSchedulerFunc
    timeSchedulerFunc = function()
        local currentTime = q.serverTime()
        local lastTime = endTime - currentTime

        if lastTime > 0 then
            local timeStr = q.timeToHourMinuteSecond(lastTime%DAY)
            self._ccbOwner.tf_countdown:setString(timeStr)
            local day = math.floor(lastTime/DAY)
            self._ccbOwner.tf_day:setString(day)
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

    self._schedulerCountDown = scheduler.scheduleGlobal(timeSchedulerFunc, 1)
    timeSchedulerFunc()
end

function QUIDialogActivityPlayerRecall:setContentInfo()
    if self._contentUtil then
        if self._contentUtil.removeListView then
            self._contentUtil:removeListView()
        end
        self._ccbOwner.client_sheet_layout:removeAllChildren()
        self._contentUtil = nil
    end

	if self._btnData[self._curSelectBtnIndex] then
        local cls = self._btnData[self._curSelectBtnIndex].className
        local class = import(app.packageRoot .. ".utils."..cls)
        self._contentUtil = class.new()
        if self._contentUtil.setView then
            self._contentUtil:setView(self._ccbOwner.client_sheet_layout)
        end
        self._ccbOwner.node_special:setVisible(self._btnData[self._curSelectBtnIndex].title == "回归加成" )
    end



end

return QUIDialogActivityPlayerRecall
