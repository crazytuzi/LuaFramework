-- 大师赛
-- Author: Qinsiyang
-- 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QMockBattleArrangement = class("QMockBattleArrangement", QBaseArrangement)
local QMyAppUtils = import("..utils.QMyAppUtils")

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QActorProp = import("...models.QActorProp")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")


function QMockBattleArrangement:ctor(options)
	QMockBattleArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.INSTANCE_TEAM)
	self._myInfo = {}
    self._myInfo.name = remote.user.nickname
    self._myInfo.avatar = remote.user.avatar
    self._myInfo.level = remote.user.level
	--self._force = options.force
	--self._battleType = options.battleType
	self._teamKey = options.teamKey or remote.teamManager.INSTANCE_TEAM
	self:setIsLocal(true)
end

function QMockBattleArrangement:startBattle(heroIdList)

	local battleFormation = remote.mockbattle:encodeBattleFormation(heroIdList)
	remote.mockbattle:mockBattleFightStartRequest(battleFormation,nil,function(data)
		        self:startBattle_begin(battleFormation,data.gfStartResponse.battleVerify)
		end,function(data)
		end)
end

function QMockBattleArrangement:startBattleForDoubleTeam(heroIdList1,heroIdList2)

	local battleFormation = remote.mockbattle:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.mockbattle:encodeBattleFormation(clone(heroIdList2))
	remote.mockbattle:mockBattleFightStartRequest(battleFormation,battleFormation2,function(data)
				self:startBattle_begin2(battleFormation, battleFormation2 , data.gfStartResponse.battleVerify)
		end,function(data)
		end)
end

function QMockBattleArrangement:saveFormation(heroIdList ,heroIdList2 ,success)
	local battleFormation = remote.mockbattle:encodeBattleFormation(heroIdList)
	local battleFormation2 = heroIdList2 and remote.mockbattle:encodeBattleFormation(heroIdList2) or nil
	remote.mockbattle:mockBattleChangeDefenseArmyRequest(battleFormation,battleFormation2,success,success)
end

function QMockBattleArrangement:startBattle_begin(battleFormation,battleVerifyKey)
	-- if ENABLE_ARENA_QUICK_BATTLE then
	-- 	return self:quickStartEndBattle(heroIdList)
	-- end
	--我方
	self.myHeroList = self:mergeHeroMount(battleFormation)
	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("arena")
	config.isPVPMode = true
	config.isArena = true
	config.isMockBattle = true
	config.team1Name = remote.user.nickname
	config.team1Icon = remote.user.avatar
	if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
		config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end
	--敌方
	local enemy_data = remote.mockbattle:getMockBattleUserCenterBattle()
	local fighter = enemy_data.fighter or {}
	local enemy_battleInfo = enemy_data.battleInfo or {}
	self.enemyHeroList = self:mergeHeroMount(enemy_battleInfo)
	config.team2Name = fighter.name
	config.team2Icon = fighter.avatar
	if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
		config.team2Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end
	config.rivalId = fighter.userId or 0
	config.pvp_archaeology = 0
	config.battleDT = 1 / 30
	config.battleFormation = battleFormation
	config.verifyKey = battleVerifyKey
    config.teamName = self._teamKey
    config.rivalsInfo = fighter
    local myInfo = {}
    config.myInfo = myInfo
    self:initMockBattleDungeonConfig(config)
    self:initMyInfo(config)

	local buffer, record = self:_createReplayBuffer(config)
	writeToBinaryFile("last.reppb", buffer)

    record.dungeonConfig.replayTimeSlices = record.recordTimeSlices
    record.dungeonConfig.replayRandomSeed = record.recordRandomSeed

    for key, value in pairs(config) do
        record.dungeonConfig[key] = value
    end
	record.dungeonConfig.isReplay = true
    record.dungeonConfig.isQuick = true	

	remote.mockbattle:mockBattleFightEndRequest(battleVerifyKey,function(data)
			local isWin = data.gfEndResponse.isWin
	    	record.dungeonConfig.quickFightResult = {isWin = isWin}
	    	record.dungeonConfig.fightEndResponse = data	
	    	record.dungeonConfig.heros = clone(config.heroInfos)
	        local myInfo = clone(config.myInfo)
	        local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin and 1 or 2, nil)

			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
			
			local loader = QDungeonResourceLoader.new(record.dungeonConfig)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources"
				, options = {dungeon = record.dungeonConfig, isKeepOldPage = true, loader = loader}})
			QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.MOCK_BATTLE)
		end,function(data)
		end)

	
end

--双队战斗数据
function QMockBattleArrangement:startBattle_begin2(battleFormation1,battleFormation2,battleVerifyKey)

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("sunwell")
	config.isPVPMultipleWave = false
	config.isPvpMultipleNew = true
	config.isArena = true
	config.isMockBattle = true
	config.isPVPMode = true
	config.isPVP2TeamBattle = true
	config.battleFormation = battleFormation1
	config.battleFormation2 = battleFormation2
	config.verifyKey = battleVerifyKey
    config.teamName = self._teamKey

    --我方
	config.team1Name = remote.user.nickname
	config.team1Icon = remote.user.avatar
	if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
		config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end
	--敌方
	local enemy_data = remote.mockbattle:getMockBattleUserCenterBattle()
	local fighter = enemy_data.fighter or {}
	local enemy_battleInfo = enemy_data.battleInfo or {}
	local enemy_battleInfo2 = enemy_data.battleInfo2 or {}

	config.team2Name = fighter.name or remote.user.nickname
	config.team2Icon = fighter.avatar or remote.user.avatar
	if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
		config.team2Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end
	config.rivalId = fighter.userId or 0

    config.rivalsInfo = fighter
	config.myInfo = self._myInfo
	config.battleDT = 1 / 30


	local my_battle_info = self:mergeHeroMount2(battleFormation1,battleFormation2)
	local enemy_battle_info = self:mergeHeroMount2(enemy_battleInfo,enemy_battleInfo2)

	self:_initNewPVPTeamInfo(config , my_battle_info , enemy_battle_info)
	--self:_initNewPVPTeamInfo(config , my_battle_info , my_battle_info)--试运行战斗
	config.gameVersion = app:getBattleVersion()

	local buffer, record = self:_createReplayBuffer(config)
	writeToBinaryFile("last.reppb", buffer)

    record.dungeonConfig.replayTimeSlices = record.recordTimeSlices
    record.dungeonConfig.replayRandomSeed = record.recordRandomSeed
    for key, value in pairs(config) do
        record.dungeonConfig[key] = value
    end
	record.dungeonConfig.isReplay = true
    record.dungeonConfig.isQuick = true	 

    --存储当前胜场
    remote.mockbattle:saveCurWinCount()

	remote.mockbattle:mockBattleFightEndRequest(battleVerifyKey,function(data)
			local isWin = data.gfEndResponse.isWin
	    	record.dungeonConfig.quickFightResult = {isWin = isWin}
	    	record.dungeonConfig.fightEndResponse = data	
	    	record.dungeonConfig.heros = clone(config.heroInfos)
	        local myInfo = clone(config.myInfo)
	        local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin and 1 or 2, nil)
			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
			local loader = QDungeonResourceLoader.new(record.dungeonConfig)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources"
				, options = {dungeon = record.dungeonConfig, isKeepOldPage = true, loader = loader}})
			QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.MOCK_BATTLE)
		end,function(data)
		end)
end



function QMockBattleArrangement:initMockBattleDungeonConfig(config)
	self:_addHeroSkill(config)
	config.gameVersion = app:getBattleVersion()
    --是否需要添加英雄图鉴战力加成
	-- config.heroRecords = remote.user.collectedHeros or {}
	-- config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}	
end

function QMockBattleArrangement:_createReplayBuffer(config)
    local dungeon = QMyAppUtils:generateDungeonConfig(config)


    dungeon.supportSkillHeroIndex = config.supportSkillHeroIndex
    dungeon.supportSkillHeroIndex2 = config.supportSkillHeroIndex2
    dungeon.supportSkillHeroIndex3 = config.supportSkillHeroIndex3
    dungeon.supportSkillEnemyIndex = config.supportSkillEnemyIndex
    dungeon.supportSkillEnemyIndex2 = config.supportSkillEnemyIndex2
    dungeon.supportSkillEnemyIndex3 = config.supportSkillEnemyIndex3

    dungeon.last_enable_fragment_id = 0 --[[remote.user.archaeologyInfo and remote.user.archaeologyInfo.last_enable_fragment_id]]
    local prop, id = remote.sunWar:getHeroBuffPropTable()
    dungeon.sunWarBuffID = id
    local targetOrder = remote.sunWar:getCurrentWaveTargetOrder() or {}
    dungeon.sunwarTargetOrder = targetOrder
    local targetOrder = remote.tower:getCurrentFloorTargetOrder() or {}
    dungeon.gloryTargetOrder = targetOrder

    local timeGearChange = {}
    dungeon.timeGearChange = timeGearChange

    local disableAIChange = {}
    dungeon.disableAIChange = disableAIChange

    local playerAction = {}
    dungeon.playerAction = playerAction

    local forceAutoChange = {}
    dungeon.forceAutoChange = forceAutoChange

    local recordTimeSlices = {}

    local record = {}
    local replayCord = {}
    replayCord.replayList = {}

    record.dungeonConfig = dungeon
    record.recordRandomSeed = q.OSTime()
    record.recordFrameCount = #recordTimeSlices
    record.recordTimeSlices = recordTimeSlices
    
    dungeon.supportSkillHeroIndex = config.supportSkillHeroIndex
    dungeon.supportSkillHeroIndex2 = config.supportSkillHeroIndex2

    table.insert(replayCord.replayList, record)

    local buff = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayList", replayCord)
    return buff, record
end

--双队的数据 没有替补 没有援助技能  这个玩法战斗力不重要 所以都没有做计算
function QMockBattleArrangement:_initNewPVPTeamInfo(config, my_battle_info , enemy_battle_info)
    local teamForce1 = 0
    local teamForce2 = 0
    local enemyTeamForce1 = 0
    local enemyTeamForce2 = 0
    config.pvpMultipleTeams = { 
        {hero = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}, 
        enemy = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}},
        {hero = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}, 
        enemy = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}},
    }
	local armListInfo = {}
	local enemyArmListInfo = {}

    for i=1,2 do
	    if not q.isEmpty(my_battle_info[i]) then
			remote.herosUtil:addPeripheralSkills(my_battle_info[i])
		    for _, member in ipairs(my_battle_info[i]) do
		        local info = clone(member)
		        if info.currHp == nil or info.currHp > 0 then
		            table.insert(config.pvpMultipleTeams[i].hero.heroes, info)
		    	end
		    end
	    end

	    if my_battle_info.soulSpirit[i] then
			local soulSpirit ={}
		    soulSpirit.id = my_battle_info.soulSpirit[i].actorId
		    soulSpirit.grade = my_battle_info.soulSpirit[i].grade
		    soulSpirit.level = my_battle_info.soulSpirit[i].level
			table.insert(config.pvpMultipleTeams[i].hero.soulSpirits, self:getSoulSpiritInfo(soulSpirit))
	    end


	    if not q.isEmpty(my_battle_info.godArmList[i]) then
		    for index, member in ipairs(my_battle_info.godArmList[i]) do
		    	local info = clone(member)
		    	local godArm = {}
			    godArm.id = info.actorId
			    godArm.grade = info.grade
			    godArm.level = info.level
            	table.insert(armListInfo, info.actorId..";"..(info.grade or 0))
				table.insert(config.pvpMultipleTeams[i].hero.godArmIdList,self:_getGodarmInfo(godArm))
		    end
	    end

	    if not q.isEmpty(enemy_battle_info[i]) then
			remote.herosUtil:addPeripheralSkills(enemy_battle_info[i])
		    for _, member in ipairs(enemy_battle_info[i]) do
		        local info = clone(member)
		        if info.currHp == nil or info.currHp > 0 then
		            table.insert(config.pvpMultipleTeams[i].enemy.heroes, info)
		    	end
		    end
	    end
	    if enemy_battle_info.soulSpirit[i] then
			local soulSpirit ={}
		    soulSpirit.id = enemy_battle_info.soulSpirit[i].actorId
		    soulSpirit.grade = enemy_battle_info.soulSpirit[i].grade
		    soulSpirit.level = enemy_battle_info.soulSpirit[i].level
			table.insert(config.pvpMultipleTeams[i].enemy.soulSpirits, self:getSoulSpiritInfo(soulSpirit))
	    end

	    if not q.isEmpty(enemy_battle_info.godArmList[i]) then
		    for index, member in ipairs(enemy_battle_info.godArmList[i]) do
		    	local info = clone(member)
		    	local godArm = {}
			    godArm.id = info.actorId
			    godArm.grade = info.grade
			    godArm.level = info.level
            	table.insert(enemyArmListInfo, info.actorId..";"..(info.grade or 0))
				table.insert(config.pvpMultipleTeams[i].enemy.godArmIdList, self:_getGodarmInfo(godArm))
		    end
	    end
    end

	config.allHeroGodArmIdList = armListInfo
	config.allEnemyGodArmIdList = enemyArmListInfo

    config.pvpMultipleTeams[1].hero.force = teamForce1
    config.pvpMultipleTeams[2].hero.force = teamForce2
    config.pvpMultipleTeams[1].enemy.force = enemyTeamForce1
    config.pvpMultipleTeams[2].enemy.force = enemyTeamForce2
end


function QMockBattleArrangement:initMyInfo(config)

    config.myInfo.heros = config.heroInfos
    config.myInfo.alternateHeros = {}
    config.myInfo.subheros = config.supportHeroInfos 
    config.myInfo.sub2heros = config.supportHeroInfos2
    config.myInfo.sub3heros = config.supportHeroInfos3
    config.myInfo.soulSpirits = config.userSoulSpirits
	config.myInfo.activeSubActorId = config.activeSubActorId
	config.myInfo.activeSub2ActorId =	config.activeSub2ActorId 
	config.myInfo.activeSub3ActorId = config.activeSub3ActorId

 
  	config.rivalsInfo.heros = config.pvp_rivals
    config.rivalsInfo.alternateHeros = {}
    config.rivalsInfo.subheros = config.pvp_rivals2
    config.rivalsInfo.sub2heros = config.pvp_rivals4
    config.rivalsInfo.sub3heros = config.pvp_rivals6
    config.rivalsInfo.soulSpirit = config.enemySoulSpirits[1] or nil
	config.rivalsInfo.activeSubActorId = config.activeSubEnemyActorId
	config.rivalsInfo.activeSub2ActorId = config.activeSub2EnemyActorId
	config.rivalsInfo.activeSub3ActorId = config.activeSub3EnemyActorId
end

function QMockBattleArrangement:_addHeroSkill(dungeonConfig)


    dungeonConfig.heroInfos = {}
    dungeonConfig.supportHeroInfos = {}
    dungeonConfig.supportHeroInfos2 = {}
    dungeonConfig.supportHeroInfos3 = {}
    dungeonConfig.userSoulSpirits = {}
	dungeonConfig.userGodArmList = {}
	dungeonConfig.supportSkillHeroIndex = 1
	dungeonConfig.supportSkillHeroIndex2 = 1
	dungeonConfig.supportSkillHeroIndex3 = 1

	dungeonConfig.activeSubActorId =1
	dungeonConfig.activeSub2ActorId =1
	dungeonConfig.activeSub3ActorId =1

	local userAlternateTargetOrder= {}
	local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    teamVO:initBattleFormation()

    if next(self.myHeroList[1]) ~= nil then
		remote.herosUtil:addPeripheralSkills(self.myHeroList[1])
	    for _, member in ipairs(self.myHeroList[1]) do
	        local info = clone(member)
	        if info.currHp == nil or info.currHp > 0 then
	            table.insert(dungeonConfig.heroInfos, info)
	        	table.insert(userAlternateTargetOrder, info.actorId)
	    	end
	    end
    end

    if self.myHeroList.soulSpirit then
		local soulSpirit ={}
	    soulSpirit.id = self.myHeroList.soulSpirit.actorId
	    soulSpirit.grade = self.myHeroList.soulSpirit.grade
	    soulSpirit.level = self.myHeroList.soulSpirit.level
	    soulSpirit.exp = 0
	    soulSpirit.currMp = 0
	    soulSpirit.force = 0
		table.insert(dungeonConfig.userSoulSpirits, self:getSoulSpiritInfo(soulSpirit))
    end

    if q.isEmpty(self.myHeroList.godArmList) then
	    for index, member in ipairs(self.myHeroList.godArmList) do
	    	local info = clone(member)
	    	local godArm = {}
		    godArm.id = info.actorId
		    godArm.grade = info.grade
		    godArm.level = info.level
			table.insert(enemyGodArmIdList, godArm)
	    end
    end

    if next(self.myHeroList[2]) ~= nil then

	    remote.herosUtil:addPeripheralSkills(self.myHeroList[2])
	    local x = 1
	    for index, member in ipairs(self.myHeroList[2]) do
	        local info = clone(member)
	        if info.currHp == nil or info.currHp > 0 then
	            table.insert(dungeonConfig.supportHeroInfos, info)
				if member.id == self.myHeroList.activeSubActorId then
	            	dungeonConfig.supportSkillHeroIndex = x
	            	dungeonConfig.activeSubActorId = member.actorId
	        	end
				x =x + 1
	        end

	    end
	end

    if next(self.myHeroList[3]) ~= nil then
	    remote.herosUtil:addPeripheralSkills(self.myHeroList[3])
	    local x = 1
	    for index, member in ipairs(self.myHeroList[3]) do
	        local info = clone(member)
	        if info.currHp == nil or info.currHp > 0 then
	            table.insert(dungeonConfig.supportHeroInfos2, info)
		        if member.id == self.myHeroList.activeSub2ActorId then
		            dungeonConfig.supportSkillHeroIndex2 = x
		            dungeonConfig.activeSub2ActorId = member.actorId
		        end	        
				x =x + 1
	    	end
	    end
	end

    if next(self.myHeroList[4]) ~= nil then
	    remote.herosUtil:addPeripheralSkills(self.myHeroList[4])
	    local x = 1
	    for _, member in ipairs(self.myHeroList[4]) do
	        local info = clone(member)
	        if info.currHp == nil or info.currHp > 0 then
	            table.insert(dungeonConfig.supportHeroInfos3, info)
		        if member.id == self.myHeroList.activeSub3ActorId then
		            dungeonConfig.supportSkillHeroIndex3 = x
		            dungeonConfig.activeSub3ActorId = member.actorId
		        end
				x =x + 1
	        end
	    end
	end

    teamVO:sortTeamByHeroId(userAlternateTargetOrder)
    dungeonConfig.userAlternateTargetOrder = userAlternateTargetOrder


    local enemyInfo = {}
    local enemyInfo2 = {}
    local skillInfo = nil
    local enemyInfo3 = {}
    local skillInfo2 = nil
    local enemyInfo4 = {}
    local skillInfo3 = nil
    local enemySoulSpirits = {}
    local enemyGodArmIdList = {}


    local enemyAlternateTargetOrder = {}

	dungeonConfig.supportSkillEnemyIndex = 1
	dungeonConfig.supportSkillEnemyIndex2 = 1
	dungeonConfig.supportSkillEnemyIndex3 = 1
	dungeonConfig.activeSubEnemyActorId = 1
	dungeonConfig.activeSub2EnemyActorId = 1
	dungeonConfig.activeSub3EnemyActorId = 1

    if next(self.enemyHeroList[1]) ~= nil then
		remote.herosUtil:addPeripheralSkills(self.enemyHeroList[1])
	    for _, member in ipairs(self.enemyHeroList[1]) do
	        local info = clone(member)
	        if info.currHp == nil or info.currHp > 0 then
	            table.insert(enemyInfo, info)
	        	table.insert(enemyAlternateTargetOrder, info.actorId)
	    	end
	    end
    end

    if self.enemyHeroList.soulSpirit then
		local soulSpirit ={}
	    soulSpirit.id = self.enemyHeroList.soulSpirit.actorId
	    soulSpirit.grade = self.enemyHeroList.soulSpirit.grade
	    soulSpirit.level = self.enemyHeroList.soulSpirit.level
	    soulSpirit.exp = 0
	    soulSpirit.currMp = 0
	    soulSpirit.force = 0
		table.insert(enemySoulSpirits, self:getSoulSpiritInfo(soulSpirit))
    end

    if q.isEmpty(self.enemyHeroList.godArmList) then
	    for index, member in ipairs(self.enemyHeroList.godArmList) do
	    	local info = clone(member)
	    	local godArm = {}
		    godArm.id = info.actorId
		    godArm.grade = info.grade
		    godArm.level = info.level
			table.insert(enemyGodArmIdList, godArm)
	    end
    end


    if next(self.enemyHeroList[2]) ~= nil then
	    local x = 1
	    remote.herosUtil:addPeripheralSkills(self.enemyHeroList[2])
	    for index, member in ipairs(self.enemyHeroList[2]) do
	        local info = clone(member)
	        if info.currHp == nil or info.currHp > 0 then
	            table.insert(enemyInfo2, info)
		        if member.id == self.enemyHeroList.activeSubActorId then
		            skillInfo = info
		            dungeonConfig.supportSkillEnemyIndex = x
		            dungeonConfig.activeSubEnemyActorId = member.actorId
		        end
	            x = x + 1
	        end
	    end
	    if not skillInfo and #enemyInfo2 ~= 0 then
	        skillInfo = enemyInfo2[1]
	    end
	end

    if next(self.enemyHeroList[3]) ~= nil then
	    local x = 1
	    remote.herosUtil:addPeripheralSkills(self.enemyHeroList[3])
	    for index, member in ipairs(self.enemyHeroList[3]) do
	        local info = clone(member)
	        if info.currHp == nil or info.currHp > 0 then
	            table.insert(enemyInfo3, info)
		        if member.id == self.enemyHeroList.activeSub2ActorId then
		            skillInfo2 = info
		            dungeonConfig.supportSkillEnemyIndex2 = x
		            dungeonConfig.activeSub2EnemyActorId = member.actorId
		        end
				x = x + 1
	        end
	    end
	    if not skillInfo2 and #enemyInfo3 ~= 0 then
	        skillInfo2 = enemyInfo3[1]
	    end
	end

    if next(self.enemyHeroList[4]) ~= nil then
	    remote.herosUtil:addPeripheralSkills(self.enemyHeroList[4])
	    local x = 1
	    for index, member in ipairs(self.enemyHeroList[4]) do
	        local info = clone(member)
	        if info.currHp == nil or info.currHp > 0 then
	            table.insert(enemyInfo4, info)
		        if member.id == self.enemyHeroList.activeSub3ActorId then
		            skillInfo3 = info
	            	dungeonConfig.supportSkillEnemyIndex3 = x
		            dungeonConfig.activeSub3EnemyActorId = member.actorId
		        end
				x = x + 1
	        end
	    end
	    if not skillInfo3 and #enemyInfo4 ~= 0 then
	        skillInfo3 = enemyInfo4[1]
	    end
	end
    dungeonConfig.pvp_rivals = enemyInfo
    dungeonConfig.pvp_rivals2 = enemyInfo2
    dungeonConfig.pvp_rivals3 = skillInfo
    dungeonConfig.pvp_rivals4 = enemyInfo3
    dungeonConfig.pvp_rivals5 = skillInfo2
    dungeonConfig.pvp_rivals6 = enemyInfo4
    dungeonConfig.pvp_rivals7 = skillInfo3
    dungeonConfig.enemySoulSpirits = enemySoulSpirits
    teamVO:sortTeamByHeroId(enemyAlternateTargetOrder)
    dungeonConfig.enemyAlternateTargetOrder = enemyAlternateTargetOrder
    dungeonConfig.enemyGodArmIdList = enemyGodArmIdList
end



function QMockBattleArrangement:mergeHeroMount(battleInfo)
	local herosList = {}
	herosList[1] ={}
	herosList[2] ={}
	herosList[3] ={}
	herosList[4] ={}
	herosList.soulSpirit = nil
	herosList.godArmList = {}

	if battleInfo.soulSpiritId ~= 0 then
		local soulSpirit = clone(remote.mockbattle:getCardInfoByIndex(battleInfo.soulSpiritId ))
		herosList.soulSpirit = soulSpirit
	end




	herosList.activeSubActorId = battleInfo.activeSub1HeroId or 0
	herosList.activeSub2ActorId = battleInfo.activeSub2HeroId or 0
	herosList.activeSub3ActorId = battleInfo.activeSub3HeroId or 0
	
	local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    teamVO:sortTeam(battleInfo.mainHeroIds)
    teamVO:sortTeam(battleInfo.sub1HeroIds)
    teamVO:sortTeam(battleInfo.sub2HeroIds)
    teamVO:sortTeam(battleInfo.sub3HeroIds)

	for _, hero in pairs(battleInfo.mainHeroIds or {}) do
		local heroinfo = clone(remote.mockbattle:getCardInfoByIndex(hero))
		for _, value in pairs(battleInfo.wearInfo or {}) do
			if value.actorId == hero then
				local mountinfo = clone(remote.mockbattle:getCardInfoByIndex(value.zuoqiId))
				mountinfo.zuoqi.actorId = heroinfo.actorId
				heroinfo.zuoqi = mountinfo.zuoqi
				--local uiModel = QActorProp.new(heroinfo)
				--heroInfo.force = uiModel:getBattleForce(true)
				--QPrintTable(mountinfo.zuoqi) 
			end
		end
		table.insert(herosList[1],heroinfo)
	end

	for _, hero in pairs(battleInfo.sub1HeroIds or {}) do
		local heroinfo = clone(remote.mockbattle:getCardInfoByIndex(hero))
		table.insert(herosList[2],heroinfo)
	end
	for _, hero in pairs(battleInfo.sub2HeroIds or {}) do
		local heroinfo = clone(remote.mockbattle:getCardInfoByIndex(hero))
		table.insert(herosList[3],heroinfo)
	end
	for _, hero in pairs(battleInfo.sub3HeroIds or {}) do
		local heroinfo = clone(remote.mockbattle:getCardInfoByIndex(hero))
		table.insert(herosList[4],heroinfo)
	end

	for _, hero in pairs(battleInfo.godArmIdList or {}) do
		local heroinfo = clone(remote.mockbattle:getCardInfoByIndex(hero))
		table.insert(herosList.godArmList,heroinfo)
	end
	
	return herosList
end




function QMockBattleArrangement:mergeHeroMount2(battleInfo1,battleInfo2)

	local herosList = {}
	herosList[1] ={}
	herosList[2] ={}
	herosList.soulSpirit = {}
	herosList.godArmList = {}
	herosList.godArmList[1] = {}
	herosList.godArmList[2] = {}
	herosList.soulSpirit[1] = nil
	herosList.soulSpirit[2] = nil

	if battleInfo1.soulSpiritId ~= 0 then
		local soulSpirit = clone(remote.mockbattle:getCardInfoByIndex(battleInfo1.soulSpiritId ))
		herosList.soulSpirit[1] = soulSpirit
	end

	if battleInfo2.soulSpiritId ~= 0 then
		local soulSpirit = clone(remote.mockbattle:getCardInfoByIndex(battleInfo2.soulSpiritId ))
		herosList.soulSpirit[2] = soulSpirit
	end
	
	local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    teamVO:sortTeam(battleInfo1.mainHeroIds)
    teamVO:sortTeam(battleInfo2.mainHeroIds)
   

	for _, hero in pairs(battleInfo1.mainHeroIds or {}) do
		local heroinfo = clone(remote.mockbattle:getCardInfoByIndex(hero))
		for _, value in pairs(battleInfo1.wearInfo or {}) do
			if value.actorId == hero then
				local mountinfo = clone(remote.mockbattle:getCardInfoByIndex(value.zuoqiId))
				mountinfo.zuoqi.actorId = heroinfo.actorId
				heroinfo.zuoqi = mountinfo.zuoqi
			end
		end
		table.insert(herosList[1],heroinfo)
	end

	for _, hero in pairs(battleInfo2.mainHeroIds or {}) do
		local heroinfo = clone(remote.mockbattle:getCardInfoByIndex(hero))
		for _, value in pairs(battleInfo2.wearInfo or {}) do
			if value.actorId == hero then
				local mountinfo = clone(remote.mockbattle:getCardInfoByIndex(value.zuoqiId))
				mountinfo.zuoqi.actorId = heroinfo.actorId
				heroinfo.zuoqi = mountinfo.zuoqi
			end
		end
		table.insert(herosList[2],heroinfo)
	end

	
	for _, hero in pairs(battleInfo1.godArmIdList or {}) do
		local heroinfo = clone(remote.mockbattle:getCardInfoByIndex(hero))
		table.insert(herosList.godArmList[1],heroinfo)
	end

	for _, hero in pairs(battleInfo2.godArmIdList or {}) do
		local heroinfo = clone(remote.mockbattle:getCardInfoByIndex(hero))
		table.insert(herosList.godArmList[2],heroinfo)
	end

	return herosList
end



function QMockBattleArrangement:quickStartEndBattle( heroIdList )
	-- body
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	app:getClient():arenaFightStartRequest(BattleTypeEnum.ARENA, self._rivalInfo.userId, battleFormation, 
		    function(data)
		        -- local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("arena")
		        -- print("data.gfStartResponse.battleVerify = "..data.gfStartResponse.battleVerify)
		        -- config.verifyKey = data.gfStartResponse.battleVerify
		        self:quickStartBattle(heroIdList,data.gfStartResponse.battleVerify)
		end,function(data)
		end)
end

function QMockBattleArrangement:getHeroes()
	return remote.mockbattle:getMyHeroInfoList()
end

function QMockBattleArrangement:getMounts()
	local mounts = remote.mockbattle:getMyMountInfoList()
	table.sort(mounts, function (x, y)
		local hero_info_x = remote.mockbattle:getCardInfoByIndex(x)
		local hero_info_y = remote.mockbattle:getCardInfoByIndex(y)
		if hero_info_x and hero_info_y then
			local characher_x = QStaticDatabase:sharedDatabase():getCharacterByID(hero_info_x.actorId)
			local characher_y = QStaticDatabase:sharedDatabase():getCharacterByID(hero_info_y.actorId)
			if characher_x and characher_y then
				return characher_x.aptitude > characher_y.aptitude
			end
		end
		return false
	end )
    return remote.mockbattle:getMyMountInfoList()
end

function QMockBattleArrangement:getSoulSpirits()
    return remote.mockbattle:getMySoulSpiritInfoList()
end

function QMockBattleArrangement:getHaveGodarmList()
    return remote.mockbattle:getHaveGodarmList()
end

--不知道要不要加 先不实装
function QMockBattleArrangement:getSoulSpiritInfo(soulSpiritInfo)
	remote.soulSpirit:updateSoulSpiritData(soulSpiritInfo)
    local info = {}
    info.id = soulSpiritInfo.id
    info.grade = soulSpiritInfo.grade
    info.level = soulSpiritInfo.level
    info.addCoefficient = soulSpiritInfo.addCoefficient
    info.additionSkills = soulSpiritInfo.additionSkills or {}
	info.exp = 0
	info.currMp = 0
	info.force = 0 
    return info
end


return QMockBattleArrangement
