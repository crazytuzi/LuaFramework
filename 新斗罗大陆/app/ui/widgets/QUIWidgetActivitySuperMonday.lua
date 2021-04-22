-- @Author: xurui
-- @Date:   2019-03-21 11:09:41
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-05 19:06:13
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivitySuperMonday = class("QUIWidgetActivitySuperMonday", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActivitySuperMondayClient = import("..widgets.QUIWidgetActivitySuperMondayClient")
local QUIWdigetActivityNumber = import("..widgets.QUIWdigetActivityNumber")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIWidgetActivitySuperMonday:ctor(options)
	local ccbFile = "ccb/Widget_MondayTime.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerRecive", callback = handler(self, self._onTriggerRecive)},
    }
    QUIWidgetActivitySuperMonday.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._targetClient = {}
	self._isAnimation = false
	self._currentCompleteTargetId = nil     --当前正在播放完成动画的目标钻石数量先不计入总数

	self._ccbOwner.node_tf_time:setPositionY(-display.height/2)

end

function QUIWidgetActivitySuperMonday:onEnter()
end

function QUIWidgetActivitySuperMonday:onExit()
	if self._countDownScheduler then
		scheduler.unscheduleGlobal(self._countDownScheduler)
		self._countDownScheduler = nil
	end
	if self._effectScheduler then
		scheduler.unscheduleGlobal(self._effectScheduler)
		self._effectScheduler = nil
	end
end

function QUIWidgetActivitySuperMonday:setInfo(activityInfo)
	self._activityInfo = activityInfo or {}

	--更新登录计时活动
	local isAwardTime = self:checkIsAwardTime()
	if not isAwardTime then
		remote.activity:updateLocalDataByType(705, q.serverTime() - remote.user.currentLoginTime)
		remote.user.currentLoginTime = q.serverTime()
	end

    local startTimeTbl = q.date("*t", (self._activityInfo.start_at or 0)/1000)
    local endTimeTbl = q.date("*t", (self._activityInfo.end_at or 0)/1000)
    local timeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", 
        startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, 
        endTimeTbl.month, endTimeTbl.day, endTimeTbl.hour, endTimeTbl.min)
    self._ccbOwner.tf_time:setString(timeStr)

	self:setTargetClient()

	self:setCurrentTokenNum()

	self:setAwardTimeCountdown()
end

function QUIWidgetActivitySuperMonday:setTargetClient( ... )
	self._targets = self._activityInfo.targets or {}

	table.sort(self._targets, function(a, b)
			local targetConfigA = remote.activity:getActivityTargetConfigByTargetId(a.activityTargetId)
			local targetConfigB = remote.activity:getActivityTargetConfigByTargetId(b.activityTargetId)

			return (targetConfigA.index or 100) < (targetConfigB.index or 100)
		end)
	local isAwardTime = self:checkIsAwardTime()
	for i = 1, 4 do
		if self._targets[i] and self._targets[i].index then
			if self._targetClient[i] == nil then
				self._targetClient[i] = QUIWidgetActivitySuperMondayClient.new()
				self._targetClient[i]:addEventListener(QUIWidgetActivitySuperMondayClient.EVENT_RECIVE, handler(self, self._reciveTarget))
				self._ccbOwner["node_"..i]:addChild(self._targetClient[i])
			end
			self._targetClient[i]:setInfo(self._targets[i], isAwardTime, i)
		end
	end
end

function QUIWidgetActivitySuperMonday:setCurrentTokenNum()
	local awardToken = 0
	for i = 1, 5 do
		if self._targets[i].index == 5 then
			local finalTargetConfig = remote.activity:getActivityTargetConfigByTargetId(self._targets[i].activityTargetId)
			awardToken = awardToken + finalTargetConfig.diamond or 0
		elseif self._targets[i].completeNum == 3 and self._targets[i].activityTargetId ~= self._currentCompleteTargetId then -- 当这个目标完成时，complete_progress 字段则为这个目标完成后累加的钻石数量
			local targetRecord = remote.activity:getActivityTargetProgressDataById(self._targets[i].activityId, self._targets[i].activityTargetId)
			awardToken = awardToken + (targetRecord.param1 or 0)
		end
	end

	if self._numberClient == nil then
	 	self._numberClient = QUIWdigetActivityNumber.new()
	 	self._ccbOwner.node_number:addChild(self._numberClient)
	end
	self._numberClient:setInfo(awardToken)
end

function QUIWidgetActivitySuperMonday:setAwardTimeCountdown( ... )
	if self._countDownScheduler then
		scheduler.unscheduleGlobal(self._countDownScheduler)
		self._countDownScheduler = nil
	end
	
	local lastTime = self._activityInfo.start_at / 1000 + (2 * DAY) 

	local countDownFunc
	countDownFunc = function()
		local currentTime = q.serverTime()
		local isAwardTime = currentTime > lastTime
		self._ccbOwner.node_recive_time:setVisible(not isAwardTime)
		self._ccbOwner.node_btn_recive:setVisible(isAwardTime)
		self._ccbOwner.node_ok:setVisible(false)

		local targets 
		for i = 1, 5 do
			if self._targets[i].index == 5 then
				targets = self._targets[i]
				break
			end
		end

		if targets and targets.completeNum == 3 then
			self._ccbOwner.node_recive_time:setVisible(false)
			self._ccbOwner.node_btn_recive:setVisible(false)
			self._ccbOwner.node_ok:setVisible(true)
		end

		if isAwardTime then
			if self._countDownScheduler then
				scheduler.unscheduleGlobal(self._countDownScheduler)
				self._countDownScheduler = nil
			end
		else
			self._ccbOwner.tf_recive_time:setString(string.format("%s", q.timeToHourMinuteSecond(lastTime - currentTime)))
		end
	end

	countDownFunc()
	self._countDownScheduler = scheduler.scheduleGlobal(countDownFunc, 1)
end

function QUIWidgetActivitySuperMonday:_reciveTarget(event)
	if event == nil or self._currentCompleteTargetId ~= nil then return end

	local targetInfo = event.info or {}
	local activityId = targetInfo.activityId 
	local activityTargetId = targetInfo.activityTargetId 
	local awards = event.awards or {}
	local index = event.index
	
	app:getClient():activityCompleteRequest(activityId, activityTargetId, nil, nil, function()
		self._currentCompleteTargetId = activityTargetId
		remote.activity:setCompleteDataById(activityId, activityTargetId)

		self:showEffect(index, function()
			if self._numberClient then
				local targetRecord = remote.activity:getActivityTargetProgressDataById(activityId, activityTargetId)
				self._numberClient:addNumber(targetRecord.param1 or 0, function()
					self._currentCompleteTargetId = nil

					self._effectScheduler = scheduler.performWithDelayGlobal(function( ... )
				  		local dialog = app:getNavigationManager():pushViewController( app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
				    		options = {awards = awards}}, {isPopCurrentDialog = false} )
						dialog:setTitle("恭喜您获得活动奖励")
					end, 0.2)
				end)
			end
		end)
	end)
end

function QUIWidgetActivitySuperMonday:showEffect(index, callback)
	if index == nil or self._ccbOwner["node_"..index] == nil then 
		if callback then
			callback()
		end
		return 
	end
    local proxy = CCBProxy:create()
    local ccbOwner = {}
    local effect = CCBuilderReaderLoad("monday_lizi_fx.ccbi", proxy, ccbOwner)
    self:getCCBView():addChild(effect)

    local speed = 800
    local startPosition = ccp(self._ccbOwner["node_"..index]:getPosition())
    startPosition = ccp(startPosition.x, startPosition.y - 130)
    effect:setPosition(startPosition)

    local targetPos = ccp(self._ccbOwner.node_effect:getPosition())
    targetPos = ccp(targetPos.x, targetPos.y)

    local dirction = 1
    if targetPos.x > startPosition.x then
    	dirction = -1
    end
    effect:setScaleX(dirction)

    local distance = q.distOf2Points(startPosition, targetPos)
    local angle = -q.angleOf2Points(startPosition, targetPos)
    effect:setRotation(angle)

    local effectArray = CCArray:create()
    effectArray:addObject(CCMoveTo:create(distance/speed, targetPos))
    effectArray:addObject(CCCallFunc:create(function()
    		effect:removeFromParent()
			local fcaAnimation = QUIWidgetFcaAnimation.new("fca/tx_cjmonday_effect", "res")
			fcaAnimation:playAnimation("animation", false)
			fcaAnimation:setPosition(ccp(35, -15))
			fcaAnimation:setEndCallback(function( )
				if callback then
	    			callback()
	    		end
			end)
    		self._ccbOwner.node_effect:addChild(fcaAnimation)
		end))

    effect:runAction(CCSequence:create(effectArray))
end

function QUIWidgetActivitySuperMonday:checkIsAwardTime()
	local lastTime = self._activityInfo.start_at / 1000 + (2 * DAY)
	local currentTime = q.serverTime()

	return currentTime > lastTime
end

function QUIWidgetActivitySuperMonday:_onTriggerRecive(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_recive) == false then return end
	local isAwardTime = self:checkIsAwardTime()
	if isAwardTime then
		local activityId = nil
		local activityTargetId = nil 
		local awardToken = 0
		local haveOtherAward = false
		for i = 1, 5 do
			if self._targets[i].index == 5 then
				activityId = self._targets[i].activityId 
				activityTargetId = self._targets[i].activityTargetId 
				local finalTargetConfig = remote.activity:getActivityTargetConfigByTargetId(activityTargetId)
				awardToken = awardToken + (finalTargetConfig.diamond or 0)
			elseif self._targets[i].completeNum == 3 then -- 当这个目标完成时，complete_progress 字段则为这个目标完成后累加的钻石数量
				local targetRecord = remote.activity:getActivityTargetProgressDataById(self._targets[i].activityId, self._targets[i].activityTargetId)
				awardToken = awardToken + (targetRecord.param1 or 0)
			elseif self._targets[i].completeNum == 2 then
				haveOtherAward = true
				break
			end
		end

		if haveOtherAward then
			app.tip:floatTip("魂师大人，您还有任务奖励没有领取，请领取之后再领取钻石大奖！")
		end

		local awards = {{type = ITEM_TYPE.TOKEN_MONEY, count = awardToken}}
		if activityId and activityTargetId then
			app:getClient():activityCompleteRequest(activityId, activityTargetId, nil, nil, function()
				self._currentCompleteTargetId = activityTargetId
		  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		    		options = {awards = awards}},{isPopCurrentDialog = false} )
				dialog:setTitle("恭喜您获得活动奖励")
				remote.activity:setCompleteDataById(activityId, activityTargetId)
			end)
		end
	end
end

return QUIWidgetActivitySuperMonday
