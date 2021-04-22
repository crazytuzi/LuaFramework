--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QStormArenaAutoArrangement = class("QStormArenaAutoArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")

QStormArenaAutoArrangement.NO_FIGHT_HEROES = "第%d队还未设置战队，无法参加战斗！现在就设置战队？"
QStormArenaAutoArrangement.ALL_HEAL_HEROES = "第%d队出战魂师不能全部为治疗魂师"

function QStormArenaAutoArrangement:ctor(options)
	QStormArenaAutoArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.STORM_ARENA_ATTACK_TEAM)

	self._rivalInfo = options.rivalInfo
	self._rivalsPos = options.rivalsPos
	self._myInfo = options.myInfo

	self._isReady = false
	self._config = {}

	--加上 工会 头像 等属性
	self:addOtherPropForArena(self._rivalInfo)
end

function QStormArenaAutoArrangement:isReady()
	return self._isReady
end

function QStormArenaAutoArrangement:getConfig()
	return self._config 
end

function QStormArenaAutoArrangement:startBattle( heroIdList1, heroIdList2, callback )
	local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)

	remote.stormArena:requestStormArenaFightStartRequest(BattleTypeEnum.STORM, self._rivalInfo.userId, battleFormation1, battleFormation2,
		    function(data)
		        self:autoFightEnd(heroIdList1, heroIdList2, data.gfStartResponse.battleVerify, callback)
		end,function(data)
		end)
end

function QStormArenaAutoArrangement:autoFightEnd(heroIdList1, heroIdList2, battleVerifyKey, callback)
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
    	remote.stormArena:setTopRankUpdate(data, config.rivalsInfo.userId)

    	local isWin = data.gfEndResponse.isWin and 1 or 0
    	local scoreList = data.gfEndResponse.scoreList
    	record.dungeonConfig.quickFightResult = {isWin = isWin, scoreList = scoreList}

        local myInfo = clone(config.myInfo)
        myInfo.heros = self:_constructAttackHero(remote.teamManager.STORM_ARENA_ATTACK_TEAM1, 1)
        myInfo.main1Heros = self:_constructAttackHero(remote.teamManager.STORM_ARENA_ATTACK_TEAM2, 2)

        local replayInfo = QReplayUtil:generateMultipleTeamReplayInfo(myInfo, config.rivalsInfo, config.pvpMultipleTeams, isWin == 1 and 1 or 2)
        QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.STORM_ARENA)
		
        local awards = {}
    	local count = data.wallet.maritimeMoney - config.myInfo.maritimeMoney
    	table.insert(awards, {id = nil, typeName = ITEM_TYPE.MARITIME_MONEY, count = count})
    	local yield = data.stormFightEndResponse.yield
        local text = ""

        if isWin == 1 then
        	if #scoreList == 2 then
        		-- 2:0
        		text = "魂师大人，本次战斗您不费吹灰之力就以2:0战胜了对手，以下是您的奖励哟～"
        	else
        		-- 2:1
        		text = "魂师大人，本次战斗您以2:1微弱优势险胜对手，以下是您的奖励哟～"
        	end
        	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWin", 
                options = {awards = awards, bonusAwards = bonusAwards, addScore = addScore, yield = yield, activityYield = activityYield, userComeBackRatio = userComeBackRatio, text = text, 
                	callback = function()
	                    if callback then
	                    	callback()
	                    end
	                end}}, {isPopCurrentDialog = true})
        else
        	if #scoreList == 2 then
        		-- 0:2
        		text = "魂师大人，本次战斗您0:2并未战胜对手，要再接再厉哦～"
        	else
        		-- 1:2
        		text = "魂师大人，本次战斗您1:2的微弱劣势不敌对手，要再接再厉哦～"
        	end
        	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogLose", 
        		options = {awards = awards, bonusAwards = bonusAwards, addScore = addScore, yield = yield, activityYield = activityYield, userComeBackRatio = userComeBackRatio, text = text, 
        			callback = function()
	                    if callback then
	                    	callback()
	                    end
	                end}}, {isPopCurrentDialog = true})
        end
    end, function(data)		
		if data.error ~= nil then --如果后台返回错误码 则刷新斗魂场信息
			
		end
    end)
end

function QStormArenaAutoArrangement:getHeroIdList()
	-- local actorIds = self:getExistingHeroes()
	-- if #actorIds == 0 then
	-- 	local teams = remote.teamManager:getDefaultTeam(remote.teamManager.INSTANCE_TEAM)
	-- 	remote.teamManager:updateTeamData(self:getTeamKey(), teams)
	-- end
	local teamVO = remote.teamManager:getTeamByKey(self:getTeamKey(), false)
	return teamVO:getAllTeam()
end

function QStormArenaAutoArrangement:_constructAttackHero(teamKey, index)
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

function QStormArenaAutoArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QStormArenaAutoArrangement
