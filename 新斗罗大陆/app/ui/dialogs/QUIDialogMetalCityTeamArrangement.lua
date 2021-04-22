-- @Author: xurui
-- @Date:   2018-08-09 10:21:12
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-10-20 10:39:49
local QUIDialog = import(".QUIDialog")
local QUIDialogMetalCityTeamArrangement = class("QUIDialogMetalCityTeamArrangement", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetMetalCityHeroBattleArray = import("..widgets.QUIWidgetMetalCityHeroBattleArray")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUserData = import("...utils.QUserData")

local NUMBER_TIME = 1
local AVATAR_SCALE = 1.3
local SWITCH_DISTANCE = 1340
local SWITCH_DURATION = 0.3
local NORMAL_POS = {ccp(390, 0), ccp(130, 0), ccp(-130.0, 0), ccp(-390, 0)}
local HAVE_SOUL_POS = {ccp(400, 0), ccp(200, 0), ccp(-0, 0), ccp(-200, 0), ccp(-410, 0)}
local HAVE_TWO_SOUL_POS = {ccp(420, 0), ccp(240, 0), ccp(60, 0), ccp(-120, 0), ccp(-290, 0),ccp(-450, 0)}

function QUIDialogMetalCityTeamArrangement:ctor(options)
	local ccbFile = "ccb/Dialog_HeroBattleArray_tower_change.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick1", callback = handler(self, self._onTriggerClick1)},
		{ccbCallbackName = "onTriggerClick2", callback = handler(self, self._onTriggerClick2)},
		{ccbCallbackName = "onTriggerClick3", callback = handler(self, self._onTriggerClick3)},
		{ccbCallbackName = "onTriggerClick4", callback = handler(self, self._onTriggerClick4)},
		{ccbCallbackName = "onTriggerClickH1", callback = handler(self, self._onTriggerClickH1)},
		{ccbCallbackName = "onTriggerClickH2", callback = handler(self, self._onTriggerClickH2)},
		{ccbCallbackName = "onTriggerClickH3", callback = handler(self, self._onTriggerClickH3)},
		{ccbCallbackName = "onTriggerClickH4", callback = handler(self, self._onTriggerClickH4)},
		{ccbCallbackName = "onTriggerSkill1", callback = handler(self, self._onTriggerSkill1)},
		{ccbCallbackName = "onTriggerSkill2", callback = handler(self, self._onTriggerSkill2)},
		{ccbCallbackName = "onTriggerSkill3", callback = handler(self, self._onTriggerSkill3)},
		{ccbCallbackName = "onTriggerSkill4", callback = handler(self, self._onTriggerSkill4)},
		{ccbCallbackName = "onTriggerAssistSkill1", callback = handler(self, self._onTriggerAssistSkill1)},
		{ccbCallbackName = "onTriggerAssistSkill2", callback = handler(self, self._onTriggerAssistSkill2)},
		{ccbCallbackName = "onTriggerAssistSkill3", callback = handler(self, self._onTriggerAssistSkill3)},
		{ccbCallbackName = "onTriggerAssistSkill4", callback = handler(self, self._onTriggerAssistSkill4)},
		{ccbCallbackName = "onTriggerClickSoul1", callback = handler(self, self._onTriggerClickSoul1)},
		{ccbCallbackName = "onTriggerClickSoul2", callback = handler(self, self._onTriggerClickSoul2)},
		{ccbCallbackName = "onTriggerFight", callback = handler(self, self._onTriggerFight)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerConditionInfo", callback = handler(self, self._onTriggerConditionInfo)},
		{ccbCallbackName = "onTriggerSoulInfo", callback = handler(self, self._onTriggerSoulInfo)},
		{ccbCallbackName = "onTriggerGodarmInfo", callback = handler(self,self._onTriggerGodarmInfo)},
		{ccbCallbackName = "onTriggerHelperDetail", callback = handler(self, self._onTriggerHelperDetail)},
		{ccbCallbackName = "onTriggerChangeTeam", callback = handler(self, self._onTriggerChangeTeam)},
		{ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},
		{ccbCallbackName = "onTriggerSkipFight", callback = handler(self, self._onTriggerSkipFight)},
		{ccbCallbackName = "onTriggerSync", callback = handler(self, self._onTriggerSync)},

	}
	QUIDialogMetalCityTeamArrangement.super.ctor(self,ccbFile,callBacks,options)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setAllUIVisible(false)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page and page.setAllUIVisible then page:setAllUIVisible(false) end
    if page and page.setScalingVisible then page:setScalingVisible(false) end
	q.setButtonEnableShadow(self._ccbOwner.btn_godarm_info)
	q.setButtonEnableShadow(self._ccbOwner.btn_soul_spirit)
	q.setButtonEnableShadow(self._ccbOwner.btn_sync)


	self._force = 0
	self._selectTrialNum = options.trialNum or 1        --金属之城默认选择试炼
	self._arrangements = {}
	self._arrangements[1] = options.arrangement1
	self._arrangements[2] = options.arrangement2
	self._fighterInfo = clone(options.fighterInfo or {})

	self._arrangement = self._arrangements[self._selectTrialNum]
	self._unlockedSlot = self._arrangement:getUnlockSlots(1, self._selectTrialNum)
	self._onConfirm = options.onConfirm -- this callback will show the confirm button and hide battle button
	self._onFight = options.onFight
	self._floor = options.floor
	self._isDefence = options.defense
	self._widgetClass = options.widgetClass
	self._isStromArena = options.isStromArena
	self._isTotemChallenge = options.isTotemChallenge or false
	self._isSkipFight = false

	self._allHeroList = self:initHero(self._arrangement:getHeroes())
	self._allSpiritList = self:initSoulSpirit(self._arrangement:getSoulSpirits())
	self._godarmList = self:initGodarmList(remote.godarm:getHaveGodarmList() or {})

	self._heroList = {}
	self._spiritList = {}
	self._trailBossInfo = {}
	self._widgetSoulSpirit = {}

	self._ccbOwner.node_pvp:setPositionX(420)

	self._widgetHeroArray = QUIWidgetMetalCityHeroBattleArray.new({
		unlockNumber = self._unlockedSlot, 
		heroList = self._allHeroList, 
		soulSpiritList = self._allSpiritList, 
		godarmList = self._godarmList,
		arrangement = self._arrangement,
		state = self._arrangement:showHeroState(), 
		tips = self._arrangement:getPrompt(), 
		trialNum = self._selectTrialNum, 
		isStromArena = self._isStromArena
	})
    self._widgetHeroArrayProxy = cc.EventProxy.new(self._widgetHeroArray)
    self._widgetHeroArrayProxy:addEventListener(QUIWidgetMetalCityHeroBattleArray.HERO_CHANGED, handler(self, self._onHeroChanged))
    self._widgetHeroArrayProxy:addEventListener(QUIWidgetMetalCityHeroBattleArray.EVENT_SELECT_TAB, handler(self, self._onHeroChangedTab))
	self._selectSkillHero1 = {}
	self._selectSkillHero2 = {}
	self:initSelectSkill()

	self._widgetHeroArray:setPositionY(122 - display.cy)
	self._ccbOwner.node_confirmBtn:setPositionY(110 - display.cy)
	self._ccbOwner.node_skip_fight:setVisible(false)

	
	if self._isTotemChallenge and app.unlock:checkLock("UNLOCK_SHENGZHUTIAOZHAN_SKIP", false) then
		self._ccbOwner.node_skip_fight:setVisible(true)
		self._ccbOwner.node_confirmBtn:setPositionY(110 - display.cy - 20)
		local isSkip = app:getUserData():getUserValueForKey(QUserData.Totem_Challenge_SKIP)
		if isSkip and isSkip == "1" then  self._isSkipFight = true end
		self._ccbOwner.sp_select:setVisible(self._isSkipFight)
	end 

	self._ccbOwner.tf_defens_force:setString(self._force)
	self._ccbOwner.helperRule:setVisible(true)

	self._forceUpdate = QTextFiledScrollUtils.new()
	self._effectPlay = false

	self._ccbOwner.node_left:setVisible(false)
	self._ccbOwner.node_right:setVisible(true)
	self._selectIndex = self._widgetHeroArray:getSelectIndex()

	self._heroAvatars = {}
	self._heroHelperAvatars = {}
	self._combinedSkill = {}

	self:updateLockState(1)

	if self._arrangement ~= nil then
		if self._arrangement:getIsBattle() == false then
			self._ccbOwner.node_btn_confirm:setVisible(true)
			self._ccbOwner.node_btn_battle:setVisible(false)
		end
	end
	if app.unlock:checkLock("ARRAY_SYNC", false)  then
		self._ccbOwner.node_sync:setVisible(true)
	else
		self._ccbOwner.node_sync:setVisible(false)
	end
	self._ccbOwner.node_skill_1:setVisible(false)
	self._ccbOwner.node_skill_2:setVisible(false)
	self._ccbOwner.node_skill_3:setVisible(false)
	self._ccbOwner.node_skill_4:setVisible(false)

	self:initBackground()
	self:initTeamPos()
end

function QUIDialogMetalCityTeamArrangement:initBackground()
	self._ccbOwner.sp_main_bg:setVisible(true)
	self._ccbOwner.sp_helper_bg:setVisible(false)
	self._ccbOwner.sp_godarm_bg:setVisible(false)
    CalculateUIBgSize(self._ccbOwner.sp_main_bg)
    CalculateUIBgSize(self._ccbOwner.sp_helper_bg)
    CalculateUIBgSize(self._ccbOwner.sp_godarm_bg)
	if self._arrangement:getBackPagePath(1) then
		self._ccbOwner.sp_main_bg:setDisplayFrame(self._arrangement:getBackPagePath(1))
	end
	if self._arrangement:getBackPagePath(2) then
		self._ccbOwner.sp_helper_bg:setDisplayFrame(self._arrangement:getBackPagePath(2))
	end

	-- 背景专场
	self._ccbOwner.sp_effect_bg1:setVisible(true)
	self._ccbOwner.sp_effect_bg2:setVisible(true)
	if self._arrangement:getEffectPagePath(1) then
		self._ccbOwner.sp_effect_bg1:setDisplayFrame(self._arrangement:getEffectPagePath(1))
		self._ccbOwner.sp_effect_bg2:setDisplayFrame(self._arrangement:getEffectPagePath(1))
	end
end

--初始化战队位置，是否显示魂灵
function QUIDialogMetalCityTeamArrangement:initTeamPos()
	local pos = NORMAL_POS
	for ii = 1,2 do
		self._ccbOwner["node_soul_"..ii]:setVisible(false)
	end
	self._ccbOwner["node_soul_info"]:setVisible(false)
	self._ccbOwner["node_godarm_info"]:setVisible(false)

	if app.unlock:checkLock("UNLOCK_SOUL_SPIRIT", false) then
		pos = HAVE_TWO_SOUL_POS
		local scale = 0.82
		local lockSoulNum = remote.soulSpirit:getTeamSpiritsMaxCount(true)
		for ii = 1,2 do
			self._ccbOwner["node_soul_"..ii]:setScale(scale)
			self._ccbOwner["node_soul_"..ii]:setVisible(true)
			self._ccbOwner["enable_soul"..ii]:setVisible(lockSoulNum >= ii)
			self._ccbOwner["disable_soul"..ii]:setVisible(ii > lockSoulNum)
			self._ccbOwner["light_soul"..ii]:setVisible(true)
			self._ccbOwner["unlock_soul"..ii]:setVisible(ii > lockSoulNum)

			self._ccbOwner["node_soul_"..ii]:setPosition(pos[4+ii].x, pos[4+ii].y)
			
		end

		self._ccbOwner["node_soul_info"]:setVisible(true)
		for i = 1, 4 do
			self._ccbOwner["node_avatar_"..i]:setScale(scale)
			self._ccbOwner["node_helper_"..i]:setScale(scale)
		end
	end
	for i = 1, 4 do
		self._ccbOwner["node_avatar_"..i]:setPosition(pos[i].x, pos[i].y)
	end
end

function QUIDialogMetalCityTeamArrangement:showLeftBtn(isGodarmTab)
	if isGodarmTab then
		self._ccbOwner["node_godarm_info"]:setVisible(remote.godarm:checkGodArmUnlock())
		self._ccbOwner["node_soul_info"]:setVisible(false)
	else
		self._ccbOwner["node_soul_info"]:setVisible(app.unlock:checkLock("UNLOCK_SOUL_SPIRIT", false))
		self._ccbOwner["node_godarm_info"]:setVisible(false)
	end
end

function QUIDialogMetalCityTeamArrangement:initHero(availableHeroIDs)
	local availableHero = {}

	local teamVO = remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)
	for i, actorId in pairs(availableHeroIDs) do
		local characher = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)

		local heroType = 1
		local hatred = characher.hatred
		if characher.func == 't' then
			heroType = 't'
		elseif characher.func == 'health' then
			heroType = 'h'
		elseif characher.func == 'dps' and characher.attack_type == 1 then
			heroType = 'pd'
		elseif characher.func == 'dps' and characher.attack_type == 2 then
			heroType = 'md'
		end
		local force = remote.herosUtil:createHeroPropById(actorId):getBattleForce(self._arrangement:getIsLocal())
		availableHero[actorId] = {actorId = actorId, type = heroType, hatred = hatred, index = 0, force = force}
		availableHero[actorId].arrangement = self._arrangement
	end

	local teamVO1 = remote.teamManager:getTeamByKey(self._arrangements[1]:getTeamKey(), false)
	local maxIndex1 = teamVO1:getTeamMaxIndex()
	for i = 1, maxIndex1 do
		local actorIds = teamVO1:getTeamActorsByIndex(i)
		if actorIds ~= nil then
			for _,v in ipairs(actorIds) do
				if availableHero[v] then
					availableHero[v].index = i
					availableHero[v].trialNum = 1
				end
			end
		end
	end
	local teamVO2 = remote.teamManager:getTeamByKey(self._arrangements[2]:getTeamKey(), false)
	local maxIndex2 = teamVO2:getTeamMaxIndex()
	for i = 1, maxIndex2 do
		local actorIds = teamVO2:getTeamActorsByIndex(i)
		if actorIds ~= nil then
			for _, v in ipairs(actorIds) do
				if availableHero[v] then
					availableHero[v].index = i
					availableHero[v].trialNum = 2
				end
			end
		end
	end

	return availableHero
end

function QUIDialogMetalCityTeamArrangement:initSoulSpirit(allSoulSpirits)
	local soulSpirits = {}
	for i, soulSpiritInfo in pairs(allSoulSpirits) do
		local soulSpiritId = soulSpiritInfo.id
		local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
		local force = remote.soulSpirit:countForceBySpirit(soulSpiritInfo)
		soulSpirits[soulSpiritId] = {soulSpiritId = soulSpiritId, index = 0, force = force}
	end

	local teamV1 = remote.teamManager:getTeamByKey(self._arrangements[1]:getTeamKey(), false)
	local maxIndex = teamV1:getTeamMaxIndex()
	for i = 1, maxIndex do
		local soulSpiritIds = teamV1:getTeamSpiritsByIndex(i)
		for _, soulSpiritId in ipairs(soulSpiritIds) do
			if soulSpirits[soulSpiritId] then
				soulSpirits[soulSpiritId].index = i
				soulSpirits[soulSpiritId].trialNum = 1
			end
		end
	end
	local teamV2 = remote.teamManager:getTeamByKey(self._arrangements[2]:getTeamKey(), false)
	local maxIndex = teamV2:getTeamMaxIndex()
	for i = 1, maxIndex do
		local soulSpiritIds = teamV2:getTeamSpiritsByIndex(i)
		for _, soulSpiritId in ipairs(soulSpiritIds) do
			if soulSpirits[soulSpiritId] then
				soulSpirits[soulSpiritId].index = i
				soulSpirits[soulSpiritId].trialNum = 2
			end
		end
	end
	return soulSpirits
end

function QUIDialogMetalCityTeamArrangement:initGodarmList(godarmList)
	local godarmArray = {}
	for i, godarmInfo in pairs(godarmList) do
		godarmArray[godarmInfo.id] = {godarmId = godarmInfo.id, grade = godarmInfo.grade,level = godarmInfo.level,index = 0, pos = 5,force = godarmInfo.main_force}
	end
	local teamV1 = remote.teamManager:getTeamByKey(self._arrangements[1]:getTeamKey(), false)
	local godarmIds1 = teamV1:getTeamGodarmByIndex(remote.teamManager.TEAM_INDEX_GODARM)
	local pos = 1
	for _, godarmId in ipairs(godarmIds1) do
		if godarmArray[godarmId] then
			godarmArray[godarmId].index = remote.teamManager.TEAM_INDEX_GODARM
			godarmArray[godarmId].pos = pos
			godarmArray[godarmId].trialNum = 1
			pos = pos + 1
		end
	end

	local teamV2 = remote.teamManager:getTeamByKey(self._arrangements[2]:getTeamKey(), false)
	local godarmIds2 = teamV2:getTeamGodarmByIndex(remote.teamManager.TEAM_INDEX_GODARM)
	pos = 1
	for _, godarmId in ipairs(godarmIds2) do
		if godarmArray[godarmId] then
			godarmArray[godarmId].index = remote.teamManager.TEAM_INDEX_GODARM
			godarmArray[godarmId].pos = pos
			godarmArray[godarmId].trialNum = 2
			pos = pos + 1
		end
	end	
	return godarmArray
end

function QUIDialogMetalCityTeamArrangement:initSelectSkill()
	local actorIds1 = self._arrangements[1]:getActorTeams(remote.teamManager.TEAM_INDEX_HELP) or {}
	local skills1 = self._arrangements[1]:getSkillTeams(remote.teamManager.TEAM_INDEX_SKILL) or {}
	local actorIds2 = self._arrangements[2]:getActorTeams(remote.teamManager.TEAM_INDEX_HELP) or {}
	local skills2 = self._arrangements[2]:getSkillTeams(remote.teamManager.TEAM_INDEX_SKILL) or {}
	self._selectSkillHero1 = remote.teamManager:sortSubActorIds(actorIds1, skills1[1], skills1[2])
    self._selectSkillHero2 = remote.teamManager:sortSubActorIds(actorIds2, skills2[1], skills2[2])
    remote.teamManager:setHeroUpOrder(1, self._selectSkillHero1)
    remote.teamManager:setHeroUpOrder(2, self._selectSkillHero2)
end

function QUIDialogMetalCityTeamArrangement:viewDidAppear()
	QUIDialogMetalCityTeamArrangement.super.viewDidAppear(self)
	self._arrangement:viewDidAppear()
	self:addBackEvent(false)

	self._ccbOwner.node_teamField:addChild(self._widgetHeroArray)

	-- avatar caches to speed up update
	for i = 1, 4 do -- main hero
		local avatar = QUIWidgetHeroInformation.new() 
		self._ccbOwner["hero"..i]:addChild(avatar)
		avatar:setVisible(false)
        avatar:setBackgroundVisible(false)
	    avatar:setNameVisible(false)
	    avatar:setStarVisible(false)

	    table.insert(self._heroAvatars, avatar)
	end

	self:setTrailInfo()

	local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    if animationManager ~= nil then 
		animationManager:stopAnimation()
    end
end

function QUIDialogMetalCityTeamArrangement:selectGodarmSkill(slot)
	if slot and self._ccbOwner["node_skill_select"..slot] then
		self._ccbOwner["node_skill_select"..slot]:setVisible(true)
	end
	if slot and self._ccbOwner["sp_team_godarm_"..slot] then
		self._ccbOwner["sp_team_godarm_"..slot]:setVisible(true)
	end	
end

function QUIDialogMetalCityTeamArrangement:viewWillDisappear()
	QUIDialogMetalCityTeamArrangement.super.viewWillDisappear(self)
	self._arrangement:viewWillDisappear()

	self:removeBackEvent()

    if self._widgetHeroArrayProxy then
	  	self._widgetHeroArrayProxy:removeAllEventListeners()
	  	self._widgetHeroArrayProxy = nil
	end
	if self._forceUpdate then
		self._forceUpdate:stopUpdate()
		self._forceUpdate = nil
	end
	if self._effectHandler ~= nil then
		scheduler.unscheduleGlobal(self._effectHandler)
		self._effectHandler = nil
	end
	if self._handleCombinedSkill then
		scheduler.unscheduleGlobal(self._handleCombinedSkill)
		self._handleCombinedSkill = nil
	end

	if self._effectCombination then
		self._effectCombination:stopAnimation()
		self._effectCombination = nil
	end

	local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    if animationManager ~= nil then 
		animationManager:stopAnimation()
    end
    
	if self._animationScheduler ~= nil then
		scheduler.unscheduleGlobal(self._animationScheduler)
		self._animationScheduler = nil
	end
end

function QUIDialogMetalCityTeamArrangement:updateLockState(index)
	self._selectIndex = index
	self._unlockedSlot = self._arrangement:getUnlockSlots(self._selectIndex, self._selectTrialNum)
	print("QUIDialogMetalCityTeamArrangement--updateLockState-",self._unlockedSlot)
	if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		self._ccbOwner.node_helper:setVisible(app.unlock:getUnlockHelper(false, nil))
		-- self._ccbOwner.node_bg_godarm:setVisible(false)
		for i = 1, 4 do
			self._ccbOwner["light"..i]:removeAllChildren()
			if i > self._unlockedSlot then
				self._ccbOwner["unlock"..i]:setVisible(true)
				self._ccbOwner["disable"..i]:setVisible(true)
				self._ccbOwner["enable"..i]:setVisible(false)
			else
				self._ccbOwner["unlock"..i]:setVisible(false)
				self._ccbOwner["disable"..i]:setVisible(false)
				self._ccbOwner["enable"..i]:setVisible(true)
			end
		end

		for _, avatar in ipairs(self._heroAvatars) do
			avatar:setVisible(false)
		end
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._ccbOwner.node_bg_godarm:setVisible(true)
		for i=1,4 do
			self._ccbOwner["lightH"..i]:removeAllChildren()
			self._ccbOwner["sp_team1_"..i]:setVisible(false)
			self._ccbOwner["sp_team2_"..i]:setVisible(false)
			self._ccbOwner["sp_team3_"..i]:setVisible(false)
			self._ccbOwner["sp_team1_"..i]:setPositionY(260)
			self._ccbOwner["sp_team2_"..i]:setPositionY(260)
			self._ccbOwner["sp_team3_"..i]:setPositionY(260)
			self._ccbOwner["node_skill"..i]:setVisible(false)
			self._ccbOwner["node_skill"..i]:setPositionY(232)
			self._ccbOwner["green"..i]:setVisible(true)	
			self._ccbOwner["green"..i]:setPositionY(40)
			self._ccbOwner["green"..i]:setDisplayFrame(QSpriteFrameByKey("godarm_arrangement_bg", 3))
			if i > self._unlockedSlot then
				local unlockLevel = app.unlock:getConfigByKey("UNLOCK_GOD_ARM_"..self._selectTrialNum.."_"..i).team_level
				self._ccbOwner["unlockH"..i]:setString(unlockLevel.." 级解锁")
				self._ccbOwner["unlockH"..i]:setVisible(true)
				self._ccbOwner["disableH"..i]:setVisible(false)
				makeNodeFromNormalToGray(self._ccbOwner["green"..i])				
			else
				self._ccbOwner["node_unlock"..i]:setVisible(false)
				self._ccbOwner["unlockH"..i]:setVisible(false)
				self._ccbOwner["disableH"..i]:setVisible(false)	
				makeNodeFromGrayToNormal(self._ccbOwner["green"..i])		
			end		
		end
		for _, avatar in ipairs(self._heroHelperAvatars) do
			avatar:setVisible(false)
		end			
	else
		self._ccbOwner.node_helper:setVisible(true)
		-- self._ccbOwner.node_bg_godarm:setVisible(false)
		local helpIndex = 0
		for i = 1, 4 do
			self._ccbOwner["lightH"..i]:removeAllChildren()
			self._ccbOwner["sp_team1_"..i]:setVisible(false)
			self._ccbOwner["sp_team2_"..i]:setVisible(false)
			self._ccbOwner["sp_team3_"..i]:setVisible(false)
			self._ccbOwner["sp_team1_"..i]:setPositionY(260)
			self._ccbOwner["sp_team2_"..i]:setPositionY(260)
			self._ccbOwner["sp_team3_"..i]:setPositionY(260)
			self._ccbOwner["node_skill"..i]:setVisible(false)
			self._ccbOwner["node_skill"..i]:setPositionY(232)
			self._ccbOwner["green"..i]:setVisible(false)
			self._ccbOwner["green"..i]:setPositionY(-10)
			self._ccbOwner["green"..i]:setDisplayFrame(QSpriteFrameByKey("godarm_arrangement_bg", 2))
		end

		for i = 1, 4 do
			if i > self._unlockedSlot then
				local unlockLevel = self._arrangement:getUnlockLevel(i)		
				self._ccbOwner["unlockH"..i]:setString(unlockLevel.." 级解锁")
				self._ccbOwner["unlockH"..i]:setVisible(true)
				self._ccbOwner["disableH"..i]:setVisible(true)
				self._ccbOwner["green"..i]:setVisible(false)
			else
				self._ccbOwner["node_unlock"..i]:setVisible(false)
				self._ccbOwner["unlockH"..i]:setVisible(false)
				self._ccbOwner["disableH"..i]:setVisible(false)
				self._ccbOwner["green"..i]:setVisible(true)
			end
		end

		for _, avatar in ipairs(self._heroHelperAvatars) do
			avatar:setVisible(false)
		end
	end
	self._widgetHeroArray:setUnlockNumber(self._unlockedSlot)
end

function QUIDialogMetalCityTeamArrangement:update(heroList, victoryId, callback)
	self:updateLockState(self._widgetHeroArray:getSelectIndex())
	local slot = 1
	for k, v in pairs(heroList) do
		if v.trialNum == self._selectTrialNum then 
			local avatar = nil
			if v.index == remote.teamManager.TEAM_INDEX_HELP then
				avatar = self._heroHelperAvatars[slot]
				avatar:setInfotype("QUIDialogMetalCityTeamArrangement")
				avatar:setAvatar(v.actorId, AVATAR_SCALE)
			    avatar:setStarVisible(false)		
			    avatar:setNameVisible(false)				
			    avatar:setHpMp(v.hpScale, v.mpScale)
			    avatar:hideGodarmInfo()
				
				self._ccbOwner["node_skill"..slot]:setVisible(true)
				local skillConfig = remote.herosUtil:getManualSkillsByActorId(v.actorId)
				if skillConfig ~= nil then
					local texture = CCTextureCache:sharedTextureCache():addImage(skillConfig.icon)
					self._ccbOwner["sp_skill"..slot]:setTexture(texture)
				    local size = texture:getContentSize()
				    local rect = CCRectMake(0, 0, size.width, size.height)
				    self._ccbOwner["sp_skill"..slot]:setTextureRect(rect)
				end
			else
				avatar = self._heroAvatars[slot]
				avatar:setInfotype("QUIDialogMetalCityTeamArrangement")
				avatar:setAvatar(v.actorId, AVATAR_SCALE)
			    avatar:setStarVisible(false)				
			    avatar:setHpMp(v.hpScale, v.mpScale)
			    avatar:setNameVisible(false)				
			end	

			avatar:setVisible(true)

		    -- play victory effect for selected hero and sound
		    if victoryId == v.actorId then
		    	avatar:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY)
				local effect = QUIWidgetAnimationPlayer.new()
				if v.index == 1 then
					self._ccbOwner["light"..slot]:addChild(effect)
				else
					self._ccbOwner["lightH"..slot]:addChild(effect)
				end
				effect:playAnimation("effects/ChooseHero.ccbi")

			    local heroInfo = remote.herosUtil:getHeroByID(v.actorId)
			    local preparation = nil
			    if heroInfo.skinId then
			    	local skinConfig = db:getHeroSkinConfigByID(heroInfo.skinId)
			    	preparation = skinConfig.preparation
			    end
			    if not preparation then
			    	local heroDisplay = db:getCharacterByID(v.actorId)
			    	preparation = heroDisplay.preparation
			    end
				app.sound:playSound(preparation)
				
				--如果是援助魂师浮动显示属性加成
				if v.index == remote.teamManager.TEAM_INDEX_HELP then
					local heroModel = remote.herosUtil:createHeroPropById(v.actorId)
					local teams = self._widgetHeroArray:getSelectTeam(self._selectTrialNum)
	  				local mainTeamNum = teams[1] ~= nil and #teams[1] or 0
	  				self._effectProps = {}
					self:playProp(avatar, "主力生命+", heroModel:getMaxHp()*mainTeamNum/4)
					self:playProp(avatar, "主力攻击+", heroModel:getMaxAttack()*mainTeamNum/4)
					self:playProp(avatar, "主力物理防御+", heroModel:getMaxArmorPhysical()*mainTeamNum/4)
					self:playProp(avatar, "主力法术防御+", heroModel:getMaxArmorMagic()*mainTeamNum/4)
					self:playProp(avatar, "主力物理穿透+", heroModel:getMaxPhysicalPenetration()*mainTeamNum/4)
					self:playProp(avatar, "主力法术穿透+", heroModel:getMaxMagicPenetration()*mainTeamNum/4)
					self:playProp(avatar, "主力命中+", heroModel:getMaxHit()*mainTeamNum/4)
					self:playProp(avatar, "主力闪避+", heroModel:getMaxDodge()*mainTeamNum/4)
					self:playProp(avatar, "主力暴击+", heroModel:getMaxCrit()*mainTeamNum/4)
					self:playProp(avatar, "主力抗暴+", heroModel:getMaxCriReduce()*mainTeamNum/4)
					self:playProp(avatar, "主力格挡+", heroModel:getMaxBlock()*mainTeamNum/4)
					self:playProp(avatar, "主力攻速+", heroModel:getMaxHaste()*mainTeamNum/4)
					self:playAllProp()
				end

				if self._handleCombinedSkill then
					scheduler.unscheduleGlobal(self._handleCombinedSkill)
					self._handleCombinedSkill = nil
				end
				local index = v.index
				self._handleCombinedSkill = scheduler.performWithDelayGlobal(function()
					callback()
				end, 0)
		    end
		    slot = slot + 1
		end
	end

	if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
		self._selectSkillHero1 = remote.teamManager:getHeroUpOrder(1)
		self._selectSkillHero2 = remote.teamManager:getHeroUpOrder(2)

		local orderActorIds = {}
		if self._selectTrialNum == 1 then
			orderActorIds = self._selectSkillHero1
		else
			orderActorIds = self._selectSkillHero2
		end			
		for k, v in pairs(heroList) do
			self._ccbOwner["sp_team1_"..k]:setVisible(false)
			self._ccbOwner["sp_team2_"..k]:setVisible(false)
			self._ccbOwner["sp_team3_"..k]:setVisible(false)
			self._ccbOwner["node_skill_select"..k]:setVisible(false)
			if orderActorIds[1] == v.actorId then
				self._ccbOwner["sp_team1_"..k]:setVisible(true)
				self._ccbOwner["node_skill_select"..k]:setVisible(true)
			elseif orderActorIds[2] == v.actorId then
				self._ccbOwner["sp_team2_"..k]:setVisible(true)
				self._ccbOwner["node_skill_select"..k]:setVisible(true)
			end
		end
	end

	local force = 0
	for _,v in pairs(self._allHeroList) do
		if v.trialNum == self._selectTrialNum then
			if v.index == remote.teamManager.TEAM_INDEX_MAIN then
				force = force + v.force
			elseif v.index == remote.teamManager.TEAM_INDEX_HELP then
				force = force + v.force
			end
		end
	end

	--显示精灵在界面上
	if app.unlock:checkLock("UNLOCK_SOUL_SPIRIT", false) then
		for i = 1, 2 do
			if self._widgetSoulSpirit[i] then
				self._widgetSoulSpirit[i]:removeFromParent()
				self._widgetSoulSpirit[i] = nil
			end
		end
		--计算当前的精灵列表的战力
		local soulSpiritId = {}
		for _,v in pairs(self._allSpiritList) do
			if v.trialNum == self._selectTrialNum then
				if v.index == remote.teamManager.TEAM_INDEX_MAIN then
					-- soulSpiritId = v.soulSpiritId
					table.insert(soulSpiritId,v.soulSpiritId)
				end
			end
		end
		local soulForce = remote.soulSpirit:countForceBySpiritIds(soulSpiritId)
		force = force + soulForce
		-- if soulSpiritId ~= 0 then self._selectTrialNum
		for ii,v in pairs(soulSpiritId) do
			self._widgetSoulSpirit[ii] = QUIWidgetActorDisplay.new(v)
			self._widgetSoulSpirit[ii]:setScaleX(-AVATAR_SCALE)
			self._widgetSoulSpirit[ii]:setScaleY(AVATAR_SCALE)
			self._ccbOwner["hero_soul"..ii]:addChild(self._widgetSoulSpirit[ii])

			if victoryId == v then
				local heroDisplay = db:getCharacterByID(v)
				app.sound:playSound(heroDisplay.preparation)
				self._handleCombinedSkill = scheduler.performWithDelayGlobal(function()
					callback()
				end, 0)
			end
		end
	end
	
	for i=1,4 do
		self._ccbOwner["sp_team_godarm_"..i]:setVisible(false)
	end	
 	--显示神器在界面上
	if app.unlock:checkLock("UNLOCK_GOD_ARM", false) then
		-- local slot = 1
		for k, v in pairs(self._shangzhengGodarms) do
			--计算当前的精灵列表的战力`
			local avatar = nil
			if v.index == remote.teamManager.TEAM_INDEX_GODARM and v.trialNum == self._selectTrialNum  then
				force = force + v.force
				if self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM and v.pos ~= 5 then
					local slot = v.pos or 1
					avatar = self._heroHelperAvatars[slot]
					avatar:setInfotype("QUIDialogMetalCityTeamArrangement")
					avatar:setAvatar(v.godarmId, AVATAR_SCALE)
				    avatar:setStarVisible(false)	
	    			avatar:setVisible(true)
					avatar:setNameVisible(false)
					avatar:setGodarmInfo(v.godarmId)	
					avatar:setHpMp()

					self:selectGodarmSkill(slot)
					self._ccbOwner["node_skill"..slot]:setVisible(true)
					self._ccbOwner["node_skill"..slot]:setPositionY(250)
					local gradeConfig = db:getGradeByHeroActorLevel(v.godarmId, v.grade)
					if gradeConfig ~= nil and gradeConfig.god_arm_skill_sz then
				        local skillIds = string.split(gradeConfig.god_arm_skill_sz, ":")
	        			local skillConfig = db:getSkillByID(tonumber(skillIds[1]))
	        			if skillConfig then
							local texture = CCTextureCache:sharedTextureCache():addImage(skillConfig.icon)
							self._ccbOwner["sp_skill"..slot]:setTexture(texture)
						    local size = texture:getContentSize()
						    local rect = CCRectMake(0, 0, size.width, size.height)
						    self._ccbOwner["sp_skill"..slot]:setTextureRect(rect)
						end
					end	
					if victoryId == v.godarmId then
						self._handleCombinedSkill = scheduler.performWithDelayGlobal(function()
							callback()
						end, 0)							
					end					
				end
				-- slot = slot + 1		
			end	
		end	
	end
	local change = force - self._force
	if force ~= self._force and victoryId then
		self:nodeEffect(self._ccbOwner.force)
	end

	self._forceUpdate:addUpdate(self._force, force, handler(self, self._onForceUpdate), NUMBER_TIME)

	self._force = force
	self:updateAssistSkill()

	self:checkTeamCountTip()
end

function QUIDialogMetalCityTeamArrangement:setTrailInfo()
	self._ccbOwner.widget_node_team:setVisible(false)
	self._ccbOwner.sp_inherit:setVisible(false)
	self._ccbOwner.node_pvp:setVisible(false)
	local path = ""
	if self._selectTrialNum == 1 then
		QSetDisplayFrameByPath(self._ccbOwner.sp_words_zhanli, "ui/tower/firstteam_zi.png")
	elseif self._selectTrialNum == 2 then
		QSetDisplayFrameByPath(self._ccbOwner.sp_words_zhanli, "ui/tower/secondteam_zi.png")
	end
	self._ccbOwner.tf_defens_force:setPositionX(270)

	if self._isStromArena and self._isDefence then
		local teamV1 = remote.teamManager:getTeamByKey(self._arrangements[1]:getTeamKey(), false)
		local teamV2 = remote.teamManager:getTeamByKey(self._arrangements[2]:getTeamKey(), false)
	    local team1Main = teamV1:getTeamActorsByIndex(1)
	    local team1Spirit = teamV1:getTeamSpiritsByIndex(1)
	    local team1Help = teamV1:getTeamActorsByIndex(2)
	    local team1Skill = teamV1:getTeamSkillByIndex(2)
	    local team1GodArm = teamV1:getTeamGodarmByIndex(5)
	    local team2Main = teamV2:getTeamActorsByIndex(1)
	    local team2Spirit = teamV2:getTeamSpiritsByIndex(1)
	    local team2Help = teamV2:getTeamActorsByIndex(2)
	    local team2Skill = teamV2:getTeamSkillByIndex(2)
	    local team2GodArm = teamV2:getTeamGodarmByIndex(5)
    
	    self._fighterInfo.heros = {}
	    self._fighterInfo.subheros = {}
	    self._fighterInfo.godArm1List = {}
	    self._fighterInfo.main1Heros = {}
	    self._fighterInfo.sub1heros = {}
	    self._fighterInfo.godArm2List = {}
	    self._fighterInfo.soulSpirit = {}
	    self._fighterInfo.soulSpirit2 = {}
	    
	    local insertHeroFunc = function (srcHeros, destHeros)
	        if srcHeros ~= nil then
	            for _,actorId in pairs(srcHeros) do
	                table.insert(destHeros, remote.herosUtil:getHeroByID(actorId))
	            end
	        end
	    end

	    insertHeroFunc(team1Main, self._fighterInfo.heros)
	    insertHeroFunc(team1Help, self._fighterInfo.subheros)
	    insertHeroFunc(team2Main, self._fighterInfo.main1Heros)
	    insertHeroFunc(team2Help, self._fighterInfo.sub1heros)

	    local insertGodArmFunc = function (srcGodArms, destGodArms)
	        if srcGodArms ~= nil then
	            for _, godArmId in pairs(srcGodArms) do
        			local godArmInfo = remote.godarm:getGodarmById(godArmId)
	                table.insert(destGodArms, godArmInfo)
	            end
	        end
	    end
	        
	    insertGodArmFunc(team1GodArm, self._fighterInfo.godArm1List)
	    insertGodArmFunc(team2GodArm, self._fighterInfo.godArm2List)

	    -- if team1Spirit[1] then
	    for _, v in pairs(team1Spirit or {}) do
	    	table.insert(self._fighterInfo.soulSpirit, remote.soulSpirit:getMySoulSpiritInfoById(v))
	    end

	    for _, v in pairs(team2Spirit or {}) do
	    	table.insert(self._fighterInfo.soulSpirit2, remote.soulSpirit:getMySoulSpiritInfoById(v))
	    end

	    -- if team2Spirit[1] then
	    -- 	self._fighterInfo.soulSpirit2 = remote.soulSpirit:getMySoulSpiritInfoById(team2Spirit[1])
	    -- end
	    self._fighterInfo.activeSubActorId = team1Skill[1]
	    self._fighterInfo.active1SubActorId = team1Skill[2]
	    self._fighterInfo.activeSub2ActorId = team2Skill[1]
	    self._fighterInfo.active1Sub2ActorId = team2Skill[2]
	end

	if q.isEmpty(self._fighterInfo) then
		self._ccbOwner.node_trail:setVisible(false)
		return 
	end

	local widget = self._widgetClass or "QUIWidgetMetalCityTeamBossInfo"
	local width = 0
	for i = 1, 2 do
		if self._trailBossInfo[i] == nil then
			local widgetClass = import(app.packageRoot .. ".ui.widgets." .. widget)
			self._trailBossInfo[i] = widgetClass.new()
			if self._isTotemChallenge then
				local userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo() 
			    if userInfoDict then
			    	if (i == 1 and userInfoDict.team1IsQuickPass) or (i == 2 and userInfoDict.team2IsQuickPass) then
			    		self._trailBossInfo[i]._ccbOwner.tf_tip:setString("已神罚")
			    		self._trailBossInfo[i]._ccbOwner.tf_tip:setColor(COLORS.e)
			    	else
			    		self._trailBossInfo[i]._ccbOwner.tf_tip:setString("可上阵")
			    		self._trailBossInfo[i]._ccbOwner.tf_tip:setColor(COLORS.c)
			    	end
			    end
			   end
			self._trailBossInfo[i]:addEventListener("EVENT_BOSSINFO_CLICK", handler(self, self._onTiggerClickTrail))
			self._ccbOwner.node_trail:addChild(self._trailBossInfo[i])
		end
		self._trailBossInfo[i]:setInfo(self._fighterInfo, i, self._isDefence)
		self._trailBossInfo[i]:setButtonStated(self._selectTrialNum == i) 
		self._trailBossInfo[i]:setPositionX(width)

		width = width + self._trailBossInfo[i]:getContentSize().width + 6
	end

	--set pvp icon
	local teamVO = remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)
	if ENABLE_PVP_FORCE and teamVO:getIsPVP() then
		self._ccbOwner.node_pvp:setVisible(true)
	end
end

function QUIDialogMetalCityTeamArrangement:playProp(avatar,desc,value)
	if value == nil then value = 0 end
	value = math.floor(value)
	if value > 0 then
		-- self:playPropEffect(desc..value)
		table.insert(self._effectProps, desc..value)
	end
end
function QUIDialogMetalCityTeamArrangement:playAllProp()
	if #self._effectProps > 0 then
		local effect = QUIWidgetAnimationPlayer.new()
		effect:setPosition(0,0)
		self._ccbOwner.node_effect:addChild(effect)
		effect:playAnimation("ccb/effects/Arena_tips.ccbi", function(ccbOwner)
				-- ccbOwner.tf_value:setString(value)
				local i = 1
				while ccbOwner["tf_value"..i] ~= nil do
					ccbOwner["tf_value"..i]:setString("")
					i = i + 1
				end
				for index,value in ipairs(self._effectProps) do
					if ccbOwner["tf_value"..index] ~= nil then
						ccbOwner["tf_value"..index]:setString(value)
					end
				end
	        end,function()
	        	if self:safeCheck() then
	        		effect:removeFromParentAndCleanup(true)
	        	end
	        end)
	end
end

function QUIDialogMetalCityTeamArrangement:nodeEffect(node)
	if node ~= nil then
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
	    local ccsequence = CCSequence:create(actionArrayIn)
		node:runAction(ccsequence)
	end
end

function QUIDialogMetalCityTeamArrangement:_onHeroChanged(event)
	self._heroList = {}
	self._spiritList = {}
	if event.hero then
		self._heroList = event.hero
	end
	if event.soulSpirits then
		self._spiritList = event.soulSpirits
	end

	self._shangzhengGodarms = {}
	if event.godarmList then
		self._shangzhengGodarms = event.godarmList
	end	
	if self._teamIndex == remote.teamManager.TEAM_INDEX_MAIN then
		table.sort(self._heroList, function (x, y)
			if x.hatred == y.hatred then
				return x.force > y.force
			end
			return x.hatred > y.hatred
		end )

		-- table.sort(self._spiritList, function (x, y)
		-- 	return x.force < y.force
		-- end )

	else
		table.sort(self._heroList, function (x, y)
			if x.force ~= y.force then
				return x.force > y.force
			else
				return false
			end
		end )
	end

	self:update(self._heroList, event.victoryId, function ()
		if not self:safeCheck() then
			return
		end

		local unlockMain1Count = self._arrangements[1]:getUnlockSlots(remote.teamManager.TEAM_INDEX_MAIN, self._selectTrialNum)
		local unlockHelp1Count = self._arrangements[1]:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP, self._selectTrialNum)
		local unlockGodarm1Count = self._arrangements[1]:getUnlockSlots(remote.teamManager.TEAM_INDEX_GODARM, self._selectTrialNum)

		local unlockMain2Count = self._arrangements[2]:getUnlockSlots(remote.teamManager.TEAM_INDEX_MAIN, self._selectTrialNum)
		local unlockHelp2Count = self._arrangements[2]:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP, self._selectTrialNum)
		local unlockGodarm2Count = self._arrangements[2]:getUnlockSlots(remote.teamManager.TEAM_INDEX_GODARM, self._selectTrialNum)

		local mainTeam1Count = 0 
		local help1Count = 0 
		local godarm1Count = 0
		local mainTeam2Count = 0 
		local help2Count = 0 
		local godarm2Count = 0

		for _, value in pairs(self._allHeroList) do
			if value.trialNum == 1 then
				if value.index == remote.teamManager.TEAM_INDEX_MAIN then
					mainTeam1Count = mainTeam1Count + 1
				elseif value.index == remote.teamManager.TEAM_INDEX_HELP then
					help1Count = help1Count + 1
				end
			elseif value.trialNum == 2 then
				if value.index == remote.teamManager.TEAM_INDEX_MAIN then
					mainTeam2Count = mainTeam2Count + 1
				elseif value.index == remote.teamManager.TEAM_INDEX_HELP then
					help2Count = help2Count + 1
				end
			end
		end
		local spirit1Count = 0
		local spirit2Count = 0
		for _, value in pairs(self._allSpiritList) do
			if value.trialNum == 1 and value.index ~= 0 then
				spirit1Count = spirit1Count + 1
			end
			if value.trialNum == 2 and value.index ~= 0 then
				spirit2Count = spirit2Count + 1
			end
		end

		for _, value in pairs(self._godarmList) do
			if value.trialNum == 1 and value.index == remote.teamManager.TEAM_INDEX_GODARM then
				godarm1Count = godarm1Count + 1
			end

			if value.trialNum == 2 and value.index == remote.teamManager.TEAM_INDEX_GODARM then
				godarm2Count = godarm2Count + 1
			end
		end

		if self._selectTrialNum == 1 then
			local teamV1 = remote.teamManager:getTeamByKey(self._arrangements[1]:getTeamKey(), false)
			if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
				if mainTeam1Count == unlockMain1Count then
					if spirit1Count < teamV1:getSpiritsMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN) then
						self._widgetHeroArray:_onTriggerSoul(CCControlEventTouchUpInside)
					elseif help1Count == unlockHelp1Count then
						if remote.godarm:checkGodArmUnlock() then
							self._widgetHeroArray:onTriggerGodarm()
						else
							self:_onTiggerClickTrail({trialNum = 2})
						end
					elseif godarm1Count == unlockGodarm1Count then
						self:_onTiggerClickTrail({trialNum = 2})
					else
						self._widgetHeroArray:onTriggerHelper()
					end
				end
			elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
				if remote.godarm:checkGodArmUnlock() then
					if help1Count == unlockHelp1Count then
						if godarm1Count == 0 then
							self._widgetHeroArray:onTriggerGodarm()
						elseif unlockMain2Count > mainTeam2Count then
							self:_onTiggerClickTrail({trialNum = 2})
						end
					end							
				else
					if help1Count == unlockHelp1Count then
						if mainTeam1Count == 0 then
							self._widgetHeroArray:onTriggerMain()
						elseif unlockMain2Count > mainTeam2Count then
							self:_onTiggerClickTrail({trialNum = 2})
						end
					end					
				end
			elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
				if godarm1Count == unlockGodarm1Count then
					if mainTeam1Count == 0 then
						self._widgetHeroArray:onTriggerMain()
					elseif unlockMain2Count > mainTeam2Count then
						self:_onTiggerClickTrail({trialNum = 2})
					end
				end
			end
		elseif self._selectTrialNum == 2 then
			local teamV2 = remote.teamManager:getTeamByKey(self._arrangements[2]:getTeamKey(), false)
			if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
				if mainTeam2Count == unlockMain2Count then
					if spirit2Count < teamV2:getSpiritsMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN) then
						self._widgetHeroArray:_onTriggerSoul(CCControlEventTouchUpInside)
					elseif unlockHelp2Count > help2Count then
						self._widgetHeroArray:onTriggerHelper()
					elseif unlockGodarm2Count > godarm2Count and remote.godarm:checkGodArmUnlock() then
						self._widgetHeroArray:onTriggerGodarm()
					end
				end
			elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
				if remote.godarm:checkGodArmUnlock() then
					if help2Count == unlockHelp2Count then
						if unlockGodarm2Count > godarm2Count then
							self._widgetHeroArray:onTriggerGodarm()
						elseif unlockMain2Count > mainTeam2Count then
							self._widgetHeroArray:onTriggerMain()
						end
					end	
				end				
			end
		end

	end)
end

function QUIDialogMetalCityTeamArrangement:checkTeamCountTip()
	local unlockMain1Count = self._arrangements[1]:getUnlockSlots(remote.teamManager.TEAM_INDEX_MAIN, 1)
	local unlockHelp1Count = self._arrangements[1]:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP, 1)

	local unlockMain2Count = self._arrangements[2]:getUnlockSlots(remote.teamManager.TEAM_INDEX_MAIN, 2)
	local unlockHelp2Count = self._arrangements[2]:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP, 2)

	local teamData1 = self:_getSelectTeams(1)
	local teamData2 = self:_getSelectTeams(2)
	
	local selectTeam1Num = #teamData1[1].actorIds + #teamData1[2].actorIds
	local selectTeam2Num = #teamData2[1].actorIds + #teamData2[2].actorIds
	local haveHeros = self._arrangement:getHeroes()
	local lastHeros = #haveHeros - selectTeam1Num - selectTeam2Num


	local userInfoDict
	if self._isTotemChallenge then
		userInfoDict = remote.totemChallenge:getTotemUserDungeonInfo() 
	end
	local tip1 = false
	if (selectTeam1Num < unlockMain1Count + unlockHelp1Count and lastHeros > 0) or (userInfoDict and userInfoDict.team1IsQuickPass) then
		tip1 = true
	end
	local tip2 = false
	if (selectTeam2Num < unlockMain2Count + unlockHelp2Count and lastHeros > 0) or (userInfoDict and userInfoDict.team2IsQuickPass) then
		tip2 = true
	end
	if self._trailBossInfo[1] then
		self._trailBossInfo[1]:setTipState(tip1)
	end
	if self._trailBossInfo[2] then
		self._trailBossInfo[2]:setTipState(tip2)
	end
end

function QUIDialogMetalCityTeamArrangement:_onHeroChangedTab(event)
	-- @qinyuanji, stop combination skill prompt animation
	if self._effectCombination then
		self._effectCombination:stopAnimation()
		self._effectCombination = nil
	end
	if event then
		self._teamIndex = event.index or 1
	end

	-- Load helper avatar when moving to that screen to elevate performance
	if not next(self._heroHelperAvatars) then
		for i = 1, 4 do -- helper
			local avatar = QUIWidgetHeroInformation.new()
			self._ccbOwner["heroH"..i]:setPositionY(130)
			self._ccbOwner["heroH"..i]:addChild(avatar) 
			avatar:setVisible(false)
	        avatar:setBackgroundVisible(false)
		    avatar:setNameVisible(false)
		    avatar:setStarVisible(false)
		    avatar:hideGodarmInfo()
	    	-- avatar:setScale(0.9)

		    table.insert(self._heroHelperAvatars, avatar)
		end
	else
		for i = 1, 4 do -- helper
			if self._teamIndex ~= remote.teamManager.TEAM_INDEX_GODARM then
				self._ccbOwner["heroH"..i]:setPositionY(145)
			else
				self._ccbOwner["heroH"..i]:setPositionY(195)
			end
		end		
	end
	self._ccbOwner.node_btn_confirm:setVisible(false)
	if self._teamIndex == remote.teamManager.TEAM_INDEX_MAIN then 
		self._ccbOwner.node_left:setVisible(true)
		self._ccbOwner.node_right:setVisible(false)
		self._ccbOwner.node_btn_battle_aid:setVisible(false) 
		local showBattleBtn = self._selectTrialNum == 2
		self._ccbOwner.node_btn_next:setVisible(not showBattleBtn)
		if self._isDefence then
			self._ccbOwner.node_btn_battle:setVisible(false)
			self._ccbOwner.node_btn_confirm:setVisible(true)
		else
			self._ccbOwner.node_btn_confirm:setVisible(false)
			self._ccbOwner.node_btn_battle:setVisible(showBattleBtn)
		end
		self:showLeftBtn(false)
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP then
		self._ccbOwner.node_left:setVisible(remote.godarm:checkGodArmUnlock())
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
		self._ccbOwner.node_btn_next:setVisible(false)
		self._ccbOwner.node_btn_battle:setVisible(false)	
		self:showLeftBtn(false)	
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._ccbOwner.node_left:setVisible(false)
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
		self._ccbOwner.node_btn_next:setVisible(false)
		self._ccbOwner.node_btn_battle:setVisible(false)
		self:showLeftBtn(true)
	end
	local animationName
	if self._teamIndex == remote.teamManager.TEAM_INDEX_MAIN and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
		animationName = "2-1"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_MAIN and self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		animationName = "3-1"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP and self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		animationName = "1-2"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP and self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._ccbOwner.sp_godarm_bg:setVisible(true)
		animationName = "3-2"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM and self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then 
		animationName = "1-3"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
		self._ccbOwner.sp_helper_bg:setVisible(true)
		animationName = "2-3"	
	end
	print("切换tab-------------",self._teamIndex,self._selectIndex,animationName,showGodarmbg)
	if animationName then
		local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	    if animationManager ~= nil then 
			animationManager:runAnimationsForSequenceNamed(animationName)
	    end

		if self._animationScheduler ~= nil then
			scheduler.unscheduleGlobal(self._animationScheduler)
			self._animationScheduler = nil
		end

		self._animationScheduler = scheduler.performWithDelayGlobal(function ( ... )
			self._ccbOwner.sp_main_bg:setVisible(animationName == "2-1" or animationName == "3-1")
			self._ccbOwner.sp_helper_bg:setVisible((animationName == "1-2" or animationName == "3-2"))
			self._ccbOwner.sp_godarm_bg:setVisible((animationName == "1-3" or animationName == "2-3"))
		end, 0.2)
	end
end

function QUIDialogMetalCityTeamArrangement:updateAssistSkill()
	for i = 1, 4, 1 do
		self._ccbOwner["node_skill_"..i]:setVisible(false)
		self._ccbOwner["effect_"..i]:setVisible(false)
		self._ccbOwner["node_skill_"..i]:setPositionY(232)
	end

	local index = 1
	while self._heroList[index] do 
		local actorId = self._heroList[index].actorId
		local assistSkill, haveAssistHero = remote.herosUtil:checkHeroHaveAssistHero(actorId)
		if assistSkill then
			self._ccbOwner["node_skill_"..index]:setVisible(true)
			local skillInfo = remote.herosUtil:getManualSkillsByActorId(actorId)

			local skillIcon = CCSprite:create()
			self._ccbOwner["skill_icon_"..index]:addChild(skillIcon)
			skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(skillInfo.icon))
			skillIcon:setScale(0.9)
			if haveAssistHero then
				makeNodeFromGrayToNormal(self._ccbOwner["skill_icon_"..index])
				self._ccbOwner["effect_"..index]:setVisible(true)
			else
				makeNodeFromNormalToGray(self._ccbOwner["skill_icon_"..index])
				self._ccbOwner["effect_"..index]:setVisible(false)
			end
		end
		index = index + 1
	end
end

function QUIDialogMetalCityTeamArrangement:_checkNewCombinedSkill(callback)
	local combinedSkill = 1

	if callback then
		if animationPlayed then
			scheduler.performWithDelayGlobal(function() 
					if self:safeCheck() then
						callback()
					end
				end, 2.0)
		else
			callback()
		end
	end
end

function QUIDialogMetalCityTeamArrangement:_onForceUpdate(value)
    local word = nil
    if value >= 1000000 then
      word = tostring(math.floor(value/10000)).."万"
    else
      word = math.floor(value)
    end
    self._ccbOwner.tf_defens_force:setString(word)
    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(value,true)
    if fontInfo ~= nil then
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))
    end
end

function QUIDialogMetalCityTeamArrangement:_onTriggerClick1( )
	if self._heroList[1] then
		self._widgetHeroArray:removeSelectedHero(self._heroList[1].actorId)
		table.remove(self._heroList, 1)
		self:update(self._heroList)
	end
end

function QUIDialogMetalCityTeamArrangement:_onTriggerClick2( )
	if self._heroList[2] then
		self._widgetHeroArray:removeSelectedHero(self._heroList[2].actorId)
		table.remove(self._heroList, 2)
		self:update(self._heroList)
	end
end

function QUIDialogMetalCityTeamArrangement:_onTriggerClick3( )
	if self._heroList[3] then
		self._widgetHeroArray:removeSelectedHero(self._heroList[3].actorId)
		table.remove(self._heroList, 3)
		self:update(self._heroList)
	end
end

function QUIDialogMetalCityTeamArrangement:_onTriggerClick4( )
	if self._heroList[4] then
		self._widgetHeroArray:removeSelectedHero(self._heroList[4].actorId)
		table.remove(self._heroList, 4)
		self:update(self._heroList)
	end
end

function QUIDialogMetalCityTeamArrangement:_onTriggerClickSoul1( )
	if self._spiritList[1] then
		self._widgetHeroArray:removeSelectedSoulSpirit(self._spiritList[1].soulSpiritId)
		table.remove(self._spiritList, 1)
		self:update(self._heroList)
	end
end

function QUIDialogMetalCityTeamArrangement:_onTriggerClickSoul2( )
	local lockSoulNum = remote.soulSpirit:getTeamSpiritsMaxCount(true)
	if lockSoulNum < 2 then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTeamGuideTips",options = {soulTeamNum = 2}})
		return
	end

	if self._spiritList[2] then
		self._widgetHeroArray:removeSelectedSoulSpirit(self._spiritList[2].soulSpiritId)
		table.remove(self._spiritList, 2)
		self:update(self._heroList)
	end
end
function QUIDialogMetalCityTeamArrangement:_onTriggerClickH1( )
	if self._unlockedSlot < 1 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			if self._selectTrialNum == 1 then
				if self._isStromArena then 
					app.unlock:checkLock("UNLOCK_STORM_HELP_1", true)
				else
					app.unlock:checkLock("UNLOCK_METALCITY_HELP_1", true)
				end
			else
				if self._isStromArena then 
					app.unlock:checkLock("UNLOCK_STORM_HELP_2", true)
				else
					app.unlock:checkLock("UNLOCK_METALCITY_HELP_2", true)
				end
			end
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
			if self._selectTrialNum == 1 then
				app.unlock:getUnlockTeamGodarmHelp1(true)
			else
				app.unlock:getUnlockTeam2GodarmHelp1(true)
			end
		end
		return
	end	
	if self._selectIndex ~= remote.teamManager.TEAM_INDEX_GODARM then
		if self._heroList[1] then
			self._widgetHeroArray:removeSelectedHero(self._heroList[1].actorId)
			table.remove(self._heroList, 1)
			self:update(self._heroList)
		end
	else
		-- if self._shangzhengGodarms[1] then
		-- 	self._widgetHeroArray:removeSelectedGodarm(self._shangzhengGodarms[1].godarmId)
		-- 	table.remove(self._shangzhengGodarms, 1)
		-- 	self:update(self._heroList)
		-- end		
		for index,v in pairs(self._shangzhengGodarms) do
			if v.pos == 1 then
				self._widgetHeroArray:removeSelectedGodarm(self._shangzhengGodarms[index].godarmId)
				table.remove(self._shangzhengGodarms, index)
				self:update(self._heroList)
				break
			end
		end		
	end
end

function QUIDialogMetalCityTeamArrangement:_onTriggerClickH2( )
	if self._unlockedSlot < 2 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			if self._selectTrialNum == 1 then
				if self._isStromArena then 
					app.unlock:checkLock("UNLOCK_STORM_HELP_3", true)
				else
					app.unlock:checkLock("UNLOCK_METALCITY_HELP_3", true)
				end
			else
				if self._isStromArena then 
					app.unlock:checkLock("UNLOCK_STORM_HELP_4", true)
				else
					app.unlock:checkLock("UNLOCK_METALCITY_HELP_4", true)
				end
			end
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
			if self._selectTrialNum == 1 then
				app.unlock:getUnlockTeamGodarmHelp2(true)
			else
				app.unlock:getUnlockTeam2GodarmHelp2(true)
			end				
		end
		return
	end	
	if self._selectIndex ~= remote.teamManager.TEAM_INDEX_GODARM then
		if self._heroList[2] then
			self._widgetHeroArray:removeSelectedHero(self._heroList[2].actorId)
			table.remove(self._heroList, 2)
			self:update(self._heroList)
		end
	else
		-- if self._shangzhengGodarms[2] then
		-- 	self._widgetHeroArray:removeSelectedGodarm(self._shangzhengGodarms[2].godarmId)
		-- 	table.remove(self._shangzhengGodarms, 2)
		-- 	self:update(self._heroList)
		-- end		
		for index,v in pairs(self._shangzhengGodarms) do
			if v.pos == 2 then
				self._widgetHeroArray:removeSelectedGodarm(self._shangzhengGodarms[index].godarmId)
				table.remove(self._shangzhengGodarms, index)
				self:update(self._heroList)
				break
			end
		end		
	end
end

function QUIDialogMetalCityTeamArrangement:_onTriggerClickH3( )
	if self._unlockedSlot < 3 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			if self._selectTrialNum == 1 then
				if self._isStromArena then 
					app.unlock:checkLock("UNLOCK_STORM_HELP_5", true)
				else
					app.unlock:checkLock("UNLOCK_METALCITY_HELP_5", true)
				end
			else
				if self._isStromArena then 
					app.unlock:checkLock("UNLOCK_STORM_HELP_6", true)
				else
					app.unlock:checkLock("UNLOCK_METALCITY_HELP_6", true)
				end
			end
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
			if self._selectTrialNum == 1 then
				app.unlock:getUnlockTeamGodarmHelp3(true)
			else
				app.unlock:getUnlockTeam2GodarmHelp3(true)
			end	
		end
		return
	end	
	if self._selectIndex ~= remote.teamManager.TEAM_INDEX_GODARM then
		if self._heroList[3] then
			self._widgetHeroArray:removeSelectedHero(self._heroList[3].actorId)
			table.remove(self._heroList, 3)
			self:update(self._heroList)
		end
	else
		-- if self._shangzhengGodarms[3] then
		-- 	self._widgetHeroArray:removeSelectedGodarm(self._shangzhengGodarms[3].godarmId)
		-- 	table.remove(self._shangzhengGodarms, 3)
		-- 	self:update(self._heroList)
		-- end		
		for index,v in pairs(self._shangzhengGodarms) do
			if v.pos == 3 then
				self._widgetHeroArray:removeSelectedGodarm(self._shangzhengGodarms[index].godarmId)
				table.remove(self._shangzhengGodarms, index)
				self:update(self._heroList)
				break
			end
		end		
	end
end

function QUIDialogMetalCityTeamArrangement:_onTriggerClickH4( )
	if self._unlockedSlot < 4 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			if self._selectTrialNum == 1 then
				if self._isStromArena then 
					app.unlock:checkLock("UNLOCK_STORM_HELP_7", true)
				else
					app.unlock:checkLock("UNLOCK_METALCITY_HELP_7", true)
				end
			else
				if self._isStromArena then 
					app.unlock:checkLock("UNLOCK_STORM_HELP_8", true)
				else
					app.unlock:checkLock("UNLOCK_METALCITY_HELP_8", true)
				end
			end
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
			if self._selectTrialNum == 1 then
				app.unlock:getUnlockTeamGodarmHelp4(true)
			else
				app.unlock:getUnlockTeam2GodarmHelp4(true)
			end					
		end
		return
	end	
	if self._selectIndex ~= remote.teamManager.TEAM_INDEX_GODARM then
		if self._heroList[4] then
			self._widgetHeroArray:removeSelectedHero(self._heroList[4].actorId)
			table.remove(self._heroList, 4)
			self:update(self._heroList)
		end
	else
		-- if self._shangzhengGodarms[4] then
		-- 	self._widgetHeroArray:removeSelectedGodarm(self._shangzhengGodarms[4].godarmId)
		-- 	table.remove(self._shangzhengGodarms, 4)
		-- 	self:update(self._heroList)
		-- end		
		for index,v in pairs(self._shangzhengGodarms) do
			if v.pos == 4 then
				self._widgetHeroArray:removeSelectedGodarm(self._shangzhengGodarms[index].godarmId)
				table.remove(self._shangzhengGodarms, index)
				self:update(self._heroList)
				break
			end
		end		
	end
end

function QUIDialogMetalCityTeamArrangement:_onTriggerSkill1()

end

function QUIDialogMetalCityTeamArrangement:_onTriggerSkill2()

end

function QUIDialogMetalCityTeamArrangement:_onTriggerSkill3()

end

function QUIDialogMetalCityTeamArrangement:_onTriggerSkill4()

end

function QUIDialogMetalCityTeamArrangement:_onTriggerAssistSkill1()
	self:_openHeroDetail(self._heroList[1].actorId)
end

function QUIDialogMetalCityTeamArrangement:_onTriggerAssistSkill2()
	self:_openHeroDetail(self._heroList[2].actorId)
end

function QUIDialogMetalCityTeamArrangement:_onTriggerAssistSkill3()
	self:_openHeroDetail(self._heroList[3].actorId)
end

function QUIDialogMetalCityTeamArrangement:_onTriggerAssistSkill4()
	self:_openHeroDetail(self._heroList[4].actorId)
end

function QUIDialogMetalCityTeamArrangement:_openHeroDetail(actorId)
	local assistSkillInfo = QStaticDatabase:sharedDatabase():getAssistSkill(actorId)
	local skillInfo = remote.herosUtil:getUIHeroByID(actorId):getSkillBySlot(3)

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAssistHeroSkill", 
		options = {actorId = actorId, assistSkill = assistSkillInfo, skillSlotInfo = skillInfo}},{isPopCurrentDialog = false})
end

function QUIDialogMetalCityTeamArrangement:_onTriggerFight()
	if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP or self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._widgetHeroArray:onTriggerMain()
		return 
	end

	local teams = self._widgetHeroArray:getSelectTeam(1)
	if teams[remote.teamManager.TEAM_INDEX_MAIN] == nil then teams[remote.teamManager.TEAM_INDEX_MAIN] = {} end 
	if not self._arrangement:teamValidity(teams[remote.teamManager.TEAM_INDEX_MAIN], 1) then
		return 
	end

	if self._selectTrialNum == 2 then
		local teams = self._widgetHeroArray:getSelectTeam(2)
		if teams[remote.teamManager.TEAM_INDEX_MAIN] == nil then teams[remote.teamManager.TEAM_INDEX_MAIN] = {} end 
		if not self._arrangement:teamValidity(teams[remote.teamManager.TEAM_INDEX_MAIN], 2) then
			return 
		end
	end

	if self._selectTrialNum == 1 and self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		self:_onTiggerClickTrail({trialNum = 2})
		return
	end

	if self:checkTeamIsEmpty(1) == false then
		return
	end

	if self:checkTeamIsEmpty(2) == false then
		return
	end

	self:startBattle()
  	
end 

function QUIDialogMetalCityTeamArrangement:checkTeamIsEmpty(arrangementIndex)
	local teamVO = remote.teamManager:getTeamByKey(self._arrangements[arrangementIndex]:getTeamKey(), false)
	local heros = remote.herosUtil:getHaveHero()
	local soulSpirits = remote.soulSpirit:getMySoulSpiritInfoList()
	local teams = self._widgetHeroArray:getSelectTeam(arrangementIndex)
	local soulTeams = self._widgetHeroArray:getSelectSoulSpirit(arrangementIndex)
	local mainTeamHeros = teams[1] or {}
	local helpTeamHeros = teams[2] or {}

  	local numStr = q.numToWord(arrangementIndex)

 	local mainTeamNum = #mainTeamHeros
 	local helpTeamNum = #helpTeamHeros
 	local soulTeamNum = #soulTeams

	local godarmTeams = self._widgetHeroArray:getSelectGodarmList(arrangementIndex)
	local godarmIds = remote.godarm:getHaveGodarmIdList()
	local isUnlockGodarm = app.unlock:getUnlockGodarm()

  	local mainMaxNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN, self._selectTrialNum)
  	if mainTeamNum < mainMaxNum and #heros - (helpTeamNum + mainTeamNum) > 0 then
		app:alert({content = string.format("第%s战队有主力魂师未上阵，确定开始战斗吗？", numStr), title = "系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return false
  	end

  	local soulMaxNum = teamVO:getSpiritsMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
  	if soulTeamNum < soulMaxNum and (#soulSpirits - soulTeamNum > 0) then
		app:alert({content = string.format("第%s战队有魂灵未上阵，确定开始战斗吗？", numStr), title = "系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return false
  	end
  	
  	local helpMaxNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_HELP, self._selectTrialNum)
  	if helpTeamNum < helpMaxNum and #heros - (mainTeamNum + helpTeamNum) > 0 then
		app:alert({content = string.format("第%s战队有援助魂师未上阵，确定开始战斗吗？", numStr), title = "系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return false
  	end

  	local teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_GODARM,self._selectTrialNum)
  	local godarmTeams1 = self._widgetHeroArray:getSelectGodarmList(1)
  	local godarmTeams2 = self._widgetHeroArray:getSelectGodarmList(2)
  	print("上阵神器提示----teamHeroNum-#godarmTeams-#godarmIds",teamHeroNum,#godarmTeams,#godarmIds)
  	if isUnlockGodarm and #godarmTeams < teamHeroNum and (#godarmIds - #godarmTeams1 - #godarmTeams2 > 0)  then
  		local canBattle = false
  		local labelhuimie = {}
  		for _,v in pairs(godarmTeams) do
  			local sameLabel = 0
  			local compare1 = db:getCharacterByID(v)
  			if not labelhuimie[compare1.label] then
  				labelhuimie[compare1.label] = {}
  				labelhuimie[compare1.label].number = (labelhuimie[compare1.label].number or 0) + 1
  			else
  				labelhuimie[compare1.label].number = (labelhuimie[compare1.label].number or 0) + 1
  			end
  		end
  		QPrintTable(labelhuimie)
  		local havelabelhuimie = {}
		for _,value in pairs(godarmIds) do
			local compare2 = db:getCharacterByID(value)
			if not havelabelhuimie[compare2.label] then
				havelabelhuimie[compare2.label] = {}
				havelabelhuimie[compare2.label].number = (havelabelhuimie[compare2.label].number or 0) + 1
			else
				havelabelhuimie[compare2.label].number = (havelabelhuimie[compare2.label].number or 0) + 1		
			end
		end

		for k,v in pairs(havelabelhuimie) do
			local  num = labelhuimie[k] and (labelhuimie[k].number or 0) or 0
			if v.number and (v.number -  num)  > 0 and num < 2 then
				canBattle = true
				break
			end
		end
  		if canBattle then
			app:alert({content = string.format("第%s战队有神器未上阵，确定开始战斗吗？", numStr), title = "系统提示", callback = function (state)
				if state == ALERT_TYPE.CONFIRM then
					self:startBattle()
				end
			end})	
			return false	
  		end
  	end
	return true
end

function QUIDialogMetalCityTeamArrangement:startBattle()
	app.sound:playSound("battle_fight")
	
	local teamKey1 = self._arrangements[1]:getTeamKey()
	local teamKey2 = self._arrangements[2]:getTeamKey()
	local teamVO1 = remote.teamManager:getTeamByKey(teamKey1, false)
	local teamVO2 = remote.teamManager:getTeamByKey(teamKey2, false)
	local teams1
	local teams2
	if self._selectTrialNum == 1 then
		teams1 = self:_getSelectTeams(1)
		teams2 = self:_getSelectTeams(2)
	else
		teams1 = self:_getSelectTeams(1)
		teams2 = self:_getSelectTeams(2)
	end

	remote.teamManager:updateTeamData(teamKey1, teams1)
	remote.teamManager:updateTeamData(teamKey2, teams2)
  	self._arrangements[1]:startBattle(teams1, teams2)

  	if self._onConfirm then
  		self._onConfirm()
  	end
end

function QUIDialogMetalCityTeamArrangement:_checkHelpSkill(help, skill)
	if help == nil or help[1] == nil then 
		return nil
	end

	local haveSkillHero = false
	for _, value in pairs(help) do
		if value == skill then
			haveSkillHero = true
			break
		end
	end
	if haveSkillHero then
		return skill
	else
		return help[1]
	end
end

function QUIDialogMetalCityTeamArrangement:_onTiggerClickTrail(event)
	local selectTrialNum = event.trialNum
	if selectTrialNum == self._selectTrialNum then return end

	self._selectTrialNum = selectTrialNum
	self:changeTrialInfo()
end

function QUIDialogMetalCityTeamArrangement:changeTrialInfo()
	local teamKey = remote.teamManager.METAL_CIRY_ATTACK_TEAM1
	if self._selectTrialNum == 2 then
		teamKey = remote.teamManager.METAL_CIRY_ATTACK_TEAM2
	end

	remote.teamManager:updateTeamData(self._arrangements[1]:getTeamKey(), self:_getSelectTeams(1))
	remote.teamManager:updateTeamData(self._arrangements[2]:getTeamKey(), self:_getSelectTeams(2))

	self._arrangement = self._arrangements[self._selectTrialNum]
	if self._arrangement then
		self._unlockedSlot = self._arrangement:getUnlockSlots(self._selectIndex, self._selectTrialNum)
		self._allHeroList = self:initHero(self._arrangement:getHeroes())
		self._allSpiritList = self:initSoulSpirit(self._arrangement:getSoulSpirits())
		self._godarmList = self:initGodarmList(remote.godarm:getHaveGodarmList() or {})
		local options = {
			unlockNumber = self._unlockedSlot, 
			heroList = self._allHeroList, 
			soulSpiritList = self._allSpiritList, 
			godarmList = self._godarmList,
			arrangement = self._arrangement,
			state = self._arrangement:showHeroState(), 
			tips = self._arrangement:getPrompt(), 
			trialNum = self._selectTrialNum
		}
		self._widgetHeroArray:updateArrangement(options)
	end

	self:setTrailInfo()

	self:_onHeroChangedTab({})
end

function QUIDialogMetalCityTeamArrangement:_getSelectTeams(trialNum)
	local teams = self._widgetHeroArray:getSelectTeam(trialNum)

	local teamData = {{}, {}, {}, {},{}}
	teamData[1].actorIds = teams[1] or {}
	teamData[2].actorIds = teams[2] or {}
	teamData[3].actorIds = teams[3] or {}
	teamData[4].actorIds = teams[4] or {}

	local godarmInfo = self._widgetHeroArray:getSelectGodarmListInfo(trialNum) or {}
	local godarmIds = {}
	table.sort( godarmInfo, function(a,b)
		if a.pos ~= b.pos then
			return a.pos < b.pos
		end
	end )
	for _,v in pairs(godarmInfo) do
		table.insert(godarmIds,v.godarmId)
	end
	teamData[5].godarmIds = godarmIds

	teamData[1].spiritIds = self._widgetHeroArray:getSelectSoulSpirit(trialNum) or {}

	local skills = {}
	if trialNum == 1 then
		table.insert(skills, self._selectSkillHero1[1])
		table.insert(skills, self._selectSkillHero1[2])
	else
		table.insert(skills, self._selectSkillHero2[1])
		table.insert(skills, self._selectSkillHero2[2])
	end
	teamData[2].skill = skills
	return teamData
end

function QUIDialogMetalCityTeamArrangement:_onTriggerRight()
	if self._selectIndex == 2 then
		self._widgetHeroArray:onTriggerMain()
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._widgetHeroArray:onTriggerHelper()
	end
end

function QUIDialogMetalCityTeamArrangement:_onTriggerLeft()
	if self._selectIndex == 1 then
		self._widgetHeroArray:onTriggerHelper()
	elseif self._selectIndex == 2 then
		self._widgetHeroArray:onTriggerGodarm()
	end
end

function QUIDialogMetalCityTeamArrangement:_moveToHelper()
	self._ccbOwner.avatarMain:moveBy(SWITCH_DURATION, SWITCH_DISTANCE, 0)
	self._ccbOwner.avatarHelper:moveBy(SWITCH_DURATION, SWITCH_DISTANCE, 0)
end

function QUIDialogMetalCityTeamArrangement:_moveToMain()
	self._ccbOwner.avatarMain:moveBy(SWITCH_DURATION, -SWITCH_DISTANCE, 0)
	self._ccbOwner.avatarHelper:moveBy(SWITCH_DURATION, -SWITCH_DISTANCE, 0)
end

function QUIDialogMetalCityTeamArrangement:_onTriggerConditionInfo()
   app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHelperExplain"})
end

function QUIDialogMetalCityTeamArrangement:_onTriggerSoulInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_soulInfo) == false then return end
	app.sound:playSound("common_small")

	local soulSpirits = self._widgetHeroArray:getSelectSoulSpirit(self._selectTrialNum)
	if not soulSpirits[1] then
		app.tip:floatTip("魂灵未上阵~")
		return
	end
	local teams = self._widgetHeroArray:getSelectTeam(self._selectTrialNum)
	local mainTeam = teams[remote.teamManager.TEAM_INDEX_MAIN] or {}
	local helpTeam1 = teams[remote.teamManager.TEAM_INDEX_HELP] or {}
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamSoulSpiritInfo",
   		options = {mainTeam = mainTeam, helpTeam1 = helpTeam1, soulSpiritId = soulSpirits}})
end

function QUIDialogMetalCityTeamArrangement:_onTriggerGodarmInfo(event)
	app.sound:playSound("common_small")
	local godarmInfo = self._widgetHeroArray:getSelectGodarmListInfo(self._selectTrialNum)
	if next(godarmInfo) == nil then
		app.tip:floatTip("神器未上阵~")
		return		
	end
	self._widgetHeroArray:onTriggerGodarm()
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodarmTeamDetail",
   		options = {mainGodarmList = godarmInfo}})	
end

function QUIDialogMetalCityTeamArrangement:_onTriggerHelperDetail()
	app.sound:playSound("common_small")
	local teams = self._widgetHeroArray:getSelectTeam(self._selectTrialNum)
	local helpTeam1 = teams[remote.teamManager.TEAM_INDEX_HELP] or {}
   app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamHelperAddInfo", options = {helpTeam1 = helpTeam1}})
end

function QUIDialogMetalCityTeamArrangement:_onTriggerChangeTeam(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_change_team) == false then return end
	app.sound:playSound("common_small")

	local teamVO = remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)
	local teams1 = self._widgetHeroArray:getSelectTeam(1)
	local teams2 = self._widgetHeroArray:getSelectTeam(2)
	local soulSpirit1 = self._widgetHeroArray:getSelectSoulSpirit(1)
	local soulSpirit2 = self._widgetHeroArray:getSelectSoulSpirit(2)
	local godarmList1 = self._widgetHeroArray:getSelectGodarmList(1) or {}
	local godarmList2 = self._widgetHeroArray:getSelectGodarmList(2) or {}
	local subHeros1 = remote.teamManager:getHeroUpOrder(1)
	local subHeros2 = remote.teamManager:getHeroUpOrder(2)
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityQuickChangeTeam",
    	options = {
    		teams1 = teams1, 
    		teams2 = teams2, 
    		subHeros1 = subHeros1, 
    		subHeros2 = subHeros2, 
    		soulSpirit1 = soulSpirit1, 
    		soulSpirit2 = soulSpirit2, 
    		godarmList1 = godarmList1,
    		godarmList2 = godarmList2,
    		fighterInfo = self._fighterInfo, 
    		isStromArena = self._isStromArena, 
    		isTotemChallenge = self._isTotemChallenge,
    		isDefence = self._isDefence, 
    		isPVP = teamVO:getIsPVP(),
    		callBack = function ()
    			local skills = {}
    			if teams1[2] then
    				table.insert(skills, teams1[2][1])
    				table.insert(skills, teams1[2][2])
    			end
    			self._arrangements[1]:setActorTeams(remote.teamManager.TEAM_INDEX_MAIN, teams1[1])
    			self._arrangements[1]:setActorTeams(remote.teamManager.TEAM_INDEX_HELP, teams1[2])
    			self._arrangements[1]:setSoulSpiritTeams(remote.teamManager.TEAM_INDEX_MAIN, teams1[3])
				self._arrangements[1]:setSkillTeams(remote.teamManager.TEAM_INDEX_SKILL, skills)
				self._arrangements[1]:setGodarmTeams(remote.teamManager.TEAM_INDEX_GODARM,teams1[4])

    			local skills = {}
    			if teams2[2] then
    				table.insert(skills, teams2[2][1])
    				table.insert(skills, teams2[2][2])
    			end
    			self._arrangements[2]:setActorTeams(remote.teamManager.TEAM_INDEX_MAIN, teams2[1])
    			self._arrangements[2]:setActorTeams(remote.teamManager.TEAM_INDEX_HELP, teams2[2])
    			self._arrangements[2]:setSoulSpiritTeams(remote.teamManager.TEAM_INDEX_MAIN, teams2[3])
				self._arrangements[2]:setSkillTeams(remote.teamManager.TEAM_INDEX_SKILL, skills)
				self._arrangements[2]:setGodarmTeams(remote.teamManager.TEAM_INDEX_GODARM,teams2[4])
				
				for i, teams in pairs(teams1) do
		    		teams1[i] = table.mapToArray(teams)
		    	end
		    	for i, teams in pairs(teams2) do
		    		teams2[i] = table.mapToArray(teams)
		    	end
				if self:safeCheck() then
					self:initSelectSkill()
		    		self._widgetHeroArray:updateHeroByTeams(teams1, teams2)
		    	end
    		end
    	}})
end

function QUIDialogMetalCityTeamArrangement:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    local teamKey = self._arrangement:getTeamKey()

	local extraProp = app.extraProp:getSelfExtraProp()
    local getFighterByTrialNum = function(trialNum)
	    local fighter = remote.user:makeFighterByTeamKey(teamKey, trialNum)

		local teams = self._widgetHeroArray:getSelectTeam(trialNum)
		if trialNum == 1 then
			fighter.heros = remote.user:getHerosFun(teams[remote.teamManager.TEAM_INDEX_MAIN] or {})
			fighter.subheros = remote.user:getHerosFun(teams[remote.teamManager.TEAM_INDEX_HELP] or {})
			fighter.sub2heros = remote.user:getHerosFun(teams[remote.teamManager.TEAM_INDEX_HELP2] or {})
			fighter.sub3heros = remote.user:getHerosFun(teams[remote.teamManager.TEAM_INDEX_HELP3] or {})
		else
			fighter.main1Heros = remote.user:getHerosFun(teams[remote.teamManager.TEAM_INDEX_MAIN] or {})
			fighter.sub1heros = remote.user:getHerosFun(teams[remote.teamManager.TEAM_INDEX_HELP] or {})
		end

		return fighter
    end

	local fighter = getFighterByTrialNum(self._selectTrialNum)
    if self._selectTrialNum == 1 then
	    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
	        options = {teamKey = teamKey, fighter = fighter, showTeam = true, extraProp = extraProp}}, {isPopCurrentDialog = false})
    else
	    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
	        options = {teamKey2 = teamKey, fighter2 = fighter, showTeam = true, extraProp = extraProp}}, {isPopCurrentDialog = false})
    end
end


function QUIDialogMetalCityTeamArrangement:_onTriggerSkipFight()
    app.sound:playSound("common_switch")
    local tipStr ="跳过战斗设置关闭，您将可以手动操作战斗"
    if not self._isSkipFight then
		tipStr ="已设置成跳过战斗"
    end
    app.tip:floatTip(tipStr)
	self:setUpdateSkipFightState()

end

function QUIDialogMetalCityTeamArrangement:_onTriggerSync(event)

	local teams = self._widgetHeroArray:getSelectTeam(1)
	if teams[remote.teamManager.TEAM_INDEX_MAIN] == nil then teams[remote.teamManager.TEAM_INDEX_MAIN] = {} end 
	if not self._arrangement:teamValidity(teams[remote.teamManager.TEAM_INDEX_MAIN], 1) then
		return 
	end

	teams = self._widgetHeroArray:getSelectTeam(2)
	if teams[remote.teamManager.TEAM_INDEX_MAIN] == nil then teams[remote.teamManager.TEAM_INDEX_MAIN] = {} end 
	if not self._arrangement:teamValidity(teams[remote.teamManager.TEAM_INDEX_MAIN], 2) then
		return 
	end

	local teams1 = self:_getSelectTeams(1)
	local teams2 = self:_getSelectTeams(2)
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSyncFormation",
   		options = {teamKey = self._arrangement:getTeamKey(), teamType = 2 , teams = {teams1,teams2} }}, {isPopCurrentDialog = false})
end



function QUIDialogMetalCityTeamArrangement:setUpdateSkipFightState()
    self._isSkipFight = not self._isSkipFight
    app:getUserData():setUserValueForKey(QUserData.Totem_Challenge_SKIP,self._isSkipFight and "1" or "0")
	self._ccbOwner.sp_select:setVisible(self._isSkipFight)
end


function QUIDialogMetalCityTeamArrangement:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMetalCityTeamArrangement:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogMetalCityTeamArrangement
