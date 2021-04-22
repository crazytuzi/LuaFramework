-- 大师赛布阵界面
-- Author: Qinsiyang
-- 
--
local QUIDialog = import(".QUIDialog")
local QUIDialogMockTeamArrangement = class("QUIDialogMockTeamArrangement", QUIDialog)
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetMockBattleArray = import("..widgets.QUIWidgetMockBattleArray")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetHeroBattleArray = import("..widgets.QUIWidgetHeroBattleArray")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QMockBattle = import("..network.models.QMockBattle")

local NUMBER_TIME = 1
local AVATAR_SCALE = 1.3
local SWITCH_DISTANCE = 1340
local SWITCH_DURATION = 0.3
local NORMAL_POS = {ccp(390, 0), ccp(130, 0), ccp(-130.0, 0), ccp(-390, 0)}
local HAVE_SOUL_POS = {ccp(400, 0), ccp(200, 0), ccp(-0, 0), ccp(-200, 0), ccp(-410, 0)}
local TEAM_MAX_NUM = 4

local TEAM_INDEX_MOUNT = 9909

function QUIDialogMockTeamArrangement:ctor(options)
	local ccbFile = "ccb/Dialog_MockBattle_Arrangement.ccbi"
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
		{ccbCallbackName = "onTriggerMount1", callback = handler(self, self._onTriggerMount1)},
		{ccbCallbackName = "onTriggerMount2", callback = handler(self, self._onTriggerMount2)},
		{ccbCallbackName = "onTriggerMount3", callback = handler(self, self._onTriggerMount3)},
		{ccbCallbackName = "onTriggerMount4", callback = handler(self, self._onTriggerMount4)},
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
		{ccbCallbackName = "onTriggerEnemyInfo", callback = handler(self, self._onTriggerEnemyInfo)},
		{ccbCallbackName = "onTriggerEnemyInfo2", callback = handler(self, self._onTriggerEnemyInfo2)},
		{ccbCallbackName = "onTriggerChangeTeam", callback = handler(self, self._onTriggerChangeTeam)},
		{ccbCallbackName = "onTriggerChangeTeam2", callback = handler(self, self._onTriggerChangeTeam2)},
		{ccbCallbackName = "onTriggerChangeTeamOneKey", callback = handler(self, self._onTriggerChangeTeamOneKey)},
		{ccbCallbackName = "onTriggerGodarmInfo", callback = handler(self,self._onTriggerGodarmInfo)},
	}
	QUIDialogMockTeamArrangement.super.ctor(self, ccbFile, callBacks, options)


	q.setButtonEnableShadow(self._ccbOwner.btn_enemyinfo)
	q.setButtonEnableShadow(self._ccbOwner.btn_enemyinfo2)
	q.setButtonEnableShadow(self._ccbOwner.btn_change_team)


	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page and page.setAllUIVisible then page:setAllUIVisible(false) end
	if page and page.setScalingVisible then page:setScalingVisible(false) end


	self._ccbOwner.node_btn_battle_aid:setVisible(false)
	-- self._ccbOwner.node_btn_battle:setVisible(false)
	self._ccbOwner.node_btn_confirm:setVisible(false)
	
	self._force = 0
	self._selectTrialNum = options.trialNum or 1
	self._arrangements = options.arrangements
	self._arrangement = self._arrangements[self._selectTrialNum]


	self._ccbOwner.node_btn_changeTeam:setVisible(#self._arrangements > 1)


	self._unlockedSlot = self._arrangement:getUnlockSlots()
	self._unlockedMountSlot = self._arrangement:getUnlockSlots()
	self._onConfirm = options.onConfirm -- this callback will show the confirm button and hide battle button
	self._onFight = options.onFight
	self._backCallback = options.backCallback
	self._seasonType = options.seasonType

	-- local teamVO = remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)
	local teamVs = self:getMockBattleTeam(true) 
	for i,teamVO in ipairs(teamVs) do
		teamVO:initBattleFormation(i)
	end
	self._allHeroList = self:initHero(self._arrangement:getHeroes())
	self._allSpiritList = self:initSoulSpirit(self._arrangement:getSoulSpirits())
	self._allMountList = self:initMount(self._arrangement:getMounts())
	self._allGodarmList = self:initGodarmList(self._arrangement:getHaveGodarmList() or {})

	self._heroList = {}
	self._spiritList = {}
	self._mountList = {}
	self._widgetSoulSpirit = {}
	self._widgetmount = {}

	self._widgetHeroArray = QUIWidgetMockBattleArray.new({
		unlockNumber = self._unlockedSlot, 
		unlockMountNumber = self._unlockedMountSlot, 
		heroList = self._allHeroList, 
		soulSpiritList = self._allSpiritList, 
		mountList = self._allMountList, 
		godarmList = self._allGodarmList,
		arrangement = self._arrangement,
		state = self._arrangement:showHeroState(), 
		trialNum = self._selectTrialNum,
		tips = self._arrangement:getPrompt(),
		seasonType = options.seasonType
	})
    self._widgetHeroArrayProxy = cc.EventProxy.new(self._widgetHeroArray)
    self._widgetHeroArrayProxy:addEventListener(QUIWidgetHeroBattleArray.HERO_CHANGED, handler(self, self._onHeroChanged))
    self._widgetHeroArrayProxy:addEventListener(QUIWidgetHeroBattleArray.EVENT_SELECT_TAB, handler(self, self._onHeroChangedTab))
	
	self._widgetHeroArray:setPositionY(122 - display.cy)
	self._ccbOwner.node_confirmBtn:setPositionY(110 - display.cy)
	--self._ccbOwner.force:setString(self._force)
	self._ccbOwner.helperRule:setVisible(app.unlock:getUnlockHelper())

	--self._forceUpdate = QTextFiledScrollUtils.new()
	self._effectPlay = false

	self._ccbOwner.node_left:setVisible(false)
	self._ccbOwner.node_right:setVisible(false)
	self._selectIndex = -1

	self._heroAvatars = {}
	self._mountNodes = {}
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

	self:initBackground()
	self:initTeamPos()
	self:initEnemyTeam()
	self:updateEnemyInfo()
	self:updateLockState()

end


function QUIDialogMockTeamArrangement:getMockBattleTeam(_need_all_teams)
	if _need_all_teams then
		local teams_table ={}
		for i,v in ipairs(self._arrangements) do
			if v and v:getTeamKey() then
				table.insert(teams_table,remote.teamManager:getTeamByKey(v:getTeamKey(), false))
			end
		end
		return teams_table
	else
		return remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)
	end

end


function QUIDialogMockTeamArrangement:initBackground()
	self._ccbOwner.sp_main_bg:setVisible(true)
	self._ccbOwner.sp_main_bg1:setVisible(false)
	self._ccbOwner.sp_helper_bg:setVisible(false)
	self._ccbOwner.sp_helper2_bg:setVisible(false)
	self._ccbOwner.sp_godarm_bg:setVisible(false)

	if self._arrangement:getBackPagePath(1) then
		self._ccbOwner.sp_main_bg:setDisplayFrame(self._arrangement:getBackPagePath(1))
	end
	if self._arrangement:getBackPagePath(2) then
		self._ccbOwner.sp_helper_bg:setDisplayFrame(self._arrangement:getBackPagePath(2))
	end
	if self._arrangement:getBackPagePath(3) then
		self._ccbOwner.sp_helper2_bg:setDisplayFrame(self._arrangement:getBackPagePath(3))
	end
    CalculateUIBgSize(self._ccbOwner.sp_main_bg)
    CalculateUIBgSize(self._ccbOwner.sp_main_bg1)
    CalculateUIBgSize(self._ccbOwner.sp_helper_bg)
    CalculateUIBgSize(self._ccbOwner.sp_helper2_bg)
    CalculateUIBgSize(self._ccbOwner.sp_godarm_bg)
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

function QUIDialogMockTeamArrangement:createHeroHead(data_)
	local heroHead = QUIWidgetHeroHead.new()
	--heroHead:setHero(data_.actorId)
	heroHead:setHeroInfo(data_)

	if data_.cType == QMockBattle.CARD_TYPE_HERO then
		heroHead:setProfession(nil)
        -- heroHead:setLevel(data_.level)
        -- heroHead:setBreakthrough(data_.breakthrough)
        -- heroHead:setStar(data_.grade)
	elseif data_.cType == QMockBattle.CARD_TYPE_MOUNT then
        -- heroHead:setLevel(data_.uiModel.level)
        -- heroHead:setStar(data_.uiModel.grade)
	elseif data_.cType == QMockBattle.CARD_TYPE_SOUL then
        -- heroHead:setLevel(data_.uiModel.level)
        -- heroHead:setStar(data_.uiModel.grade)
	end
	heroHead:showSabc()
	heroHead:setScale(0.6)
	return heroHead
end


function QUIDialogMockTeamArrangement:initEnemyTeam()
	local enemy_data = remote.mockbattle:getMockBattleUserCenterBattle()
	if enemy_data == nil or next(enemy_data) == nil  then return end

	--enemy_info
	local enemy_battleInfo = enemy_data.battleInfo or {}
	local enemy_info = enemy_data.fighter or {}
	local main_4hero = enemy_battleInfo.mainHeroIds or {}
	local sub_4hero = enemy_battleInfo.sub1HeroIds or {}
	local wear_4hero = enemy_battleInfo.wearInfo or {}
	local soulSpiritId = enemy_battleInfo.soulSpiritId or 0
	local godArmIdList = enemy_battleInfo.godArmIdList or {}
	self.enemy_card_ids = {}
	self.enemy_card_ids[1] = {}
	self.enemy_card_ids[2] = {}

	self.enemy_card_nodes = {}
	self.enemy_card_nodes[1] = {}
	self.enemy_card_nodes[2] = {}


	for i, id in pairs(main_4hero) do
		table.insert(self.enemy_card_ids[1], {id = id , team_index = remote.teamManager.TEAM_INDEX_MAIN })
	end
	for i, id in pairs(sub_4hero) do
		table.insert(self.enemy_card_ids[1], {id = id , team_index = remote.teamManager.TEAM_INDEX_HELP })
	end
	if soulSpiritId ~= 0 then
		table.insert(self.enemy_card_ids[1], {id = soulSpiritId , team_index = remote.teamManager.TEAM_INDEX_MAIN })
	end
	for i, value in pairs(wear_4hero) do
		table.insert(self.enemy_card_ids[1], {id = value.zuoqiId , team_index = TEAM_INDEX_MOUNT })
	end
	for i, id in pairs(godArmIdList) do
		table.insert(self.enemy_card_ids[1], {id = id , team_index = remote.teamManager.TEAM_INDEX_GODARM  })
	end
	local  index_ = 1
	for i, value in pairs(self.enemy_card_ids[1]) do
		if index_ > 4 then
			break
		end
		local data_ = remote.mockbattle:getCardInfoByIndex(value.id)
		local heroHead = self:createHeroHead(data_)
        heroHead:setPositionX((index_ - 1) * 68)
        self._ccbOwner.node_enemycell_father1:addChild(heroHead)
        table.insert(self.enemy_card_nodes[1],heroHead)

        index_ = index_ +1
    end
	self._ccbOwner.tf_team1:setString(enemy_info.name or "")
	local enemy_battleInfo2 = enemy_data.battleInfo2 or {}
	if not q.isEmpty(enemy_battleInfo2) then

		local main_4hero = enemy_battleInfo2.mainHeroIds or {}
		local sub_4hero = enemy_battleInfo2.sub1HeroIds or {}
		local wear_4hero = enemy_battleInfo2.wearInfo or {}
		local soulSpiritId = enemy_battleInfo2.soulSpiritId or 0
		local godArmIdList = enemy_battleInfo2.godArmIdList or {}
		for i, id in pairs(main_4hero) do
			table.insert(self.enemy_card_ids[2], {id = id , team_index = remote.teamManager.TEAM_INDEX_MAIN })
		end
		for i, id in pairs(sub_4hero) do
			table.insert(self.enemy_card_ids[2], {id = id , team_index = remote.teamManager.TEAM_INDEX_HELP })
		end
		if soulSpiritId ~= 0 then
			table.insert(self.enemy_card_ids[2], {id = soulSpiritId , team_index = remote.teamManager.TEAM_INDEX_MAIN })
		end
		for i, value in pairs(wear_4hero) do
			table.insert(self.enemy_card_ids[2], {id = value.zuoqiId , team_index = TEAM_INDEX_MOUNT })
		end
		for i, id in pairs(godArmIdList) do
			table.insert(self.enemy_card_ids[2], {id = id , team_index = remote.teamManager.TEAM_INDEX_GODARM  })
		end
		index_ = 1
		for i, value in pairs(self.enemy_card_ids[2]) do
			if index_ > 4 then
				break
			end
			local data_ = remote.mockbattle:getCardInfoByIndex(value.id)
			local heroHead = self:createHeroHead(data_)
	        heroHead:setPositionX((index_ - 1) * 68)
	        self._ccbOwner.node_enemycell_father2:addChild(heroHead)
        	table.insert(self.enemy_card_nodes[2],heroHead)
	        index_ = index_ +1
	    end
	end

end


--初始化战队位置，是否显示魂灵
function QUIDialogMockTeamArrangement:initTeamPos()
	local pos = NORMAL_POS
	self._ccbOwner["node_soul_1"]:setVisible(false)
	self._ccbOwner["node_soul_info"]:setVisible(false)
	self._ccbOwner["node_godarm_info"]:setVisible(false)

	self._ccbOwner["node_soul_1"]:setScale(0.82)
	self._ccbOwner["node_soul_1"]:setVisible(true)
	self._ccbOwner["enable_soul1"]:setVisible(true)
	self._ccbOwner["disable_soul1"]:setVisible(false)
	self._ccbOwner["light_soul1"]:setVisible(true)
	self._ccbOwner["node_soul_info"]:setVisible(true)
	pos = HAVE_SOUL_POS
	for i = 1, 4 do
		self._ccbOwner["node_avatar_"..i]:setScale(0.82)
		self._ccbOwner["node_helper_"..i]:setScale(0.82)
	end
	for i = 1, 4 do
		self._ccbOwner["node_avatar_"..i]:setPosition(pos[i].x, pos[i].y)
	end
end


function QUIDialogMockTeamArrangement:initHero(availableHeroIDs)
	local availableHero = {}
	local availableHero2 = {}

	local idsMap ={}
	--QPrintTable(availableHeroIDs)


	for i, actorId in pairs(availableHeroIDs) do
		local hero_info = remote.mockbattle:getCardInfoByIndex(actorId)
		local characher = QStaticDatabase:sharedDatabase():getCharacterByID(hero_info.actorId)

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
		local force  = 0
		if hero_info then
			force = hero_info.force
		end
		idsMap[hero_info.id] = hero_info.actorId

		availableHero[hero_info.actorId] = {id = hero_info.id ,actorId = hero_info.actorId, type = heroType, hatred = hatred, index = 0, force = force}
		--availableHero[hero_info.actorId].arrangement = self._arrangement
	end

	local teamVs = self:getMockBattleTeam(true) 
	for teamIdx,teamVO in ipairs(teamVs) do
		local maxIndex = teamVO:getTeamMaxIndex()
		for i=1,maxIndex do
			local actorIds = teamVO:getTeamActorsByIndexAndTeamIdx(i,teamIdx)
			if actorIds ~= nil then
				for _,v in ipairs(actorIds) do
					if availableHero[idsMap[v]] then
						availableHero[idsMap[v]].index = i
						availableHero[idsMap[v]].trialNum = teamIdx
					end
				end
			end
		end		
	end
	return availableHero
end

function QUIDialogMockTeamArrangement:initSoulSpirit(allSoulSpirits)
	local soulSpirits = {}

	local teamVs = self:getMockBattleTeam(true) 
	local teams_soulSpirits = {}

	for i,teamVO in ipairs(teamVs) do
		teams_soulSpirits[i] = teamVO:getTeamSpiritsByIndexAndTeamIdx( remote.teamManager.TEAM_INDEX_MAIN,i)
	end
	
	for i, index_ in pairs(allSoulSpirits) do
		local _info = remote.mockbattle:getCardInfoByIndex(index_)
		local force = 0
		local _index = 0 
		local trialNum = 0 
		for trial_idx,soulSpiritIds in ipairs(teams_soulSpirits) do
			for _, id in ipairs(soulSpiritIds) do
				if id == index_ then
					_index =  remote.teamManager.TEAM_INDEX_MAIN
					trialNum = trial_idx
				end
			end	
		end
		soulSpirits[_info.actorId] = {id = _info.id ,soulSpiritId = _info.actorId, index = _index, force = force , trialNum = trialNum}
	end
	return soulSpirits
end

function QUIDialogMockTeamArrangement:initMount(allMounts)
	local mounts = {}
	local teamVs = self:getMockBattleTeam(true) 
	local teams_mountIds = {}

	for i,teamVO in ipairs(teamVs) do
		teams_mountIds[i] = teamVO:getTeamMountsByIndexAndTeamIdx( remote.teamManager.TEAM_INDEX_MAIN , i)
	end
	for i, index_ in pairs(allMounts) do
		local _info = remote.mockbattle:getCardInfoByIndex(index_)
		local force = 0
		local _ipos = 99 
		local _index = 0 
		local trialNum = 0 
		for trial_idx,mountIds in ipairs(teams_mountIds) do
			for pos, id in pairs(mountIds) do
				if id == index_ then
					_ipos = pos
					_index =  remote.teamManager.TEAM_INDEX_MAIN
					trialNum = trial_idx
				end
			end
		end
		mounts[_info.actorId] = {id = _info.id ,mountId = _info.actorId, index = _index, force = force,pos = _ipos , trialNum = trialNum}
	end

	return mounts
end


function QUIDialogMockTeamArrangement:initGodarmList(godarmList)

	if q.isEmpty(godarmList) then return {} end 

	local godarmArray = {}
	for i, index_ in pairs(godarmList) do
		local godarmInfo = remote.mockbattle:getCardInfoByIndex(index_)
		godarmArray[godarmInfo.id] = {id = godarmInfo.id ,godarmId = godarmInfo.actorId, grade = godarmInfo.grade,level = godarmInfo.level,index = 0, pos = 5,force = 0}--force = godarmInfo.main_force
	end

	local teamVs = self:getMockBattleTeam(true) 
	for i,teamVO in ipairs(teamVs) do
		local maxIndex = teamVO:getTeamMaxIndex()
		local godarmIds = teamVO:getTeamGodarmByIndexAndTeamIdx(remote.teamManager.TEAM_INDEX_GODARM,i)
		for pos, godarmId in ipairs(godarmIds) do
			if godarmArray[godarmId] then
				godarmArray[godarmId].index = remote.teamManager.TEAM_INDEX_GODARM
				godarmArray[godarmId].pos = pos
				godarmArray[godarmId].trialNum = i
			end
		end
	end

	return godarmArray
end



function QUIDialogMockTeamArrangement:viewDidAppear()
	QUIDialogMockTeamArrangement.super.viewDidAppear(self)
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

    	local heroHead = QUIWidgetHeroHead.new()
        heroHead:setScale(0.7)
        --heroHead:setVisible(false)
        heroHead:setHeroByFile(1, "ui/update_mockbattle/sp_anqi_icon.jpg", 1)
        self._ccbOwner["mount_card_"..i]:addChild(heroHead)	
	    table.insert(self._mountNodes, heroHead)
	end

	local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    if animationManager ~= nil then 
		animationManager:stopAnimation()
    end
end

function QUIDialogMockTeamArrangement:viewWillDisappear()
	QUIDialogMockTeamArrangement.super.viewWillDisappear(self)
	self._arrangement:viewWillDisappear()

	self:removeBackEvent()

    if self._widgetHeroArrayProxy then
	  	self._widgetHeroArrayProxy:removeAllEventListeners()
	  	self._widgetHeroArrayProxy = nil
	end
	-- if self._forceUpdate then
	-- 	self._forceUpdate:stopUpdate()
	-- 	self._forceUpdate = nil
	-- end
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

function QUIDialogMockTeamArrangement:nodeEffect(node)
	if node ~= nil then
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
	    local ccsequence = CCSequence:create(actionArrayIn)
		node:runAction(ccsequence)
	end
end

function QUIDialogMockTeamArrangement:playForceEffect(change)
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

function QUIDialogMockTeamArrangement:_onForceUpdate(value)
    local word = nil
    if value >= 1000000 then
      word = tostring(math.floor(value/10000)).."万"
    else
      word = math.floor(value)
    end
    --self._ccbOwner.force:setString(word)
    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(value,true)
    if fontInfo ~= nil then
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.force:setColor(ccc3(color[1], color[2], color[3]))
    end
end

function QUIDialogMockTeamArrangement:playProp(avatar,desc,value)
	if value == nil then value = 0 end
	value = math.floor(value)
	if value > 0 then
		table.insert(self._effectProps, desc..value)
	end
end

function QUIDialogMockTeamArrangement:playAllProp()
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


function QUIDialogMockTeamArrangement:_onHeroChanged(event)
	self._heroList = event.hero or {}
	self._spiritList = event.soulSpirits or {}
	self._mountList = event.mountList or {}
	self._godarmList = event.godarmList or {}
	-- if event.idtype then
	-- 	if event.idtype == QUIWidgetMockBattleArray.HERO_TYPE then
	-- 		self._heroList = event.hero or {}
	-- 	elseif event.idtype == QUIWidgetMockBattleArray.MOUNT_TYPE then
	-- 		self._mountList = event.mountList or {}
	-- 	elseif event.idtype == QUIWidgetMockBattleArray.SOUL_TYPE then
	-- 		self._spiritList = event.soulSpirits or {}
	-- 	elseif event.idtype == QUIWidgetMockBattleArray.GODARM_TYPE then
	-- 		self._godarmList = event.godarmList or {}
	-- 	end
	-- else
	-- 	self._heroList = event.hero or {}
	-- 	self._spiritList = event.soulSpirits or {}
	-- 	self._mountList = event.mountList or {}
	-- 	self._godarmList = event.godarmList or {}
	-- end
	table.sort(self._heroList, function (x, y)
		if x.hatred == y.hatred then
			return x.force > y.force
		end
		return x.hatred > y.hatred
	end )
	
	local handler_func = function ()
		if not self:safeCheck() then
			return
		end

		if event.victoryId == nil then --下阵不自动跳转
			print("event.victoryId == nil 下阵不自动跳转")
			return
		end


		local unlockMainCount = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_MAIN)
		local unlockHelp1Count = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP)
		local unlockHelp2Count = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP2)
		local unlockHelp3Count = self._arrangement:getUnlockSlots(remote.teamManager.TEAM_INDEX_HELP3)
		local help1Count = 0 
		local help2Count = 0
		local help3Count = 0
		local mainTeamCount = 0 

		local isUnlockHelper = self._seasonType == QMockBattle.SEASON_TYPE_SINGLE
  		local isUnlockGodArm = self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE



		for _,value in pairs(self._allHeroList) do
			if value.trialNum == self._selectTrialNum then 
				if value.index == remote.teamManager.TEAM_INDEX_MAIN then
					mainTeamCount = mainTeamCount + 1
				elseif value.index == remote.teamManager.TEAM_INDEX_HELP then
					help1Count = help1Count + 1
				elseif value.index == remote.teamManager.TEAM_INDEX_HELP2 then
					help2Count = help2Count + 1
				elseif value.index == remote.teamManager.TEAM_INDEX_HELP3 then
					help3Count = help3Count + 1
				end
			end
		end


		local spiritCount = 0
		for _, value in pairs(self._allSpiritList) do
			if value.trialNum == self._selectTrialNum then
				spiritCount = spiritCount + 1
			end
		end

		local mountCount = 0

		for _, value in pairs(self._allMountList) do
			if value.trialNum == self._selectTrialNum then
				mountCount = mountCount + 1
			end
		end

		local teamVO = self:getMockBattleTeam()
		local toSoul = spiritCount < teamVO:getSpiritsMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN,true) 
		local toMount =  mountCount < mainTeamCount
		local toMain =  mainTeamCount < unlockMainCount
		local toGodarm = false
		local toHelp = false
		local check_main = true
		
		if self._seasonType == QMockBattle.SEASON_TYPE_SINGLE then

			toHelp =  help1Count < unlockHelp1Count
			self._widgetHeroArray:handlerTag(self._selectIndex , toMain , toHelp , toSoul, toMount, toGodarm )

			-- if toMain then
			-- 	self._widgetHeroArray:_onTriggerHero()
			-- elseif toSoul or toMount  then
			-- 	self._widgetHeroArray:handlerSoulAndMount(toMount,toSoul)
			-- elseif toHelp then
			-- 	self._widgetHeroArray:_onTriggerHero()
			-- 	check_main = false
			-- 	if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
			-- 		self._widgetHeroArray:onTriggerHelper()
			-- 	end
			-- else
			-- 	self._widgetHeroArray:_onTriggerHero()
			-- end
		elseif self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE then

			local godarm_maxnum =  teamVO:getHerosGodArmMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
			local godarmCount = 0
			for _, value in pairs(self._allGodarmList) do
				if value.trialNum == self._selectTrialNum then
					godarmCount = godarmCount + 1
				end
			end
			toGodarm =  godarmCount < godarm_maxnum
			self._widgetHeroArray:handlerTag(self._selectIndex , toMain , toHelp , toSoul, toMount, toGodarm )

			-- if toMain then
			-- 	self._widgetHeroArray:_onTriggerHero()
			-- elseif toSoul or toMount  then
			-- 	self._widgetHeroArray:handlerSoulAndMount(toMount,toSoul)
			-- elseif toGodarm then
			-- 	check_main = false
			-- 	self._widgetHeroArray:onTriggerGodarm()
			-- elseif self._selectTrialNum == 1 then
			-- 	self:_onTriggerChangeTeam2()
			-- else
			-- 	self._widgetHeroArray:_onTriggerHero()
			-- end
			if self._selectTrialNum == 1 
			and toHelp == false 
			and toSoul == false 
			and toMount == false 
			and toGodarm == false 
			and toMain == false 
			then
				self:_onTriggerChangeTeam2()
				self._widgetHeroArray:onTriggerMain()
			end


		end


		-- if check_main and self._selectIndex ~= remote.teamManager.TEAM_INDEX_MAIN then
		-- 	self._widgetHeroArray:onTriggerMain()
		-- end
		-- local teamVO = remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)

		-- if isUnlockGodArm and self._selectTrialNum == 1 and not to_soul and not to_mount and godarmCount >= godarm_maxnum then
		-- 	self._widgetHeroArray:onTriggerMain()
		-- 	self:_onTriggerChangeTeam2()
		-- elseif self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN and #self._heroList >= unlockMainCount and event.victoryId ~= nil then
		-- 	if to_soul then
		-- 		if to_mount then
		-- 			self._widgetHeroArray:_onTriggerSoul(QUIWidgetMockBattleArray.SPECIAL_TYPE)
		-- 		else
		-- 			self._widgetHeroArray:_onTriggerSoul(CCControlEventTouchUpInside)
		-- 		end
  -- 			elseif to_mount then
		-- 		self._widgetHeroArray:_onTriggerMount(CCControlEventTouchUpInside)
		-- 	elseif to_godarm then
		-- 		self._widgetHeroArray:onTriggerGodarm()
		-- 	elseif unlockHelp1Count > help1Count  and isUnlockHelper then
		-- 		self._widgetHeroArray:_onTriggerHero()
		-- 		self._widgetHeroArray:onTriggerHelper()
		-- 	elseif unlockHelp2Count > help2Count and isUnlockHelper  then
		-- 		--self._widgetHeroArray:onTriggerHelper2()
		-- 	elseif unlockHelp3Count > help3Count and isUnlockHelper then
		-- 		--self._widgetHeroArray:onTriggerHelper3()
		-- 	end
		-- elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM and godarmCount >= godarm_maxnum then
		-- 	self._widgetHeroArray:onTriggerMain()
		-- elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP and #self._heroList >= unlockHelp1Count and isUnlockHelper  then
		-- 	self._widgetHeroArray:onTriggerMain()
		-- 	if unlockHelp2Count > help2Count then
		-- 		---self._widgetHeroArray:onTriggerHelper2()
		-- 	end
		-- elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 and #self._heroList >= unlockHelp2Count and isUnlockHelper  then
		-- 	if unlockHelp3Count > help3Count then
		-- 		--elf._widgetHeroArray:onTriggerHelper3()
		-- 	end
		-- elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 and #self._heroList >= unlockHelp3Count and isUnlockHelper  then
		-- 	self._widgetHeroArray:onTriggerMain()
		-- end



	end

	self:update(event.idtype,event.victoryId, handler_func)

end





function QUIDialogMockTeamArrangement:_onHeroChangedTab(event)
	if self._effectCombination then
		self._effectCombination:stopAnimation()
		self._effectCombination = nil
	end
	self._teamIndex = event.index or 1
	self._selectAlternate = event.isAlternate or false

	if not next(self._heroHelperAvatars) then
		for i = 1, TEAM_MAX_NUM do -- helper
			local avatar = QUIWidgetHeroInformation.new()
			self._ccbOwner["heroH"..i]:addChild(avatar)
			avatar:setVisible(false)
	        avatar:setBackgroundVisible(false)
		    avatar:setNameVisible(false)
		    avatar:setStarVisible(false)
		    --avatar:setForceVisible(false)
		    table.insert(self._heroHelperAvatars, avatar)
		end
	end
	if self._teamIndex == remote.teamManager.TEAM_INDEX_MAIN then
		self._ccbOwner.node_left:setVisible(true)
		self._ccbOwner.node_right:setVisible(false)
		self._ccbOwner.node_btn_battle_aid:setVisible(false)
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP then
		self._ccbOwner.node_left:setVisible(false)
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP2 then
		self._ccbOwner.node_left:setVisible(app.unlock:getUnlockTeamAlternateHelp10())
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_HELP3 then
		self._ccbOwner.node_left:setVisible(false)
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
	elseif self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._ccbOwner.node_left:setVisible(false)
		self._ccbOwner.node_right:setVisible(true)
		self._ccbOwner.node_btn_battle_aid:setVisible(true)
	end
	self:showLeftBtn(self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM)		

	if self._isInitAni then
		self._isInitAni = false
		return
	end

	self:updateLockState()
	print("self._teamIndex = "..self._teamIndex)
	local animationName
	local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	if self._teamIndex == remote.teamManager.TEAM_INDEX_MAIN then
		if  self._selectIndex  == -1 then
			animationName = "aid"
		elseif self._selectAlternate and self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
			animationName = "right_to_main"
		else
			animationName = "left_to_main"
	    end
	else
		if self._teamIndex > self._selectIndex then 
			animationName = "right_to_help"
		else
			self._ccbOwner.sp_godarm_bg:setVisible(self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM)
			animationName = "left_to_help"
	    end
	end
	animationManager:runAnimationsForSequenceNamed(animationName)
	if self._animationScheduler ~= nil then
		scheduler.unscheduleGlobal(self._animationScheduler)
		self._animationScheduler = nil
	end

	self._animationScheduler = scheduler.performWithDelayGlobal(function ( ... )
		local mainBg = animationName == "right_to_main" or animationName == "left_to_main" or animationName == "aid"
		self._ccbOwner.sp_main_bg:setVisible(mainBg)
		local helpBg = animationName == "right_to_help" or animationName == "left_to_help"
		self._ccbOwner.sp_helper_bg:setVisible(helpBg)
		local help2Bg = false
		self._ccbOwner.sp_helper2_bg:setVisible(helpBg)
		self._ccbOwner.sp_godarm_bg:setVisible(self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM)
	end, 0.2)

end

function QUIDialogMockTeamArrangement:showLeftBtn(isGodarmTab)
	if isGodarmTab then
		self._ccbOwner["node_godarm_info"]:setVisible(remote.godarm:checkGodArmUnlock())
		self._ccbOwner["node_soul_info"]:setVisible(false)
	else
		self._ccbOwner["node_soul_info"]:setVisible(app.unlock:checkLock("UNLOCK_SOUL_SPIRIT", false))
		self._ccbOwner["node_godarm_info"]:setVisible(false)
	end
end

function QUIDialogMockTeamArrangement:update(idType ,victoryId, callback)
	self._selectIndex = self._widgetHeroArray:getSelectIndex()
	-- if false then
	-- 	if idType == QUIWidgetMockBattleArray.HERO_TYPE then
	-- 		self:updateHero(victoryId, callback)
	-- 	elseif idType == QUIWidgetMockBattleArray.MOUNT_TYPE then
	-- 		self:updateMount(victoryId, callback)
	-- 	elseif idType == QUIWidgetMockBattleArray.SOUL_TYPE then
	-- 		self:updateSpirit(victoryId, callback)
	-- 	elseif idType == QUIWidgetMockBattleArray.GODARM_TYPE then
	-- 		self:updateGodArm(victoryId, callback)		
	-- 	end
	-- else
		
	-- end
	self:updateHero(victoryId, callback)
	self:updateMount(victoryId, callback)
	self:updateSpirit(victoryId, callback)
	self:updateGodArm(victoryId, callback)	

	--self:updateForceDisplay()
	self:updateAssistSkill()
end


function QUIDialogMockTeamArrangement:updateEnemyInfo( )

	if self._seasonType ~= QMockBattle.SEASON_TYPE_DOUBLE then
		self._ccbOwner["node_enemyInfo1"]:setPositionX(0)
		self._ccbOwner["node_enemyInfo2"]:setVisible(false)
		self._ccbOwner.node_btn_next:setVisible(false)
		return
	end

	local size_table ={{330 , 125 },{125 , 330} }
	local btn_pos_table ={{136 , 31 },{31 , 136} }
	local father_pos_table ={{-116 , -20 },{ -20, -116} }
	local pos_node_table ={{-127 , 104 },{-228,0} }

	self._ccbOwner.tf_team1:setString("敌方战队1")
	self._ccbOwner.tf_team2:setString("敌方战队2")

	for i=1,2 do
		self._ccbOwner["node_enemyInfo"..i]:setPositionX(pos_node_table[self._selectTrialNum][i])
		self._ccbOwner["node_enemycell_father"..i]:setPositionX(father_pos_table[self._selectTrialNum][i])
		self._ccbOwner["btn_enemyinfo"..i]:setPositionX(btn_pos_table[self._selectTrialNum][i])
		self._ccbOwner["sp_enemy_bg"..i]:setContentSize(CCSize(size_table[self._selectTrialNum][i],100))
	end

	local max_team_num = #self._arrangements
	self._ccbOwner.node_btn_next:setVisible( self._selectTrialNum~=max_team_num)

	for i=1,max_team_num do
		local num = self._selectTrialNum == i and 4 or 1
		for j,v in ipairs(self.enemy_card_nodes[i]) do
			v:setVisible(j<= num)
		end
	end
end


function QUIDialogMockTeamArrangement:changeTrialInfo()
	-- for i,v in ipairs(self._arrangements) do
	-- 	remote.teamManager:updateTeamData(v:getTeamKey(), self:_getSelectTeams(i))
	-- end

	self._arrangement = self._arrangements[self._selectTrialNum]
	if self._arrangement then
		self._unlockedSlot = self._arrangement:getUnlockSlots()
		self._unlockedMountSlot = self._arrangement:getUnlockSlots()
		-- self._allHeroList = self:initHero(self._arrangement:getHeroes())
		-- self._allSpiritList = self:initSoulSpirit(self._arrangement:getSoulSpirits())
		-- self._allMountList = self:initMount(self._arrangement:getMounts())
		-- self._allGodarmList = self:initGodarmList(self._arrangement:getHaveGodarmList() or {})
		local options = {
			unlockNumber = self._unlockedSlot, 
			unlockMountNumber = self._unlockedMountSlot, 
			-- heroList = self._allHeroList, 
			-- soulSpiritList = self._allSpiritList, 
			-- mountList = self._allMountList, 
			-- godarmList = self._allGodarmList,
			arrangement = self._arrangement,
			state = self._arrangement:showHeroState(), 
			trialNum = self._selectTrialNum,
			tips = self._arrangement:getPrompt()
		}
		self._widgetHeroArray:updateArrangement(options)
		self._widgetHeroArray:_updatePage()
		self._widgetHeroArray:notificationMainPage()
	end

	self:setTrailInfo()
end


function QUIDialogMockTeamArrangement:setTrailInfo()
	self:updateEnemyInfo()

end


function QUIDialogMockTeamArrangement:updateHero( victoryId, callback)

	print("QUIDialogMockTeamArrangement:updateHero ")
	self:updateLockState()
	local heroList = self._heroList
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

	local add_hero_pos = 0

	local slot = 1
	local isSelectSkill = false
	for k, v in pairs(heroList) do
		local avatar = nil
		if v.index == remote.teamManager.TEAM_INDEX_HELP or 
			v.index == remote.teamManager.TEAM_INDEX_HELP2 or
			v.index == remote.teamManager.TEAM_INDEX_HELP3 then--援助魂师

			avatar = self._heroHelperAvatars[slot]
			avatar:setInfotype("QUIDialogMockTeamArrangement")
			avatar:setMockBattleAvatar(v.id,v.actorId, AVATAR_SCALE)
		    avatar:setStarVisible(false)			
		    avatar:setHpMp(v.hpScale, v.mpScale)

			self._ccbOwner["sp_team"..slotIndex.."_"..slot]:setVisible(true)
			self._ccbOwner["node_skill"..slot]:setVisible(true)
			if self._selectHero == nil and k == 1 then
				self:selectSkill(k)
				isSelectSkill = true
			elseif self._selectHero == v.id then 
				self:selectSkill(k)
				isSelectSkill = true
			elseif not isSelectSkill then
				self:selectSkill(k)
				isSelectSkill = true
			end
			--头上显示技能
			local skillConfig = remote.herosUtil:getManualSkillsByActorId(v.actorId)
			if skillConfig ~= nil then
				local texture = CCTextureCache:sharedTextureCache():addImage(skillConfig.icon)
				self._ccbOwner["sp_skill"..slot]:setTexture(texture)
			    local size = texture:getContentSize()
			    local rect = CCRectMake(0, 0, size.width, size.height)
			    self._ccbOwner["sp_skill"..slot]:setTextureRect(rect)
			end
		else--主力魂师
			avatar = self._heroAvatars[slot]
			avatar:setInfotype("QUIDialogMockTeamArrangement")
			avatar:setMockBattleAvatar(v.id,v.actorId, AVATAR_SCALE)
		    avatar:setStarVisible(false)				
		    avatar:setHpMp(v.hpScale, v.mpScale)
		    if victoryId == v.actorId then
		    	add_hero_pos = slot
		    end
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

		    local preparation = nil
		    --local heroInfo = remote.herosUtil:getHeroByID(v.actorId)
		    -- if heroInfo.skinId then
		    -- 	local skinConfig = db:getHeroSkinConfigByID(heroInfo.skinId)
		    -- 	preparation = skinConfig.preparation
		    -- end
		    if not preparation then
		    	local heroDisplay = db:getCharacterByID(v.actorId)
		    	preparation = heroDisplay.preparation
		    end
			app.sound:playSound(preparation)
				
			--如果是援助魂师浮动显示属性加成
			if v.index == remote.teamManager.TEAM_INDEX_HELP or v.index == remote.teamManager.TEAM_INDEX_HELP2 then
				local heroModel = remote.mockbattle:getCardUiInfoById(v.actorId)
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

	if add_hero_pos ~= 0 then
		self._widgetHeroArray:moveBackMountByHeroPos(add_hero_pos,self._selectTrialNum )
	end

end


function QUIDialogMockTeamArrangement:updateMount( victoryId, callback)

	local cur_main_hero_num = self._widgetHeroArray:getCurMainHeroNum(self._selectTrialNum)

	local  mountList = self._mountList
	for i= 1 ,4 do
		self._mountNodes[i]:hideSabc()
        self._mountNodes[i]:setHeroByFile(1, "ui/update_mockbattle/sp_anqi_icon.jpg", 1)
		self._ccbOwner["mount_effect_"..i]:setVisible(cur_main_hero_num >= i)
		--self._mountNodes[i]:setVisible(false)
	end
	local t_pos = 1
	for k, v in pairs(mountList) do
		if v.pos < 5 and v.trialNum == self._selectTrialNum then
			local heroHead = self._mountNodes[v.pos]
			if victoryId == v.mountId then
				if self._handleCombinedSkill then
					scheduler.unscheduleGlobal(self._handleCombinedSkill)
					self._handleCombinedSkill = nil
				end
				self._handleCombinedSkill = scheduler.performWithDelayGlobal(function()
					callback()
				end, 0)

				--flyAction
				local move_start_pos = self._widgetHeroArray:getTempPosition()
				if move_start_pos then
					t_pos = clone(v.pos)
					local heroHeadfly = QUIWidgetHeroHead.new()
					heroHeadfly:setScale(2)
					heroHeadfly:setHero(v.mountId)
					heroHeadfly:showSabc()
					self._ccbOwner["mount_card_"..t_pos]:addChild(heroHeadfly)	
					local startpos = self._ccbOwner["mount_card_"..t_pos]:convertToNodeSpace(move_start_pos)
					heroHeadfly:setPosition(startpos)
					local dur = 0.5
					local array2 = CCArray:create()
				    array2:addObject(CCMoveTo:create(dur, ccp(0,0)))
				    array2:addObject(CCScaleTo:create(dur, 0.7))
				    local arr = CCArray:create()
				    arr:addObject(CCSpawn:create(array2))
				    arr:addObject(CCCallFunc:create(function()
				    	if v.trialNum == self._selectTrialNum then
							heroHead:setHero(v.mountId)
							heroHead:showSabc()
				    	end
						heroHeadfly:removeFromParent()
				      	self._widgetHeroArray:setNullTempPosition()
						self._ccbOwner["mount_effect_"..t_pos]:setVisible(false)
				    end))
					heroHeadfly:runAction(CCSequence:create(arr))
				end

			else
				heroHead:setHero(v.mountId)
				self._ccbOwner["mount_effect_"..v.pos]:setVisible(false)
				heroHead:showSabc()
			end
		end
	end
	
	local isShow = true
	for i=1,4 do
		if self._ccbOwner["mount_effect_"..i]:isVisible() and isShow then
			isShow = false
		else
			self._ccbOwner["mount_effect_"..i]:setVisible(false)
		end
	end


end


function QUIDialogMockTeamArrangement:updateSpirit( victoryId, callback)
	if app.unlock:checkLock("UNLOCK_SOUL_SPIRIT", false)  then
		if self._widgetSoulSpirit[1] then
			self._widgetSoulSpirit[1]:removeFromParent()
			self._widgetSoulSpirit[1] = nil
		end
		local soulSpiritId = 0
		--计算当前的精灵列表的战力`
		for _,v in pairs(self._allSpiritList) do
			if v.trialNum == self._selectTrialNum then
				soulSpiritId = v.soulSpiritId
			end
		end
		print("soulSpiritId     :"..soulSpiritId)

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
end

function QUIDialogMockTeamArrangement:updateGodArm( victoryId, callback)
	if app.unlock:checkLock("UNLOCK_GOD_ARM", false) then

		--QPrintTable(self._godarmList)
		for i=1,2 do
			self:selectGodarmSkill(i ,false)
		end
		for k, v in pairs(self._godarmList) do
			local avatar = nil
			if v.index == remote.teamManager.TEAM_INDEX_GODARM and v.trialNum == self._selectTrialNum  then
				if self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM and v.pos ~= 5 then
					local slot = v.pos or 1
					avatar = self._heroHelperAvatars[slot]
					avatar:setInfotype("QUIDialogMockTeamArrangement")
					avatar:setAvatar(v.godarmId, AVATAR_SCALE)
				    avatar:setStarVisible(false)	
	    			avatar:setVisible(true)
					avatar:setNameVisible(false)
					avatar:setGodarmInfo(v.godarmId)	
					avatar:setHpMp()
					avatar:setPositionY(50)

					self:selectGodarmSkill(slot , true)
					self._ccbOwner["node_skill"..slot]:setVisible(true)
					--self._ccbOwner["node_skill"..slot]:setPositionY(250)
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
			end	
		end	
	end
end




function QUIDialogMockTeamArrangement:updateForceDisplay()
	--notice 魂师与暗器需要结合计算
	local force = 0
	for _,v in pairs(self._allHeroList) do
		if v.index == remote.teamManager.TEAM_INDEX_MAIN or
			v.index == remote.teamManager.TEAM_INDEX_HELP or 
			v.index == remote.teamManager.TEAM_INDEX_HELP2 or
			v.index == remote.teamManager.TEAM_INDEX_HELP3 then 
			force = force + v.force 
		end
	end
	for _,v in pairs(self._allSpiritList) do
		if v.index ~= 0 then
			local soulForce = remote.soulSpirit:countForceBySpiritIds({v.soulSpiritId})
			force = force + soulForce
		end
	end
 
	local change = force - self._force
	if force ~= self._force and victoryId then
		self:nodeEffect(self._ccbOwner.force)
	end

	--self._forceUpdate:addUpdate(self._force, force, handler(self, self._onForceUpdate), NUMBER_TIME)

	if self._force > 0 then 
		self:playForceEffect(change)
	end

	self._force = force	
end


function QUIDialogMockTeamArrangement:updateAssistSkill()
	for i = 1, 4, 1 do
		self._ccbOwner["node_skill_"..i]:setVisible(false)
		self._ccbOwner["effect_"..i]:setVisible(false)
	end

	local index = 1
	while self._heroList[index] do 
		local actorId = self._heroList[index].actorId
		local assistSkill, haveAssistHero = remote.mockbattle:checkHeroHaveAssistHero(actorId)
		if assistSkill then
			self._ccbOwner["node_skill_"..index]:setVisible(true)
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

--

function QUIDialogMockTeamArrangement:_onTriggerClick1( )
	if self._unlockedSlot < 1 then
		return
	end
	self:withdrawHero(1)
end

function QUIDialogMockTeamArrangement:_onTriggerClick2( )
	if self._unlockedSlot < 2 then
		
		return
	end
	self:withdrawHero(2)
end

function QUIDialogMockTeamArrangement:_onTriggerClick3( )
	if self._unlockedSlot < 3 then
		return
	end
	self:withdrawHero(3)
end

function QUIDialogMockTeamArrangement:_onTriggerClick4( )
	if self._unlockedSlot < 4 then
		return
	end
	self:withdrawHero(4)
end

--卸下魂师
function QUIDialogMockTeamArrangement:withdrawHero(index_)
	-- body
	if self._selectIndex ~= remote.teamManager.TEAM_INDEX_GODARM then
		if self._heroList[index_] then
			if self._selectHero == self._heroList[index_].actorId then
				self._selectHero = nil
				self._selectSkillHero = nil
			end
			if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
				self._widgetHeroArray:removeSelectedMountByHeroPos(index_,self._selectTrialNum )
			end
			self._widgetHeroArray:removeSelectedHero(self._heroList[index_].actorId)
			table.remove(self._heroList, index_)
			self:update(QUIWidgetMockBattleArray.HERO_TYPE)
		end	
	else
		if index_ > 2 then
			app.tip:floatTip("该位置神器布置未开启")
			return
		end

		for index,v in pairs(self._godarmList) do
			if v.pos == 1 then
				self._widgetHeroArray:removeSelectedGodarm(self._godarmList[index].godarmId)
				table.remove(self._godarmList, index)
				self:update(QUIWidgetMockBattleArray.GODARM_TYPE)
				break
			end
		end	
	end
end


function QUIDialogMockTeamArrangement:_onTriggerMount1( )
	if self._unlockedSlot < 1 then
		return
	end
	self:withdrawMount(1)
end

function QUIDialogMockTeamArrangement:_onTriggerMount2( )
	if self._unlockedSlot < 2 then
		
		return
	end
	self:withdrawMount(2)
end

function QUIDialogMockTeamArrangement:_onTriggerMount3( )
	if self._unlockedSlot < 3 then
		return
	end
	self:withdrawMount(3)
end

function QUIDialogMockTeamArrangement:_onTriggerMount4( )
	if self._unlockedSlot < 4 then
		return
	end
	self:withdrawMount(4)
end

--卸下暗器
function QUIDialogMockTeamArrangement:withdrawMount(index_)
	-- body
	for k, mount_ in pairs(self._mountList) do
		if mount_.pos == index_ then
			self._widgetHeroArray:removeSelectedMount(mount_.mountId)
			self:update(QUIWidgetMockBattleArray.MOUNT_TYPE)
		end
	end
end


function QUIDialogMockTeamArrangement:_onTriggerClickSoul1( )
	if self._spiritList[1] then
		self._widgetHeroArray:removeSelectedSoulSpirit(self._spiritList[1].soulSpiritId)
		table.remove(self._spiritList, 1)
		self:update(QUIWidgetMockBattleArray.SOUL_TYPE)
	end
end

function QUIDialogMockTeamArrangement:_onTriggerClickH1( )
	if self._unlockedSlot < 1 then
		return
	end
	self:withdrawHero(1)
end

function QUIDialogMockTeamArrangement:_onTriggerClickH2( )
	if self._unlockedSlot < 2 then
		return
	end
	self:withdrawHero(2)
end

function QUIDialogMockTeamArrangement:_onTriggerClickH3( )
	if self._unlockedSlot < 3 then
		return
	end
	self:withdrawHero(3)
end

function QUIDialogMockTeamArrangement:_onTriggerClickH4( )
	if self._unlockedSlot < 4 then
		return
	end
	self:withdrawHero(4)
end

function QUIDialogMockTeamArrangement:_onTriggerSkill1()
	self:_HandleTriggerSkill(1)
end

function QUIDialogMockTeamArrangement:_onTriggerSkill2()
	self:_HandleTriggerSkill(2)
end

function QUIDialogMockTeamArrangement:_onTriggerSkill3()
	self:_HandleTriggerSkill(3)
end

function QUIDialogMockTeamArrangement:_onTriggerSkill4()
	self:_HandleTriggerSkill(4)

end

function QUIDialogMockTeamArrangement:_HandleTriggerSkill(index)
	if self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		return
	end

	self:selectSkill(index)
	app.tip:floatTip("设置成功！该魂技将作为战斗中的援助魂技！")
	self._selectHero = self._heroList[index].actorId
end

function QUIDialogMockTeamArrangement:selectGodarmSkill(slot,isVisible)
	if slot and self._ccbOwner["node_skill_select"..slot] then
		self._ccbOwner["node_skill_select"..slot]:setVisible(isVisible)
	end
	if slot and self._ccbOwner["sp_team_godarm_"..slot] then
		self._ccbOwner["sp_team_godarm_"..slot]:setVisible(isVisible)
	end	
end



function QUIDialogMockTeamArrangement:_onTriggerAssistSkill1()
	self:_openHeroDetail(self._heroList[1].actorId)
end

function QUIDialogMockTeamArrangement:_onTriggerAssistSkill2()
	self:_openHeroDetail(self._heroList[2].actorId)
end

function QUIDialogMockTeamArrangement:_onTriggerAssistSkill3()
	self:_openHeroDetail(self._heroList[3].actorId)
end

function QUIDialogMockTeamArrangement:_onTriggerAssistSkill4()
	self:_openHeroDetail(self._heroList[4].actorId)
end


function QUIDialogMockTeamArrangement:selectSkill(slot)

	if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then 
		self._selectSkillHero1 = self._heroList[slot].id
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then 
		self._selectSkillHero2 = self._heroList[slot].id
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then 
		self._selectSkillHero3 = self._heroList[slot].id
	end
	
	for i = 1, TEAM_MAX_NUM do
		self._ccbOwner["node_skill_select"..i]:setVisible(i==slot)
	end

	-- app.tip:floatTip("设置成功！该魂技将作为战斗中的援助魂技！")
	-- self._selectHero = self._heroList[slot].actorId
end


function QUIDialogMockTeamArrangement:updateLockState()
	print("QUIDialogMockTeamArrangement:updateLockState()")
	if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
		local pos = HAVE_SOUL_POS
		if self._selectAlternate then
			pos = ALTERNATE_POS
			self._ccbOwner["node_avatar_4"]:setVisible(false)
			self._ccbOwner["node_soul_1"]:setVisible(false)
		else
			pos = HAVE_SOUL_POS
			self._ccbOwner["node_avatar_4"]:setVisible(true)
			self._ccbOwner["node_soul_1"]:setVisible(true)
		end
		for i = 1, TEAM_MAX_NUM do
			self._ccbOwner["light"..i]:removeAllChildren()
			if i > self._unlockedSlot then
				self._ccbOwner["disable"..i]:setVisible(true)
				self._ccbOwner["enable"..i]:setVisible(false)
			else
				self._ccbOwner["disable"..i]:setVisible(false)
				if self._selectAlternate then
					self._ccbOwner["enable"..i]:setVisible(false)
				else
					self._ccbOwner["enable"..i]:setVisible(true)
				end
			end
			self._ccbOwner["node_avatar_"..i]:setPosition(pos[i].x, pos[i].y)
		end

		for _, avatar in ipairs(self._heroAvatars) do
			avatar:setVisible(false)
		end
	elseif self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		local pos = NORMAL_POS
		local teamVO = self:getMockBattleTeam()
		local godarm_maxnum =  teamVO:getHerosGodArmMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
		for i = 1, TEAM_MAX_NUM do
			self._ccbOwner["green"..i]:setVisible(i <= godarm_maxnum)
			self._ccbOwner["disableH"..i]:setVisible(i > godarm_maxnum)
			self._ccbOwner["node_unlock"..i]:setVisible(i > godarm_maxnum)
			self._ccbOwner["lightH"..i]:removeAllChildren()
			self._ccbOwner["sp_team1_"..i]:setVisible(false)
			self._ccbOwner["sp_team2_"..i]:setVisible(false)
			self._ccbOwner["sp_team3_"..i]:setVisible(false)
			self._ccbOwner["node_skill"..i]:setVisible(false)
			self._ccbOwner["node_skill_select"..i]:setVisible(false)
			self._ccbOwner["node_helper_"..i]:setPosition(pos[i].x, pos[i].y)
		end
		for _, avatar in ipairs(self._heroHelperAvatars) do
			avatar:setVisible(false)
		end
	else
		local pos = NORMAL_POS
		local helpIndex = 0
		for i = 1, TEAM_MAX_NUM do
			self._ccbOwner["lightH"..i]:removeAllChildren()
			self._ccbOwner["sp_team1_"..i]:setVisible(false)
			self._ccbOwner["sp_team2_"..i]:setVisible(false)
			self._ccbOwner["sp_team3_"..i]:setVisible(false)
			self._ccbOwner["node_skill"..i]:setVisible(false)
			self._ccbOwner["node_skill_select"..i]:setVisible(false)
			if i > self._unlockedSlot then
				self._ccbOwner["disableH"..i]:setVisible(true)
				self._ccbOwner["green"..i]:setVisible(false)
			else
				self._ccbOwner["node_unlock"..i]:setVisible(false)
				self._ccbOwner["disableH"..i]:setVisible(false)
				self._ccbOwner["green"..i]:setVisible(true)
			end
			self._ccbOwner["node_helper_"..i]:setPosition(pos[i].x, pos[i].y)
		end
		for _, avatar in ipairs(self._heroHelperAvatars) do
			avatar:setVisible(false)
		end
	end
	self._widgetHeroArray:setUnlockNumber(self._unlockedSlot)
end


function QUIDialogMockTeamArrangement:_openHeroDetail(actorId)
	--notice 需要读大师赛配置中的技能
	local hero_info = remote.mockbattle:getCardInfoById(actorId)
	local assistSkillInfo = QStaticDatabase:sharedDatabase():getAssistSkill(actorId)
	local skillInfo = clone(hero_info.slots[3])
	skillInfo.info = {slotLevel = skillInfo.slotLevel}
	local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(hero_info.actorId, skillInfo.slotId)
	skillInfo.skillId = skillId
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAssistHeroSkill", 
		options = {actorId = actorId, assistSkill = assistSkillInfo, skillSlotInfo = skillInfo, isMockBattle = true}},{isPopCurrentDialog = false})
end

function QUIDialogMockTeamArrangement:_onTriggerFight(event)

	if self:checkSeasonTime() then
		app.tip:floatTip("赛季已结束，无法战斗~")
		self:_onExit()
		return 
	end

	-- if q.buttonEventShadow(event,self._ccbOwner.btn_confirm) == false then return end
	if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP or 
		self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 or 
		self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 or 
		self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._widgetHeroArray:onTriggerMain()
		return 
	end

	if self._selectTrialNum < #self._arrangements then
		self:_onTriggerChangeTeam2()
		return 
	end
  	local str = "确定开始战斗吗？"
 	if self._arrangement:getIsBattle() == false then
  		str = "确定保存吗？"
  	end

  	local isUnlockHelper = self._seasonType == QMockBattle.SEASON_TYPE_SINGLE
  	local isUnlockGodArm = self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE


 --  	local heros = remote.mockbattle:getMyHeroInfoList()
	-- local mounts = remote.mockbattle:getMyMountInfoList()
	-- local soulSpirits = remote.mockbattle:getMySoulSpiritInfoList()
	-- local godarmList = remote.mockbattle:getHaveGodarmList()

	-- local teamVO = remote.teamManager:getTeamByKey(self._arrangement:getTeamKey(), false)
	-- local teamVO = self:getMockBattleTeam()
  	-- local teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
  	-- local soulMaxNum = teamVO:getSpiritsMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
	local upTeam = 0  --记录总的上阵魂师人数
  	local teamHeroNum = 0	--存储最大上阵魂师与暗器数量
  	local soulMaxNum = 0	--存储最大上阵魂灵数量
  	local godarmMaxNum = 0	--存储最大上阵神器数量


	local mountTeams_num = 0
	local soulTeams_num = 0
	local godarmTeams_num = 0

	local teamVs = self:getMockBattleTeam(true) 
	for i,teamVO in ipairs(teamVs) do


		local str_team = string.format("第%s战队", i)
		if #teamVs == 1 or self._selectTrialNum == i  then
			str_team = "当前战队"
		end


		local teams = self._widgetHeroArray:getSelectTeam(false , i)
		if teams[remote.teamManager.TEAM_INDEX_MAIN] == nil then teams[remote.teamManager.TEAM_INDEX_MAIN] = {} end 

		if not self._arrangement:teamValidity(teams[remote.teamManager.TEAM_INDEX_MAIN]) then
			return 
		end
	  	local mainTeam = teams[remote.teamManager.TEAM_INDEX_MAIN] ~= nil and #teams[remote.teamManager.TEAM_INDEX_MAIN] or 0
	  	local helpTeam = teams[remote.teamManager.TEAM_INDEX_HELP] ~= nil and #teams[remote.teamManager.TEAM_INDEX_HELP] or 0
	  	local helpTeam2 = teams[remote.teamManager.TEAM_INDEX_HELP2] ~= nil and #teams[remote.teamManager.TEAM_INDEX_HELP2] or 0
	  	local helpTeam3 = teams[remote.teamManager.TEAM_INDEX_HELP3] ~= nil and #teams[remote.teamManager.TEAM_INDEX_HELP3] or 0
	  	upTeam = helpTeam + mainTeam + helpTeam2 + helpTeam3

		mountTeams_num =  #self._widgetHeroArray:getSelectMount(false ,i)
		soulTeams_num =  #self._widgetHeroArray:getSelectSoulSpirit(false ,i)
		godarmTeams_num = #self._widgetHeroArray:getSelectGodarmList(false ,i)
		teamHeroNum = teamVO:getHerosMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
		soulMaxNum = teamVO:getSoulSpriteMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)
		godarmMaxNum = teamVO:getHerosGodArmMaxCountByIndex(remote.teamManager.TEAM_INDEX_MAIN)


	  	if mainTeam < teamHeroNum 
	  		-- and #heros - upTeam > 0 
	  		then
			app:alert({content= str_team .."有主力魂师未上阵，"..str,title="系统提示", callback = function (state)
				if state == ALERT_TYPE.CONFIRM then
					self:startBattle()
				end
			end})
			return
	  	end


	  	--暗器
	  	if mountTeams_num < teamHeroNum 
	  		-- and (#mounts  > mountTeams_num) 
	  		then
			app:alert({content=str_team .."有主力魂师暗器未上阵，"..str,title="系统提示", callback = function (state)
				if state == ALERT_TYPE.CONFIRM then
					self:startBattle()
				end
			end})
			return
		end


	  	if soulTeams_num < soulMaxNum 
	  		-- and (#soulSpirits - soulTeams_num > 0) 
	  		then
			app:alert({content = string.format(str_team .."有魂灵未上阵，确定开始战斗吗？"), title = "系统提示", callback = function (state)
				if state == ALERT_TYPE.CONFIRM then
					self:startBattle()
				end
			end})
			return
	  	end

	  	if isUnlockHelper then
		  	if  helpTeam < teamHeroNum 
		  		-- and #heros - upTeam > 0 
		  		then
				app:alert({content= str_team .."有援助1魂师未上阵，"..str,title="系统提示", callback = function (state)
					if state == ALERT_TYPE.CONFIRM then
						self:startBattle()
					end
				end})
				return
		  	end
		  -- 	--没有援助2、3队伍 无需检测
		  -- 	if  helpTeam2 < teamHeroNum 
		  -- 		-- and #heros - upTeam > 0 
		  -- 		then
				-- app:alert({content=str_team .."有援助2魂师未上阵，"..str,title="系统提示", callback = function (state)
				-- 	if state == ALERT_TYPE.CONFIRM then
				-- 		self:startBattle()
				-- 	end
				-- end})
				-- return
		  -- 	end

		  -- 	if  helpTeam3 < teamHeroNum 
		  -- 		-- and #heros - upTeam > 0 
		  -- 		then
				-- app:alert({content=str_team .."有援助3魂师未上阵，"..str,title="系统提示", callback = function (state)
				-- 	if state == ALERT_TYPE.CONFIRM then
				-- 		self:startBattle()
				-- 	end
				-- end})
				-- return
		  -- 	end
	  	end

	  	if isUnlockGodArm then
		  	if godarmTeams_num < godarmMaxNum 
		  		-- and #godarmList > godarmTeams_num  
		  		then
				app:alert({content=str_team .."有神器未上阵，"..str,title="系统提示", callback = function (state)
					if state == ALERT_TYPE.CONFIRM then
						self:startBattle()
					end
				end})
				return
		  	end
	  	end


	end



	self:startBattle()
end 

function QUIDialogMockTeamArrangement:checkSeasonTime()
	local currTime = q.serverTime()
	local endTime = remote.mockbattle:getMockBattleSeasonInfo().endAt or 0
	return currTime > endTime
end


function QUIDialogMockTeamArrangement:startBattle()
	app.sound:playSound("battle_fight")
	if self._seasonType == QMockBattle.SEASON_TYPE_SINGLE then
		local teams , num = self:_getSelectTeams(1)
  		self._arrangement:startBattle(teams)
	elseif self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE then
		local teams1 , num1 = self:_getSelectTeams(1)
		local teams2 , num2 = self:_getSelectTeams(2)
  		self._arrangement:startBattleForDoubleTeam(teams1,teams2)
	end
end


function QUIDialogMockTeamArrangement:sortMainTeam(teams)
	local sortTeam ={}
	for k,info in pairs(self._allHeroList) do
		for k,v in pairs(teams or {}) do
			if info.id == v then
				sortTeam[v] =info
			end
		end
	end
	if next(sortTeam) then
		table.sort(teams, function (x, y)
			local aa = sortTeam[x]
			local bb = sortTeam[y]
			if aa.hatred == bb.hatred then
				return aa.force > bb.force
			end
			return aa.hatred > bb.hatred
		end )
	end

end


function QUIDialogMockTeamArrangement:_getSelectTeams(trialNum)
	local num_ = 0
	local teams = self._widgetHeroArray:getSelectTeam(true ,trialNum )
	local teamData = {{}, {}, {}, {}, {}}
	self:sortMainTeam(teams[1])

	-- local sortTeam ={}
	-- for k,info in pairs(self._allHeroList) do
	-- 	for k,v in pairs(teams[1] or {}) do
	-- 		if info.id == v then
	-- 			sortTeam[v] =info
	-- 		end
	-- 	end
	-- end
	-- if next(sortTeam) then
	-- 	table.sort(teams[1], function (x, y)
	-- 		local aa = sortTeam[x]
	-- 		local bb = sortTeam[y]
	-- 		if aa.hatred == bb.hatred then
	-- 			return aa.force > bb.force
	-- 		end
	-- 		return aa.hatred > bb.hatred
	-- 	end )
	-- end
	teamData[1].actorIds = teams[1] or {}
	teamData[2].actorIds = teams[2] or {}
	teamData[3].actorIds = teams[3] or {}
	teamData[4].actorIds = teams[4] or {}


	teamData[1].spiritIds = self._widgetHeroArray:getSelectSoulSpirit(true ,trialNum ) or {}
	teamData[1].mountIds = self._widgetHeroArray:getSelectMount(true ,trialNum ) or {}


	local skill1 = self._selectSkillHero1
	skill1 = self:_checkHelpSkill(teamData[2].actorIds, skill1)
	teamData[2].skill = {skill1}

	local skill2 = self._selectSkillHero2
	skill2 = self:_checkHelpSkill(teamData[3].actorIds, skill2)
	teamData[3].skill = {skill2}

	local skill3 = self._selectSkillHero3
	skill3 = self:_checkHelpSkill(teamData[4].actorIds, skill3)
	teamData[4].skill = {skill3}

	--	神器
	local godarmInfo = self._widgetHeroArray:getSelectGodarmListInfo(trialNum) or {}
	local godarmIds = {}
	if not q.isEmpty(godarmInfo) then
		table.sort( godarmInfo, function(a,b)
			if a.pos ~= b.pos then
				return a.pos < b.pos
			end
		end )
		for _,v in pairs(godarmInfo) do
			table.insert(godarmIds,v.id)
		end
	end
	teamData[5].godarmIds = godarmIds or {}

	num_ = #teamData[1].actorIds + num_
	num_ = #teamData[2].actorIds + num_
	num_ = #teamData[3].actorIds + num_
	num_ = #teamData[4].actorIds + num_
	num_ = #teamData[1].spiritIds + num_
	num_ = #teamData[1].mountIds + num_
	num_ = #teamData[5].godarmIds + num_
	if #teamData[1].actorIds <= 0 then
		num_ = 0
	end

	return teamData ,num_
end

function QUIDialogMockTeamArrangement:_checkHelpSkill(help, skill)
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

function QUIDialogMockTeamArrangement:_onTriggerRight()

	if self._seasonType == QMockBattle.SEASON_TYPE_SINGLE then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			self._widgetHeroArray:onTriggerMain()
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
			self._widgetHeroArray:onTriggerHelper()
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP3 then
			self._widgetHeroArray:onTriggerHelper2()
		end

	else
		if self._selectIndex == remote.teamManager.TEAM_INDEX_GODARM then
			self._widgetHeroArray:onTriggerMain()
		end
	end

end

function QUIDialogMockTeamArrangement:_onTriggerLeft()
	if self._seasonType == QMockBattle.SEASON_TYPE_SINGLE then
		if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
			self._widgetHeroArray:onTriggerHelper()
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP then
			self._widgetHeroArray:onTriggerHelper2()
		elseif self._selectIndex == remote.teamManager.TEAM_INDEX_HELP2 then
			self._widgetHeroArray:onTriggerHelper3()
		end
	else
		if self._selectIndex == remote.teamManager.TEAM_INDEX_MAIN then
			self._widgetHeroArray:onTriggerGodarm()
		end
	end	
end

function QUIDialogMockTeamArrangement:_moveToHelper()
	self._ccbOwner.avatarMain:moveBy(SWITCH_DURATION, SWITCH_DISTANCE, 0)
	self._ccbOwner.avatarHelper:moveBy(SWITCH_DURATION, SWITCH_DISTANCE, 0)
end

function QUIDialogMockTeamArrangement:_moveToMain()
	self._ccbOwner.avatarMain:moveBy(SWITCH_DURATION, -SWITCH_DISTANCE, 0)
	self._ccbOwner.avatarHelper:moveBy(SWITCH_DURATION, -SWITCH_DISTANCE, 0)
end

function QUIDialogMockTeamArrangement:_onTriggerConditionInfo()
   app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHelperExplain"})
end

function QUIDialogMockTeamArrangement:_onTriggerSoulInfo()
	app.sound:playSound("common_small")

	local soulSpirits = self._widgetHeroArray:getSelectSoulSpirit(false ,self._selectTrialNum)
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
   		options = {mainTeam = mainTeam, helpTeam1 = helpTeam1, helpTeam2 = helpTeam2, helpTeam3 = helpTeam3, soulSpiritId = soulSpirits,isMockBattle =true}})
end

function QUIDialogMockTeamArrangement:_onTriggerHelperDetail()
	app.sound:playSound("common_small")
	local teams = self._widgetHeroArray:getSelectTeam()
	local helpTeam1 = teams[remote.teamManager.TEAM_INDEX_HELP] or {}
	local helpTeam2 = teams[remote.teamManager.TEAM_INDEX_HELP2] or {}
	local helpTeam3 = teams[remote.teamManager.TEAM_INDEX_HELP3] or {}
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamHelperAddInfo",
   		options = {helpTeam1 = helpTeam1, helpTeam2 = helpTeam2, helpTeam3 = helpTeam3 ,isMockBattle =true}})
end



function QUIDialogMockTeamArrangement:_onTriggerClickPVP(event)
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


function QUIDialogMockTeamArrangement:_onTriggerEnemyInfo(event)
    app.sound:playSound("common_small")
	
	local enemy_data = remote.mockbattle:getMockBattleUserCenterBattle()
	if enemy_data == nil or next(enemy_data) == nil  then return end

   	local enemy_battleInfo = enemy_data.battleInfo or {}
	local fighter = enemy_data.fighter or {}

	local main_4hero = enemy_battleInfo.mainHeroIds or {}
	local sub_4hero = enemy_battleInfo.sub1HeroIds or {}
	local wear_4hero = enemy_battleInfo.wearInfo or {}
	local soulSpiritId = enemy_battleInfo.soulSpiritId or 0
	

    local heros_ = {}
    local subheros_ = {}
    local sub2heros_ = {}
    local sub3heros_ = {}
    local mounts_ = {}
    local godArm1List = {}

	for i, value in pairs(self.enemy_card_ids[1]) do
		local data_ = remote.mockbattle:getCardInfoByIndex(value.id)
		if value.team_index == remote.teamManager.TEAM_INDEX_MAIN then
        	table.insert(heros_,data_ )
		elseif value.team_index == remote.teamManager.TEAM_INDEX_HELP then
        	table.insert(subheros_, data_)
		elseif value.team_index == remote.teamManager.TEAM_INDEX_HELP2 then
        	table.insert(sub2heros_, data_)
		elseif value.team_index == remote.teamManager.TEAM_INDEX_HELP3 then
        	table.insert(sub3heros_, data_)
		elseif value.team_index == TEAM_INDEX_MOUNT then
        	table.insert(mounts_, data_)
		elseif value.team_index == remote.teamManager.TEAM_INDEX_GODARM then
        	table.insert(godArm1List, data_)
		end
	end

    local options_ = {fighter = fighter, isPVP = true ,heros = heros_ ,subheros = subheros_ 
    ,sub2heros = sub2heros_ ,sub3heros = sub3heros_ ,mounts = mounts_ , godArm1List = godArm1List ,model = GAME_MODEL.MOCKBATTLE ,forceTitle="胜场 :" , isPVP = false , force = fighter.winCount or 0 }

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
   		options = options_ }, {isPopCurrentDialog = false})
end

--敌方2队阵容
function QUIDialogMockTeamArrangement:_onTriggerEnemyInfo2(event)
    app.sound:playSound("common_small")
	
	local enemy_data = remote.mockbattle:getMockBattleUserCenterBattle()
	if enemy_data == nil or next(enemy_data) == nil  then return end

   	local enemy_battleInfo = enemy_data.battleInfo or {}
	local fighter = enemy_data.fighter or {}

	local main_4hero = enemy_battleInfo.mainHeroIds or {}
	local sub_4hero = enemy_battleInfo.sub1HeroIds or {}
	local wear_4hero = enemy_battleInfo.wearInfo or {}
	local soulSpiritId = enemy_battleInfo.soulSpiritId or 0
	

    local heros_ = {}
    local subheros_ = {}
    local sub2heros_ = {}
    local sub3heros_ = {}
    local mounts_ = {}
    local godArm1List = {}

	for i, value in pairs(self.enemy_card_ids[2]) do
		local data_ = remote.mockbattle:getCardInfoByIndex(value.id)
		if value.team_index == remote.teamManager.TEAM_INDEX_MAIN then
        	table.insert(heros_,data_ )
		elseif value.team_index == remote.teamManager.TEAM_INDEX_HELP then
        	table.insert(subheros_, data_)
		elseif value.team_index == remote.teamManager.TEAM_INDEX_HELP2 then
        	table.insert(sub2heros_, data_)
		elseif value.team_index == remote.teamManager.TEAM_INDEX_HELP3 then
        	table.insert(sub3heros_, data_)
		elseif value.team_index == TEAM_INDEX_MOUNT then
        	table.insert(mounts_, data_)
		elseif value.team_index == remote.teamManager.TEAM_INDEX_GODARM then
        	table.insert(godArm1List, data_)
		end
	end

    local options_ = {fighter = fighter, isPVP = true ,heros = heros_ ,subheros = subheros_ 
    ,sub2heros = sub2heros_ ,sub3heros = sub3heros_ ,mounts = mounts_ , godArm1List = godArm1List ,model = GAME_MODEL.MOCKBATTLE ,forceTitle="胜场 :" , isPVP = false , force = fighter.winCount or 0 }

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
   		options = options_ }, {isPopCurrentDialog = false})
end

--切换部队
function QUIDialogMockTeamArrangement:_onTriggerChangeTeam(event)
	if self._selectTrialNum == 1 then return end
	self._selectTrialNum = 1
	self:changeTrialInfo()
end

function QUIDialogMockTeamArrangement:_onTriggerChangeTeam2(event)
	if self._selectTrialNum == 2 then return end
	self._selectTrialNum = 2
	self:changeTrialInfo()
end

function QUIDialogMockTeamArrangement:_onTriggerGodarmInfo(event)
	app.sound:playSound("common_small")
	local godarmInfo = self._widgetHeroArray:getSelectGodarmListInfo(self._selectTrialNum)
	if next(godarmInfo) == nil then
		app.tip:floatTip("神器未上阵~")
		return		
	end
	self._widgetHeroArray:onTriggerGodarm()
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodarmTeamDetail",
   		options = {mainGodarmList = godarmInfo , isMockBattle = true}})	
end


function QUIDialogMockTeamArrangement:_onTriggerChangeTeamOneKey(event)
	app.sound:playSound("common_small")

	local teams1 = self._widgetHeroArray:getSelectTeam(true ,1)
	local teams2 = self._widgetHeroArray:getSelectTeam(true ,2)
	local soulSpirit1 = self._widgetHeroArray:getSelectSoulSpirit(true ,1)
	local soulSpirit2 = self._widgetHeroArray:getSelectSoulSpirit(true ,2)
	local godarmList1 = self._widgetHeroArray:getSelectGodarmList(true ,1) or {}
	local godarmList2 = self._widgetHeroArray:getSelectGodarmList(true ,2) or {}
	local mountList1 = self._widgetHeroArray:getSelectMount(true ,1) or {}
	local mountList2 = self._widgetHeroArray:getSelectMount(true ,2) or {}
	local enemy_data = remote.mockbattle:getMockBattleUserCenterBattle()
	if enemy_data == nil or next(enemy_data) == nil  then return end
	self:sortMainTeam(teams1[1])
	self:sortMainTeam(teams2[1])

	local fighterInfo = {}
	fighterInfo.enemy_card_ids = self.enemy_card_ids
	fighterInfo.fighter = enemy_data.fighter or {}


	-- local subHeros1 = remote.teamManager:getHeroUpOrder(1)
	-- local subHeros2 = remote.teamManager:getHeroUpOrder(2)
   	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityQuickChangeTeam",
    	options = {
    		teams1 = teams1, 
    		teams2 = teams2, 
    		-- subHeros1 = subHeros1, 
    		-- subHeros2 = subHeros2, 
    		soulSpirit1 = soulSpirit1, 
    		soulSpirit2 = soulSpirit2, 
    		godarmList1 = godarmList1,
    		godarmList2 = godarmList2,
    		mountList1 = mountList1 ,
    		mountList2 = mountList2 ,
    		fighterInfo = fighterInfo, 
    		isMockBattle = true,
    		isDefence = false, 
    		isPVP = true,
    		callBack = function ()
				if self:safeCheck() then
    				local teamVO = self:getMockBattleTeam()
	    			-- local skills = {}
	    			-- if teams1[2] then
	    			-- 	table.insert(skills, teams1[2][1])
	    			-- 	table.insert(skills, teams1[2][2])
	    			-- end
					local team_pos_change = {}	
					team_pos_change[1]={}
					team_pos_change[2]={}
					for i,v in pairs(teams1[1] or {}) do
						team_pos_change[1][i]={ id = v}
					end
					for i,v in pairs(teams2[1] or {}) do
						team_pos_change[2][i]={ id = v}
					end

					-- QPrintTable(teams1[1])
					-- QPrintTable(teams2[1])	
					-- QPrintTable(teams1[5])	
					-- QPrintTable(teams2[5])

	    			teamVO:setTeamActorsByIndex(remote.teamManager.TEAM_INDEX_MAIN, teams1[1])
	    			-- self._arrangements[1]:setActorTeams(remote.teamManager.TEAM_INDEX_HELP, teams1[2])
	    			teamVO:setTeamSpiritsByIndex(remote.teamManager.TEAM_INDEX_MAIN, teams1[3])
					-- self._arrangements[1]:setSkillTeams(remote.teamManager.TEAM_INDEX_SKILL, skills)
					teamVO:setTeamGodarmByIndex(remote.teamManager.TEAM_INDEX_GODARM,teams1[4])
					teamVO:setTeamMountsListByIndex(remote.teamManager.TEAM_INDEX_MAIN,teams1[5])

	    			-- local skills = {}
	    			-- if teams2[2] then
	    			-- 	table.insert(skills, teams2[2][1])
	    			-- 	table.insert(skills, teams2[2][2])
	    			-- end
	    			local offside =  100
	    			teamVO:setTeamActorsByIndex(remote.teamManager.TEAM_INDEX_MAIN + offside, teams2[1])
	    			-- self._arrangements[2]:setActorTeams(remote.teamManager.TEAM_INDEX_HELP, teams2[2])
	    			teamVO:setTeamSpiritsByIndex(remote.teamManager.TEAM_INDEX_MAIN + offside, teams2[3])
					-- self._arrangements[2]:setSkillTeams(remote.teamManager.TEAM_INDEX_SKILL, skills)
					teamVO:setTeamGodarmByIndex(remote.teamManager.TEAM_INDEX_GODARM + offside ,teams2[4])
					teamVO:setTeamMountsListByIndex(remote.teamManager.TEAM_INDEX_MAIN + offside ,teams2[5])
					self:sortMainTeam(teams1[1])
					self:sortMainTeam(teams2[1])					
					-- QPrintTable(teams1[1])
					-- QPrintTable(teams2[1])	
					-- QPrintTable(teams1[5])	
					-- QPrintTable(teams2[5])	

					local index_ = 1
					for i=1,4 do
						if teams1[1] and teams1[1][i] then
							for k,vvv in pairs(team_pos_change[1] or {}) do
								if vvv.id == teams1[1][i] then 
									vvv.pos = index_
								end
							end
							index_ = index_ + 1
						end
					end
					index_ = 1
					for i=1,4 do
						if teams2[1] and teams2[1][i] then
							for k,vvv in pairs(team_pos_change[2] or {}) do
								if vvv.id == teams2[1][i] then 
									vvv.pos = index_
								end
							end
							index_ = index_ + 1
						end
					end
				

					for i, teams in pairs(teams1) do
						if i ~= 5 then
			    			teams1[i] = table.mapToArray(teams)
						end
			    	end
			    	for i, teams in pairs(teams2) do
						if i ~= 5 then
			    			teams2[i] = table.mapToArray(teams)
						end
			    	end
					-- self:initSelectSkill()
		    		self._widgetHeroArray:updateHeroByTeams(teams1, teams2 , team_pos_change)
		    	end
    		end
    	}})
end

function QUIDialogMockTeamArrangement:_onExit()
    self:popSelf()
    if self._backCallback then
    	self._backCallback()
    end
end

function QUIDialogMockTeamArrangement:onTriggerBackHandler()

	if self:checkSeasonTime() then
		self:_onExit()
		return 
	end

	local success = function ( )
		self:_onExit()
	end
	local teams , num  = self:_getSelectTeams()
	if self._seasonType == QMockBattle.SEASON_TYPE_SINGLE then
		local teams , num = self:_getSelectTeams(1)
		if num > 0 then	
	  		self._arrangement:saveFormation(teams,nil,success)
	  	else
			self:_onExit()
	  	end
	elseif self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE then
		local teams1 , num1 = self:_getSelectTeams(1)
		local teams2 , num2 = self:_getSelectTeams(2)
		if num1  > 0 and num2 > 0 then	
	  		self._arrangement:saveFormation(teams1,teams2,success)
	  	else
			self:_onExit()
	  	end
	end
end

return QUIDialogMockTeamArrangement