--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QGloryArenaArrangement = class("QGloryArenaArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")


function QGloryArenaArrangement:ctor(options)
	QGloryArenaArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.GLORY_TEAM)
	self._rivalInfo = options.rivalInfo
	self._rivalsPos = options.rivalsPos
	self._myInfo = options.myInfo
	self._info = options.info
	self._isNeedCallback = options.isNeedCallback or false
end

function QGloryArenaArrangement:startBattle( heroIdList )
	-- body
	app:getClient():topGloryArenaRankUserRequest(self._rivalInfo.userId, function(data)
		table.extend(self._rivalInfo, (data.towerFightersDetail or {})[1])
		self:addOtherPropForArena(self._rivalInfo)
		self:startBattle_begin(heroIdList)
	end)
end

function QGloryArenaArrangement:startBattle_begin(heroIdList)
	if ENABLE_GLORY_ARENA_QUICK_BATTLE then
		return self:quickStartBattle(heroIdList)
	end

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	self.super.setAllTeams(self, heroIdList)

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("tower_2")
	config.isPVPMode = true
	config.isArena = true
	config.isGloryArena = true

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
	config.myInfo.towerMoney = remote.user.towerMoney or 0
	config.rivalsInfo = self._rivalInfo
	config.rivalsPos = self._rivalsPos
	config.battleDT = 1 / 30
	config.battleFormation = battleFormation

	if config.rivalsInfo.force >= (self._myInfo.force or 0) then
		config.skipBattleWithWin = false
	else
		config.skipBattleWithWin = true
	end
    config.teamName = self._teamKey
    
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}

    self:_initDungeonConfig(config, self._rivalInfo)

    -- printf("self._info.arenaResponse set nil")
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	-- self._info.arenaResponse = nil
	remote.arena:setInBattle(true)
   	local loader = QDungeonResourceLoader.new(config)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
   	-- app:getNavigationManager():getController(app.mainUILayer):getTopPage():loadBattleResources()
end

function QGloryArenaArrangement:startAutoFight(heroIdList,succss,fail)
	if heroIdList == nil or heroIdList[1] == nil or next(heroIdList[1].actorIds) == nil then
        app.tip:floatTip("魂师大人，当前没有魂师上阵，快去设置上阵吧~")
        return
    end

    if self:teamValidity(heroIdList[1].actorIds) == false then
        return
    end
    app:getClient():topGloryArenaRankUserRequest(self._rivalInfo.userId, function(data)
		table.extend(self._rivalInfo, (data.towerFightersDetail or {})[1])
		self:addOtherPropForArena(self._rivalInfo)
		local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
			remote.tower:requestGloryArenaFightStartRequest(BattleTypeEnum.GLORY_COMPETITION, self._rivalInfo.userId, battleFormation, 
		    function(data)
		        self:quickStartEndBattle(heroIdList,data.gfStartResponse.battleVerify,succss,fail)
			end,function(data)
		end)
	end)

end


function QGloryArenaArrangement:quickStartBattle(heroIdList)
	-- body
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.tower:requestGloryArenaFightStartRequest(BattleTypeEnum.GLORY_COMPETITION, self._rivalInfo.userId, battleFormation, 
		    function(data)
		        self:quickStartEndBattle(heroIdList,data.gfStartResponse.battleVerify)
		end,function(data)
		end)
end

function QGloryArenaArrangement:quickStartEndBattle(heroIdList,battleVerifyKey,success,failed)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	self.super.setAllTeams(self, heroIdList)

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("tower_2")
	config.isPVPMode = true
	config.isArena = true
	config.isGloryArena = true

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
	config.myInfo.towerMoney = remote.user.towerMoney or 0
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

    remote.tower:requestGloryArenaFightEndRequest(config.rivalsInfo.userId, config.battleFormation, config.rivalsPos, {selfHerosStatus = {}, rivalHerosStatus = {}}, {}, battleVerifyKey, function (data)
    	record.dungeonConfig.fightEndResponse = data
    	local isWin = data.gfEndResponse and data.gfEndResponse.isWin
    	record.dungeonConfig.quickFightResult = {isWin = isWin}
        local myInfo = clone(config.myInfo)
        myInfo.heros = self:_constructAttackHero()
        local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin and 1 or 2, self._teamKey)
        if self._isNeedCallback and success then
			success(data)
		else
			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
			local loader = QDungeonResourceLoader.new(record.dungeonConfig)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
		end
        QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.GLORY_ARENA)
    end, function(data)		
		if data.error ~= nil then --如果后台返回错误码 则刷新斗魂场信息
			if failed and self._isNeedCallback then
				failed()
			end
		end
    end, nil, true)
end

function QGloryArenaArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QGloryArenaArrangement
