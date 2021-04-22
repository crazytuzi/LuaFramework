-- @Author: xurui
-- @Date:   2019-12-30 17:42:27
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-02-24 18:13:00
local QBaseArrangement = import(".QBaseArrangement")
local QTotemChallengeArrangement = class("QTotemChallengeArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")
local QUserData = import("..utils.QUserData")

QTotemChallengeArrangement.NO_FIGHT_HEROES = "第%d队还未设置战队，无法参加战斗！现在就设置战队？"
QTotemChallengeArrangement.ALL_HEAL_HEROES = "第%d队出战魂师不能全部为治疗魂师"

function QTotemChallengeArrangement:ctor(options)
	QTotemChallengeArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.TOTEM_CHALLENGE_TEAM1)

	self._fighterInfo = options.fighterInfo
	self._rivalInfo = options.rivalsFight

	self._myInfo = {}
    self._myInfo.name = remote.user.nickname
    self._myInfo.avatar = remote.user.avatar
    self._myInfo.level = remote.user.level
    local _,_,topNForce = remote.herosUtil:getMaxForceHeros()
    self._myInfo.force = topNForce

	--加上 工会 头像 等属性
	self:addOtherPropForArena(self._rivalInfo)
end

function QTotemChallengeArrangement:getOpponent()
	return self._rivalInfo or {}
end

function QTotemChallengeArrangement:getOpponentTeamByIndex(index)
	local opponent = self:getOpponent()
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		return opponent.heros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		return nil,false
	end
end

function QTotemChallengeArrangement:getUnlockSlots(index, trailNum)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHerosMaxCountByIndex(index, trailNum)
end

function QTotemChallengeArrangement:getUnlockLevel(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHelpUnlockLevel(index)
end

function QTotemChallengeArrangement:startBattle( heroIdList1, heroIdList2 )
	self._battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	self._battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)

	remote.totemChallenge:requestTotemChallengeFightStartRequest(self._fighterInfo.rivalPos, self._battleFormation1, self._battleFormation2,
		    function(data)
                remote.totemChallenge:setDungeonPassRivalPos()
		        self:startBattle_begin(data.gfStartResponse.battleVerify, self._battleFormation1, self._battleFormation2)
		end,function(data)
		end)
end

function QTotemChallengeArrangement:startBattle_begin(battleVerifyKey)
	local team1VO = remote.teamManager:getTeamByKey(remote.teamManager.STORM_ARENA_DEFEND_TEAM1, false)
	local isSkip = app:getUserData():getUserValueForKey(QUserData.Totem_Challenge_SKIP)

	local team1ActorIds = team1VO:getTeamActorsByIndex(1)
	if q.isEmpty(team1ActorIds) then
		team1VO:setTeamDataWithBattleFormation(self._battleFormation1)
		remote.stormArena:requestChangeStormDefendTeam(self._battleFormation1)
  	end
	local team2VO = remote.teamManager:getTeamByKey(remote.teamManager.STORM_ARENA_DEFEND_TEAM2, false)
	local team2ActorIds = team1VO:getTeamActorsByIndex(1)
	if q.isEmpty(team2ActorIds) then
		team1VO:setTeamDataWithBattleFormation(self._battleFormation2)
		remote.stormArena:requestChangeStormDefendTeam(self._battleFormation2)
  	end

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("sunwell")
	config.isPvpMultipleNew = true
	config.isArena = true
	config.isTotemChallenge = true
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

	config.battleFormation = self._battleFormation1
	config.battleFormation2 = self._battleFormation2
	config.pvp_archaeology = self._rivalInfo.apiArchaeologyInfoResponse
	config.rivalId = self._rivalInfo.userId
	config.rivalPos = self._fighterInfo.rivalPos
	config.rivalsInfo = self._rivalInfo
	config.verifyKey = battleVerifyKey
    config.teamName = self._teamKey
	config.forceYield = self._fighterInfo.forceYield or 1
    config.totemChallengeBuffId = self._fighterInfo.buffId
    config.totemChallengePos = self._fighterInfo.buffNum
	config.myInfo = self._myInfo
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}
	local userTotemDungeonInfo = remote.totemChallenge:getTotemUserDungeonInfo()
	if userTotemDungeonInfo then
		if userTotemDungeonInfo.team1IsQuickPass then
    		config.holyPressureWave = 1
    	elseif userTotemDungeonInfo.team2IsQuickPass then
    		config.holyPressureWave = 2
    	end
    end

	config.isTotemChallengeQuick = (isSkip == "1" and true or false)

    self:_initNewPVPTeamInfo(config, self._rivalInfo, remote.teamManager.TOTEM_CHALLENGE_TEAM1, remote.teamManager.TOTEM_CHALLENGE_TEAM2)
    self:_initDungeonConfig(config, self._rivalInfo)

	local buffer, record = self:_createReplayBuffer(config)
	writeToBinaryFile("last.reppb", buffer)

    record.dungeonConfig.replayTimeSlices = record.recordTimeSlices
    record.dungeonConfig.replayRandomSeed = record.recordRandomSeed
    for key, value in pairs(config) do
        record.dungeonConfig[key] = value
    end
	
    if isSkip and isSkip == "1" then

    	remote.totemChallenge:requestTotemChallengeFightEndRequest(config.rivalPos, config.verifyKey, config.battleFormation, config.battleFormation2,
    	    function (data)
			remote.totemChallenge:setDungeonPassRivalPos(config.rivalPos)
			-- local isWin = data.totemChallengeFightEndResponse.fightSuccessCount >= 2 and true or false
		   	local info = {}
		    local rivalsInfo = config.rivalsInfo
		    local myInfo = config.myInfo
		    local reward = ""
		    
		    if data.totemChallengeFightEndResponse and data.totemChallengeFightEndResponse.fightEndReward then
		        reward = reward..(data.totemChallengeFightEndResponse.fightEndReward.reward or "")
		    end
		    
		    local replayInfo = QReplayUtil:generateMultipleTeamReplayInfo(config.myInfo, config.rivalsInfo, config.pvpMultipleTeams, isWin, false)
		    local scoreList = data.totemChallengeFightEndResponse and data.totemChallengeFightEndResponse.scoreList or {}
		    local heroScore, enemyScore = 0, 0
		    for _, score in ipairs(scoreList or {}) do 
		        if score then
		            heroScore = heroScore + 1
		        else
		            enemyScore = enemyScore + 1
		        end
		    end
		    local isWin = heroScore >= 2 and true or false

		    info.isTotemChallenge = true
		    info.team1Score = heroScore
		    info.team2Score = enemyScore
		    info.team1avatar = myInfo.avatar
		    info.team2avatar = rivalsInfo.avatar
		    info.team1Name = myInfo.name
		    info.team2Name = rivalsInfo.name
		    info.scoreList = scoreList
		    info.replayInfo = replayInfo  
		    info.pvpMultipleTeams = config.pvpMultipleTeams
		    info.fightReportStats = data.fightReportStats
		    info.reward = reward

			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

		    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTotemChallengeBattleResult", 
		     	options = {info = info, isWin = isWin, rankInfo = data, rivalId = config.rivalId}}, {isPopCurrentDialog = true})


			end
			, function(data)
			end)
    else
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

		local loader = QDungeonResourceLoader.new(record.dungeonConfig)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
    end


end

function QTotemChallengeArrangement:_constructAttackHero(teamKey, index)
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

function QTotemChallengeArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QTotemChallengeArrangement
