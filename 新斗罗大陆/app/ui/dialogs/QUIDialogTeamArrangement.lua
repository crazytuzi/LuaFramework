--
-- Author: Your Name
-- Date: 2014-05-22 14:09:45
--
local QUIDialog = import(".QUIDialog")
local QUIDialogTeamArrangement = class("QUIDialogTeamArrangement", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroBattleArray = import("..widgets.QUIWidgetHeroBattleArray")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")

local NUMBER_TIME = 1
local AVATAR_SCALE = 1.3
local SWITCH_DISTANCE = 1340
local SWITCH_DURATION = 0.3
local NORMAL_POS = {ccp(390, 0), ccp(130, 0), ccp(-130.0, 0), ccp(-390, 0)}
local HAVE_SOUL_POS = {ccp(400, 0), ccp(200, 0), ccp(-0, 0), ccp(-200, 0), ccp(-410, 0)}
local HAVE_TWO_SOUL_POS = {ccp(420, 0), ccp(240, 0), ccp(60, 0), ccp(-120, 0), ccp(-290, 0),ccp(-450, 0)}

function QUIDialogTeamArrangement:ctor(options)
	local ccbFile = "ccb/Dialog_HeroBattleArray_change.ccbi"
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
		{ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},
		{ccbCallbackName = "onTriggerSync", callback = handler(self, self._onTriggerSync)},
	}
	QUIDialogTeamArrangement.super.ctor(self, ccbFile, callBacks, options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page then
    	if page and page.setAllUIVisible then page:setAllUIVisible(false) end
    	if page and page.setScalingVisible then page:setScalingVisible(false) end
		if FinalSDK.isHXShenhe() and page.setScalingVisible then
	        page:setScalingVisible(false)
	    end
	end

	q.setButtonEnableShadow(self._ccbOwner.btn_godarm_info)
	q.setButtonEnableShadow(self._ccbOwner.btn_soul_spirit)
	q.setButtonEnableShadow(self._ccbOwner.btn_sync)
	self._ccbOwner.node_btn_battle_aid:setVisible(false)
	-- self._ccbOwner.node_btn_battle:setVisible(false)
	self._ccbOwner.node_btn_confirm:setVisible(false)

	self._force = 0
	self._arrangement = options.arrangement
	self._unlockedSlot = self._arrangement:getUnlockSlots()
	self._onConfirm = options.onConfirm -- this callback will show the confirm button and hide battle button
	self._onFight = options.onFight
	self._backCallback = options.backCallback
	
	self._allHeroList = self:initHero(self._arrangement:getHeroes())
	self._allSpiritList = self:initSoulSpirit(self._arrangement:getSoulSpirits())
	self._godarmList = self:initGodarmList(remote.godarm:getHaveGodarmList() or {})
	self._heroList = {}
	self._spiritList = {}
	self._widgetSoulSpirit = {}

	self._widgetHeroArray = QUIWidgetHeroBattleArray.new({
		unlockNumber = self._unlockedSlot, 
		heroList = self._allHeroList, 
		godarmList = self._godarmList,
		soulSpiritList = self._allSpiritList, 
		arrangement = self._arrangement,
		state = self._arrangement:showHeroState(), 
		tips = self._arrangement:getPrompt()
	})
    self._widgetHeroArrayProxy = cc.EventProxy.new(self._widgetHeroArray)
    self._widgetHeroArrayProxy:addEventListener(QUIWidgetHeroBattleArray.HERO_CHANGED, handler(self, self._onHeroChanged))
    self._widgetHeroArrayProxy:addEventListener(QUIWidgetHeroBattleArray.EVENT_SELECT_TAB, handler(self, self._onHeroChangedTab))
	
	self._widgetHeroArray:setPositionY(122 - display.cy)
	self._ccbOwner.node_confirmBtn:setPositionY(110 - display.cy)
	self._ccbOwner.force:setString(self._force)
	self._ccbOwner.helperRule:setVisible(app.unlock:getUnlockHelper())

	self._forceUpdate = QTextFiledScrollUtils.new()
	self._effectPlay = false

	self._ccbOwner.node_left:setVisible(false)
	self._ccbOwner.node_right:setVisible(true)
	self._selectIndex = self._widgetHeroArray:getSelectIndex()

	self._heroAvatars = {}
	self._heroHelperAvatars = {}
	self._combinedSkill = {}

	self._selectSkillHero1 = nil 
	self._selectSkillHero2 = nil
	self._selectSkillHero3 = nil
	local skill1 = self._arrangement:getSkillTeams(remote.teamManager.TEAM_INDEX_SKILL)
	local skill2 = self._arrangement:getSkillTeams(remote.teamManager.TEAM_INDEX_SKILL2)
	local skill3 = self._arrangement:getSkillTeams(remote.teamManager.TEAM_INDEX_SKILL3)
	if next(skill1) then
		self._selectSkillHero1 = skill1[1]
	end
	if next(skill2) then
		self._selectSkillHero2 = skill2[1]
	end
	if next(skill3) then
		self._selectSkillHero3 = skill3[1]
	end
	self:checkTutorial()
	self:updateLockState(1)

	if self._arrangement ~= nil then
		if self._arrangement:getIsBattle() == false then
			self._ccbOwner.node_btn_confirm:setVisible(true)
			self._ccbOwner.node_btn_battle:setVisible(false)
		end
		self._arrangement:handlerDialog(self)
	end

	self._ccbOwner.node_skill_1:setVisible(false)
	self._ccbOwner.node_skill_2:setVisible(false)
	self._ccbOwner.node_skill_3:setVisible(false)
	self._ccbOwner.node_skill_4:setVisible(false)

	if app.unlock:checkLock("ARRAY_SYNC", false)  then
		self._ccbOwner.node_sync:setVisible(true)
	else
		self._ccbOwner.node_sync:setVisible(false)
	end

	self:initBackground()
	self:initTeamPos()
end

function QUIDialogTeamArrangement:initBackground()
	self._ccbOwner.sp_main_bg:setVisible(true)
	self._ccbOwner.sp_helper_bg:setVisible(false)
	self._ccbOwner.sp_helper2_bg:setVisible(false)
	self._ccbOwner.node_godarm_bg:setVisible(false)
    CalculateUIBgSize(self._ccbOwner.sp_main_bg)
    CalculateUIBgSize(self._ccbOwner.sp_helper_bg)
    CalculateUIBgSize(self._ccbOwner.sp_helper2_bg)
    CalculateUIBgSize(self._ccbOwner.sp_godarm_bg)

	if self._arrangement:getBackPagePath(1) then
		self._ccbOwner.sp_main_bg:setDisplayFrame(self._arrangement:getBackPagePath(1))
	end
	if self._arrangement:getBackPagePath(2) then
		self._ccbOwner.sp_helper_bg:setDisplayFrame(self._arrangement:getBackPagePath(2))
	end
	if self._arrangement:getBackPagePath(3) then
		self._ccbOwner.sp_helper2_bg:setDisplayFrame(self._arrangement:getBackPagePath(3))
	end

	-- 背景专场
	self._ccbOwner.sp_effect_bg1:setVisible(true)
	self._ccbOwner.sp_effect_bg2:setVisible(true)
	self._ccbOwner.sp_effect_bg:setVisible(false)
	if self._arrangement:getEffectPagePath(1) then
		self._ccbOwner.sp_effect_bg1:setVisible(false)
		self._ccbOwner.sp_effect_bg2:setVisible(false)
		self._ccbOwner.sp_effect_bg:setVisible(true)
		self._ccbOwner.sp_effect_bg:setDisplayFrame(self._arrangement:getEffectPagePath(1))
	end

	--set pvp icon
	self._ccbOwner.node_pvp:setVisible(false)
	if ENABLE_PVP_FORCE then
		local teamVO = remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)
		if teamVO:getIsPVP() then
			self._ccbOwner.node_pvp:setVisible(true)
		end
	end
end

function QUIDialogTeamArrangement:initHero(availableHeroIDs)
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

	local maxIndex = teamVO:getTeamMaxIndex()
	for i=1,maxIndex do
		local actorIds = teamVO:getTeamActorsByIndex(i)
		if actorIds ~= nil then
			for _,v in ipairs(actorIds) do
				if availableHero[v] then
					availableHero[v].index = i
				end
			end
		end
	end

	return availableHero
end

function QUIDialogTeamArrangement:initSoulSpirit(allSoulSpirits)
	local soulSpirits = {}
	for i, soulSpiritInfo in pairs(allSoulSpirits) do
		local soulSpiritId = soulSpiritInfo.id
		local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
		local force = remote.soulSpirit:countForceBySpirit(soulSpiritInfo)
		soulSpirits[soulSpiritId] = {soulSpiritId = soulSpiritId, index = 0, force = force}
		soulSpirits[soulSpiritId].arrangement = self._arrangement
	end
 
	local teamVO = remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)

	local soulSpiritIds = teamVO:getTeamSpiritsByIndex(1)
	for _, soulSpiritId in ipairs(soulSpiritIds) do
		if soulSpirits[soulSpiritId] then
			soulSpirits[soulSpiritId].index = 1
		end
	end

	return soulSpirits
end

function QUIDialogTeamArrangement:initGodarmList(godarmList)
	local godarmArray = {}
	for i, godarmInfo in pairs(godarmList) do
		godarmArray[godarmInfo.id] = {godarmId = godarmInfo.id, grade = godarmInfo.grade,level = godarmInfo.level,index = 0, pos = 5,force = godarmInfo.main_force}
		godarmArray[godarmInfo.id].arrangement = self._arrangement
	end
	print("self._arrangement:getTeamKey()=",self._arrangement:getTeamKey())
	local teamVO = remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)
	local maxIndex = teamVO:getTeamMaxIndex()

	local godarmIds = teamVO:getTeamGodarmByIndex(remote.teamManager.TEAM_INDEX_GODARM)

	local pos = 1
	for _, godarmId in ipairs(godarmIds) do
		if godarmArray[godarmId] then
			godarmArray[godarmId].index = remote.teamManager.TEAM_INDEX_GODARM
			godarmArray[godarmId].pos = pos
			pos = pos + 1
		end
	end

	return godarmArray
end

function QUIDialogTeamArrangement:isTeamHaveTangSan( )
	local haveTangSan = false
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
	local actorIds = teamVO:getTeamActorsByIndex(1)
	if not q.isEmpty(actorIds) then
		for i,h in pairs(actorIds) do
			if h == 1002 then
				haveTangSan = true
				break
			end
		end
	end

	return haveTangSan
end

function QUIDialogTeamArrangement:isHaveHeroYwd( )
	local hero = remote.herosUtil:getHeroByID(1005)
	if hero then
		return true
	else
		return false
	end
end

function QUIDialogTeamArrangement:isTeamHaveYwd( )
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
	local actorIds = teamVO:getTeamActorsByIndex(1)
	local haveHeroywd = 0
	if not q.isEmpty(actorIds) then
		for _,h in pairs(actorIds) do
			if h == 1005 then
				return true
			end
		end
	end

	return false
end

function QUIDialogTeamArrangement:checkTutorial()
	if app.tutorial and app.tutorial:isTutorialFinished() == false then
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		page:buildLayer()
		local haveTutorial = false
		if app.tutorial:getStage().unlockHelp == app.tutorial.Guide_Start and app.unlock:getUnlockHelper() and app.unlock:getUnlockHelperDisplay() then
			haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_17_UnlockHelp)
		elseif app.tutorial:getStage().unlockHelp == app.tutorial.Guide_Second_Start and app.unlock:getUnlockTeamHelp5() then
			haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_17_UnlockHelp)
     	elseif app.tutorial:getStage().addHero == app.tutorial.Guide_Start and app.unlock:getUnlockTeam3() then
     		haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_23_UnlockAddHero)	
     	elseif app.tutorial:getStage().addHeroYwd == app.tutorial.Guide_Start and app.unlock:getUnlockTeam3() 
     		and self:isTeamHaveTangSan() and not self:isTeamHaveYwd() and self:isHaveHeroYwd() then --少年唐三上阵，有杨无敌，且未上阵
     		haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_25_AddHeroYwd)	     		
		end
		if haveTutorial == false then
			page:cleanBuildLayer()
		end
	end
end

function QUIDialogTeamArrangement:viewDidAppear()
	QUIDialogTeamArrangement.super.viewDidAppear(self)
	self._arrangement:viewDidAppear()
	self:addBackEvent(false)

	self._ccbOwner.node_teamField:addChild(self._widgetHeroArray)
	
	local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    if animationManager ~= nil then 
		animationManager:stopAnimation()
    end
end

function QUIDialogTeamArrangement:viewWillDisappear()
	QUIDialogTeamArrangement.super.viewWillDisappear(self)
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

	if self._animationScheduler ~= nil then
		scheduler.unscheduleGlobal(self._animationScheduler)
		self._animationScheduler = nil
	end
	
	if self._eleanTextureScheduler ~= nil then
		scheduler.unscheduleGlobal(self._eleanTextureScheduler)
		self._eleanTextureScheduler = nil
	end

	if self._effectCombination then
		self._effectCombination:stopAnimation()
		self._effectCombination = nil
	end

	local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    if animationManager ~= nil then 
		animationManager:stopAnimation()
    end
end

function QUIDialogTeamArrangement:switchGodarmEffectbg(index)
	if index == remote.teamManager.TEAM_INDEX_GODARM then
		self._ccbOwner.sp_effect_bg1:setVisible(false)
		self._ccbOwner.sp_effect_bg2:setVisible(false)
		self._ccbOwner.sp_effect_bg:setVisible(true)
		self._ccbOwner.sp_effect_bg:setDisplayFrame(QSpriteFrameByKey("godarm_arrangement_bg", 4))		
	else
		-- 背景专场
		self._ccbOwner.sp_effect_bg1:setVisible(true)
		self._ccbOwner.sp_effect_bg2:setVisible(true)
		self._ccbOwner.sp_effect_bg:setVisible(false)
		if self._arrangement:getEffectPagePath(1) then
			self._ccbOwner.sp_effect_bg1:setVisible(false)
			self._ccbOwner.sp_effect_bg2:setVisible(false)
			self._ccbOwner.sp_effect_bg:setVisible(true)
			self._ccbOwner.sp_effect_bg:setDisplayFrame(self._arrangement:getEffectPagePath(1))
		end		
	end
end

function QUIDialogTeamArrangement:updateLockState(index)
	print("QUIDialogTeamArrangement:updateLockState----index",index)
	self._selectIndex = index
	self._unlockedSlot = self._arrangement:getUnlockSlots(self._selectIndex)
	print("self._unlockedSlot=,",self._unlockedSlot)
	if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		self._ccbOwner.node_helper:setVisible(app.unlock:getUnlockHelper(false, nil))
		self._ccbOwner.node_godarm_bg:setVisible(false)
		for i = 1, 4 do
			self._ccbOwner["light"..i]:removeAllChildren()
			self._ccbOwner["enable"..i]:setDisplayFrame(QSpriteFrameByKey("godarm_arrangement_bg", 1))
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
		self._ccbOwner.node_godarm_bg:setVisible(true)
		for i=1,4 do
			self._ccbOwner["lightH"..i]:removeAllChildren()
			self._ccbOwner["sp_team1_"..i]:setVisible(false)
			self._ccbOwner["sp_team2_"..i]:setVisible(false)
			self._ccbOwner["sp_team3_"..i]:setVisible(false)
			self._ccbOwner["node_skill"..i]:setVisible(false)
			self._ccbOwner["green"..i]:setVisible(true)	
			self._ccbOwner["green"..i]:setPositionY(40)
			self._ccbOwner["green"..i]:setDisplayFrame(QSpriteFrameByKey("godarm_arrangement_bg", 3))
			if i > self._unlockedSlot then
				local unlockLevel = app.unlock:getConfigByKey("UNLOCK_GOD_ARM_1_"..i).team_level
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
		self._ccbOwner.node_godarm_bg:setVisible(false)
		local helpIndex = 0
		if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
			helpIndex = 4
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then
			helpIndex = 8
		end

		for i = 1, 4 do
			self._ccbOwner["lightH"..i]:removeAllChildren()
			self._ccbOwner["sp_team1_"..i]:setVisible(false)
			self._ccbOwner["sp_team2_"..i]:setVisible(false)
			self._ccbOwner["sp_team3_"..i]:setVisible(false)
			self._ccbOwner["node_skill"..i]:setVisible(false)
			self._ccbOwner["green"..i]:setPositionY(-10)
			self._ccbOwner["green"..i]:setDisplayFrame(QSpriteFrameByKey("godarm_arrangement_bg", 2))
			makeNodeFromGrayToNormal(self._ccbOwner["green"..i])	
			if i > self._unlockedSlot then
				local unlockLevel = app.unlock:getConfigByKey("UNLOCK_HELP_"..(i+helpIndex)).team_level
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

--初始化战队位置，是否显示魂灵
function QUIDialogTeamArrangement:initTeamPos()
	local pos = NORMAL_POS
	for ii = 1,2 do
		self._ccbOwner["node_soul_"..ii]:setVisible(false)
	end

	self._ccbOwner.node_soul_info:setVisible(false)
	self._ccbOwner.node_godarm_info:setVisible(false)

	if app.unlock:checkLock("UNLOCK_SOUL_SPIRIT", false) then
		local soul_num = 2
		local lockSoulNum = remote.soulSpirit:getTeamSpiritsMaxCount()
		local scale = 0.82
		pos = HAVE_TWO_SOUL_POS

		for ii = 1,soul_num do
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
	else
		for i = 1, 4 do
			self._ccbOwner["node_avatar_"..i]:setScale(0.82)
			self._ccbOwner["node_helper_"..i]:setScale(0.82)
		end
	end

	for i = 1, 4 do
		self._ccbOwner["node_avatar_"..i]:setPosition(pos[i].x, pos[i].y)
	end
end

function QUIDialogTeamArrangement:showLeftBtn(isGodarmTab)
	if isGodarmTab then
		self._ccbOwner["node_godarm_info"]:setVisible(remote.godarm:checkGodArmUnlock())
		self._ccbOwner["node_soul_info"]:setVisible(false)
	else
		self._ccbOwner["node_soul_info"]:setVisible(app.unlock:checkLock("UNLOCK_SOUL_SPIRIT", false))
		self._ccbOwner["node_godarm_info"]:setVisible(false)
	end
end
function QUIDialogTeamArrangement:update(heroList, victoryId, callback)
	self:updateLockState(self._widgetHeroArray:getSelectIndex())

	if #heroList > 0 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			self._selectHero = self._selectSkillHero1 or self._arrangement:getSkillTeams(remote.teamManager.TEAM_INDEX_SKILL)[1]
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then	 
			self._selectHero = self._selectSkillHero2 or self._arrangement:getSkillTeams(remote.teamManager.TEAM_INDEX_SKILL2)[1]
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then	 
			self._selectHero = self._selectSkillHero3 or self._arrangement:getSkillTeams(remote.teamManager.TEAM_INDEX_SKILL3)[1]
		end
	end

	-- slotIndex = 1, 显示援助1；slotIndex = 2, 显示援助2；slotIndex = 3, 显示援助3
	local slotIndex = 1
	if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
		slotIndex = 2
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then
		slotIndex = 3
	end
	printInfo("~~~~~` self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN == %s ~~~~~~", self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN)
	if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		printInfo("~~~~~~~~~ q.isEmpty(self._heroAvatars) == %s ~~~~~~", q.isEmpty(self._heroAvatars))
		if q.isEmpty(self._heroAvatars) then
			for i = 1, 4 do -- main hero
				local avatar = QUIWidgetHeroInformation.new()
				self._ccbOwner["hero"..i]:addChild(avatar)
				avatar:setVisible(false)
		        avatar:setBackgroundVisible(false)
			    avatar:setNameVisible(true)
			    avatar:setStarVisible(false)

			    table.insert(self._heroAvatars, avatar)
			end
		end
	else
		printInfo("~~~~~~~~~ q.isEmpty(self._heroHelperAvatars) == %s ~~~~~~", q.isEmpty(self._heroHelperAvatars))
		if q.isEmpty(self._heroHelperAvatars) then
			for i = 1, 4 do -- helper
				local avatar = QUIWidgetHeroInformation.new()
				self._ccbOwner["heroH"..i]:addChild(avatar)
				avatar:setVisible(false)
		        avatar:setBackgroundVisible(false)
			    avatar:setNameVisible(true)
			    avatar:setStarVisible(false)
			    avatar:hideGodarmInfo()
			    table.insert(self._heroHelperAvatars, avatar)
			end
		end
	end

	local slot = 1
	local isSelectSkill = false
	for k, v in pairs(heroList) do
		local avatar = nil
		if v.index == remote.teamManager.TEAM_INDEX_HELP or 
			v.index == remote.teamManager.TEAM_INDEX_HELP2 or
			v.index == remote.teamManager.TEAM_INDEX_HELP3 then
			avatar = self._heroHelperAvatars[slot]
			avatar:setInfotype("QUIDialogTeamArrangement")
			avatar:setAvatar(v.actorId, AVATAR_SCALE)
		    avatar:setStarVisible(false)			
		    avatar:setHpMp(v.hpScale, v.mpScale)
		    avatar:hideGodarmInfo()

			self._ccbOwner["sp_team"..slotIndex.."_"..slot]:setVisible(true)
			self._ccbOwner["sp_team"..slotIndex.."_"..slot]:setPositionY(275)
			self._ccbOwner["node_skill"..slot]:setVisible(true)
			self._ccbOwner["node_skill"..slot]:setPositionY(250)
			if self._selectHero == nil and k == 1 then
				self:selectSkill(k)
				isSelectSkill = true
			elseif self._selectHero == v.actorId then 
				self:selectSkill(k)
				isSelectSkill = true
			elseif not isSelectSkill then
				self:selectSkill(k)
				isSelectSkill = true
			end
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
			avatar:setInfotype("QUIDialogTeamArrangement")
			avatar:setAvatar(v.actorId, AVATAR_SCALE)
		    avatar:setStarVisible(false)				
		    avatar:setHpMp(v.hpScale, v.mpScale)
		end	

		avatar:setVisible(true)
	    -- play victory effect for selected hero and sound
	    if victoryId == v.actorId then
	    	avatar:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY)
			local effect = QUIWidgetAnimationPlayer.new()
			if v.index == remote.teamManager.TEAM_INDEX_MAIN then
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
			if v.index == remote.teamManager.TEAM_INDEX_HELP or v.index == remote.teamManager.TEAM_INDEX_HELP2 then
				local heroModel = remote.herosUtil:createHeroPropById(v.actorId)
				local teams = self._widgetHeroArray:getSelectTeam()
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
			self._handleCombinedSkill = scheduler.performWithDelayGlobal(function()
				callback()
			end, 0)
	    end
	    slot = slot + 1
	end

	local force = 0
	for _,v in pairs(self._allHeroList) do
		if v.index == remote.teamManager.TEAM_INDEX_MAIN or
			v.index == remote.teamManager.TEAM_INDEX_HELP or 
			v.index == remote.teamManager.TEAM_INDEX_HELP2 or
			v.index == remote.teamManager.TEAM_INDEX_HELP3 then 
			force = force + v.force 
		end
	end

	--显示精灵在界面上
	if app.unlock:checkLock("UNLOCK_SOUL_SPIRIT", false) then
		for ii = 1,2 do
			if self._widgetSoulSpirit[ii] then
				self._widgetSoulSpirit[ii]:removeFromParent()
				self._widgetSoulSpirit[ii] = nil
			end
		end
		--计算当前的精灵列表的战力`
		local soulSpiritId = {}
		for _,v in pairs(self._allSpiritList) do
			if v.index ~= 0 then
				table.insert(soulSpiritId,v.soulSpiritId)
				
			end
		end
		local soulForce = remote.soulSpirit:countForceBySpiritIds(soulSpiritId)
		force = force + soulForce
		print("上阵魂灵战力---soulForce=",soulForce)
		-- if soulSpiritId ~= 0 then
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
			if v.index == remote.teamManager.TEAM_INDEX_GODARM then
				force = force + v.force
				if self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM and v.pos ~= 5 then
					local slot = v.pos or 1
					avatar = self._heroHelperAvatars[slot]
					avatar:setInfotype("QUIDialogTeamArrangement")
					avatar:setAvatar(v.godarmId, AVATAR_SCALE)
				    avatar:setStarVisible(false)	
					avatar:setVisible(true)
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

	if self._force > 0 then 
		self:playForceEffect(change)
	end

	self._force = force
	self:updateAssistSkill()
end

function QUIDialogTeamArrangement:playProp(avatar,desc,value)
	if value == nil then value = 0 end
	value = math.floor(value)
	if value > 0 then
		table.insert(self._effectProps, desc..value)
	end
end
function QUIDialogTeamArrangement:playAllProp()
	if #self._effectProps > 0 then
		local effect = QUIWidgetAnimationPlayer.new()
		effect:setPosition(0,0)
		self._ccbOwner.node_effect:addChild(effect)
		effect:playAnimation("ccb/effects/Arena_tips.ccbi", function(ccbOwner)
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

function QUIDialogTeamArrangement:selectSkill(slot)
	if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then 
		self._selectSkillHero1 = self._heroList[slot].actorId
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then 
		self._selectSkillHero2 = self._heroList[slot].actorId
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then 
		self._selectSkillHero3 = self._heroList[slot].actorId
	end
	
	for i=1,4 do
		self._ccbOwner["node_skill_select"..i]:setVisible(i==slot)
	end

end

function QUIDialogTeamArrangement:selectGodarmSkill(slot)
	if slot and self._ccbOwner["node_skill_select"..slot] then
		self._ccbOwner["node_skill_select"..slot]:setVisible(true)
	end
	if slot and self._ccbOwner["sp_team_godarm_"..slot] then
		self._ccbOwner["sp_team_godarm_"..slot]:setVisible(true)
		self._ccbOwner["sp_team_godarm_"..slot]:setPositionY(275)
	end
end

function QUIDialogTeamArrangement:nodeEffect(node)
	if node ~= nil then
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
	    local ccsequence = CCSequence:create(actionArrayIn)
		node:runAction(ccsequence)
	end
end

function QUIDialogTeamArrangement:playForceEffect(change)
    if change ~= 0 then 
    	local effectName
      if change > 0 then
        effectName = "effects/Tips_add.ccbi"
      elseif change < 0 then 
        effectName = "effects/Tips_Decrease.ccbi"
      end
      local numEffect = QUIWidgetAnimationPlayer.new()
      self._ccbOwner.node_battle:addChild(numEffect)
      numEffect:playAnimation(effectName, function(ccbOwner)
      		if self:safeCheck() then
	            if change < 0 then
	              ccbOwner.content:setString(" -" .. math.abs(change))
	            else
	              ccbOwner.content:setString(" +" .. math.abs(change))
	            end
	        end
          end)
    end
end

function QUIDialogTeamArrangement:getTeamHeroList( )
	return self._heroList
end

function QUIDialogTeamArrangement:_onHeroChanged(event)
	self._heroList = {}
	if event.hero then
		self._heroList = event.hero
	end
	self._spiritList = {}
	if event.soulSpirits then
		self._spiritList = event.soulSpirits
	end
	-- local isGodarmTab = event.isGodarmTab
	self._shangzhengGodarms = {}
	if event.godarmList then
		self._shangzhengGodarms = event.godarmList
	end
	-- if not isGodarmTab and self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM then
	-- 	self._widgetHeroArray:onTriggerMain()
	-- end

	table.sort(self._heroList, function (x, y)
		if x.hatred == y.hatred then
			return x.force > y.force
		end
		return x.hatred > y.hatred
	end )

	-- table.sort(self._spiritList, function (x, y)
	-- 	return x.force < y.force
	-- end )

	self:update(self._heroList, event.victoryId, function ()
		if not self:safeCheck() then
			return
		end

		local unlockMainCount = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_MAIN)
		local unlockHelp1Count = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP)
		local unlockHelp2Count = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP2)
		local unlockHelp3Count = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP3)
		local unlockGodarmCount = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_GODARM)

		local help1Count = 0 
		local help2Count = 0
		local help3Count = 0
		local godarmCount = 0
		for _,value in pairs(self._allHeroList) do
			if value.index == remote.teamManager.TEAM_INDEX_HELP then
				help1Count = help1Count + 1
			elseif value.index == remote.teamManager.TEAM_INDEX_HELP2 then
				help2Count = help2Count + 1
			elseif value.index == remote.teamManager.TEAM_INDEX_HELP3 then
				help3Count = help3Count + 1
			end
		end

		local spiritCount = 0
		for _, value in pairs(self._allSpiritList) do
			if value.index ~= 0 then
				spiritCount = spiritCount + 1
			end
		end

		for _,value in pairs(self._godarmList) do
			if value.index == remote.teamManager.TEAM_INDEX_GODARM then
				godarmCount = godarmCount + 1
			end
		end
		print("self._selectIndex--",self._selectIndex)
		local teamVO = remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)
		if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN and #self._heroList >= unlockMainCount and event.victoryId ~= nil then
			if spiritCount < teamVO:getSpiritsMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN) then
				self._widgetHeroArray:_onTriggerSoul(CCControlEventTouchUpInside)
			elseif unlockHelp1Count > help1Count then
				self._widgetHeroArray:onTriggerHelper()
			elseif unlockHelp2Count > help2Count then
				self._widgetHeroArray:onTriggerHelper2()
			elseif unlockHelp3Count > help3Count then
				self._widgetHeroArray:onTriggerHelper3()
			elseif unlockGodarmCount > godarmCount and remote.godarm:checkGodArmUnlock() then
				self._widgetHeroArray:onTriggerGodarm()
			end
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP and #self._heroList >= unlockHelp1Count then
			if unlockHelp2Count > help2Count then
				self._widgetHeroArray:onTriggerHelper2()
			end
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 and #self._heroList >= unlockHelp2Count then
			if unlockHelp3Count > help3Count then
				self._widgetHeroArray:onTriggerHelper3()
			elseif unlockGodarmCount > godarmCount and remote.godarm:checkGodArmUnlock() then
				self._widgetHeroArray:onTriggerGodarm()
			end
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 and #self._heroList >= unlockHelp3Count then
			if unlockGodarmCount > godarmCount and remote.godarm:checkGodArmUnlock() then
				self._widgetHeroArray:onTriggerGodarm()
			else
				self._widgetHeroArray:onTriggerMain()
			end
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 and #self._godarmList >= unlockGodarmCount then
			self._widgetHeroArray:onTriggerMain()
		end
	end)

end

function QUIDialogTeamArrangement:_onHeroChangedTab(event)
	-- @qinyuanji, stop combination skill prompt animation
	if self._effectCombination then
		self._effectCombination:stopAnimation()
		self._effectCombination = nil
	end
	if event then
		self._teamIndex = event.index or 1
	end
	self:switchGodarmEffectbg(self._teamIndex)


	local i = 1
	while self._ccbOwner["hero"..i] do
		self._ccbOwner["hero"..i]:removeAllChildren()
		i = i + 1
	end
	self._heroAvatars = {}

	i = 1
	while self._ccbOwner["heroH"..i] do
		self._ccbOwner["heroH"..i]:removeAllChildren()
		i = i + 1
	end
	self._heroHelperAvatars = {}

	for i = 1, 4 do -- helper
		if self._teamIndex ~= remote.teamManager.TEAM_INDEX_GODARM then
			self._ccbOwner["heroH"..i]:setPositionY(145)
		else
			self._ccbOwner["heroH"..i]:setPositionY(195)
		end
	end

			


	if self._teamIndex == remote.teamManager.TEAM_INDEX_MAIN then
		self._ccbOwner.node_left:setVisible(app.unlock:getUnlockTeamHelp1())
		self._ccbOwner.node_right:setVisible(false)
		self._ccbOwner.node_btn_battle_aid:setVisible(false)
		self:showLeftBtn(false)
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP then
		self._ccbOwner.node_left:setVisible(app.unlock:getUnlockTeamHelp5())
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
		self:showLeftBtn(false)
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP2 then
		self._ccbOwner.node_left:setVisible(app.unlock:getUnlockTeamHelp9())
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
		self:showLeftBtn(false)
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP3 then
		self._ccbOwner.node_left:setVisible(remote.godarm:checkGodArmUnlock())
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
		self:showLeftBtn(false)
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._ccbOwner.node_left:setVisible(false)
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)	
		self:showLeftBtn(true)
	end

	local animationName
	print("self._teamIndex,self._selectIndex",self._teamIndex,self._selectIndex)
	if self._teamIndex == remote.teamManager.TEAM_INDEX_MAIN and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
		animationName = "normal"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_MAIN and (self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 or
	 self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 or self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM) then
		animationName = "3-1"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP and self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		animationName = "aid"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP and (self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 or 
		self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 or self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM) then
	    animationName = "aid2_1"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP2 and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
		animationName = "aid2"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP2 and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then
		animationName = "aid2_1"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP2 and self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		animationName = "5-2"	
	elseif (self._teamIndex == remote.teamManager.TEAM_INDEX_HELP2 or self._teamIndex == remote.teamManager.TEAM_INDEX_HELP3 or self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM) 
		and self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		animationName = "1-3"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP3 and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
		animationName = "aid2"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP3 and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
		animationName = "aid2"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP3 and self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		animationName = "1-3"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP3 and self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		animationName = "aid2_1"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM and (self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 
		or self._selectIndex == remote.teamManager.TEAM_INDEX_HELP or self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 ) then
		self._ccbOwner.sp_helper_bg:setVisible(true)
		animationName = "2-5"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM and self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		self._ccbOwner.sp_main_bg:setVisible(true)
		animationName = "1-3"	
	end
	
	print("----animationName--------",animationName)
	if animationName then
		local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	    if animationManager ~= nil then 
			animationManager:runAnimationsForSequenceNamed(animationName)
		    animationManager:connectScriptHandler(function()
		        animationManager:disconnectScriptHandler()
		    	if self._checkNewCombinedSkill and self:safeCheck() then
					self:_checkNewCombinedSkill()
				end
		    end)
	    end

		if self._animationScheduler ~= nil then
			scheduler.unscheduleGlobal(self._animationScheduler)
			self._animationScheduler = nil
		end

		self._animationScheduler = scheduler.performWithDelayGlobal(function ( ... )
			local mainBg = animationName == "normal" or animationName == "3-1"
			self._ccbOwner.sp_main_bg:setVisible(mainBg)
			local helpBg = animationName == "aid2_1" or animationName == "aid" or animationName == "5-2"
			self._ccbOwner.sp_helper_bg:setVisible(helpBg)
			local help2Bg = animationName == "aid2" or animationName == "1-3" 
			self._ccbOwner.sp_helper2_bg:setVisible(help2Bg)

		end, 0.2)

		if self._eleanTextureScheduler ~= nil then
			scheduler.unscheduleGlobal(self._eleanTextureScheduler)
			self._eleanTextureScheduler = nil
		end
		self._eleanTextureScheduler = scheduler.performWithDelayGlobal(function ( ... )
			app:setIsClearSkeletonData(true)
		    app:cleanTextureCache()
		end, 0)
	end

	self._ccbOwner.tf_help_tip:setVisible(false)
end

function QUIDialogTeamArrangement:updateAssistSkill()
	for i = 1, 4, 1 do
		self._ccbOwner["node_skill_"..i]:setVisible(false)
		self._ccbOwner["effect_"..i]:setVisible(false)
	end

	local index = 1
	while self._heroList[index] do 
		local actorId = self._heroList[index].actorId
		local assistSkill, haveAssistHero = remote.herosUtil:checkHeroHaveAssistHero(actorId)
		if assistSkill then
			self._ccbOwner["node_skill_"..index]:setVisible(true)
			self._ccbOwner["node_skill_"..index]:setPositionY(250)
			local skillInfo = remote.herosUtil:getManualSkillsByActorId(actorId)

			local skillIcon = CCSprite:create()
			self._ccbOwner["skill_icon_"..index]:removeAllChildren()
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

function QUIDialogTeamArrangement:_checkNewCombinedSkill(callback)
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

function QUIDialogTeamArrangement:_onForceUpdate(value)
    local word = nil
    if value >= 1000000 then
      word = tostring(math.floor(value/10000)).."万"
    else
      word = math.floor(value)
    end
    self._ccbOwner.force:setString(word)
    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(value,true)
    if fontInfo ~= nil then
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.force:setColor(ccc3(color[1], color[2], color[3]))
		-- self._ccbOwner.sp_battle_bg:setColor(ccc3(color[1], color[2], color[3]))
    end
end

function QUIDialogTeamArrangement:_onTriggerClick1( )
	if self._unlockedSlot < 1 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			app.unlock:getUnlockTeamHelp1(true)
		end
		return
	end
	if self._heroList[1] then
		if self._selectHero == self._heroList[1].actorId then
			self._selectHero = nil
			self._selectSkillHero = nil
		end
		self._widgetHeroArray:removeSelectedHero(self._heroList[1].actorId)
		table.remove(self._heroList, 1)
		self:update(self._heroList)
	end
end

function QUIDialogTeamArrangement:_onTriggerClick2( )
	if self._unlockedSlot < 2 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
			app.unlock:checkLock("UNLOCK_THE_SECOND", true)
		end
		return
	end

	if self._heroList[2] then
		if self._selectHero == self._heroList[2].actorId then
			self._selectHero = nil
			self._selectSkillHero = nil
		end
		self._widgetHeroArray:removeSelectedHero(self._heroList[2].actorId)
		table.remove(self._heroList, 2)
		self:update(self._heroList)
	end
end

function QUIDialogTeamArrangement:_onTriggerClick3( )
	if self._unlockedSlot < 3 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
			local dungeonInfo = remote.instance:getDungeonById(app.unlock:getConfigByKey("UNLOCK_THE_THIRD").dungeon)
			app.tip:floatTip("攻打关卡"..dungeonInfo.number.."解锁")
		end
		return
	end

	if self._heroList[3] then
		if self._selectHero == self._heroList[3].actorId then
			self._selectHero = nil
			self._selectSkillHero = nil
		end
		self._widgetHeroArray:removeSelectedHero(self._heroList[3].actorId)
		table.remove(self._heroList, 3)
		self:update(self._heroList)
	end
end

function QUIDialogTeamArrangement:_onTriggerClick4( )
	if self._unlockedSlot < 4 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
			local dungeonInfo = remote.instance:getDungeonById(app.unlock:getConfigByKey("UNLOCK_THE_FOURTH").dungeon)
			app.tip:floatTip("攻打关卡"..dungeonInfo.number.."解锁")
		end
		return
	end

	if self._heroList[4] then
		if self._selectHero == self._heroList[4].actorId then
			self._selectHero = nil
			self._selectSkillHero = nil
		end
		self._widgetHeroArray:removeSelectedHero(self._heroList[4].actorId)
		table.remove(self._heroList, 4)
		self:update(self._heroList)
	end
end

function QUIDialogTeamArrangement:_onTriggerClickSoul1( )
	if self._spiritList[1] then
		print("魂灵ID-_onTriggerClickSoul1-",self._spiritList[1].soulSpiritId)
		self._widgetHeroArray:removeSelectedSoulSpirit(self._spiritList[1].soulSpiritId)
		table.remove(self._spiritList, 1)
		self:update(self._heroList)
	end
end

function QUIDialogTeamArrangement:_onTriggerClickSoul2( )
	local lockSoulNum = remote.soulSpirit:getTeamSpiritsMaxCount()
	if lockSoulNum < 2 then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTeamGuideTips",options = {soulTeamNum = 1}})
		return
	end
	if self._spiritList[2] then
		print("魂灵ID-_onTriggerClickSoul2-",self._spiritList[2].soulSpiritId)
		self._widgetHeroArray:removeSelectedSoulSpirit(self._spiritList[2].soulSpiritId)
		table.remove(self._spiritList, 2)
		self:update(self._heroList)
	end
end

function QUIDialogTeamArrangement:_onTriggerClickH1( )
	print("援助位下阵------",self._unlockedSlot,self._selectIndex)
	if self._unlockedSlot < 1 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			app.unlock:getUnlockTeamHelp1(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
			app.unlock:getUnlockTeamHelp5(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then
			app.unlock:getUnlockTeamHelp9(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
			app.unlock:getUnlockTeamGodarmHelp1(true)
		end
		return
	end	
	if self._selectIndex ~= remote.teamManager.TEAM_INDEX_GODARM then
		if self._heroList[1] then
			if self._selectHero == self._heroList[1].actorId then
				self._selectHero = nil
				self._selectSkillHero = nil
			end
			self._widgetHeroArray:removeSelectedHero(self._heroList[1].actorId)
			table.remove(self._heroList, 1)
			self:update(self._heroList)
		end
	else
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

function QUIDialogTeamArrangement:_onTriggerClickH2( )
	if self._unlockedSlot < 2 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			app.unlock:getUnlockTeamHelp2(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
			app.unlock:getUnlockTeamHelp6(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then
			app.unlock:getUnlockTeamHelp10(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
			app.unlock:getUnlockTeamGodarmHelp2(true)
		end
		return
	end	
	if self._selectIndex ~= remote.teamManager.TEAM_INDEX_GODARM then
		if self._heroList[2] then
			if self._selectHero == self._heroList[2].actorId then
				self._selectHero = nil
				self._selectSkillHero = nil
			end
			self._widgetHeroArray:removeSelectedHero(self._heroList[2].actorId)
			table.remove(self._heroList, 2)
			self:update(self._heroList)
		end
	else	
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

function QUIDialogTeamArrangement:_onTriggerClickH3( )
	if self._unlockedSlot < 3 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			app.unlock:getUnlockTeamHelp3(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
			app.unlock:getUnlockTeamHelp7(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then
			app.unlock:getUnlockTeamHelp11(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
			app.unlock:getUnlockTeamGodarmHelp3(true)			
		end
		return
	end	
	if self._selectIndex ~= remote.teamManager.TEAM_INDEX_GODARM then
		if self._heroList[3] then
			if self._selectHero == self._heroList[3].actorId then
				self._selectHero = nil
				self._selectSkillHero = nil
			end
			self._widgetHeroArray:removeSelectedHero(self._heroList[3].actorId)
			table.remove(self._heroList, 3)
			self:update(self._heroList)
		end
	else
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

function QUIDialogTeamArrangement:_onTriggerClickH4( )
	if self._unlockedSlot < 4 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			app.unlock:getUnlockTeamHelp4(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
			app.unlock:getUnlockTeamHelp8(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then
			app.unlock:getUnlockTeamHelp12(true)
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
			app.unlock:getUnlockTeamGodarmHelp4(true)				
		end
		return
	end	
	if self._selectIndex ~= remote.teamManager.TEAM_INDEX_GODARM then
		if self._heroList[4] then
			if self._selectHero == self._heroList[4].actorId then
				self._selectHero = nil
				self._selectSkillHero = nil
			end
			self._widgetHeroArray:removeSelectedHero(self._heroList[4].actorId)
			table.remove(self._heroList, 4)
			self:update(self._heroList)
		end
	else
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

function QUIDialogTeamArrangement:_onTriggerSkill1()
	if self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		return
	end
	self:selectSkill(1)
	app.tip:floatTip("设置成功！该魂技将作为战斗中的援助魂技！")
	self._selectHero = self._heroList[1].actorId
end

function QUIDialogTeamArrangement:_onTriggerSkill2()
	if self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		return
	end	
	self:selectSkill(2)
	app.tip:floatTip("设置成功！该魂技将作为战斗中的援助魂技！")
	self._selectHero = self._heroList[2].actorId
end

function QUIDialogTeamArrangement:_onTriggerSkill3()
	if self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		return
	end	
	self:selectSkill(3)
	app.tip:floatTip("设置成功！该魂技将作为战斗中的援助魂技！")
	self._selectHero = self._heroList[3].actorId  
end

function QUIDialogTeamArrangement:_onTriggerSkill4()
	if self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		return
	end	
	self:selectSkill(4)
	app.tip:floatTip("设置成功！该魂技将作为战斗中的援助魂技！")
	self._selectHero = self._heroList[4].actorId
end

function QUIDialogTeamArrangement:_onTriggerAssistSkill1()
	self:_openHeroDetail(self._heroList[1].actorId)
end

function QUIDialogTeamArrangement:_onTriggerAssistSkill2()
	self:_openHeroDetail(self._heroList[2].actorId)
end

function QUIDialogTeamArrangement:_onTriggerAssistSkill3()
	self:_openHeroDetail(self._heroList[3].actorId)
end

function QUIDialogTeamArrangement:_onTriggerAssistSkill4()
	self:_openHeroDetail(self._heroList[4].actorId)
end

function QUIDialogTeamArrangement:_openHeroDetail(actorId)
	local assistSkillInfo = QStaticDatabase:sharedDatabase():getAssistSkill(actorId)
	local skillInfo = remote.herosUtil:getUIHeroByID(actorId):getSkillBySlot(3)

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAssistHeroSkill", 
		options = {actorId = actorId, assistSkill = assistSkillInfo, skillSlotInfo = skillInfo}},{isPopCurrentDialog = false})
end

function QUIDialogTeamArrangement:_onTriggerFight(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_confirm) == false then return end
	if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP or 
		self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 or 
		self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 or 
		self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._widgetHeroArray:onTriggerMain()
		return 
	end
	local teams = self._widgetHeroArray:getSelectTeam()
	local soulTeams = self._widgetHeroArray:getSelectSoulSpirit()
	local godarmTeams = self._widgetHeroArray:getSelectGodarmList()

	if teams[remote.teamManager.TEAM_INDEX_MAIN] == nil then teams[remote.teamManager.TEAM_INDEX_MAIN] = {} end 
	if not self._arrangement:teamValidity(teams[remote.teamManager.TEAM_INDEX_MAIN]) then
		return 
	end
 
  	local mainTeam = teams[remote.teamManager.TEAM_INDEX_MAIN] ~= nil and #teams[remote.teamManager.TEAM_INDEX_MAIN] or 0
  	local helpTeam = teams[remote.teamManager.TEAM_INDEX_HELP] ~= nil and #teams[remote.teamManager.TEAM_INDEX_HELP] or 0
  	local helpTeam2 = teams[remote.teamManager.TEAM_INDEX_HELP2] ~= nil and #teams[remote.teamManager.TEAM_INDEX_HELP2] or 0
  	local helpTeam3 = teams[remote.teamManager.TEAM_INDEX_HELP3] ~= nil and #teams[remote.teamManager.TEAM_INDEX_HELP3] or 0

  	local heros = remote.herosUtil:getHaveHero()
	local soulSpirits = remote.soulSpirit:getMySoulSpiritInfoList()
	local godarmIds = remote.godarm:getHaveGodarmIdList()

  	local isUnlockHelper = app.unlock:getUnlockHelperDisplay()
  	local isUnlockHelper2 = app.unlock:getUnlockTeamHelp5()
  	local isUnlockHelper3 = app.unlock:getUnlockTeamHelp9()
  	local isUnlockGodarm = app.unlock:getUnlockGodarm()

  	local str = "确定开始战斗吗？"
  	if self._arrangement:getIsBattle() == false then
  		str = "确定保存吗？"
  	end

  	local upTeam = helpTeam + mainTeam + helpTeam2 + helpTeam3
	local teamVO = remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)
  	local teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
  	if mainTeam < teamHeroNum and #heros - upTeam > 0 then
		app:alert({content="有主力魂师未上阵，"..str,title="系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return
  	end

  	local soulMaxNum = teamVO:getSpiritsMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
  	if #soulTeams < soulMaxNum and (#soulSpirits - #soulTeams > 0) then
		app:alert({content = string.format("战队有魂灵未上阵，确定开始战斗吗？"), title = "系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return
  	end
  	
  	teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_HELP)
  	if isUnlockHelper and helpTeam < teamHeroNum and #heros - upTeam > 0 then
		app:alert({content="有援助1魂师未上阵，"..str,title="系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return
  	end

  	teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_HELP2)
  	if isUnlockHelper2 and helpTeam2 < teamHeroNum and #heros - upTeam > 0 then
		app:alert({content="有援助2魂师未上阵，"..str,title="系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return
  	end

  	teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_HELP3)
  	if isUnlockHelper3 and helpTeam3 < teamHeroNum and #heros - upTeam > 0 then
		app:alert({content="有援助3魂师未上阵，"..str,title="系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return
  	end

  	teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_GODARM)
  	if isUnlockGodarm and #godarmTeams < teamHeroNum and (#godarmIds - #godarmTeams > 0)  then
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
			app:alert({content="有神器未上阵，"..str,title="系统提示", callback = function (state)
				if state == ALERT_TYPE.CONFIRM then
					self:startBattle()
				end
			end}) 
			return 			
  		end
  	end

	self:startBattle()
end 

function QUIDialogTeamArrangement:startBattle()
	app.sound:playSound("battle_fight")

	local teams = self:_getSelectTeams()

  	self._arrangement:startBattle(teams)
end

function QUIDialogTeamArrangement:_getSelectTeams()
	local teams = self._widgetHeroArray:getSelectTeam()
	local teamData = {{}, {}, {}, {},{}}
	teamData[1].actorIds = teams[1] or {}
	teamData[2].actorIds = teams[2] or {}
	teamData[3].actorIds = teams[3] or {}
	teamData[4].actorIds = teams[4] or {}

	local godarmInfo = self._widgetHeroArray:getSelectGodarmListInfo() or {}
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

	teamData[1].spiritIds = self._widgetHeroArray:getSelectSoulSpirit() or {}

	local skill1 = self._selectSkillHero1
	skill1 = self:_checkHelpSkill(teamData[2].actorIds, skill1)
	teamData[2].skill = {skill1}

	local skill2 = self._selectSkillHero2
	skill2 = self:_checkHelpSkill(teamData[3].actorIds, skill2)
	teamData[3].skill = {skill2}

	local skill3 = self._selectSkillHero3
	skill3 = self:_checkHelpSkill(teamData[4].actorIds, skill3)
	teamData[4].skill = {skill3}

	return teamData
end

function QUIDialogTeamArrangement:_checkHelpSkill(help, skill)
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

function QUIDialogTeamArrangement:_onTriggerRight()
	if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
		self._widgetHeroArray:onTriggerMain()
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
		self._widgetHeroArray:onTriggerHelper()
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then
		self._widgetHeroArray:onTriggerHelper2()
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		if app.unlock:getUnlockTeamHelp9() then 
			self._widgetHeroArray:onTriggerHelper3()
		elseif app.unlock:getUnlockTeamHelp5() then
			self._widgetHeroArray:onTriggerHelper2()
		else
			self._widgetHeroArray:onTriggerHelper()
		end
	end
end

function QUIDialogTeamArrangement:_onTriggerLeft()
	if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		self._widgetHeroArray:onTriggerHelper()
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
		self._widgetHeroArray:onTriggerHelper2()
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
		self._widgetHeroArray:onTriggerHelper3()
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then
		self._widgetHeroArray:onTriggerGodarm()
	end
end

function QUIDialogTeamArrangement:_moveToHelper()
	self._ccbOwner.avatarMain:moveBy(SWITCH_DURATION, SWITCH_DISTANCE, 0)
	self._ccbOwner.avatarHelper:moveBy(SWITCH_DURATION, SWITCH_DISTANCE, 0)
end

function QUIDialogTeamArrangement:_moveToMain()
	self._ccbOwner.avatarMain:moveBy(SWITCH_DURATION, -SWITCH_DISTANCE, 0)
	self._ccbOwner.avatarHelper:moveBy(SWITCH_DURATION, -SWITCH_DISTANCE, 0)
end

function QUIDialogTeamArrangement:_onTriggerConditionInfo()
   app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHelperExplain"})
end

function QUIDialogTeamArrangement:_onTriggerSoulInfo()
	app.sound:playSound("common_small")

	local soulSpirits = self._widgetHeroArray:getSelectSoulSpirit()
	-- if not soulSpirits[1] then
	-- 	app.tip:floatTip("魂灵未上阵~")
	-- 	return
	-- end
	local teams = self._widgetHeroArray:getSelectTeam()
	local mainTeam = teams[remote.teamManager.TEAM_INDEX_MAIN] or {}
	local helpTeam1 = teams[remote.teamManager.TEAM_INDEX_HELP] or {}
	local helpTeam2 = teams[remote.teamManager.TEAM_INDEX_HELP2] or {}
	local helpTeam3 = teams[remote.teamManager.TEAM_INDEX_HELP3] or {}
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamSoulSpiritInfo",
   		options = {mainTeam = mainTeam, helpTeam1 = helpTeam1, helpTeam2 = helpTeam2, helpTeam3 = helpTeam3, soulSpiritId = soulSpirits}})
end

function QUIDialogTeamArrangement:_onTriggerGodarmInfo(event)
	app.sound:playSound("common_small")
	local godarmInfo = self._widgetHeroArray:getSelectGodarmListInfo()
	if next(godarmInfo) == nil then
		app.tip:floatTip("神器未上阵~")
		return		
	end	
	self._widgetHeroArray:onTriggerGodarm()
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodarmTeamDetail",
   		options = {mainGodarmList = godarmInfo}})	
end

function QUIDialogTeamArrangement:_onTriggerHelperDetail()
	app.sound:playSound("common_small")
	local teams = self._widgetHeroArray:getSelectTeam()
	local helpTeam1 = teams[remote.teamManager.TEAM_INDEX_HELP] or {}
	local helpTeam2 = teams[remote.teamManager.TEAM_INDEX_HELP2] or {}
	local helpTeam3 = teams[remote.teamManager.TEAM_INDEX_HELP3] or {}
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamHelperAddInfo",
   		options = {helpTeam1 = helpTeam1, helpTeam2 = helpTeam2, helpTeam3 = helpTeam3}})
end



function QUIDialogTeamArrangement:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    local teamKey = self._arrangement:getTeamKey()
    local fighter = remote.user:makeFighterByTeamKey(teamKey, 1)
    local extraProp = app.extraProp:getSelfExtraProp()

	local teams = self._widgetHeroArray:getSelectTeam()
	fighter.heros = remote.user:getHerosFun(teams[remote.teamManager.TEAM_INDEX_MAIN] or {})
	fighter.subheros = remote.user:getHerosFun(teams[remote.teamManager.TEAM_INDEX_HELP] or {})
	fighter.sub2heros = remote.user:getHerosFun(teams[remote.teamManager.TEAM_INDEX_HELP2] or {})
	fighter.sub3heros = remote.user:getHerosFun(teams[remote.teamManager.TEAM_INDEX_HELP3] or {})

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = teamKey, fighter = fighter, extraProp = extraProp}}, {isPopCurrentDialog = false})
end

function QUIDialogTeamArrangement:_onTriggerSync(event)

	local teams = self._widgetHeroArray:getSelectTeam()

	if teams[remote.teamManager.TEAM_INDEX_MAIN] == nil then teams[remote.teamManager.TEAM_INDEX_MAIN] = {} end 
	if not self._arrangement:teamValidity(teams[remote.teamManager.TEAM_INDEX_MAIN]) then
		return 
	end

	teams = self:_getSelectTeams()
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSyncFormation",
   		options = {teamKey = self._arrangement:getTeamKey(), teamType = 1 , teams = {teams} }}, {isPopCurrentDialog = false})
end


function QUIDialogTeamArrangement:onTriggerBackHandler()
    self:popSelf()
    if self._backCallback then
    	self._backCallback()
    end
end

return QUIDialogTeamArrangement