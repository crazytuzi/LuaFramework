-- @Author: xurui
-- @Date:   2016-12-28 20:06:53
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-08-29 15:05:25

local QBaseArrangement = import(".QBaseArrangement")
local QMaritimeArrangement = class("QMaritimeArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")

QMaritimeArrangement.NO_FIGHT_HEROES = "第%d队还未设置战队，无法参加战斗！现在就设置战队？"
QMaritimeArrangement.ALL_HEAL_HEROES = "第%d队出战魂师不能全部为治疗魂师"

function QMaritimeArrangement:ctor(options)
	QMaritimeArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.MARITIME_ATTACK_TEAM1)
	-- self._fighter = options.fighter
	self._rivalInfo = options.rivalInfo
	self._myInfo = options.myInfo
	self._info = options.info
	self._shipInfo = options.shipInfo
	--加上 工会 头像 等属性
	self:addOtherPropForArena(self._rivalInfo)
end

function QMaritimeArrangement:getOpponent()
	return self._rivalInfo or {}
end

function QMaritimeArrangement:getOpponentTeamByIndex(index)
	local opponent = self:getOpponent()
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		return opponent.heros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		return nil,false
	end
end

function QMaritimeArrangement:getUnlockSlots(index, trailNum)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHerosMaxCountByIndex(index, trailNum)
end

function QMaritimeArrangement:getUnlockLevel(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHelpUnlockLevel(index)
end

function QMaritimeArrangement:startBattle( heroIdList1, heroIdList2 )
	-- body
	local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)
	remote.maritime:requestMaritimeFightStartRequest(BattleTypeEnum.MARITIME, self._rivalInfo.userId, battleFormation1, battleFormation2,
		    function(data)
		        self:quickStartBattle(battleFormation1, battleFormation2, data.gfStartResponse.battleVerify)
		end,function(data)
		end)
end

function QMaritimeArrangement:quickStartBattle(battleFormation1, battleFormation2, battleVerifyKey)
	local team1VO = remote.teamManager:getTeamByKey(remote.teamManager.MARITIME_DEFEND_TEAM1, false)
	local actorIds = team1VO:getTeamActorsByIndex(1)
	if q.isEmpty(actorIds) then
		team1VO:setTeamDataWithBattleFormation(battleFormation1)
		remote.maritime:requestSetMaritimeDefenseTeam(battleFormation1)
  	end
	local team2VO = remote.teamManager:getTeamByKey(remote.teamManager.MARITIME_DEFEND_TEAM2, false)
	local actorIds = team2VO:getTeamActorsByIndex(1)
	if q.isEmpty(actorIds) then
		team2VO:setTeamDataWithBattleFormation(battleFormation2)
		remote.maritime:requestSetMaritimeDefenseTeam(battleFormation2)
  	end

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("maritime")
	config.isPVPMode = true
	config.isArena = true
	config.isMaritime = true
	config.isPvpMultipleNew = true

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
	remote.teamManager:sortTeam(self._rivalInfo.heros, true)
	remote.teamManager:sortTeam(self._rivalInfo.subheros, true)
	remote.teamManager:sortTeam(self._rivalInfo.sub2heros, true)
	remote.teamManager:sortTeam(self._rivalInfo.main1Heros, true)
	remote.teamManager:sortTeam(self._rivalInfo.sub1heros, true)

	config.battleFormation = battleFormation1
	config.battleFormation2 = battleFormation2

	config.pvp_archaeology = self._rivalInfo.apiArchaeologyInfoResponse
	config.rivalId = self._rivalInfo.userId
	config.myInfo = self._myInfo
	config.shipInfo = self._shipInfo
	config.myInfo.magicherbMoney = remote.user.magicherbMoney or 0
	config.rivalsInfo = self._rivalInfo
	config.battleDT = 1 / 30
	config.verifyKey = battleVerifyKey

	local battleForce1 = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.MARITIME_ATTACK_TEAM1) or 0
	local battleForce2 = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.MARITIME_ATTACK_TEAM2) or 0
	local battleForce = battleForce1 + battleForce2
	if (config.rivalsInfo.force or 0) >= battleForce then
		config.skipBattleWithWin = false
	else
		config.skipBattleWithWin = true
	end
    config.teamName = self._teamKey
    
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}

    self:_initNewPVPTeamInfo(config, self._rivalInfo, remote.teamManager.MARITIME_ATTACK_TEAM1, remote.teamManager.MARITIME_ATTACK_TEAM2)
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

    remote.maritime:requestMaritimeFightEnd(self._shipInfo.userId, battleVerifyKey, battleFormation1, battleFormation2, function (data)
    	record.dungeonConfig.fightEndResponse = data
    	local isWin = data.gfEndResponse.isWin
    	local scoreList = data.gfEndResponse.scoreList
    	record.dungeonConfig.quickFightResult = {isWin = isWin == true and 1 or 2, scoreList = scoreList}

        local myInfo = clone(config.myInfo)
        myInfo.heros = self:_constructAttackHero(remote.teamManager.MARITIME_ATTACK_TEAM1, 1)
        myInfo.main1Heros = self:_constructAttackHero(remote.teamManager.MARITIME_ATTACK_TEAM2, 2)

        local replayInfo = QReplayUtil:generateMultipleTeamReplayInfo(myInfo, config.rivalsInfo, config.pvpMultipleTeams, isWin == true and 1 or 2)
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		
		local loader = QDungeonResourceLoader.new(record.dungeonConfig)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})

        QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.MARITIME)
    end, function(data)		
		if data.error ~= nil then --如果后台返回错误码 则刷新斗魂场信息
			
		end
    end, nil, true)
end

function QMaritimeArrangement:_constructAttackHero(teamKey, index)
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

function QMaritimeArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QMaritimeArrangement