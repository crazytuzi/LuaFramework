--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QStormArenaArrangement = class("QStormArenaArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")

QStormArenaArrangement.NO_FIGHT_HEROES = "第%d队还未设置战队，无法参加战斗！现在就设置战队？"
QStormArenaArrangement.ALL_HEAL_HEROES = "第%d队出战魂师不能全部为治疗魂师"

function QStormArenaArrangement:ctor(options)
	QStormArenaArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.STORM_ARENA_ATTACK_TEAM)

	self._rivalInfo = options.rivalInfo
	self._rivalsPos = options.rivalsPos
	self._myInfo = options.myInfo

	--加上 工会 头像 等属性
	self:addOtherPropForArena(self._rivalInfo)
end

function QStormArenaArrangement:getOpponent()
	return self._rivalInfo or {}
end

function QStormArenaArrangement:getOpponentTeamByIndex(index)
	local opponent = self:getOpponent()
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		return opponent.heros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		return nil,false
	end
end

function QStormArenaArrangement:getUnlockSlots(index, trailNum)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHerosMaxCountByIndex(index, trailNum)
end

function QStormArenaArrangement:getUnlockLevel(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHelpUnlockLevel(index)
end

function QStormArenaArrangement:startBattle( heroIdList1, heroIdList2 )
	local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)
	remote.stormArena:requestStormArenaFightStartRequest(BattleTypeEnum.STORM, self._rivalInfo.userId, battleFormation1, battleFormation2,
		    function(data)
		        self:startBattle_begin(heroIdList1, heroIdList2, data.gfStartResponse.battleVerify)
		end,function(data)
		end)
end

function QStormArenaArrangement:startBattle_begin(heroIdList1, heroIdList2, battleVerifyKey)
	local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)

	local team1VO = remote.teamManager:getTeamByKey(remote.teamManager.STORM_ARENA_DEFEND_TEAM1, false)
	local team1ActorIds = team1VO:getTeamActorsByIndex(1)
	if q.isEmpty(team1ActorIds) then
		team1VO:setTeamDataWithBattleFormation(battleFormation1)
		remote.stormArena:requestChangeStormDefendTeam(battleFormation1)
  	end
	local team2VO = remote.teamManager:getTeamByKey(remote.teamManager.STORM_ARENA_DEFEND_TEAM2, false)
	local team2ActorIds = team1VO:getTeamActorsByIndex(1)
	if q.isEmpty(team2ActorIds) then
		team1VO:setTeamDataWithBattleFormation(battleFormation2)
		remote.stormArena:requestChangeStormDefendTeam(battleFormation2)
  	end
	--更新今日斗魂场打斗次数
	remote.user:addPropNumForKey("todayStormFightCount")
	-- remote.user:addPropNumForKey("addupArenaFightCount")

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("storm_arena")
	config.isPvpMultipleNew = true
	config.isArena = true
	config.isStormArena = true
	config.isPVPMode = true

	config.team1Name = remote.user.nickname
	config.team1Icon = remote.user.avatar
	if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
		config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end
	config.team2Name = self._rivalInfo.name
	config.team2Icon = self._rivalInfo.avatar
	if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
		config.team2Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end
	remote.herosUtil:addPeripheralSkills(self._rivalInfo.heros)

	config.battleFormation = battleFormation1
	config.battleFormation2 = battleFormation2
	config.pvp_archaeology = self._rivalInfo.apiArchaeologyInfoResponse
	config.rivalId = self._rivalInfo.userId
	config.myInfo = self._myInfo
	config.myInfo.maritimeMoney = remote.user.maritimeMoney or 0
	config.rivalsInfo = self._rivalInfo
	config.rivalsPos = self._rivalsPos
	config.battleDT = 1 / 30
	config.verifyKey = battleVerifyKey

	if config.rivalsInfo.force >= (self._myInfo.force or 0) then
		config.skipBattleWithWin = false
	else
		config.skipBattleWithWin = true
	end
    config.teamName = self._teamKey
    
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}

    self:_initNewPVPTeamInfo(config, self._rivalInfo, remote.teamManager.STORM_ARENA_ATTACK_TEAM1, remote.teamManager.STORM_ARENA_ATTACK_TEAM2)
    self:_initDungeonConfig(config, self._rivalInfo)

	local buffer, record = self:_createReplayBuffer(config)
	writeToBinaryFile("last.reppb", buffer)

    record.dungeonConfig.replayTimeSlices = record.recordTimeSlices
    record.dungeonConfig.replayRandomSeed = record.recordRandomSeed
    for key, value in pairs(config) do
        record.dungeonConfig[key] = value
    end
	record.dungeonConfig.isReplay = true
    record.dungeonConfig.isQuick = true

    remote.stormArena:requestStormArenaFightEndRequest(config.rivalsInfo.userId, config.battleFormation, config.battleFormation2, config.rivalsPos, {selfHerosStatus = {}, rivalHerosStatus = {}}, {}, battleVerifyKey, function (data)
    	
    	app.taskEvent:updateTaskEventProgress(app.taskEvent.STORM_ARENA_TASK_EVENT, 1)
    	
    	record.dungeonConfig.fightEndResponse = data
    	local isWin = data.gfEndResponse.isWin and 1 or 0
    	local scoreList = data.gfEndResponse.scoreList
    	record.dungeonConfig.quickFightResult = {isWin = isWin, scoreList = scoreList}

        local myInfo = clone(config.myInfo)
        myInfo.heros = self:_constructAttackHero(remote.teamManager.STORM_ARENA_ATTACK_TEAM1, 1)
        myInfo.main1Heros = self:_constructAttackHero(remote.teamManager.STORM_ARENA_ATTACK_TEAM2, 2)

        local replayInfo = QReplayUtil:generateMultipleTeamReplayInfo(myInfo, config.rivalsInfo, config.pvpMultipleTeams, isWin == 1 and 1 or 2)
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		
		local loader = QDungeonResourceLoader.new(record.dungeonConfig)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
	
        QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.STORM_ARENA)
    end, function(data)		
		if data.error ~= nil then --如果后台返回错误码 则刷新斗魂场信息
			
		end
    end)
end

function QStormArenaArrangement:_constructAttackHero(teamKey, index)
	if index == nil then 
		index = 1
	end
    local attackHeroInfo = {}
    for k, v in ipairs(remote.teamManager:getActorIdsByKey(teamKey, index)) do
        local heroInfo = remote.herosUtil:getHeroByID(v)
        table.insert(attackHeroInfo, heroInfo)
    end

    return attackHeroInfo
end

function QStormArenaArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QStormArenaArrangement
