--
-- Author: Qinyuanji
-- Date: 2015-1-20
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTimeMachine = class("QUIWidgetTimeMachine", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetSkeletonActor = import(".actorDisplay.QUIWidgetSkeletonActor")

local INTERVAL = 1

function QUIWidgetTimeMachine:ctor(options)
	local ccbFile = "ccb/Widget_TimeMachine.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerBuyCount", callback = handler(self, self._onTriggerBuyCount)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, self._onTriggerData)},
		{ccbCallbackName = "onTriggerMonthCard", callback = handler(self, self._onTriggerMonthCard)},
	}
	QUIWidgetTimeMachine.super.ctor(self, ccbFile, callBacks, options)
	self._options = options.options
	self:scheduleUpdate_()
	self:initButtonState()
end

function QUIWidgetTimeMachine:initButtonState( )
	q.setButtonEnableShadow(self._ccbOwner.button)
	q.setButtonEnableShadow(self._ccbOwner.btn_plus)
	q.setButtonEnableShadow(self._ccbOwner.btn_month_card)
	q.setButtonEnableShadow(self._ccbOwner.button_data)
end

function QUIWidgetTimeMachine:onEnter( ... )
	QUIWidgetTimeMachine.super.onEnter()

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))

	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, function ()
    	self:refresh()
    end)
end

function QUIWidgetTimeMachine:onExit()
	QUIWidgetTimeMachine.super.onExit(self)

	self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
	if self._animation then
  		-- self._animation:removeAvatar()
  		if self._animation.stopAnimation then
  			self._animation:stopAnimation()
  		end
  		self._animation:removeFromParent()
      	self._animation = nil
  	end

  	if self._cdInterval then
  		scheduler.unscheduleGlobal(self._cdInterval)
  	end

    self._userEventProxy:removeAllEventListeners()
end
function QUIWidgetTimeMachine:_onFrame(dt)
	if self._animation and self._animation.updateAnimation then
    	self._animation:updateAnimation(dt)
    end
end

function QUIWidgetTimeMachine:refresh()
    self:update(self:getOptions().activityType, self:getOptions().availability, self:getOptions().lockText, true)
end

function QUIWidgetTimeMachine:update(activityType, availability, lockText, force)
	if self._type == activityType and not force then return end

	self._type = activityType
	self._availability = availability
	self:getOptions().activityType = activityType
	self:getOptions().availability = availability
	self:getOptions().lockText = lockText

	self._ccbOwner.bootyBayNode:setVisible(activityType == 1)
	self._ccbOwner.tavern:setVisible(activityType == 2)
	self._ccbOwner.strengthNode:setVisible(activityType == 3)
	self._ccbOwner.intellectNode:setVisible(activityType == 4)
	self._ccbOwner.cdNode:setVisible(availability)

	self._ccbOwner.node_btn_plus:setVisible(false)
	self._ccbOwner.btn_month_card:setVisible(false)
	self._ccbOwner.node_boss_desc:setVisible(availability)
	self._availability = availability
	
	if self._animation then
  		-- self._animation:removeAvatar()
  		if self._animation.stopAnimation then
  			self._animation:stopAnimation()
  		end
      	self._animation:removeFromParent()
      	self._animation = nil
  	end
  	
	local actorId = nil
	if activityType == 1 then
		self._skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
	    self._animation = self._skeletonViewController:createSkeletonActorWithFile("fca/toujinzei", nil, false)
	    self._animation:playAnimation(ANIMATION.STAND, true)
	    self._animation:setPositionY(-150)
	    self._animation:setScaleX(-0.275)
	    self._animation:setScaleY(0.275)
	    self._ccbOwner["node_avatar_" .. activityType]:addChild(self._animation)
	    self._ccbOwner["node_avatar_" .. activityType]:setVisible(true)
	elseif activityType == 2 then
		self._skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
	    self._animation = self._skeletonViewController:createSkeletonActorWithFile("fca/xmantuoluoshe", nil, false)
	    self._animation:playAnimation(ANIMATION.STAND, true)
	    self._animation:setPositionY(-160)
	    self._animation:setScaleX(-0.2)
	    self._animation:setScaleY(0.2)
  		self._ccbOwner["node_avatar_" .. activityType]:addChild(self._animation)
  		self._ccbOwner["node_avatar_" .. activityType]:setVisible(true)
	elseif activityType == 3 then
  		actorId = 3175
		local character = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
		self._ccbOwner.tf_boss_name:setString(character.name or "")

		self._skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
	    self._animation = self._skeletonViewController:createSkeletonActorWithFile(character.actor_file, nil, false)
	    self._animation:setPositionY(-160)
	    self._animation:setScale(1.1)
  		self._ccbOwner["node_avatar_" .. activityType]:addChild(self._animation)
  		self._ccbOwner["node_avatar_" .. activityType]:setVisible(true)
	elseif activityType == 4 then
  		actorId = 3176
		local character = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
		self._ccbOwner.tf_boss_name:setString(character.name or "")

		self._skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
	    self._animation = self._skeletonViewController:createSkeletonActorWithFile(character.actor_file, nil, false)
	    self._animation:playAnimation(ANIMATION.STAND, true)
	    self._animation:setPositionY(-160)
	    self._animation:setScaleX(-0.3)
	    self._animation:setScaleY(0.3)
  		self._ccbOwner["node_avatar_" .. activityType]:addChild(self._animation)
  		self._ccbOwner["node_avatar_" .. activityType]:setVisible(true)
	end

	
	if availability then
		self._ccbOwner.text:setString("今日剩余次数：")
		self._ccbOwner.count:setVisible(true)

		if self:getChallengeState() == false then 
			makeNodeFromNormalToGray(self._ccbOwner.node_button)
			self._ccbOwner.tf_btnoktext:disableOutline()
		else
			makeNodeFromGrayToNormal(self._ccbOwner.node_button)
			self._ccbOwner.tf_btnoktext:enableOutline()
			makeNodeFromGrayToNormal(self._animation)
		end
		if self._animation then self._animation:playAnimation(ANIMATION.STAND, true) end

		self:_updateRemainingCountandCD(activityType)

		self._options.initPage = activityType
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn_info)

		-- self._ccbOwner["node_avatar_3"]:setPositionX(137)
		-- self._ccbOwner["node_avatar_4"]:setPositionX(114)
		self._ccbOwner.node_boss_name:setPositionX(0)
	else
		self._ccbOwner.text:setString(lockText)
		self._ccbOwner.count:setVisible(false)
		makeNodeFromNormalToGray(self._ccbOwner.node_button)
		self._ccbOwner.add_count:setVisible(false)
		self._ccbOwner.tf_btnoktext:disableOutline()
		makeNodeFromNormalToGray(self._animation)
		makeNodeFromNormalToGray(self._ccbOwner.node_btn_info)
		if self._animation then
			if self._animation.stopAnimation then 
				self._animation:stopAnimation() 
			elseif self._animation.getSkeletonView then
				self._animation:getSkeletonView():stopAnimation()
			end
		end

		self._onTriggerConfirmImpl = function ()
		end
		self._onTriggerBuyCountImpl = function ()
		end

		-- self._ccbOwner.node_boss_name:setPositionX(-133)
		-- self._ccbOwner["node_avatar_3"]:setPositionX(7)
		-- self._ccbOwner["node_avatar_4"]:setPositionX(-16)
	end

	if availability then
		makeNodeFromGrayToNormal(self._animation)
	else
		makeNodeFromNormalToGray(self._animation)
	end

	self:setBossInfo(activityType)
end

function QUIWidgetTimeMachine:setBossInfo(dungeonType)
	-- self._ccbOwner.node_boss_info:setVisible(dungeonType == 3 or dungeonType == 4)
	if dungeonType == 3 or dungeonType == 4 then
		local config = remote.activityInstance:getInstanceListById(self:_convertTypeToConfigType(dungeonType))
		self._ccbOwner.tf_boss_desc:setString(config[1].aside or "")
		self._ccbOwner.tf_boss_btn_name:setString("Boss信息")
		self._ccbOwner.node_boss_desc:setVisible(true)
		self._ccbOwner.node_boss_name:setVisible(true)
	elseif dungeonType == 1 or dungeonType == 2 then
		self._ccbOwner.tf_boss_btn_name:setString("宝屋情报")
		self._ccbOwner.node_boss_desc:setVisible(false)
		self._ccbOwner.node_boss_name:setVisible(false)
	end

end

function QUIWidgetTimeMachine:_convertTypeToConfigType(activityType)
	if activityType == 1 then
		return ACTIVITY_DUNGEON_TYPE.TREASURE_BAY
	elseif activityType == 2 then
		return ACTIVITY_DUNGEON_TYPE.BLACK_IRON_BAR
	elseif activityType == 3 then
		return ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE
	else
		return ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE
	end
end

function QUIWidgetTimeMachine:_convertTypeToDungeonType(activityType)
	if activityType == 1 then
		return "booty_bay_"
	elseif activityType == 2 then
		return "dwarf_cellar_"
	elseif activityType == 3 then
		return "strength_test_"
	else
		return "wisdom_test_"
	end
end

function QUIWidgetTimeMachine:_updateRemainingCountandCD(activityType)
	local config = remote.activityInstance:getInstanceListById(self:_convertTypeToConfigType(activityType))
	local maxCount = remote.activityInstance:getAttackMaxCountByType(config[1].instance_id)
	local attackCount = remote.activityInstance:getAttackCountByType(config[1].instance_id)
	local leftCount = maxCount - attackCount
	
	if remote.activity:checkMonthCardActive(2) and (activityType == 1 or activityType == 2) then
		self._ccbOwner.btn_month_card:setVisible(true)
	end
	-- 有月卡次数
	if leftCount > 2 then
		self._ccbOwner.add_count:setVisible(true)
		self._ccbOwner.count:setString("2")
	else
		self._ccbOwner.count:setString(leftCount)
		self._ccbOwner.add_count:setVisible(false)
	end

	-- Get the latest activity dungeon fight time
	local cdConfig = QStaticDatabase:sharedDatabase():getConfiguration().DUNGEON_ACTIVITIES_CD.value
	local activityLatest = 0
	for index = 1, 9 do
		local activityCD = remote.instance:dungeonLastPassAt(self:_convertTypeToDungeonType(activityType) .. index)
		if activityCD > activityLatest then
			activityLatest = activityCD 
		end
	end
	
	if activityLatest > 0 and math.floor((q.serverTime()*1000 - activityLatest)/1000) < cdConfig and leftCount > 0 and self:_checkCanNoCD() == false then
		self._ccbOwner.cdNode:setVisible(true)
		activityCD = cdConfig - math.floor((q.serverTime()*1000 - activityLatest)/1000)
		self._ccbOwner.cd:setString("("..q.timeToHourMinuteSecond(activityCD, true))

		if self._cdInterval then scheduler.unscheduleGlobal(self._cdInterval) end
		self._cdInterval = scheduler.scheduleGlobal(handler(self, function ()
			activityCD = activityCD - INTERVAL

			if activityCD == 0 then
				self:refresh()
				scheduler.unscheduleGlobal(self._cdInterval)
				self._cdInterval = nil

				if self:getOptions().cdCallback then
					self:getOptions().cdCallback()
				end

				return
			end

			self._ccbOwner.cd:setString("("..q.timeToHourMinuteSecond(activityCD, true))
		end), INTERVAL)

		self._onTriggerConfirmImpl = function ()
			app.tip:floatTip(q.timeToHourMinuteSecond(activityCD, true) .. "后可再次挑战", 150)
		end		
		self._onTriggerBuyCountImpl = function ()
		end
	else
		self._ccbOwner.cdNode:setVisible(false)
		if self:_checkIsTestingDungeon() == true then
			self._onTriggerBuyCountImpl = function () end
		else
			self._onTriggerBuyCountImpl = function ()
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCount",
					options = {typeName = QUIDialogBuyCount["BUY_TYPE_" .. activityType], buyCallback = function () 
						app.tip:floatTip("购买成功", 150) 
					end}})
			end
		end

		-- If count is zero, pop up VIP dialog
		if leftCount <= 0 then
			local state = self:getChallengeState()
			self._ccbOwner.node_btn_plus:setVisible(state)
			if state then
				self._ccbOwner.btn_month_card:setVisible(false)
			end
			if self:_checkIsTestingDungeon() then
				self._ccbOwner.node_btn_plus:setVisible(false)
				self._onTriggerConfirmImpl = function ()
					app.tip:floatTip("当前次数不足")
				end	
			else
				self._onTriggerConfirmImpl = function ()
					self:_onTriggerBuyCountImpl()
				end	
			end
		else
			self._onTriggerConfirmImpl = function ()
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogActivityInstance",
					options = {instanceId = self:_convertTypeToConfigType(activityType)}})
			end
		end	

		if self:getOptions().cdCallback then
			self:getOptions().cdCallback()
		end
	end
end

--是否是最后两个活动本
function QUIWidgetTimeMachine:_checkIsTestingDungeon()
	return self._type == 3 or self._type == 4
end

function QUIWidgetTimeMachine:_checkCanNoCD()
	if QVIPUtil:getActivityNoCD() == true then
		return true
	end
	if app.unlock:checkLock("HUODONGBENXIAO_CD") == true then
		return true
	end
	return false
end

function QUIWidgetTimeMachine:getChallengeState()
	local config = remote.activityInstance:getInstanceListById(self:_convertTypeToConfigType(self._type))
	local totalNum = remote.activityInstance:getAttackMaxCountByType(config[1].instance_id)
	local buyCount = remote.activityInstance:getAttackCountByType(config[1].instance_id)

	if self._type == 1 then
		totalNum = totalNum + QVIPUtil:getBarMaxCount()
		buyCount = buyCount + (remote.user.dungeonSeaBuyCount or 0)
	elseif self._type == 2 then
		totalNum = totalNum + QVIPUtil:getSeaMaxCount()
		buyCount = buyCount + (remote.user.dungeonBarBuyCount or 0)
	elseif self._type == 3 then
		totalNum = totalNum + QVIPUtil:getStengthMaxCount()
		buyCount = buyCount + (remote.user.dungeonStrengthBuyCount or 0)
	elseif self._type == 4 then
		totalNum = totalNum + QVIPUtil:getIntellectMaxCount()
		buyCount = buyCount + (remote.user.dungeonSapientialBuyCount or 0)
	end
	
	return (totalNum-buyCount) > 0
end

function QUIWidgetTimeMachine:_onTriggerConfirm( event )
    app.sound:playSound("common_small")

    if self._availability == false then
    	app.tip:floatTip("明日开启", 127, -43)
    	return 
    end

    if self:getChallengeState() == false then 
    	app.tip:floatTip("今日挑战次数已用完", 127, -43)
    	return 
    end
	self:_onTriggerConfirmImpl()
end

function QUIWidgetTimeMachine:_onTriggerBuyCount( event )
    app.sound:playSound("common_small")
	self:_onTriggerBuyCountImpl()
end

function QUIWidgetTimeMachine:_onTriggerMonthCard()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

function QUIWidgetTimeMachine:_onTriggerData(e)
	if q.buttonEventShadow(e, self._ccbOwner.button_data) == false then return end
    app.sound:playSound("common_small")
    
	if self._availability == false then return end
	print("self._type=",self._type)
	if self._type == 3 or self._type == 4 then
		local configs = remote.activityInstance:getInstanceListById(self:_convertTypeToConfigType(activityType))
		local monstersConfig = QStaticDatabase.sharedDatabase():getMonstersById(configs[1].dungeon_id)
		for _, config in ipairs(monstersConfig) do
			if config.boss_show then
				self._bossId = config.npc_id
				self._enemyTips = config.boss_show
				break
			else
				self._bossId = nil
				self._enemyTips = nil
			end
		end
		if self._bossId and self._enemyTips then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroducePic",
					options = {bossId = self._bossId, enemyTips = self._enemyTips}})
		else
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTimeMachineBossSkillInfo",
				options = {instanceId = self:_convertTypeToConfigType(self._type)}})
		end
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTimeMachineIntroductionPlay",
				options = {instanceId = self:_convertTypeToConfigType(self._type)}})
	end
end

return QUIWidgetTimeMachine