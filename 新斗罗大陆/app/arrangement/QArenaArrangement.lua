--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QArenaArrangement = class("QArenaArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")


function QArenaArrangement:ctor(options)
	QArenaArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.ARENA_ATTACK_TEAM)

	self._rivalInfo = options.rivalInfo
	self._rivalsPos = options.rivalsPos
	self._myInfo = options.myInfo
	self._info = options.info
end


function QArenaArrangement:startBattle( heroIdList )
	-- body
	app:getClient():arenaQueryDefenseHerosRequest(self._rivalInfo.userId, function(data)
		table.extend(self._rivalInfo, data.arenaResponse.mySelf)
		self:addOtherPropForArena(self._rivalInfo)
		self:startBattle_begin(heroIdList)
	end)
end


function QArenaArrangement:startBattle_begin(heroIdList)
	if ENABLE_ARENA_QUICK_BATTLE then
		return self:quickStartEndBattle(heroIdList)
	end

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	self.super.setAllTeams(self, heroIdList)

	--更新今日斗魂场打斗次数
	remote.user:addPropNumForKey("todayArenaFightCount")
	remote.user:addPropNumForKey("addupArenaFightCount")

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("arena")
	config.isPVPMode = true
	config.isArena = true

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
	config.myInfo.arenaMoney = remote.user.arenaMoney or 0
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

function QArenaArrangement:quickStartEndBattle( heroIdList )
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

function QArenaArrangement:quickStartBattle(heroIdList,battleVerifyKey)
-- 设置从阵容界面传递过来的阵容
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	self.super.setAllTeams(self, heroIdList)

-- 开始组装战报
	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("arena")
	config.isPVPMode = true
	config.isArena = true
-- 设置双方的用户名和头像
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
	config.myInfo.arenaMoney = remote.user.arenaMoney or 0
	config.rivalsInfo = self._rivalInfo
	config.rivalsPos = self._rivalsPos
	config.battleDT = 1 / 30
	config.battleFormation = battleFormation
	config.verifyKey = battleVerifyKey

	if (config.rivalsInfo.force or 0) >= (self._myInfo.force or 0) then
		config.skipBattleWithWin = false
	else
		config.skipBattleWithWin = true
	end
    config.teamName = self._teamKey
    
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}
-- 一些通用的战报设置
    self:_initDungeonConfig(config, self._rivalInfo)
-- 保存战报至last.reppb
	local buffer, record = self:_createReplayBuffer(config)
	writeToBinaryFile("last.reppb", buffer)
-- 设置回放参数（不进战斗的话不用设置）
    record.dungeonConfig.replayTimeSlices = record.recordTimeSlices
    record.dungeonConfig.replayRandomSeed = record.recordRandomSeed
    for key, value in pairs(config) do
        record.dungeonConfig[key] = value
    end
	record.dungeonConfig.isReplay = true
    record.dungeonConfig.isQuick = true
-- 发送战报给服务端计算，并返回结果（fight end接口会去读取刚保存的last.reppb）
    app:getClient():arenaFightEndRequest(config.rivalsInfo.userId, config.battleFormation, config.rivalsPos, {selfHerosStatus = {}, rivalHerosStatus = {}}, {}, battleVerifyKey, function (data) 
		--更新今日斗魂场打斗次数
		remote.user:addPropNumForKey("todayArenaFightCount")
		remote.user:addPropNumForKey("addupArenaFightCount")

    	record.dungeonConfig.fightEndResponse = data
    	-- local isWin = data.arenaResponse.isWin
    	local isWin = data.gfEndResponse.isWin
    	record.dungeonConfig.quickFightResult = {isWin = isWin}
    	if isWin then
		    remote.activity:updateLocalDataByType(543, 1)
    	end
		app.taskEvent:updateTaskEventProgress(app.taskEvent.ARENA_TASK_EVENT, 1, false, isWin)

        local myInfo = clone(config.myInfo)
        myInfo.heros = self:_constructAttackHero()
        local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin and 1 or 2, self._teamKey)
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		remote.arena:setInBattle(true)
		local loader = QDungeonResourceLoader.new(record.dungeonConfig)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
        -- QReplayUtil:uploadReplay(data.arenaResponse.arenaFightReportId, replayInfo, function() end, function() end, REPORT_TYPE.ARENA)
        QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.ARENA)
    end, function(data)		
    end, function(data)		
		if data.error ~= nil then --如果后台返回错误码 则刷新斗魂场信息
			remote.arena:setInBattle(true)
		end
    end, nil, true)
end

function QArenaArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QArenaArrangement
