--
-- Author: Your Name
-- Date: 2015-03-18 17:10:57
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityPanel = class("QUIDialogActivityPanel", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QScrollContain = import("..QScrollContain")
local QActivity = import("...utils.QActivity")
local QColorLabel = import("...utils.QColorLabel")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")
local QUIWidgetActivityButton = import("..widgets.QUIWidgetActivityButton")
local QUIWidgetActivityItem = import("..widgets.QUIWidgetActivityItem")
local QUIWidgetActivityTiger = import("..widgets.QUIWidgetActivityTiger")
local QUIWidgetActivityFund = import("..widgets.QUIWidgetActivityFund")
local QUIWidgetActivityForce = import("..widgets.QUIWidgetActivityForce")
local QUIWidgetActivityExchange = import("..widgets.QUIWidgetActivityExchange")
local QUIWidgetActivityPrepay = import("..widgets.QUIWidgetActivityPrepay")
local QUIWidgetActivityPreFeedback = import("..widgets.QUIWidgetActivityPreFeedback")
local QUIWidgetActivityRate = import("..widgets.QUIWidgetActivityRate")
local QUIWidgetActivityCard = import("..widgets.QUIWidgetActivityCard")
local QUIWidgetActivityWeekCard = import("..widgets.QUIWidgetActivityWeekCard")
local QUIWidgetActivityRepeatPay = import("..widgets.QUIWidgetActivityRepeatPay")
local QUIWidgetActivityMonthFund = import("..widgets.QUIWidgetActivityMonthFund")
local QUIWidgetActivityWeekFund = import("..widgets.QUIWidgetActivityWeekFund")
local QUIWidgetActivityFundAward = import("..widgets.QUIWidgetActivityFundAward")
local QUIWidgetActivityFCFL = import("..widgets.QUIWidgetActivityFCFL")
local QUIWidgetActivitySuperMonday = import("..widgets.QUIWidgetActivitySuperMonday")
local QUIWidgetActivityForge = import("..widgets.QUIWidgetActivityForge")
local QUIWidgetActivityVipDailyGift = import("..widgets.QUIWidgetActivityVipDailyGift")
local QUIWidgetActivityMzlb = import("..widgets.QUIWidgetActivityMzlb")
local QUIWidgetActivityVipInherit = import("..widgets.QUIWidgetActivityVipInherit")
local QUIWidgetActivityLevelGift = import("..widgets.QUIWidgetActivityLevelGift")
local QUIWidgetActivityLevelRace = import("..widgets.QUIWidgetActivityLevelRace")
local QUIWidgetActivityCrystalShop = import("..widgets.QUIWidgetActivityCrystalShop")
local QUIWidgetActivityVerChangeLogin = import("..widgets.QUIWidgetActivityVerChangeLogin")

function QUIDialogActivityPanel:ctor(options)
    local ccbFile = "ccb/Dialog_Activity.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogActivityPanel._onTriggerClose)},
        -- {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogActivityPanel._onTriggerConfirm)},
    }
    QUIDialogActivityPanel.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(false)
    page.topBar:showWithMainPage() 

    if not options then
        options = {}
    end
    --当前活动界面显示 1表示精彩活动 2表示限时活动 3~表示节假日活动
    self._themeId = options.themeId or 1
    if self._themeId == 1 then
        remote.activityVipGift:loadActivity()
    end
    self:reloadActivity()
    self._curSelectBtnIndex = 1 
    if options.curActivityID then
        for k, v in pairs(self._data) do
            if v.activityId == options.curActivityID then
                self._curSelectBtnIndex = k
                break
            end
        end
    end

    local btnWidth = self._ccbOwner.node_btn_size:getContentSize().width
    self._ccbOwner.node_client:setPositionX(btnWidth/2)

    local themeInfo = db:getActivityThemeInfoById(self._themeId) or {}
    self._ccbOwner.title_name:setString(themeInfo.title or "精彩活动")

    self:initBtnListView() 
    self._root:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, QUIDialogActivityPanel.onFrame))
    self._root:scheduleUpdate()
end

function QUIDialogActivityPanel:jumpTo(activityId)
    local touchIndex
    for k, v in pairs(self._data) do
        if v.activityId == "a_yueka" or v.activityId == activityId then
            touchIndex = k
            break
        end
    end

    if touchIndex and self._btnListView then
        if self._curSelectBtnIndex and self._curSelectBtnIndex ~= touchIndex then
            local oldItem = self._btnListView:getItemByIndex(self._curSelectBtnIndex)
            if oldItem then
                oldItem:setSelect(false)
            end
        end
        local item = self._btnListView:getItemByIndex(touchIndex)
        if item then
            item:setSelect(true)
        end
        if self._curSelectBtnIndex ~= touchIndex then
            self._curSelectBtnIndex = touchIndex
            self._btnListView:reload({totalNumber = #self._data,headIndex = self._curSelectBtnIndex})
            self:refreshContent()
        end
    end
end

function QUIDialogActivityPanel:onClickBtnItem( x, y, touchNode, listView )
    app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.isUnlock and item:isUnlock() then
        local info = item:getInfo()
        local startTimeTbl = q.date("*t", (info.start_at or 0)/1000)
        app.tip:floatTip(string.format("%d月%d日开启", startTimeTbl.month, startTimeTbl.day))
        return
    end
    

    if self._curSelectBtnIndex and self._curSelectBtnIndex ~= touchIndex then
        local oldItem = listView:getItemByIndex(self._curSelectBtnIndex)
        if oldItem then
            oldItem:setSelect(false)
        end
    end

    if item then
        item:setSelect(true)
    end

    if self._curSelectBtnIndex ~= touchIndex then
        self._curSelectBtnIndex = touchIndex
        self:refreshContent()
    end
end


function QUIDialogActivityPanel:initBtnListView(  )
    -- body
    local clickBtnItemHandler = handler(self, self.onClickBtnItem)
    local cfg = {
        renderItemCallBack = function( list, index, info )
            -- body
            local isCacheNode = true
            local item = list:getItemFromCache()
            local data = self._data[index]
            if not item then
                item = QUIWidgetActivityButton.new()
                isCacheNode = false
            end
            item:setInfo(data)
            info.item = item
            info.size = item._ccbOwner.btn_click:getContentSize()

            list:registerBtnHandler(index, "btn_click", clickBtnItemHandler)
            
            if self._curSelectBtnIndex == index then
                item:setSelect(true)
            else
                item:setSelect(false)
            end
            return isCacheNode
        end,
        headIndex = self._curSelectBtnIndex,
        enableShadow = true,
        topShadow = self._ccbOwner.node_top_arrow,
        bottomShadow = self._ccbOwner.node_bottom_arrow,
        ignoreCanDrag = true,
        totalNumber = #self._data,
        curOffset = 20,
        curOriginOffset = 5,
    }  
    self._btnListView = QListView.new(self._ccbOwner.sheet_menu,cfg)
   
    if #self._data > 0 then
        self:refreshContent()
    end
end


function QUIDialogActivityPanel:getCurSelectBtnIndex(  )
    -- body
    return self._curSelectBtnIndex
end

function QUIDialogActivityPanel:initContentListView(activityTargetHeadIndex, headIndexPosOffset)
    -- bod
    if type(self._selectInfo) ~= "table" then
        self._selectInfo = {}
        self._selectTargets = {}
    end
    if type(self._selectTargets) ~= "table" then
        self._selectTargets = {}
    end


    local activityTargetHeadIndex = activityTargetHeadIndex or 1
    local headIndexPosOffset = headIndexPosOffset or 0
    local cfg = {
        renderItemCallBack = function( list, index, info )
            -- body
            local isCacheNode = true
            local data = self._selectTargets[index]
            local  tag
            if remote.activity:isExchangeActivity(data.type) then
                tag = "exchange"
            end
            local item = list:getItemFromCache(tag)

            if not item then
                if tag then
                    if tag == "exchange" then
                        item = QUIWidgetActivityExchange.new()
                    end
                else
                    item = QUIWidgetActivityItem.new()
                end
                isCacheNode = false
            end

            local isPreviewActivity = false
            if self._selectInfo.subject and self._selectInfo.subject == remote.activity.THEME_ACTIVITY_RAT_FESTIVAL_1 then
                isPreviewActivity = true
            end
            item:setInfo(self._selectInfo.activityId, data, self, isPreviewActivity, self._selectInfo.start_at)
            info.item = item
            info.tag = tag
            info.size = item:getContentSize()

            if tag then
                if tag == "exchange" then
                    item:registerItemBoxPrompt(index, list)
                    list:registerTouchHandler(index,"onTouchListView")
                    list:registerBtnHandler(index, "btnExchange", "onTriggerExchange", nil, true)
                end
            else
                list:registerTouchHandler(index,"onTouchListView")
                if data.completeNum == 1 and remote.activity:isRechargeActivity(data.type) then
                    list:registerBtnHandler(index,"btn_ok2", "gotoRecharge", nil, true)
                else
                    list:registerBtnHandler(index,"btn_ok", "_onTriggerConfirm", nil, true)
                    list:registerBtnHandler(index,"btn_go", "_onTriggerGo", nil, true)
                end
                -- item:registerItemBoxPrompt(index,list)
            end
            return isCacheNode
        end,
        spaceY = 2,
        curOriginOffset = 5,
        headIndex = activityTargetHeadIndex,
        headIndexPosOffset = headIndexPosOffset,
        enableShadow = false,
        ignoreCanDrag = true,
        totalNumber = #self._selectTargets,
    }  
    self._contentListView = QListView.new(self._ccbOwner.sheet_content, cfg)
end

function QUIDialogActivityPanel:getContentListView(  )
    -- body
    return self._contentListView
end

function QUIDialogActivityPanel:refreshContent(  )
    self._oldSelectInfo = self._selectInfo

    local info = self._data[self._curSelectBtnIndex]
    remote.activity:setActivityTipEveryDay(info)

    local needUpdate = false
    if self._selectInfo ~= info then
        needUpdate = true
    end
    self._selectInfo = info
    self._curSelectActivityID = self._selectInfo.activityId
    self:getOptions().curActivityID = self._curSelectActivityID
    self._selectTargets = {}
    self._ccbOwner.node_normal:setVisible(false)

    print("-----self._selectInfo.type----", self._selectInfo.type)
    -- 封测返利
    if self._selectInfo.type == remote.activity.TYPE_FENG_CE_FAN_LI then
        if self._contentListView then
            self._contentListView:clear(true)
            self._contentListView = nil
        end
        self:onOtherContent()
        return
    end
    
    for _,target in ipairs(self._selectInfo.targets or {}) do
        if target.showStatus == nil or target.showStatus == 1 then
            table.insert(self._selectTargets, target)
        end
    end
    local timeStr = ""
    if self._selectInfo.permanent == true then
        timeStr = "永久有效"
    else
        local startTimeTbl = q.date("*t", (info.start_at or 0)/1000)

        if info.subject ~= remote.activity.THEME_ACTIVITY_RAT_FESTIVAL_1 and info.show_at then
            startTimeTbl = q.date("*t", (info.show_at or 0)/1000)
        end

        local endTimeTbl = q.date("*t", (info.end_at or 0)/1000)
        timeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", 
            startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, 
            endTimeTbl.month, endTimeTbl.day, endTimeTbl.hour, endTimeTbl.min)
    end
    self._ccbOwner.tf_time1:setString(timeStr)

    -- 横幅背景
    self._ccbOwner.sp_title_bg:setVisible(false)
    if self._selectInfo.title_icon and not isChineseStr(self._selectInfo.title_icon)  then
        local bgPath = "ui/Activity_game/"..self._selectInfo.title_icon
        QSetDisplayFrameByPath(self._ccbOwner.sp_title_bg, bgPath)
        self._ccbOwner.sp_title_bg:setVisible(true)
    end

    -- 横幅文字
    self._ccbOwner.sp_banner:setVisible(false)
    if self._selectInfo.banner and self._selectInfo.banner ~= ""  then
        local namePath = ""
        if string.find(self._selectInfo.banner, "ui/") then
            namePath = self._selectInfo.banner
        else
            namePath = "ui/Activity_game/"..self._selectInfo.banner
        end

        QSetDisplayFrameByPath(self._ccbOwner.sp_banner, namePath)
        self._ccbOwner.sp_banner:setVisible(true)
    end 
    -- 横幅大背景
    if self._selectInfo.background and self._selectInfo.background ~= ""  then
        local bgPath = ""
        if string.find(self._selectInfo.background, "ui/") then
            bgPath = self._selectInfo.background
        else
            bgPath = "ui/updata_activity/activity_bigbackground/"..self._selectInfo.background
        end
        QSetDisplayFrameByPath(self._ccbOwner.sp_activity_bg, bgPath)
    end 

    -- 替换列表背景
    local sp_list_bg
    if self._selectInfo.subject == remote.activity.THEME_ACTIVITY_ZHANGBICHEN_FORMAL then
        sp_list_bg = CCScale9Sprite:create(QResPath("activity_list_bg_zise"))
    else
        -- sp_list_bg = CCScale9Sprite:create(QResPath("activity_list_bg_chengse"))
    end
    if sp_list_bg then
        sp_list_bg:setContentSize(self._ccbOwner.sp_list_bg:getContentSize())
        sp_list_bg:setPosition(self._ccbOwner.sp_list_bg:getPosition())
        sp_list_bg:setAnchorPoint(self._ccbOwner.sp_list_bg:getAnchorPoint())
        self._ccbOwner.sp_list_bg:setVisible(false)
        self._ccbOwner.node_list_bg:removeAllChildren()
        self._ccbOwner.node_list_bg:addChild(sp_list_bg)
    else
        self._ccbOwner.sp_list_bg:setVisible(true)
        self._ccbOwner.node_list_bg:removeAllChildren()
    end

    -- 版更登录，数据虽是normal但按other处理
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY then
        if not q.isEmpty(self._selectInfo.targets) then
            local target = self._selectInfo.targets[1]
            if target.type == QActivity.TYPE_VERSION_CHANGE_LOGIN then
                self._selectInfo.isVerChangeLogin = true
            end
        end
    end

    if (self._selectInfo.type == remote.activity.TYPE_ACTIVITY or 
        self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_DESC or
        self._selectInfo.type == remote.activity.TYPE_CELEBRITY_HALL_RANK or
        self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_HOLIDAY ) and 
        (self._selectInfo.targets and #self._selectInfo.targets ~= 0) and not self._selectInfo.isVerChangeLogin then
        if needUpdate then
            if self._contentListView then
                self._contentListView:clear(true)
                self._contentListView = nil
            end
        end

        self._ccbOwner.node_normal:setVisible(true)
        self:onNormalActivity()
    else
        if self._contentListView then
            self._contentListView:clear(true)
            self._contentListView = nil
        end
        self._ccbOwner.node_normal:setVisible(false)
        self:onOtherContent()
    end
    self:updateTextOutLine()

end


function QUIDialogActivityPanel:updateTextOutLine()


    if self._selectInfo.background == "sspbsx_small_bg.jpg" 
        or self._selectInfo.background == "zhongqiu_small_bg.jpg" 
        or self._selectInfo.background == "ssphg_di.jpg" 
        then
        local outlineColor = ccc3(53, 64, 92)
        self._ccbOwner.tf_time1:setOutlineColor(outlineColor)
        self._ccbOwner.tf_time1:enableOutline()
        self._ccbOwner.tf_desc1:setOutlineColor(outlineColor)
        self._ccbOwner.tf_desc1:enableOutline()
        self._ccbOwner.tf_time_title:setOutlineColor(outlineColor)
        self._ccbOwner.tf_time_title:enableOutline()
        self._ccbOwner.tf_desc_title:setOutlineColor(outlineColor)
        self._ccbOwner.tf_desc_title:enableOutline()        
    else
        self._ccbOwner.tf_time1:disableOutline() 
        self._ccbOwner.tf_desc1:disableOutline() 
        self._ccbOwner.tf_desc_title:disableOutline() 
        self._ccbOwner.tf_time_title:disableOutline() 
    end

end


function QUIDialogActivityPanel:viewDidAppear()
    QUIDialogActivityPanel.super.viewDidAppear(self)
    self._activityProxy = cc.EventProxy.new(remote.activity)
    self._activityProxy:addEventListener(QActivity.EVENT_UPDATE, handler(self, self.onEvent))
    self._activityProxy:addEventListener(QActivity.EVENT_CHANGE, handler(self, self.onEvent))
    self._activityProxy:addEventListener(QActivity.EVENT_COMPLETE_UPDATE, handler(self, self.onEvent))

    self._activityRoundsProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsProxy:addEventListener(remote.activityRounds.WEEKFUND_UPDATE, handler(self, self.onEvent))
    self._activityRoundsProxy:addEventListener(remote.activityRounds.NEW_SERVICE_FUND_UPDATE, handler(self, self.onEvent))
    self._activityRoundsProxy:addEventListener(remote.activityRounds.FORGE_UPDATE, handler(self, self.onEvent))

    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
    self:addBackEvent(false)

    -- self:showList()
end

function QUIDialogActivityPanel:viewWillDisappear()
    QUIDialogActivityPanel.super.viewWillDisappear(self)
    self._activityProxy:removeAllEventListeners()
    self._activityRoundsProxy:removeAllEventListeners()
    self.prompt:removeItemEventListener()
    self:removeBackEvent()
    remote.activity:dispatchEvent({name = QActivity.EVENT_CHANGE})
end

--生成子内容
function QUIDialogActivityPanel:onNormalActivity()
    self._ccbOwner.node_time:setVisible(true)
    self._ccbOwner.node_right:setVisible(false)
    self._ccbOwner.node_other:setVisible(false)
    self._ccbOwner.tf_desc1:setString(self._selectInfo.description or "")

    local curActivityTargetId = self:getOptions().curActivityTargetId
    local activityTargetHeadIndex = 1
    local headIndexPosOffset = 0
    if curActivityTargetId then
        for k, v in pairs(self._selectTargets) do
            if v.activityTargetId == curActivityTargetId and v.completeNum and v.completeNum ~= 3 then
                activityTargetHeadIndex = k    
                headIndexPosOffset = self:getOptions().curActivityTargetOffset or 0
                break
            end
        end
    end

    if not self._contentListView then
        self:initContentListView(activityTargetHeadIndex, headIndexPosOffset)
    else
        self._contentListView:refreshData()
    end
end

function QUIDialogActivityPanel:onOtherContent()
    self._ccbOwner.node_time:setVisible(false)
    self._ccbOwner.node_right:setVisible(true)
    self._ccbOwner.node_other:setVisible(true)
    if self._oldSelectInfo ~= nil and self._oldSelectInfo.type == self._selectInfo.type and self._otherWidget ~= nil then
        if self._selectInfo.type == remote.activity.TYPE_ACTIVITY then
            if self._oldSelectInfo.targets and #self._oldSelectInfo.targets == 0 then
                self._otherWidget:setInfo(self._selectInfo)
                return
            end
        else
            if self._selectInfo.type ~= remote.activity.TYPE_MONTHFUND then
                self._otherWidget:setInfo(self._selectInfo)
                return
            end
        end
    end
    
    -- 用于全屏型活动
    self._ccbOwner.node_other:removeAllChildren()
    -- 用于半屏型活动
    self._ccbOwner.node_right:removeAllChildren()

    self._otherWidget = nil
    
    --炎龙宝藏
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_TIGER then
        self._otherWidget = QUIWidgetActivityTiger.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    --开服基金
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_FUND then
        self._otherWidget = QUIWidgetActivityFund.new()
        self._ccbOwner.node_right:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    --开服竞赛
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_FORCE then
        self._otherWidget = QUIWidgetActivityForce.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    --
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_PREPAY then
    self._otherWidget = QUIWidgetActivityPrepay.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_PREPAYGET then
        self._otherWidget = QUIWidgetActivityPreFeedback.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_RATE or 
        ((self._selectInfo.type == remote.activity.TYPE_ACTIVITY or 
        self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_DESC or 
        self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_HOLIDAY) and 
        (self._selectInfo.targets and #self._selectInfo.targets == 0)) then

        self._otherWidget = QUIWidgetActivityRate.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end

    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_CARD then
        self._otherWidget = QUIWidgetActivityCard.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
    end
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_WEEK then
        self._otherWidget = QUIWidgetActivityWeekCard.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    --豪华签到
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_REPEATPAY then
        self._otherWidget = QUIWidgetActivityRepeatPay.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_SUPER_MONDAY then
        self._otherWidget = QUIWidgetActivitySuperMonday.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_LEVEL_GIFT then
        self._otherWidget = QUIWidgetActivityLevelGift.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_LEVEL_RACE then
        self._otherWidget = QUIWidgetActivityLevelRace.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end

    -- 月基金
    if self._selectInfo.type == remote.activity.TYPE_MONTHFUND then
        if remote.activityMonthFund:isMonthFundOpen(self._selectInfo.activityId) then
            self._otherWidget = QUIWidgetActivityMonthFund.new({parent = self})
            self._ccbOwner.node_other:addChild(self._otherWidget)
        elseif remote.activityMonthFund:isFundAwardOpen(self._selectInfo.activityId) then
            local originDistance = self:getOptions().monthFundDistance
            self._otherWidget = QUIWidgetActivityFundAward.new({parent = self})
            self._ccbOwner.node_other:addChild(self._otherWidget)
        else
            self._otherWidget = QUIWidgetActivityMonthFund.new({parent = self})
            self._ccbOwner.node_other:addChild(self._otherWidget)
        end  
        self._otherWidget:setInfo(self._selectInfo)
    end

    --周基金
    if self._selectInfo.type == remote.activity.TYPE_WEEKFUND then
        self._otherWidget = QUIWidgetActivityWeekFund.new({parent = self, fundType = 1})
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end

    --封测返利
    if self._selectInfo.type == remote.activity.TYPE_FENG_CE_FAN_LI then
        self._otherWidget = QUIWidgetActivityFCFL.new()
        self._ccbOwner.node_right:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end

    --新服周基金
    if self._selectInfo.type == remote.activity.TYPE_NEW_SERVICE_FUND then
        self._otherWidget = QUIWidgetActivityWeekFund.new({parent = self, fundType = 2})
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end

    --新服周基金
    if self._selectInfo.type == remote.activity.TYPE_FORGE then
        self._otherWidget = QUIWidgetActivityForge.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    --每日vip福利
    if self._selectInfo.type == remote.activity.VIP_GIFT_DAILY then
        self._otherWidget = QUIWidgetActivityVipDailyGift.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    --每周礼包
    if self._selectInfo.type == remote.activity.VIP_GIFT_WEEK then
        self._otherWidget = QUIWidgetActivityMzlb.new()
        self._ccbOwner.node_right:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    --vip 继承
    if self._selectInfo.type == remote.activity.TYPE_VIP_INHERIT then
        self._otherWidget = QUIWidgetActivityVipInherit.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    -- 水晶商店每日礼包
    if self._selectInfo.type == remote.activity.TYPE_CRYSTAL_SHOP then
        self._otherWidget = QUIWidgetActivityCrystalShop.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end
    -- 版更登录
    if self._selectInfo.isVerChangeLogin then
        self._otherWidget = QUIWidgetActivityVerChangeLogin.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
    end

    --如果未匹配到
    if self._otherWidget == nil then
        local dataProxy = remote.activity:getDataProxyByActivityId(self._selectInfo.activityId)
        if dataProxy ~= nil and dataProxy.getWidget ~= nil then
           self._otherWidget = dataProxy:getWidget(self._selectInfo)
            self._ccbOwner.node_other:addChild(self._otherWidget)
            self._otherWidget:setInfo(self._selectInfo)
        end
    end
end

function QUIDialogActivityPanel:onFrame( )
    if self._dataDirty then
        if self._isForce then
            self:reloadActivity()
            if #self._data == 0 then
                app:alert({content = "魂师大人，所有活动都已结束，敬请期待新的一轮活动！", title = "系统提示", callback = function (state)
                    if state == ALERT_TYPE.CONFIRM then
                        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
                    end
                end},false,true)
                return
            end

            for k, v in pairs(self._data) do
                if v.activityId == self._curSelectActivityID then
                    self._curSelectBtnIndex = k
                    break
                end
            end
            if not self._curSelectBtnIndex or  self._curSelectBtnIndex > #self._data then
                self._curSelectBtnIndex = 1
            end
            self._btnListView:reload({totalNumber = #self._data,headIndex = self._curSelectBtnIndex})
            self:refreshContent()

            self._isForce = nil
        else
            print("----refreshData--")
            self._btnListView:refreshData()
            self:refreshContent()
        end
        self._dataDirty = nil
    end
end

function QUIDialogActivityPanel:onEvent(event)
    print("------onEvent------------",event.name)
    if event.name == QActivity.EVENT_UPDATE or event.name == QActivity.EVENT_CHANGE or QActivity.EVENT_COMPLETE_UPDATE or
        event.name == remote.activityRounds.WEEKFUND_UPDATE or event.name == remote.activityRounds.NEW_SERVICE_FUND_UPDATE then
        self._dataDirty = true
        if event.isForce then
            self._isForce = true
        end
    end
end

function QUIDialogActivityPanel:reloadActivity()
    self._data = remote.activity:getActivityByTheme(self._themeId)
end

function QUIDialogActivityPanel:onTriggerBackHandler(tag)
    self:_onTriggerBack()
end

function QUIDialogActivityPanel:onTriggerHomeHandler(tag)
    self:_onTriggerHome()
end

-- 对话框退出
function QUIDialogActivityPanel:_onTriggerBack(tag, menuItem)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogActivityPanel:_onTriggerHome(tag, menuItem)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogActivityPanel