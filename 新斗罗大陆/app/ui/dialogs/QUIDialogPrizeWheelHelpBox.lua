-- @Author: zhouxiaoshu
-- @Date:   2019-08-16 12:04:53
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-11 20:50:08
local QUIDialog = import(".QUIDialog")
local QUIDialogPrizeWheelHelpBox = class("QUIDialogPrizeWheelHelpBox", QUIDialog)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")

--初始化
function QUIDialogPrizeWheelHelpBox:ctor(options)
    local ccbFile = "ccb/Dialog_prize_wheel_box.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerGetFree", callback = handler(self, self._onTriggerGetFree)},
        {ccbCallbackName = "onTriggerGetFee", callback = handler(self, self._onTriggerGetFee)},
        {ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
    }
    QUIDialogPrizeWheelHelpBox.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    q.setButtonEnableShadow(self._ccbOwner.btn_getFree)
    q.setButtonEnableShadow(self._ccbOwner.btn_getFee)
    q.setButtonEnableShadow(self._ccbOwner.btn_buy)
end

function QUIDialogPrizeWheelHelpBox:viewDidAppear()
    QUIDialogPrizeWheelHelpBox.super.viewDidAppear(self)

    self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.PRIZA_WHEEL_UPDATE, handler(self, self.updateInfo))

    self:updateInfo()
end

function QUIDialogPrizeWheelHelpBox:viewWillDisappear()
    QUIDialogPrizeWheelHelpBox.super.viewWillDisappear(self)
    
    self._activityRoundsEventProxy:removeAllEventListeners()

    if self._timeScheduler ~= nil then 
        scheduler.unscheduleGlobal(self._timeScheduler)
        self._timeScheduler = nil
    end
end
    
function QUIDialogPrizeWheelHelpBox:updateInfo()
    local prizeWheelRound = remote.activityRounds:getPrizaWheel()
    local prizeWheelInfo = prizeWheelRound:getPrizeWheelInfo() or {}
    local wheelGiftConfig = db:getStaticByName("activity_prize_wheel_gift")
    local curWheelGiftConfig = wheelGiftConfig[tostring(prizeWheelRound.rowNum)] or {}
    
    local curWheelGift = nil
    local curDays = prizeWheelRound:getPrizeWheelDays()
    for i, v in pairs(curWheelGiftConfig) do
        if v.date == curDays then
            curWheelGift = v
            break
        end
    end
    if not curWheelGift then
        return
    end

    local itemTbl1 = string.split(curWheelGift.reward_1, "^")
    local itemTbl2 = string.split(curWheelGift.reward_2, "^")
    self._item1 = {itemId = tonumber(itemTbl1[1]), itemType = ITEM_TYPE.ITEM, count = tonumber(itemTbl1[2])}
    self._item2 = {itemId = tonumber(itemTbl2[1]), itemType = ITEM_TYPE.ITEM, count = tonumber(itemTbl2[2])}

    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setInfo(self._item1)
    itemBox:setPromptIsOpen(true)
    self._ccbOwner.node_icon_1:addChild(itemBox)

    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setInfo(self._item2)
    itemBox:setPromptIsOpen(true)
    self._ccbOwner.node_icon_2:addChild(itemBox)

    local itemConfig1 = db:getItemByID(self._item1.itemId)
    local itemConfig2 = db:getItemByID(self._item2.itemId)
    self._ccbOwner.tf_name_1:setString(itemConfig1.name)
    self._ccbOwner.tf_name_2:setString(itemConfig2.name)

    local dateDesc = q.timeToMonthDay(q.serverTime())
    self._ccbOwner.tf_date_desc:setString(dateDesc.."礼包")
    self._ccbOwner.tf_condition:setString("累计充值"..(curWheelGift.prize or 0).."元赠送")

    local freeGet = false
    local feeGet = false
    local helpPrizeGot = prizeWheelInfo.helpPrizeGot or {}
    for i, v in pairs(helpPrizeGot) do
        if v == 1 then
            freeGet = true
        elseif v == 2 then
            feeGet = true
        end
    end
    
    self._ccbOwner.sp_get_1:setVisible(freeGet)
    self._ccbOwner.sp_get_2:setVisible(feeGet)
    self._ccbOwner.node_get_1:setVisible(not freeGet)
    self._ccbOwner.node_get_2:setVisible(false)
    self._ccbOwner.node_buy:setVisible(false)
    if not feeGet then
        local isComplate = remote.user.todayRecharge >= curWheelGift.prize
        self._ccbOwner.node_buy:setVisible(not isComplate)
        self._ccbOwner.node_get_2:setVisible(isComplate)
    end

    self:setTimeCountdown()
end

function QUIDialogPrizeWheelHelpBox:setTimeCountdown()
    if self._timeScheduler ~= nil then 
        scheduler.unscheduleGlobal(self._timeScheduler)
        self._timeScheduler = nil
    end

    local leftTime = q.getLeftTimeOfDay()
    local timeDownFunction = function()
        if leftTime >= 0 then
            local timeDesc = q.timeToHourMinuteSecond(leftTime)
            self._ccbOwner.tf_refresh_time:setString("剩余时间："..timeDesc)
            leftTime = leftTime - 1
        end
    end
    timeDownFunction()
    self._timeScheduler = scheduler.scheduleGlobal(timeDownFunction, 1)
end

function QUIDialogPrizeWheelHelpBox:_onTriggerGetFree()
    app.sound:playSound("common_small")
    local prizeWheelRound = remote.activityRounds:getPrizaWheel()
    prizeWheelRound:requestPrizeWheelGetPrizeHelp(1, function(data)
        if self:safeCheck() then
            app:alertAwards({awards = {self._item1}, callback = function()
                self:updateInfo()
            end})
        end
    end)
end

function QUIDialogPrizeWheelHelpBox:_onTriggerGetFee()
    app.sound:playSound("common_small")
    local prizeWheelRound = remote.activityRounds:getPrizaWheel()
    prizeWheelRound:requestPrizeWheelGetPrizeHelp(2, function(data)
        if self:safeCheck() then
            app:alertAwards({awards = {self._item2}, callback = function()
                self:updateInfo()
            end})
        end
    end)
end

function QUIDialogPrizeWheelHelpBox:_onTriggerBuy()
    app.sound:playSound("common_small")
    if ENABLE_CHARGE() then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
    end
end

function QUIDialogPrizeWheelHelpBox:_onTriggerClose()
    app.sound:playSound("common_small")
    self:playEffectOut()
end

function QUIDialogPrizeWheelHelpBox:_backClickHandler()
    self:playEffectOut()
end

return QUIDialogPrizeWheelHelpBox

