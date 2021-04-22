--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QSparFieldArrangement = class("QSparFieldArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")

QSparFieldArrangement.NO_FIGHT_HEROES = "第%d队还未设置战队，无法参加战斗！现在就设置战队？"
QSparFieldArrangement.ALL_HEAL_HEROES = "第%d队出战魂师不能全部为治疗魂师"

function QSparFieldArrangement:ctor(options)
	QSparFieldArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.SPARFIELD_TEAM)
	self._rivalInfo = options.fightInfo
	self._waveId = options.waveId
	self._difficulty = options.difficulty

	self._myInfo = {}
    self._myInfo.name = remote.user.nickname
    self._myInfo.avatar = remote.user.avatar
    self._myInfo.level = remote.user.level
    local _,_,topNForce = remote.herosUtil:getMaxForceHeros()
    self._myInfo.force = topNForce
end

function QSparFieldArrangement:getOpponent()
	return self._rivalInfo or {}
end

function QSparFieldArrangement:getOpponentTeamByIndex(index)
	local opponent = self:getOpponent()
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		return opponent.heros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		return opponent.subheros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP2 then
		return opponent.sub2heros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP3 then
		return opponent.sub3heros,true
	end
end

function QSparFieldArrangement:getUnlockSlots(index)
	return QStaticDatabase:sharedDatabase():getStormArenaUnlockCount(remote.user.level, index)
end

function QSparFieldArrangement:getBackPagePath(index)
	return QSpriteFrameByKey("sparfield_arrangement_bg", index)
end

function QSparFieldArrangement:startBattle( heroIdList )
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.sparField:sparFieldFightStartRequest(BattleTypeEnum.SPAR_FIELD, self._rivalInfo.userId, battleFormation, 
		    function(data)
		        self:startBattle_begin(heroIdList,data.gfStartResponse.battleVerify)
		end,function(data)
		end)
end

function QSparFieldArrangement:startBattle_begin(heroIdList, battleVerifyKey)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	self.super.setAllTeams(self, heroIdList)

	self._myInfo.heros = self:_constructAttackHero()

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("spar_1_1")
	config.isPVPMode = true
	config.isArena = true
	-- config.isStormArena = true
	config.isSparField = true
	config.isPVPMultipleWave = true


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

	config.pvp_archaeology = self._rivalInfo.apiArchaeologyInfoResponse
	config.rivalId = self._rivalInfo.userId
	config.myInfo = self._myInfo
	config.legendHeroIds = self._myInfo.legendHeroIds

	-- config.myInfo.stormMoney = remote.user.stormMoney or 0
	config.rivalsInfo = self._rivalInfo
	config.difficulty = self._difficulty
	-- config.rivalsPos = self._rivalsPos
	config.battleDT = 1 / 30
	config.battleFormation = battleFormation
	config.verifyKey = battleVerifyKey

	-- if config.rivalsInfo.force >= (self._myInfo.force or 0) then
	-- 	config.skipBattleWithWin = false
	-- else
	-- 	config.skipBattleWithWin = true
	-- end
    config.teamName = self._teamKey
    
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}

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

	local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)

    remote.sparField:sparFieldFightEndRequest(self._waveId, self._difficulty, fightReportData, config.battleFormation, battleVerifyKey, function (data)
        remote.sparField:setInBattle(true)
        
    	record.dungeonConfig.fightEndResponse = data
    	-- local isWin = data.sparFieldFightEndResponse.isWin
    	-- local scoreList = data.sparFieldFightEndResponse.scoreList
    	local isWin = data.gfEndResponse.isWin and 1 or 0
    	local scoreList = data.gfEndResponse.scoreList
    	record.dungeonConfig.quickFightResult = {isWin = isWin, scoreList = scoreList}

    	--如果赢了设置一下战斗的状态
    	if isWin then
    		remote.sparField:setFightStatus(1)
    	end

    	local myInfo = clone(self._myInfo)
        local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin == 1 and 1 or 2, self._teamKey)
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		local loader = QDungeonResourceLoader.new(record.dungeonConfig)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
		-- todo fight report upload
        -- QReplayUtil:uploadReplay(data.sparFieldFightEndResponse.fightReportId, replayInfo, function() end, function() end, REPORT_TYPE.SPAR_FIELD)
    end, function(data)		
		if data.error ~= nil then --如果后台返回错误码 则刷新斗魂场信息
			
		end
    end, nil, true)
end

function QSparFieldArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QSparFieldArrangement
