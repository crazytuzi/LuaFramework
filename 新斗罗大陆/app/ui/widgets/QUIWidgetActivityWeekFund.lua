-- 
-- zxs
-- 周基金
-- 
local QUIWidget = import(".QUIWidget")
local QUIWidgetActivityWeekFund = class("QUIWidgetActivityWeekFund", QUIWidget)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView") 
local QUIViewController = import("...ui.QUIViewController")
local QRichText = import("...utils.QRichText")
local QUIWidgetActivityWeekFundDot = import("..widgets.QUIWidgetActivityWeekFundDot")
local QUIWidgetActivityWeekFundClient = import("..widgets.QUIWidgetActivityWeekFundClient")
local QUIWidgetActivityWeekFundNewClient = import("..widgets.QUIWidgetActivityWeekFundNewClient")
local QUIWidgetImageNum = import("..widgets.QUIWidgetImageNum")

function QUIWidgetActivityWeekFund:ctor(options)
    local ccbFile = "ccb/Widget_zhoujijin.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
        {ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)}, 
        {ccbCallbackName = "onTriggerClickLeft", callback = handler(self, self._onTriggerClickLeft)},
        {ccbCallbackName = "onTriggerClickRight", callback = handler(self, self._onTriggerClickRight)},
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetActivityWeekFund.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self.parent = options.parent
    self._fundType = options.fundType
    self._dots = {}
    self._selectIndex = 1
    self._activityType = 1   --只有新服基金用，周基金不用

    if self._fundType == 1 then
        self._weekFund = remote.activityRounds:getWeekFund()
        self._buyEndAt = self._weekFund:getBuyEndAt()
    elseif self._fundType == 2 then
        self._weekFund = remote.activityRounds:getNewServiceFund()
        self._activityType = self._weekFund.luckyDrawId
        self._buyDayNum = self._weekFund:getActiveDayNum()
    end
end

function QUIWidgetActivityWeekFund:onEnter()
    self._activityRoundsProxy = cc.EventProxy.new(remote.activityRounds)
    if self._fundType == 1 then
        self._activityRoundsProxy:addEventListener(remote.activityRounds.WEEKFUND_UPDATE, handler(self, self._updateInfo))
        if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.WEEK_FUND) then
            app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.WEEK_FUND)
        end
    elseif self._fundType == 2 then
        self._activityRoundsProxy:addEventListener(remote.activityRounds.NEW_SERVICE_FUND_UPDATE, handler(self, self._updateInfo))
        if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.NEW_SERVICE_FUND) then
            app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.NEW_SERVICE_FUND)
        end
    end
end

function QUIWidgetActivityWeekFund:onExit()
    if self._timeScheduler ~= nil then 
        scheduler.unscheduleGlobal(self._timeScheduler)
        self._timeScheduler = nil
    end
    self._activityRoundsProxy:removeAllEventListeners()
    self._activityRoundsProxy = nil
end

function QUIWidgetActivityWeekFund:_updateInfo()
    if self._weekFund:getActivityActiveState() then
        self._selectIndex = 1
        self:setInfo()
    end
end
function QUIWidgetActivityWeekFund:getMoneyString(money)
    if tonumber(money) == 98 then
        return "98元或168元,268元,418元,648元"
    elseif tonumber(money) == 418 then
        return "418元或648元"
    else
        return tostring(money).."元"
    end
end

function QUIWidgetActivityWeekFund:setInfo()
    self:resetAll()
    
    self._info = self._weekFund:getWeekFundInfo() or {}
    self._userInfo = self._weekFund:getUserWeekFundInfo() or {}
    self._activeDay = self._weekFund:getActivityDay() or 1
    self._achieveDay = self._weekFund:getActivityAchieveDay() or 1

    local fontSize = 20
    local color1 = ccc3(99, 9, 0)
    local color2 = ccc3(195, 26, 0)
    if self._richText == nil then
        local moneyStr = self:getMoneyString(self._info.money or 418)
        local strTable = {
                {oType = "font", content = "活动期间，", size = fontSize, color = color1},
                {oType = "font", content = "双月卡激活", size = fontSize, color = color2},
                {oType = "font", content = "状态下，单笔充值", size = fontSize, color = color1},
                {oType = "font", content = moneyStr, size = fontSize, color = color2},
                {oType = "font", content = "，即可激活周基金（激活后即可领取当前天数及之前天数奖励，累计可领取", size = fontSize, color = color1},
                {oType = "font", content = tostring(self._info.rebate or 30), size = fontSize, color = color2},
                {oType = "font", content = "倍资源返利!）", size = fontSize, color = color1},
            }
        if self._fundType == 2 then
                -- strTable = {
                --     {oType = "font", content = "单笔充值", size = fontSize, color = color1},
                --     {oType = "font", content = moneyStr, size = fontSize, color = color2},
                --     {oType = "font", content = "，即可激活（激活立即可领取当天及之前的奖励）。每日可领取", size = fontSize, color = color1},
                --     {oType = "font", content = "魂殿教皇令*10", size = fontSize, color = color2},
                --     {oType = "font", content = "和", size = fontSize, color = color1},
                --     {oType = "font", content = "SS戴沐白碎片*10", size = fontSize, color = color2},
                -- }
            if self._activityType == self._weekFund.NEW_SERVICE_FUND_7  then
                strTable = {
                    {oType = "font", content = "单笔充值", size = fontSize, color = color1},
                    {oType = "font", content = moneyStr, size = fontSize, color = color2},
                    {oType = "font", content = "，即可激活（激活立即可领取当天及之前的奖励）。每日可领取", size = fontSize, color = color1},
                    {oType = "font", content = "魂殿教皇令*10", size = fontSize, color = color2},
                    {oType = "font", content = "和", size = fontSize, color = color1},
                    {oType = "font", content = "SS戴沐白碎片*10", size = fontSize, color = color2},
                }
                -- table.insert(strTable, {oType = "font", content = "钻石招募令!）", size = fontSize, color = color1})
            elseif self._activityType == self._weekFund.NEW_SERVICE_FUND_14 or self._activityType == self._weekFund.MAX_NEW_SERVICE_FUND_14 then
               strTable = {
                    {oType = "font", content = "活动期间，单笔充值", size = fontSize, color = color1},
                    {oType = "font", content = moneyStr, size = fontSize, color = color2},
                    {oType = "font", content = "，即可激活魂师基金（激活即可领取当前天数及之前天数的奖励，累计可领取", size = fontSize, color = color1},
                    {oType = "font", content = tostring(self._info.rebate or 6), size = fontSize, color = color2},
                    {oType = "font", content = "倍资源返利）", size = fontSize, color = color1},
                }
                -- table.insert(strTable, {oType = "font", content = "倍资源返利!）", size = fontSize, color = color1})
            end
        end
        self._richText = QRichText.new(strTable, 450)
        self._richText:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.tf_desc:addChild(self._richText)

        if self._rebateNum == nil then
            self._rebateNum = QUIWidgetImageNum.new()
            self._ccbOwner.node_rebate:addChild(self._rebateNum)
        end
        self._rebateNum:setString(self._info.rebate or "30")
    end

    if self._userInfo.status == false then
        if self._fundType == 1 then
            if self._buyEndAt and q.serverTime() > self._buyEndAt then
                self._ccbOwner.node_finish:setVisible(true)
            elseif self._fundType == 1 and not remote.activity:checkMonthCardActive() then
                self._ccbOwner.node_go_active:setVisible(true)
            else
                self._ccbOwner.node_buy:setVisible(true)
            end
        elseif self._fundType == 2 then
            if self._activeDay > self._buyDayNum then
                self._ccbOwner.node_finish:setVisible(true)
            elseif self._fundType == 1 and not remote.activity:checkMonthCardActive() then
                self._ccbOwner.node_go_active:setVisible(true)
            else
                self._ccbOwner.node_buy:setVisible(true)
            end
        end
    else
        self._ccbOwner.node_ok:setVisible(true)
    end

    self:setDayDots()

    -- set awards info
    local reciviedAwards = self._weekFund:getActivityReceivedAwards()
    local awards = self._info.weekFundAwardInfo or {}
    self._data = {}
    local isUpdate = false
    local doneNum = 0
    for i = 1, #awards do
        local isDone = reciviedAwards[i]
        local isReady = false
        if self._userInfo.status and not isDone and i <= self._achieveDay then
            isReady = true
            if isUpdate == false then
                self._selectIndex = i
                isUpdate = true
            end
        end
        if isDone then
            doneNum = doneNum + 1
        end
        table.insert(self._data, {info = awards[i], isDone = isDone, isReady = isReady})
    end
    if doneNum > 0 and isUpdate == false then
        self._selectIndex = doneNum
    end

    self:initListView()
    self:selectDot(self._selectIndex)
    self:setTimeCountdown()
end

function QUIWidgetActivityWeekFund:initListView()
    if not self._listView then
        local isNewServer = false
        local sheet_layout = self._ccbOwner.sheet_layout
        if self._fundType == 2 and self._activityType == self._weekFund.NEW_SERVICE_FUND_7 then
            -- 武魂基金
            isNewServer = true
            sheet_layout = self._ccbOwner.sheet_new_layout
        end

        local cfg = {
            renderItemCallBack = function( list, index, info )
                    -- body
                    local isCacheNode = true
                    local itemData = self._data[index]
                    local item = list:getItemFromCache()
                    if not item then
                        if isNewServer then
                            item = QUIWidgetActivityWeekFundNewClient.new()
                            item:addEventListener(QUIWidgetActivityWeekFundNewClient.EVENT_CLICK, handler(self, self._clickAwardBox))
                        else
                            item = QUIWidgetActivityWeekFundClient.new()
                            item:addEventListener(QUIWidgetActivityWeekFundClient.EVENT_CLICK, handler(self, self._clickAwardBox))
                        end
                        isCacheNode = false
                    end

                    item:setInfo(itemData, index)
                    info.item = item
                    info.size = item:getContentSize()

                    if itemData.isReady then
                        list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
                    else
                        item:registerItemBoxPrompt(index, list)
                    end

                    return isCacheNode
                end,
            curOriginOffset = 0,
            isVertical = false,
            spaceY = 10,
            enableShadow = false,
            ignoreCanDrag = true,
            headIndex = self._selectIndex,
            totalNumber = #self._data,
        }
        
        self._listView = QListView.new(sheet_layout, cfg)
        if isNewServer then
            self._listView:setCanNotTouchMove(true)
        end
    else
        self._listView:reload({totalNumber = #self._data, headIndex = self._selectIndex})
    end
end

function QUIWidgetActivityWeekFund:setDayDots()
    local activeDay = self._achieveDay
    if self._userInfo.status == false then
        activeDay = 0
    end

    for i = 1, 7 do
        if self._dots[i] == nil then 
            self._dots[i] = QUIWidgetActivityWeekFundDot.new()
            self._ccbOwner["node_day_"..i]:addChild(self._dots[i])
            self._dots[i]:addEventListener(QUIWidgetActivityWeekFundDot.EVENT_CLICK, handler(self, self._clickDot))
        end

        self._dots[i]:setDotIndex(i)
        self._dots[i]:setIsReady(i <= activeDay)
    end
end

function QUIWidgetActivityWeekFund:resetAll()
    self._ccbOwner.node_buy:setVisible(false)
    self._ccbOwner.node_go_active:setVisible(false)
    self._ccbOwner.node_ok:setVisible(false)
    self._ccbOwner.node_finish:setVisible(false)
    self._ccbOwner.sp_weekFund_bg_1:setVisible(self._fundType == 1)
    self._ccbOwner.sp_weekFund_bg_2:setVisible(self._fundType == 2)
    self._ccbOwner.node_weekFund_1:setVisible(false)
    self._ccbOwner.node_weekFund_2:setVisible(false)
    self._ccbOwner.node_title_1_1:setVisible(false)
    self._ccbOwner.node_title_1_2:setVisible(false)
    if self._fundType == 1 then
        self._ccbOwner.node_weekFund_1:setVisible(true)
        self._ccbOwner.node_title_1_1:setVisible(true)
    elseif self._fundType == 2 then
        if self._activityType == self._weekFund.NEW_SERVICE_FUND_7 then
            self._ccbOwner.node_weekFund_2:setVisible(true)
        elseif self._activityType == self._weekFund.NEW_SERVICE_FUND_14 then
            self._ccbOwner.node_weekFund_1:setVisible(true)
            self._ccbOwner.node_title_1_2:setVisible(true)
            QSetDisplayFrameByPath(self._ccbOwner.sp_new_title_2, "ui/updata_activity/zi_sjihungu.png")              
            QSetDisplayFrameByPath(self._ccbOwner.sp_award_title_1, QResPath("new_service_14_title"))
        elseif self._activityType == self._weekFund.MAX_NEW_SERVICE_FUND_14 then
            self._ccbOwner.node_weekFund_1:setVisible(true)
            self._ccbOwner.node_title_1_2:setVisible(true)
            QSetDisplaySpriteByPath(self._ccbOwner.sp_new_title_2,"ui/updata_activity/zi_hunshijijin.png")
            QSetDisplayFrameByPath(self._ccbOwner.sp_award_title_1, QResPath("new_service_14_title"))            
        end
    end

    self._ccbOwner.tf_time_title:setString("活动已结束")
    self._ccbOwner.tf_left_time:setString("")
end

function QUIWidgetActivityWeekFund:setTimeCountdown()
    if self._timeScheduler ~= nil then 
        scheduler.unscheduleGlobal(self._timeScheduler)
        self._timeScheduler = nil
    end

    local endAt = 0
    local str = ""
    if self._userInfo.status == false then
        str = "购买剩余时间："
        
        if self._fundType == 1 then
            endAt = self._buyEndAt
        elseif self._fundType == 2 then
            endAt = (self._weekFund.startAt or 0) + DAY * self._buyDayNum 
        end
    else
        str = "活动剩余时间："
        endAt = self._weekFund.endAt or 0
    end

    -- 购买时间已过
    local nowTime = q.serverTime()
    if nowTime > endAt then
        self:resetAll()
        self._weekFund:handleOffLine()
        self._ccbOwner.node_finish:setVisible(true)
        return
    end

    self._ccbOwner.tf_time_title:setString(str)
    local timeCount = endAt - nowTime
    local day = math.floor(timeCount/DAY)
    timeCount = timeCount%DAY
    local str = q.timeToHourMinuteSecond(timeCount)
    if day > 0 then
        str = day.."天 "..str
    end
    self._ccbOwner.tf_left_time:setString(str)

    self._timeScheduler = scheduler.scheduleGlobal(function()
            self:setTimeCountdown()
        end, 1)
end

function QUIWidgetActivityWeekFund:selectDot(index)
    for i = 1, 7 do
        self._dots[i]:setIsSelect(false)
    end
    self._dots[index]:setIsSelect(true)
    self._selectIndex = index

    self._ccbOwner.node_left:setVisible(not (self._selectIndex == 1))
    self._ccbOwner.node_right:setVisible(not (self._selectIndex == #self._data))

    if self._fundType == 2 and self._activityType == self._weekFund.NEW_SERVICE_FUND_7 then
        self._listView:startScrollToIndex(self._selectIndex, false, 40)
    else
        self._listView:startScrollToIndex(self._selectIndex, false, 40)
    end
end

function QUIWidgetActivityWeekFund:_clickDot(event)
    if event.index == nil then return end

    self:selectDot(event.index)
end

function QUIWidgetActivityWeekFund:_clickAwardBox(event)
    local info = event.info
    self._weekFund:requestWeekFundAward(info.awardIndex, function(data)
            if info.award then
                local awards = {}
                for _, value in pairs(info.award) do
                    table.insert(awards, {id = value.id, typeName = value.type or value.typeName, count = value.count})
                end
                local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                    options = {awards = awards}},{isPopCurrentDialog = false} )
                if self._fundType == 1 then
                    dialog:setTitle("恭喜您获得周基金奖励")
                elseif self._fundType == 2 then
                    dialog:setTitle("恭喜您获得武魂基金奖励")
                end
            end
        end)
end

function QUIWidgetActivityWeekFund:_clickAwardItemBox(event)
    if self._fundType ~= 2 then
        return 
    end

    local data = self._data[self._selectIndex]
    if data.isReady then
        self:_clickAwardBox({info = data.info})
    else
        local award = data.info.award
        app.tip:itemTip(nil, event.itemID)
    end
end

function QUIWidgetActivityWeekFund:_onTriggerClick()
    if self._fundType ~= 2 then
        return 
    end

    local data = self._data[self._selectIndex]
    if data.isReady then
        self:_clickAwardBox({info = data.info})
    end
end

function QUIWidgetActivityWeekFund:_onTriggerClickLeft()
    app.sound:playSound("common_small")

    local index = self._selectIndex - 1
    if index < 1 then
        return
    end
    self:_clickDot({index = index}) 
end

function QUIWidgetActivityWeekFund:_onTriggerClickRight()
    app.sound:playSound("common_small")
    
    local index = self._selectIndex + 1
    if index > #self._data then
        return
    end
    self:_clickDot({index = index})
end

function QUIWidgetActivityWeekFund:_onTriggerBuy(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_buy) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
end

function QUIWidgetActivityWeekFund:_onTriggerGo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
    app.sound:playSound("common_small")

    if self._fundType == 1 then
        if self.parent then
            self.parent:jumpTo("a_yueka")
        end
    elseif self._fundType == 2 then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
    end
end

return QUIWidgetActivityWeekFund