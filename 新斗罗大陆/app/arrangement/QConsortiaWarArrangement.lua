-- @Author: zhouxiaoshu
-- @Date:   2019-04-28 11:43:43
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-12 15:40:28

local QBaseArrangement = import(".QBaseArrangement")
local QConsortiaWarArrangement = class("QConsortiaWarArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")

QConsortiaWarArrangement.NO_FIGHT_HEROES = "第%d队还未设置战队，无法参加战斗！现在就设置战队？"
QConsortiaWarArrangement.ALL_HEAL_HEROES = "第%d队出战魂师不能全部为治疗魂师"

function QConsortiaWarArrangement:ctor(options)
	QConsortiaWarArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.CONSORTIA_WAR_ATTACK_TEAM1)

	self._rivalInfo = options.rivalInfo
	self._myInfo = options.myInfo
	self._hallId = options.hallId

	--加上 工会 头像 等属性
	self:addOtherPropForArena(self._rivalInfo)
end

function QConsortiaWarArrangement:getOpponent()
	return self._rivalInfo or {}
end

function QConsortiaWarArrangement:getBackPagePath(index)
	return QSpriteFrameByKey("sanctuary_arrangement_bg", 1)
end

function QConsortiaWarArrangement:getEffectPagePath(index)
	return QSpriteFrameByKey("sanctuary_arrangement_bg", 2)
end

function QConsortiaWarArrangement:getOpponentTeamByIndex(index)
	local opponent = self:getOpponent()
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		return opponent.heros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		return nil,false
	end
end

function QConsortiaWarArrangement:getUnlockSlots(index, trailNum)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHerosMaxCountByIndex(index, trailNum)
end

function QConsortiaWarArrangement:getUnlockLevel(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHelpUnlockLevel(index)
end

function QConsortiaWarArrangement:startBattle( heroIdList1, heroIdList2,isAuto,sucess,fail )
	local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)
	remote.consortiaWar:consortiaWarFightStartRequest(self._hallId, self._rivalInfo.userId, battleFormation1, battleFormation2, function(data)
		    self:startBattleBegin(battleFormation1, battleFormation2, data.gfStartResponse.battleVerify,isAuto,sucess,fail)
		end,function(data)
		end)
end

function QConsortiaWarArrangement:startBattleBegin(battleFormation1, battleFormation2, battleVerify,isAuto,sucess,fail)
	local config = db:getDungeonConfigByID("sanctuary")
	config.isArena = true
	config.isPVPMode = true
	config.isPvpMultipleNew = true
	config.isPVP2TeamBattle = true
	config.isConsortiaWar = true

	config.team1Name = remote.user.nickname
	config.team1Icon = remote.user.avatar
	if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
		config.team1Icon = db:getDefaultAvatarIcon()
	end
	config.team2Name = self._rivalInfo.name
	config.team2Icon = self._rivalInfo.avatar
	if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
		config.team2Icon = db:getDefaultAvatarIcon()
	end
	remote.herosUtil:addPeripheralSkills(self._rivalInfo.heros)

	config.pvp_archaeology = self._rivalInfo.apiArchaeologyInfoResponse
	config.rivalId = self._rivalInfo.userId
	config.myInfo = self._myInfo
	config.myInfo.maritimeMoney = remote.user.maritimeMoney or 0
	config.rivalsInfo = self._rivalInfo
	config.battleDT = 1 / 30
	config.verifyKey = battleVerify
    config.teamName = self._teamKey
    
    config.consortiaWarHallIdNum = remote.consortiaWar:getBreakHallIdNum()
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}
    config.battleFormation = battleFormation1
    config.battleFormation2 = battleFormation2
    
    self:_initNewPVPTeamInfo(config, self._rivalInfo, remote.teamManager.CONSORTIA_WAR_ATTACK_TEAM1, remote.teamManager.CONSORTIA_WAR_ATTACK_TEAM2)
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

    remote.consortiaWar:consortiaWarFightEndRequest(self._hallId, self._rivalInfo.userId, battleFormation1, battleFormation2, battleVerify, function (data)
    	record.dungeonConfig.fightEndResponse = data
    	local isWin = data.gfEndResponse.isWin and 1 or 0
    	local scoreList = data.gfEndResponse.scoreList
    	record.dungeonConfig.quickFightResult = {isWin = isWin, scoreList = scoreList}

        local myInfo = {}
        myInfo.name = remote.user.nickname
		myInfo.avatar = remote.user.avatar
		myInfo.level = remote.user.level
		
        local replayInfo = QReplayUtil:generateMultipleTeamReplayInfo(myInfo, config.rivalsInfo, config.pvpMultipleTeams, isWin == 1 and 1 or 2)
		if isAuto and sucess then
			sucess(data)
		else
			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
			local loader = QDungeonResourceLoader.new(record.dungeonConfig)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
		end

        QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.CONSORTIA_WAR)
    end, function(data)		
		if data.error ~= nil then --如果后台返回错误码 则刷新斗魂场信息
			if isAuto and fail then
				fail(data)
			end
		end
    end)
end


function QConsortiaWarArrangement:getHeroIdList()
	local teamVO = remote.teamManager:getTeamByKey(self:getTeamKey(), false)
	return teamVO:getAllTeam()
end


function QConsortiaWarArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QConsortiaWarArrangement
