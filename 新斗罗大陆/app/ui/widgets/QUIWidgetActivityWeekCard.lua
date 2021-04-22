--
-- zxs 
-- 周礼包
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityWeekCard = class("QUIWidgetActivityWeekCard", QUIWidget)

local QPayUtil = import("...utils.QPayUtil")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")
local QScrollView = import("...views.QScrollView")

function QUIWidgetActivityWeekCard:ctor()
	local ccbFile = "ccb/Widget_zhoulibao.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerNormal", callback = handler(self, self._onTriggerNormal)},
  		{ccbCallbackName = "onTriggerPrime", callback = handler(self, self._onTriggerPrime)},
  		{ccbCallbackName = "onTriggerDrawNormal", callback = handler(self, self._onTriggerDrawNormal)},
  		{ccbCallbackName = "onTriggerDrawPrime", callback = handler(self, self._onTriggerDrawPrime)},
  		{ccbCallbackName = "onTriggerInfoNormal", callback = handler(self, self._onTriggerInfoNormal)},
  		{ccbCallbackName = "onTriggerInfoPrime", callback = handler(self, self._onTriggerInfoPrime)},
  	}
	QUIWidgetActivityWeekCard.super.ctor(self,ccbFile,callBacks,options)
	CalculateUIBgSize(self._ccbOwner.sp_bg, 1024)
	self._isFinish = false			-- 活动已结束
	self._isAwardFinish = false		-- 活动领奖已结束

	self._ccbOwner.node_tf_time:setPositionY(-display.height/2)
end

function QUIWidgetActivityWeekCard:onExit()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QUIWidgetActivityWeekCard:setInfo(info)
	self._isFinish = false
	self._isAwardFinish = false
	self._info = info

	-- 保证左边是小的充值金额
	self._normalInfo = nil
	self._primeInfo = nil
	if info.targets[1].value2 < info.targets[2].value2 then
		self._normalInfo = info.targets[1]
		self._primeInfo = info.targets[2]
	else
		self._normalInfo = info.targets[2]
		self._primeInfo = info.targets[1]
	end

	self:update()
	self:_timeCountDown()
end

function QUIWidgetActivityWeekCard:update()
	local size = self._ccbOwner.sheet_layout:getContentSize()
	
	local completeNum = self._normalInfo.completeNum or 1
	self._ccbOwner["button1"]:setVisible(completeNum == 1)
	self._ccbOwner["button_lab1"]:setVisible(completeNum == 1)
	self._ccbOwner["drawButton1"]:setVisible(completeNum == 2)
	self._ccbOwner["drawButton_lab1"]:setVisible(completeNum == 2)
	self._ccbOwner["drawn1"]:setVisible(completeNum == 3)
	self._ccbOwner["tf_desc1"]:setString("")
	self._ccbOwner["node_icon1"]:removeAllChildren()
    self._ccbOwner.sheet1:removeAllChildren()

	local awards = self:_getAwardByStr(self._normalInfo.awards)
	if awards[1] then
		local item = QUIWidgetItemsBox.new()
		self._ccbOwner["node_icon1"]:addChild(item)
		item:setGoodsInfo(awards[1].id, ITEM_TYPE.ITEM, awards[1].count)
		item:setPromptIsOpen(true)
	end

	local desc = self._normalInfo.description or ""
    local strArr  = string.split(desc,"\n") or {}
    local textNode = CCNode:create()
    local height = 0
    for i, v in pairs(strArr) do
        local richText = QRichText.new(v, 204, {stringType = 1, defaultColor = GAME_COLOR_SHADOW.normal, defaultSize = 20})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-height)
        textNode:addChild(richText)
        height = height + richText:getContentSize().height
    end
    textNode:setContentSize(CCSize(406, height))
	local scrollView1 = QScrollView.new(self._ccbOwner.sheet1, size, {bufferMode = 1})
    scrollView1:setVerticalBounce(true)
	scrollView1:addItemBox(textNode)
	scrollView1:setRect(0, -height, 0, 0)

	local completeNum = self._primeInfo.completeNum or 1
	self._ccbOwner["button2"]:setVisible(completeNum == 1)
	self._ccbOwner["button_lab2"]:setVisible(completeNum == 1)
	self._ccbOwner["drawButton2"]:setVisible(completeNum == 2)
	self._ccbOwner["drawButton_lab2"]:setVisible(completeNum == 2)
	self._ccbOwner["drawn2"]:setVisible(completeNum == 3)
	self._ccbOwner["tf_desc2"]:setString("")
	self._ccbOwner["node_icon2"]:removeAllChildren()
    self._ccbOwner.sheet2:removeAllChildren()

	local awards = self:_getAwardByStr(self._primeInfo.awards)
	if awards[1] then
		local item = QUIWidgetItemsBox.new()
		self._ccbOwner["node_icon2"]:addChild(item)
		item:setGoodsInfo(awards[1].id, ITEM_TYPE.ITEM, awards[1].count)
		item:setPromptIsOpen(true)
	end

	local desc = self._primeInfo.description or ""
    local strArr  = string.split(desc,"\n") or {}
    local textNode = CCNode:create()
    local height = 0
    for i, v in pairs(strArr) do
        local richText = QRichText.new(v, 204, {stringType = 1, defaultColor = GAME_COLOR_SHADOW.normal, defaultSize = 20})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-height)
        textNode:addChild(richText)
        height = height + richText:getContentSize().height
    end
    textNode:setContentSize(CCSize(406, height))
	local scrollView2 = QScrollView.new(self._ccbOwner.sheet2, size, {bufferMode = 1})
    scrollView2:setVerticalBounce(true)
	scrollView2:addItemBox(textNode)
	scrollView2:setRect(0, -height, 0, 0)
end

--倒计时
function QUIWidgetActivityWeekCard:_timeCountDown()
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end

	local timeCount = self._info.end_at/1000 - q.serverTime()
	if timeCount <= 0 then
		self._isFinish = true
	end

	local awardEnd = self._info.award_end_at or self._info.end_at
	local awardTimeCount = awardEnd/1000 - q.serverTime()
	if awardTimeCount <= 0 then
		self._isAwardFinish = true
	end

	if timeCount > 0 then
		local day = math.floor(timeCount/DAY)
		timeCount = timeCount%DAY
		local str = q.timeToHourMinuteSecond(timeCount)
		if day > 0 then
			str = day.."天 "..str
		end
		self._schedulerHandler = scheduler.performWithDelayGlobal(function ()
			self:_timeCountDown()
		end,1)

		self._ccbOwner.tf_tips:setString("活动剩余时间："..str)
	else
		self._ccbOwner.tf_tips:setString("活动已结束")
	end
end

function QUIWidgetActivityWeekCard:_getAwardByStr(awardsStr)
	if not awardsStr or awardsStr == "" then
		return {}
	end

	local awards = {}
    local rewards = string.split(awardsStr, ";")
    for i, v in pairs(rewards) do
        if v ~= "" then
            local reward = string.split(v, "^")
            local itemType = ITEM_TYPE.ITEM
            if tonumber(reward[1]) == nil then
                itemType = remote.items:getItemType(reward[1])
            end
            table.insert(awards, {id = reward[1], typeName = itemType, count = tonumber(reward[2])})
        end
    end
    return awards
end

function QUIWidgetActivityWeekCard:_onTriggerNormal(event)
	if q.buttonEventShadow(event,self._ccbOwner.button1) == false then return end
    app.sound:playSound("common_small")
	if self._isFinish then
		app.tip:floatTip("当前活动已结束，下次请早！")
		return
	end
	if ENABLE_CHARGE() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

function QUIWidgetActivityWeekCard:_onTriggerPrime(event)
	if q.buttonEventShadow(event,self._ccbOwner.button2) == false then return end
    app.sound:playSound("common_small")
	if self._isFinish then
		app.tip:floatTip("当前活动已结束，下次请早！")
		return
	end
	if ENABLE_CHARGE() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

function QUIWidgetActivityWeekCard:_onTriggerDrawNormal(event)
	if q.buttonEventShadow(event,self._ccbOwner.drawButton1) == false then return end
	app.sound:playSound("common_confirm")
	if self._isAwardFinish then
		app.tip:floatTip("当前活动已结束，下次请早！")
		return
	end

	local awards = self:_getAwardByStr(self._normalInfo.awards)
	app:getClient():activityCompleteRequest(self._info.activityId, self._normalInfo.activityTargetId, nil, nil, function (data)
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	    		options = {awards = awards}},{isPopCurrentDialog = false} )
			dialog:setTitle("恭喜您获得活动奖励")
			remote.activity:setCompleteDataById(self._info.activityId, self._normalInfo.activityTargetId)
		end)
end

function QUIWidgetActivityWeekCard:_onTriggerDrawPrime(event)
	if q.buttonEventShadow(event,self._ccbOwner.drawButton2) == false then return end
	app.sound:playSound("common_confirm")
	if self._isAwardFinish then
		app.tip:floatTip("当前活动已结束，下次请早！")
		return
	end

	local awards = self:_getAwardByStr(self._primeInfo.awards)
	app:getClient():activityCompleteRequest(self._info.activityId, self._primeInfo.activityTargetId, nil, nil, function (data)
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	    		options = {awards = awards}},{isPopCurrentDialog = false} )
			dialog:setTitle("恭喜您获得活动奖励")
			remote.activity:setCompleteDataById(self._info.activityId, self._primeInfo.activityTargetId)
		end)
end

function QUIWidgetActivityWeekCard:_onTriggerInfoNormal(event)
	app.sound:playSound("common_confirm")
	self:_showAwardAlert(self._normalInfo.awards)
end

function QUIWidgetActivityWeekCard:_onTriggerInfoPrime()
	app.sound:playSound("common_confirm")
	self:_showAwardAlert(self._primeInfo.awards)
end

function QUIWidgetActivityWeekCard:_showAwardAlert(awardsStr)
	local awards = self:_getAwardByStr(awardsStr)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsBoxAlert",
	    options = {awards = awards, isGet = false}},{isPopCurrentDialog = false} )
end

return QUIWidgetActivityWeekCard
