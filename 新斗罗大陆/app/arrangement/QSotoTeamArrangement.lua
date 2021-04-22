-- @Author: zhouxiaoshu
-- @Date:   2019-09-07 17:47:24
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-06-03 12:38:58
local QBaseArrangement = import(".QBaseArrangement")
local QSotoTeamArrangement = class("QSotoTeamArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")


function QSotoTeamArrangement:ctor(options)
	QSotoTeamArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.SOTO_TEAM_ATTACK_TEAM)

	self._rivalInfo = options.rivalInfo
	self._rivalsPos = options.rivalsPos
	self._myInfo = options.myInfo
end

function QSotoTeamArrangement:getBackPagePath(index)
	return QSpriteFrameByKey("soto_team_arrangement_bg", 1)
end

function QSotoTeamArrangement:getEffectPagePath(index)
	return QSpriteFrameByKey("soto_team_arrangement_bg", 2)
end

function QSotoTeamArrangement:startAutoFight(heroIdList,succss,fail)
	if heroIdList == nil or heroIdList[1] == nil or next(heroIdList[1].actorIds) == nil then
        app.tip:floatTip("魂师大人，当前没有魂师上阵，快去设置上阵吧~")
        return
    end

    if self:teamValidity(heroIdList[1].actorIds) == false then
        return
    end
    local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.sotoTeam:sotoTeamFightStartRequest(self._rivalInfo.userId, battleFormation, function(data)
	    self:quickStartBattle(heroIdList, battleFormation, data.gfStartResponse.battleVerify,succss,fail)
	end)
end

function QSotoTeamArrangement:startBattle( heroIdList )
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	local isInherit = remote.sotoTeam:checkIsInheritSeason()
	local isEquilibrium = remote.sotoTeam:checkIsEquilibriumSeason()
	remote.sotoTeam:sotoTeamFightStartRequest(self._rivalInfo.userId, battleFormation, function(data)
	    self:startBattleBegin(heroIdList, battleFormation, data.gfStartResponse.battleVerify,isInherit,isEquilibrium)
	end)
end

function QSotoTeamArrangement:startBattleBegin(heroIdList, battleFormation, battleVerifyKey,isInherit,isEquilibrium)
	self.super.setAllTeams(self, heroIdList)

	local config = db:getDungeonConfigByID("soto_team")
	config.isPVPMode = true
	config.isArena = true
	config.isSotoTeam = true
	config.isSotoTeamInherit = isInherit
	config.isSotoTeamEquilibrium = isEquilibrium
	
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
	
	config.pvp_archaeology = self._rivalInfo.apiArchaeologyInfoResponse
	config.rivalId = self._rivalInfo.userId
	config.myInfo = self._myInfo
	config.myInfo.money = remote.user.money or 0
	config.rivalsInfo = self._rivalInfo
	config.rivalsPos = self._rivalsPos
	config.battleDT = 1 / 30
	config.battleFormation = battleFormation
	config.verifyKey = battleVerifyKey

	if config.rivalsInfo.force >= (self._myInfo.force or 0) then
		config.skipBattleWithWin = false
	else
		config.skipBattleWithWin = true
	end
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

    remote.sotoTeam:sotoTeamFightEndRequest(config.rivalsInfo.userId, config.rivalsPos, config.battleFormation, {selfHerosStatus = {}, rivalHerosStatus = {}}, {}, battleVerifyKey, function (data)
    	record.dungeonConfig.fightEndResponse = data
    	local isWin = data.gfEndResponse.isWin and 1 or 0
    	record.dungeonConfig.quickFightResult = {isWin = isWin}
    	remote.sotoTeam:setTopRankUpdate(data, config.rivalsInfo.userId)
   		app.taskEvent:updateTaskEventProgress(app.taskEvent.SOTO_TEAM_TASK_EVENT, 1, false, isWin)
		remote.user:addPropNumForKey("todaySotoTeamFightCount")

        local myInfo = clone(config.myInfo)
        myInfo.heros = self:_constructAttackHero()

        local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin == 1 and 1 or 2, self._teamKey)
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		
		local loader = QDungeonResourceLoader.new(record.dungeonConfig)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
	
        QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.SOTO_TEAM)
    end, function(data)		
		if data.error ~= nil then --如果后台返回错误码 则刷新斗魂场信息
			
		end
    end)
end

function QSotoTeamArrangement:quickStartEndBattle( heroIdList )
	-- body
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	app:getClient():sotoTeamFightStartRequest(self._rivalInfo.userId, battleFormation, function(data)
		    self:quickStartBattle(heroIdList, battleFormation, data.gfStartResponse.battleVerify)
		end)
end

function QSotoTeamArrangement:quickStartBattle(heroIdList, battleFormation, battleVerifyKey,sucess,fail)
	local config = db:getDungeonConfigByID("soto_team")
	config.isPVPMode = true
	config.isArena = true
	config.isSotoTeam = true
	config.isSotoTeamInherit = isInherit
	config.isSotoTeamEquilibrium = isEquilibrium
	
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
	
	config.pvp_archaeology = self._rivalInfo.apiArchaeologyInfoResponse
	config.rivalId = self._rivalInfo.userId
	config.myInfo = self._myInfo
	config.myInfo.money = remote.user.money or 0
	config.rivalsInfo = self._rivalInfo
	config.rivalsPos = self._rivalsPos
	config.battleDT = 1 / 30
	config.battleFormation = battleFormation
	config.verifyKey = battleVerifyKey

	if config.rivalsInfo.force >= (self._myInfo.force or 0) then
		config.skipBattleWithWin = false
	else
		config.skipBattleWithWin = true
	end
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

    remote.sotoTeam:sotoTeamFightEndRequest(config.rivalsInfo.userId, config.rivalsPos, config.battleFormation, {selfHerosStatus = {}, rivalHerosStatus = {}}, {}, battleVerifyKey, function (data)
    	record.dungeonConfig.fightEndResponse = data
    	local isWin = data.gfEndResponse.isWin and 1 or 0
    	record.dungeonConfig.quickFightResult = {isWin = isWin}
    	remote.sotoTeam:setTopRankUpdate(data, config.rivalsInfo.userId)
   		app.taskEvent:updateTaskEventProgress(app.taskEvent.SOTO_TEAM_TASK_EVENT, 1, false, isWin)
		remote.user:addPropNumForKey("todaySotoTeamFightCount")

        local myInfo = clone(config.myInfo)
        myInfo.heros = self:_constructAttackHero()

        local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin == 1 and 1 or 2, self._teamKey)
        if sucess then
        	sucess(data)
        end
		-- app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		
		-- local loader = QDungeonResourceLoader.new(record.dungeonConfig)
		-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
	
        QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.SOTO_TEAM)
    end, function(data)		
		if data.error ~= nil then --如果后台返回错误码 则刷新斗魂场信息
			if fail then
				fail()
			end
		end
    end)
end

function QSotoTeamArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QSotoTeamArrangement
