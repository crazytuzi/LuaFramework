-- @Author: liaoxianbo
-- @Date:   2019-11-13 11:50:35
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-03 23:47:49
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogCollegeTrainTeamArrangement = class("QUIDialogCollegeTrainTeamArrangement", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroCollegeTrainBattleArray = import("..widgets.QUIWidgetHeroCollegeTrainBattleArray")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QActorProp = import("...models.QActorProp")

local NUMBER_TIME = 1
local AVATAR_SCALE = 1.3
local SWITCH_DISTANCE = 1340
local SWITCH_DURATION = 0.3
local NORMAL_POS = {ccp(390, 0), ccp(130, 0), ccp(-130.0, 0), ccp(-390, 0)}
local HAVE_SOUL_POS = {ccp(400, 0), ccp(200, 0), ccp(-0, 0), ccp(-200, 0), ccp(-410, 0)}

function QUIDialogCollegeTrainTeamArrangement:ctor(options)
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
		{ccbCallbackName = "onTriggerFight", callback = handler(self, self._onTriggerFight)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerConditionInfo", callback = handler(self, self._onTriggerConditionInfo)},
		{ccbCallbackName = "onTriggerSoulInfo", callback = handler(self, self._onTriggerSoulInfo)},
		{ccbCallbackName = "onTriggerHelperDetail", callback = handler(self, self._onTriggerHelperDetail)},
		{ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},
	}
	QUIDialogCollegeTrainTeamArrangement.super.ctor(self, ccbFile, callBacks, options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page then
		if page.setAllUIVisible then
			page:setAllUIVisible(false)
		end
		if FinalSDK.isHXShenhe() and page.setScalingVisible then
	        page:setScalingVisible(false)
	    end
	end

	self._ccbOwner.node_pvp:setVisible(false)
	self._ccbOwner.node_buff_up:setVisible(false)
	self._ccbOwner.node_btn_battle_aid:setVisible(false)
	self._ccbOwner.node_btn_confirm:setVisible(false)

	self._force = 0
	self._arrangement = options.arrangement
	self._remoteUtils = self._arrangement:getRemoteUtils()
	self._chapterId = self._arrangement:getChapterId()
	self._inComallheroList = self._arrangement:getHeroes() or {}

	self._allHeroList = self:initHero(self._inComallheroList)
	self._inComsoulSpritList = self._arrangement:getSoulSpirits() or {}
	self._allSpiritList = {}
	self._widgetSoulSpirit = {}
	self._heroList = {}

	self._chapterInfo = db:getCollegeTrainConfigById(self._chapterId)
	self._unlockedSlot = tonumber(self._chapterInfo.main_force_num_1) or 4
	self._soulSpiritNum = tonumber(self._chapterInfo.soul_sprite_1) or 0
	if self._soulSpiritNum > 0 then
		self._allSpiritList = self:initSoulSpirit(self._inComsoulSpritList)
	end

	self._heroAvatars = {}
	for i = 1, 4 do -- main hero
		local avatar = QUIWidgetHeroInformation.new()
		self._ccbOwner["hero"..i]:addChild(avatar)
		avatar:setVisible(false)
        avatar:setBackgroundVisible(false)
	    avatar:setNameVisible(true)
	    -- avatar:setProVisible(false) 
	    avatar:setStarVisible(false)

	    table.insert(self._heroAvatars, avatar)
	end

	-- self._soulSpiritNum = 0
	self._widgetHeroArray = QUIWidgetHeroCollegeTrainBattleArray.new({
		chapterId = self._chapterId,
		heroList = self._allHeroList, 
		soulSpiritList = self._allSpiritList, 
	})
    self._widgetHeroArrayProxy = cc.EventProxy.new(self._widgetHeroArray)
    self._widgetHeroArrayProxy:addEventListener(QUIWidgetHeroCollegeTrainBattleArray.HERO_CHANGED, handler(self, self._onHeroChanged))
    self._widgetHeroArrayProxy:addEventListener(QUIWidgetHeroCollegeTrainBattleArray.EVENT_SELECT_TAB, handler(self, self._onHeroChangedTab))
	
	self._widgetHeroArray:setPositionY(122 - display.cy)
	self._ccbOwner.node_confirmBtn:setPositionY(110 - display.cy)
	self._ccbOwner.force:setString(self._force)
	self._ccbOwner.helperRule:setVisible(self._unlockedSlot > 0)


	self._forceUpdate = QTextFiledScrollUtils.new()
	self._effectPlay = false

	self._ccbOwner.node_left:setVisible(false)
	self._ccbOwner.node_right:setVisible(true)
	self._selectIndex = self._widgetHeroArray:getSelectIndex()

	self._heroHelperAvatars = {}
	self._combinedSkill = {}
	self:updateLockState(1)

	local saveTeamHero = app:getUserOperateRecord():getCollegeTrainTeam(self._chapterId)
	self._selectSkillHero1 = nil 
	self._selectSkillHero2 = nil
	self._selectSkillHero3 = nil
	if next(saveTeamHero) ~= nil then
		local skill1 = saveTeamHero[2].skill or {}
		local skill2 = saveTeamHero[3].skill or {}
		local skill3 = saveTeamHero[4].skill or {}
		if next(skill1) then
			self._selectSkillHero1 = skill1[1]
		end
		if next(skill2) then
			self._selectSkillHero2 = skill2[1]
		end
		if next(skill3) then
			self._selectSkillHero3 = skill3[1]
		end
	end

	self._ccbOwner.node_skill_1:setVisible(false)
	self._ccbOwner.node_skill_2:setVisible(false)
	self._ccbOwner.node_skill_3:setVisible(false)
	self._ccbOwner.node_skill_4:setVisible(false)

	self:initBackground()
	self:initTeamPos()
end

function QUIDialogCollegeTrainTeamArrangement:viewDidAppear()
	QUIDialogCollegeTrainTeamArrangement.super.viewDidAppear(self)
	self:addBackEvent(true)

	self._ccbOwner.node_teamField:addChild(self._widgetHeroArray)
	
	local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    if animationManager ~= nil then 
		animationManager:stopAnimation()
    end
end

function QUIDialogCollegeTrainTeamArrangement:viewWillDisappear()
  	QUIDialogCollegeTrainTeamArrangement.super.viewWillDisappear(self)

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

function QUIDialogCollegeTrainTeamArrangement:initHero(availableHeroIDs)
	local availableHero = {}
	for i, actorId in pairs(availableHeroIDs) do
		if actorId ~= nil and actorId ~= "" then
			local characher = db:getCharacterByID(actorId)

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
			local heroProp = self._remoteUtils:getHeroModelById(self._chapterId,actorId)
			local force = heroProp:getBattleForce(true)
			availableHero[actorId] = {actorId = actorId, type = heroType, hatred = hatred, index = 0, force = force } 
		end
	end


	local saveTeamHero = app:getUserOperateRecord():getCollegeTrainTeam(self._chapterId)
	if next(saveTeamHero) ~= nil then
		for i=1,4 do
			local actorIds = saveTeamHero[i].actorIds or {}
			if next(actorIds) ~= nil then
				for _,v in ipairs(actorIds) do
					print("type(v)=",type(v))
					local key = tostring(v)
					if availableHero[key] then
						availableHero[key].index = i
					end
				end
			end
		end
	end 	
	return availableHero
end

function QUIDialogCollegeTrainTeamArrangement:initSoulSpirit(allSoulSpirits)
	local soulSpirits = {}
	for i, soulSpiritInfo in pairs(allSoulSpirits) do
		local soulSpiritId = soulSpiritInfo.id
		local force = remote.soulSpirit:countForceBySpirit(soulSpiritInfo)
		soulSpirits[soulSpiritId] = {soulSpiritId = soulSpiritId, index = 0, force = force}
	end

	return soulSpirits
end

function QUIDialogCollegeTrainTeamArrangement:initBackground()
	self._ccbOwner.sp_main_bg:setVisible(true)
	self._ccbOwner.sp_helper_bg:setVisible(false)
	self._ccbOwner.sp_helper2_bg:setVisible(false)
	self._ccbOwner.sp_godarm_bg:setVisible(false)
    CalculateUIBgSize(self._ccbOwner.sp_main_bg)
    CalculateUIBgSize(self._ccbOwner.sp_helper_bg)
    CalculateUIBgSize(self._ccbOwner.sp_helper2_bg)
	-- 背景专场
	if self._arrangement:getBackPagePath(1) then
		self._ccbOwner.sp_main_bg:setDisplayFrame(self._arrangement:getBackPagePath(1))
	end
	if self._arrangement:getBackPagePath(2) then
		self._ccbOwner.sp_helper_bg:setDisplayFrame(self._arrangement:getBackPagePath(2))
	end
	if self._arrangement:getBackPagePath(3) then
		self._ccbOwner.sp_helper2_bg:setDisplayFrame(self._arrangement:getBackPagePath(3))
	end

	self._ccbOwner.sp_effect_bg1:setVisible(true)
	self._ccbOwner.sp_effect_bg2:setVisible(true)
	self._ccbOwner.sp_effect_bg:setVisible(false)
	
	self._ccbOwner.node_pvp:setVisible(false)
end

--初始化战队位置，是否显示魂灵
function QUIDialogCollegeTrainTeamArrangement:initTeamPos()
	local pos = NORMAL_POS
	for ii = 1,2 do
		self._ccbOwner["node_soul_"..ii]:setVisible(false)
	end
	
	self._ccbOwner["node_soul_info"]:setVisible(false)
	self._ccbOwner["node_godarm_info"]:setVisible(false)

	if self._soulSpiritNum >= 1 then
		self._ccbOwner["node_soul_1"]:setScale(0.82)
		self._ccbOwner["node_soul_1"]:setVisible(true)
		self._ccbOwner["enable_soul1"]:setVisible(true)
		self._ccbOwner["disable_soul1"]:setVisible(false)
		self._ccbOwner["light_soul1"]:setVisible(true)
		self._ccbOwner["unlock_soul1"]:setVisible(false)
		self._ccbOwner["node_soul_info"]:setVisible(true)
		pos = HAVE_SOUL_POS
		for i = 1, 4 do
			self._ccbOwner["node_avatar_"..i]:setScale(0.82)
			self._ccbOwner["node_helper_"..i]:setScale(0.82)
		end
	else
		for i = 1, 4 do
			self._ccbOwner["node_avatar_"..i]:setScale(0.95)
			self._ccbOwner["node_helper_"..i]:setScale(0.95)
		end
	end

	for i = 1, 4 do
		self._ccbOwner["node_avatar_"..i]:setPosition(pos[i].x, pos[i].y)
	end
end

function QUIDialogCollegeTrainTeamArrangement:getUnlockSlots(index )
	local assisTanceNum = tonumber(self._chapterInfo.assistance_num_1)
	local mainTeamNum = tonumber(self._chapterInfo.main_force_num_1) or 4
	print("援助位----index=",index,assisTanceNum)
	if index == 1 then
		return mainTeamNum
	elseif index == 2 then
		if assisTanceNum >= 4 then
			return 4
		else
			return assisTanceNum
		end
	elseif index == 3 then 
		if assisTanceNum >= 8 then
			return 4
		elseif assisTanceNum < 8 and assisTanceNum > 4 then 
			local num = assisTanceNum - 4
			return num
		else
			return 0
		end
	elseif index == 4 then 
		if assisTanceNum >= 12 then
			return 4
		elseif assisTanceNum < 12 and assisTanceNum > 8 then 
			local num =  assisTanceNum - 8
			return num
		else
			return 0
		end		
	end

	return 0
end
function QUIDialogCollegeTrainTeamArrangement:updateLockState(index)
	self._selectIndex = index

	self._unlockedSlot = self:getUnlockSlots(self._selectIndex)

	if self._selectIndex == self._remoteUtils.TEAM_INDEX_MAIN then
		self._ccbOwner.node_helper:setVisible(app.unlock:getUnlockHelper(false, nil))

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
	else
		self._ccbOwner.node_helper:setVisible(true)
		local helpIndex = 0
		if self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP2 then
			helpIndex = 4
		elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP3 then
			helpIndex = 8
		end

		for i = 1, 4 do
			self._ccbOwner["lightH"..i]:removeAllChildren()
			self._ccbOwner["sp_team1_"..i]:setVisible(false)
			self._ccbOwner["sp_team2_"..i]:setVisible(false)
			self._ccbOwner["sp_team3_"..i]:setVisible(false)
			self._ccbOwner["node_skill"..i]:setVisible(false)
			if i > self._unlockedSlot then
				self._ccbOwner["unlockH"..i]:setString("未解锁")
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


function QUIDialogCollegeTrainTeamArrangement:_onHeroChanged(event)
	self._heroList = {}
	if event.hero then
		self._heroList = event.hero
	end
	self._spiritList = {}
	if event.soulSpirits then
		self._spiritList = event.soulSpirits
	end
	local isLocal = event.isLocal or false

	table.sort(self._heroList, function (x, y)
		if x.hatred == y.hatred then
			return x.force > y.force
		end
		return x.hatred > y.hatred
	end )

	self:update(self._heroList, event.victoryId, isLocal,function ()
		if not self:safeCheck() then
			return
		end

		local unlockMainCount = self:getUnlockSlots(1)
		local unlockHelp1Count = self:getUnlockSlots(2)
		local unlockHelp2Count = self:getUnlockSlots(3)
		local unlockHelp3Count = self:getUnlockSlots(4)

		local help1Count = 0 
		local help2Count = 0
		local help3Count = 0
		for _,value in pairs(self._allHeroList) do
			if value.index == self._remoteUtils.TEAM_INDEX_HELP then
				help1Count = help1Count + 1
			elseif value.index == self._remoteUtils.TEAM_INDEX_HELP2 then
				help2Count = help2Count + 1
			elseif value.index == self._remoteUtils.TEAM_INDEX_HELP3 then
				help3Count = help3Count + 1
			end
		end

		local spiritCount = 0
		for _, value in pairs(self._allSpiritList) do
			if value.index ~= 0 then
				spiritCount = spiritCount + 1
			end
		end
		if self._selectIndex == self._remoteUtils.TEAM_INDEX_MAIN and #self._heroList >= unlockMainCount and event.victoryId ~= nil then
			if spiritCount < 1 and self._soulSpiritNum > 0 then
				self._widgetHeroArray:_onTriggerSoul(CCControlEventTouchUpInside)
			elseif unlockHelp1Count > help1Count then
				self._widgetHeroArray:onTriggerHelper()
			elseif unlockHelp2Count > help2Count then
				self._widgetHeroArray:onTriggerHelper2()
			elseif unlockHelp3Count > help3Count then
				self._widgetHeroArray:onTriggerHelper3()
			end
		elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP and #self._heroList >= unlockHelp1Count then
			if unlockHelp2Count > help2Count then
				self._widgetHeroArray:onTriggerHelper2()
			end
		elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP2 and #self._heroList >= unlockHelp2Count then
			if unlockHelp3Count > help3Count then
				self._widgetHeroArray:onTriggerHelper3()
			end
		elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP3 and #self._heroList >= unlockHelp3Count then
			self._widgetHeroArray:onTriggerMain()
		end
	end)

end

function QUIDialogCollegeTrainTeamArrangement:_onHeroChangedTab(event)
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
			self._ccbOwner["heroH"..i]:addChild(avatar)
			avatar:setVisible(false)
	        avatar:setBackgroundVisible(false)
		    avatar:setNameVisible(true)
		    avatar:setStarVisible(false)
		    table.insert(self._heroHelperAvatars, avatar)
		end
	end
	if self._teamIndex == self._remoteUtils.TEAM_INDEX_MAIN then
		self._ccbOwner.node_left:setVisible(app.unlock:getUnlockTeamHelp1())
		self._ccbOwner.node_right:setVisible(false)
		self._ccbOwner.node_btn_battle_aid:setVisible(false)
	elseif self._teamIndex == self._remoteUtils.TEAM_INDEX_HELP then
		self._ccbOwner.node_left:setVisible(app.unlock:getUnlockTeamHelp5())
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
	elseif self._teamIndex == self._remoteUtils.TEAM_INDEX_HELP2 then
		self._ccbOwner.node_left:setVisible(app.unlock:getUnlockTeamHelp9())
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
	elseif self._teamIndex == self._remoteUtils.TEAM_INDEX_HELP3 then
		self._ccbOwner.node_left:setVisible(false)
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
	end

	local animationName
	if self._teamIndex == remote.teamManager.TEAM_INDEX_MAIN and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
		animationName = "normal"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_MAIN and 
		(self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 or self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3) then
		animationName = "3-1"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP and self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		animationName = "aid"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP and (self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 or self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3) then
	    animationName = "aid2_1"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP2 and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
		animationName = "aid2"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP2 and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then
		animationName = "aid2_1"
	elseif (self._teamIndex == remote.teamManager.TEAM_INDEX_HELP2 or self._teamIndex == remote.teamManager.TEAM_INDEX_HELP3) and self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		animationName = "1-3"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP3 and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
		animationName = "aid2"
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP3 and self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
		animationName = "aid2"
	end

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
			local mainBg = animationName == "normal" or animationName == "3-1" or animationName == "1-3"
			self._ccbOwner.sp_main_bg:setVisible(mainBg)
			local helpBg = animationName == "aid2_1" or animationName == "aid"
			self._ccbOwner.sp_helper_bg:setVisible(helpBg)
			local help2Bg = animationName == "aid2"
			self._ccbOwner.sp_helper2_bg:setVisible(help2Bg)
		end, 0.2)
	end

	self._ccbOwner.tf_help_tip:setVisible(false)
	-- if remote.user.level <= 51 and remote.user.level >= 30 and self._teamIndex == self._remoteUtils.TEAM_INDEX_HELP then
	-- 	self._ccbOwner.tf_help_tip:setVisible(true)
	-- end
end


function QUIDialogCollegeTrainTeamArrangement:update(heroList, victoryId, isLocal,callback)
	self:updateLockState(self._widgetHeroArray:getSelectIndex())
	
	if #heroList > 0 then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			self._selectHero = self._selectSkillHero1 
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then	 
			self._selectHero = self._selectSkillHero2 
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then	 
			self._selectHero = self._selectSkillHero3 
		end
	end

	-- slotIndex = 1, 显示援助1；slotIndex = 2, 显示援助2；slotIndex = 3, 显示援助3
	local slotIndex = 1
	if self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP2 then
		slotIndex = 2
	elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP3 then
		slotIndex = 3
	end
	print("update----victoryId=",victoryId)
	local slot = 1
	local isSelectSkill = false
	for k, v in pairs(heroList) do
		print("v.actorId==",v.actorId)
		local avatar = nil
		if v.index == self._remoteUtils.TEAM_INDEX_HELP or 
			v.index == self._remoteUtils.TEAM_INDEX_HELP2 or
			v.index == self._remoteUtils.TEAM_INDEX_HELP3 then
			avatar = self._heroHelperAvatars[slot]
			avatar:setInfotype("QUIDialogCollegeTrainTeamArrangement")
			avatar:setCollegeTrainAvatar(self._chapterId, v.actorId, AVATAR_SCALE)
		    avatar:setStarVisible(false)			
		    avatar:setHpMp(v.hpScale, v.mpScale)

		    print("-------------new team-------------------")
		    print("self._selectHero=",self._selectHero)
			self._ccbOwner["sp_team"..slotIndex.."_"..slot]:setVisible(true)
			self._ccbOwner["node_skill"..slot]:setVisible(true)
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
			avatar:setInfotype("QUIDialogCollegeTrainTeamArrangement")
			avatar:setCollegeTrainAvatar(self._chapterId,v.actorId, AVATAR_SCALE)
		    avatar:setStarVisible(false)				
		    avatar:setHpMp(v.hpScale, v.mpScale)
		end	

		avatar:setVisible(true)
	    -- play victory effect for selected hero and sound
	    if tonumber(victoryId) == tonumber(v.actorId) then
	    	avatar:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY)
			local effect = QUIWidgetAnimationPlayer.new()
			if v.index == self._remoteUtils.TEAM_INDEX_MAIN then
				self._ccbOwner["light"..slot]:addChild(effect)
			else
				self._ccbOwner["lightH"..slot]:addChild(effect)
			end
			effect:playAnimation("effects/ChooseHero.ccbi")

		    -- local heroInfo = remote.herosUtil:getHeroByID(v.actorId)
		    print("选择的英雄-----v,actorId=",v.actorId)
		    print("当前章节---self._chapterId=",self._chapterId)
			local heroInfo = self._remoteUtils:getHeroInfoById(self._chapterId,v.actorId)

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
			if v.index == self._remoteUtils.TEAM_INDEX_HELP or v.index == self._remoteUtils.TEAM_INDEX_HELP2 then
				-- local heroModel = remote.herosUtil:createHeroPropById(v.actorId)
				local heroModel = remote.herosUtil:createHeroProp(heroInfo)
				local teams = self._widgetHeroArray:getSelectTeam()
  				local mainTeamNum = teams[1] ~= nil and #teams[1] or 0
  				self._effectProps = {}
  				print("---------------new team---------加成----")
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
		if v.index == self._remoteUtils.TEAM_INDEX_MAIN or
		v.index == self._remoteUtils.TEAM_INDEX_HELP or 
		v.index == self._remoteUtils.TEAM_INDEX_HELP2 or
		v.index == self._remoteUtils.TEAM_INDEX_HELP3 then 
			force = force + v.force 
		end
	end

	--显示精灵在界面上
	if self._soulSpiritNum >= 1 then
		if self._widgetSoulSpirit[1] then
			self._widgetSoulSpirit[1]:removeFromParent()
			self._widgetSoulSpirit[1] = nil
		end
		--计算当前的精灵列表的战力`
		local soulSpiritId = 0
		for _,v in pairs(self._allSpiritList) do
			if v.index ~= 0 then
				soulSpiritId = v.soulSpiritId
				local soulForce = remote.soulSpirit:countForceBySpiritIds({soulSpiritId})
				force = force + soulForce
			end
		end
		if soulSpiritId ~= 0 then
			self._widgetSoulSpirit[1] = QUIWidgetActorDisplay.new(soulSpiritId)
			self._widgetSoulSpirit[1]:setScaleX(-AVATAR_SCALE)
			self._widgetSoulSpirit[1]:setScaleY(AVATAR_SCALE)
			self._ccbOwner.hero_soul1:addChild(self._widgetSoulSpirit[1])

			if victoryId == soulSpiritId then
				local heroDisplay = db:getCharacterByID(soulSpiritId)
				app.sound:playSound(heroDisplay.preparation)
				self._handleCombinedSkill = scheduler.performWithDelayGlobal(function()
					callback()
				end, 0)
			end
		end
	end

	local change = force - self._force
	if force ~= self._force and victoryId then
		self:nodeEffect(self._ccbOwner.force)
	end

	self._forceUpdate:addUpdate(self._force, force, handler(self, self._onForceUpdate), NUMBER_TIME)

	if self._force > 0 and not isLocal then 
		self:playForceEffect(change)
	end

	self._force = force
	self:updateAssistSkill()
end

function QUIDialogCollegeTrainTeamArrangement:updateAssistSkill()
	for i = 1, 4, 1 do
		self._ccbOwner["node_skill_"..i]:setVisible(false)
		self._ccbOwner["effect_"..i]:setVisible(false)
	end

	local index = 1
	while self._heroList[index] do 
		local actorId = self._heroList[index].actorId
		self._ccbOwner["node_skill_"..index]:setVisible(true)
		local skillInfo = remote.herosUtil:getManualSkillsByActorId(actorId)

		local skillIcon = CCSprite:create()
		self._ccbOwner["skill_icon_"..index]:removeAllChildren()
		self._ccbOwner["skill_icon_"..index]:addChild(skillIcon)
		skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(skillInfo.icon))
		skillIcon:setScale(0.9)
		index = index + 1
	end
end

function QUIDialogCollegeTrainTeamArrangement:playProp(avatar,desc,value)
	if value == nil then value = 0 end
	value = math.floor(value)
	if value > 0 then
		table.insert(self._effectProps, desc..value)
	end
end

function QUIDialogCollegeTrainTeamArrangement:playAllProp()
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

function QUIDialogCollegeTrainTeamArrangement:_onForceUpdate(value)
    local word = nil
    if value >= 1000000 then
      word = tostring(math.floor(value/10000)).."万"
    else
      word = math.floor(value)
    end
    self._ccbOwner.force:setString(word)
    local fontInfo = db:getForceColorByForce(value,true)
    if fontInfo ~= nil then
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.force:setColor(ccc3(color[1], color[2], color[3]))
    end
end

function QUIDialogCollegeTrainTeamArrangement:nodeEffect(node)
	if node ~= nil then
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
	    local ccsequence = CCSequence:create(actionArrayIn)
		node:runAction(ccsequence)
	end
end

function QUIDialogCollegeTrainTeamArrangement:playForceEffect(change)
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

function QUIDialogCollegeTrainTeamArrangement:selectSkill(slot)

	if self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP then 
		self._selectSkillHero1 = self._heroList[slot].actorId
	elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP2 then 
		self._selectSkillHero2 = self._heroList[slot].actorId
	elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP3 then 
		self._selectSkillHero3 = self._heroList[slot].actorId
	end
	
	for i=1,4 do
		self._ccbOwner["node_skill_select"..i]:setVisible(i==slot)
	end
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerClick1( )
	if self._unlockedSlot < 1 then
		if self._selectIndex == self._remoteUtils.TEAM_INDEX_MAIN then
		elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP then
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

function QUIDialogCollegeTrainTeamArrangement:_onTriggerClick2( )
	if self._unlockedSlot < 2 then
		if self._selectIndex == self._remoteUtils.TEAM_INDEX_MAIN then
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

function QUIDialogCollegeTrainTeamArrangement:_onTriggerClick3( )
	if self._unlockedSlot < 3 then
		if self._selectIndex == self._remoteUtils.TEAM_INDEX_MAIN then
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

function QUIDialogCollegeTrainTeamArrangement:_onTriggerClick4( )
	if self._unlockedSlot < 4 then
		if self._selectIndex == self._remoteUtils.TEAM_INDEX_MAIN then
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

function QUIDialogCollegeTrainTeamArrangement:_onTriggerClickSoul1( )
	if self._spiritList[1] then
		self._widgetHeroArray:removeSelectedSoulSpirit(self._spiritList[1].soulSpiritId)
		table.remove(self._spiritList, 1)
		self:update(self._heroList)
	end
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerClickH1( )
	if self._unlockedSlot < 1 then
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

function QUIDialogCollegeTrainTeamArrangement:_onTriggerClickH2( )
	if self._unlockedSlot < 2 then
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

function QUIDialogCollegeTrainTeamArrangement:_onTriggerClickH3( )
	if self._unlockedSlot < 3 then
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

function QUIDialogCollegeTrainTeamArrangement:_onTriggerClickH4( )
	if self._unlockedSlot < 4 then
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

function QUIDialogCollegeTrainTeamArrangement:_onTriggerSkill1()
	self:selectSkill(1)
	app.tip:floatTip("设置成功！该魂技将作为战斗中的援助魂技！")
	self._selectHero = self._heroList[1].actorId
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerSkill2()
	self:selectSkill(2)
	app.tip:floatTip("设置成功！该魂技将作为战斗中的援助魂技！")
	self._selectHero = self._heroList[2].actorId
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerSkill3()
	self:selectSkill(3)
	app.tip:floatTip("设置成功！该魂技将作为战斗中的援助魂技！")
	self._selectHero = self._heroList[3].actorId
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerSkill4()
	self:selectSkill(4)
	app.tip:floatTip("设置成功！该魂技将作为战斗中的援助魂技！")
	self._selectHero = self._heroList[4].actorId
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerAssistSkill1()
	-- self:_openHeroDetail(self._heroList[1].actorId)
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerAssistSkill2()
	-- self:_openHeroDetail(self._heroList[2].actorId)
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerAssistSkill3()
	-- self:_openHeroDetail(self._heroList[3].actorId)
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerAssistSkill4()
	-- self:_openHeroDetail(self._heroList[4].actorId)
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerHelperDetail()
	app.sound:playSound("common_small")
	local teams = self._widgetHeroArray:getSelectTeam()
	local helpTeam1 = teams[self._remoteUtils.TEAM_INDEX_HELP] or {}
	local helpTeam2 = teams[self._remoteUtils.TEAM_INDEX_HELP2] or {}
	local helpTeam3 = teams[self._remoteUtils.TEAM_INDEX_HELP3] or {}
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamHelperAddInfo",
   		options = {helpTeam1 = helpTeam1, helpTeam2 = helpTeam2, helpTeam3 = helpTeam3,isCollegeTeam = true,chapterId = self._chapterId}})
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerSoulInfo()
	app.sound:playSound("common_small")

	local soulSpirits = self._widgetHeroArray:getSelectSoulSpirit()

	local teams = self._widgetHeroArray:getSelectTeam()
	local mainTeam = teams[self._remoteUtils.TEAM_INDEX_MAIN] or {}
	local helpTeam1 = teams[self._remoteUtils.TEAM_INDEX_HELP] or {}
	local helpTeam2 = teams[self._remoteUtils.TEAM_INDEX_HELP2] or {}
	local helpTeam3 = teams[self._remoteUtils.TEAM_INDEX_HELP3] or {}
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamSoulSpiritInfo",
   		options = {mainTeam = mainTeam, helpTeam1 = helpTeam1, helpTeam2 = helpTeam2, helpTeam3 = helpTeam3, soulSpiritId = soulSpirits,
   		isCollegeTeam = true,chapterId = self._chapterId}})
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerRight()
	if self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP then
		self._widgetHeroArray:onTriggerMain()
	elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP2 then
		self._widgetHeroArray:onTriggerHelper()
	elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP3 then
		self._widgetHeroArray:onTriggerHelper2()
	end
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerLeft()
	if self._selectIndex == self._remoteUtils.TEAM_INDEX_MAIN then
		self._widgetHeroArray:onTriggerHelper()
	elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP then
		self._widgetHeroArray:onTriggerHelper2()
	elseif self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP2 then
		self._widgetHeroArray:onTriggerHelper3()
	end
end

function QUIDialogCollegeTrainTeamArrangement:_onTriggerFight(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_confirm) == false then return end
	if self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP or 
		self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP2 or 
		self._selectIndex == self._remoteUtils.TEAM_INDEX_HELP3 then
		self._widgetHeroArray:onTriggerMain()
		return 
	end
	local teams = self._widgetHeroArray:getSelectTeam()

	local soulTeams = self._widgetHeroArray:getSelectSoulSpirit()
 
 	if teams[self._remoteUtils.TEAM_INDEX_MAIN] == nil then teams[self._remoteUtils.TEAM_INDEX_MAIN] = {} end 
	if not self._arrangement:teamValidity(teams[self._remoteUtils.TEAM_INDEX_MAIN]) then
		return 
	end

  	local mainTeam = teams[self._remoteUtils.TEAM_INDEX_MAIN] ~= nil and #teams[self._remoteUtils.TEAM_INDEX_MAIN] or 0
  	local helpTeam = teams[self._remoteUtils.TEAM_INDEX_HELP] ~= nil and #teams[self._remoteUtils.TEAM_INDEX_HELP] or 0
  	local helpTeam2 = teams[self._remoteUtils.TEAM_INDEX_HELP2] ~= nil and #teams[self._remoteUtils.TEAM_INDEX_HELP2] or 0
  	local helpTeam3 = teams[self._remoteUtils.TEAM_INDEX_HELP3] ~= nil and #teams[self._remoteUtils.TEAM_INDEX_HELP3] or 0

  	local heros = #self._inComallheroList
	local soulSpirits = #self._inComsoulSpritList
	local unlockMainTeam = self:getUnlockSlots(1)
  	local unlockHelper = self:getUnlockSlots(2)
  	local unlockHelper2 = self:getUnlockSlots(3)
  	local unlockHelper3 = self:getUnlockSlots(4)

  	local str = "确定开始战斗吗？"

  	local upTeam = helpTeam + mainTeam + helpTeam2 + helpTeam3
  	local offset = heros - upTeam

  	if mainTeam < unlockMainTeam and heros - upTeam > 0 then
  		print("--------有主力魂师未上阵，-------------")
		app:alert({content="有主力魂师未上阵，"..str,title="系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})

		return
  	end

  	if #soulTeams < self._soulSpiritNum and (soulSpirits - #soulTeams > 0) then
		app:alert({content = string.format("战队有魂灵未上阵，确定开始战斗吗？"), title = "系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return
  	end
  	
  	if unlockHelper > 0 and helpTeam < unlockHelper and heros - upTeam > 0 then
		app:alert({content="有援助1魂师未上阵，"..str,title="系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return
  	end

  	if unlockHelper2 > 0 and helpTeam2 < unlockHelper2 and heros - upTeam > 0 then
		app:alert({content="有援助2魂师未上阵，"..str,title="系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return
  	end

  	if unlockHelper3 > 0 and helpTeam3 < unlockHelper3 and heros - upTeam > 0 then
		app:alert({content="有援助3魂师未上阵，"..str,title="系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:startBattle()
			end
		end})
		return
  	end

	self:startBattle()
end 

function QUIDialogCollegeTrainTeamArrangement:startBattle()
	app.sound:playSound("battle_fight")

	local teams = self:_getSelectTeams()

  	self._arrangement:startBattle(self._force,teams)
end

function QUIDialogCollegeTrainTeamArrangement:_getSelectTeams()
	local teams = self._widgetHeroArray:getSelectTeam()
	local teamData = {{}, {}, {}, {}}
	teamData[1].actorIds = teams[1] or {}
	teamData[2].actorIds = teams[2] or {}
	teamData[3].actorIds = teams[3] or {}
	teamData[4].actorIds = teams[4] or {}

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

function QUIDialogCollegeTrainTeamArrangement:_checkHelpSkill(help, skill)
	if help == nil or help[1] == nil then 
		return nil
	end

	local haveSkillHero = false
	for _, value in pairs(help) do
		if tonumber(value) == tonumber(skill) then
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

function QUIDialogCollegeTrainTeamArrangement:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogCollegeTrainTeamArrangement:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogCollegeTrainTeamArrangement
