--
-- Author: MOUSECUTE
-- Date: 2016-Jul-25
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QPlunderArrangement = class("QPlunderArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QUIWidget = import("..ui.widgets.QUIWidget")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")

QPlunderArrangement.MIN_LEVEL = 0

function QPlunderArrangement:ctor(options)
	local heroIdList = {}
	for k, v in ipairs(remote.herosUtil:getHaveHero()) do
		if remote.herosUtil:getHeroByID(v).level >= QPlunderArrangement.MIN_LEVEL then
			table.insert(heroIdList, v)
		end
	end

	QPlunderArrangement.super.ctor(self, heroIdList, options.teamKey or remote.teamManager.PLUNDER_ATTACK_TEAM)

	-- todo options.dungeonInfo
	self._mineId = options.mineId
	self._mineOwnerId = options.mineOwnerId
	self._isPlunder = options.isPlunder -- 是否掠夺，不是的话就是狩猎
end

-- Sunwell team arrangement needs to show hero states to decide if can go on fighting
function QPlunderArrangement:showHeroState()
	return false
end

function QPlunderArrangement:availableHeroPrompt( ... )
	return false
end

function QPlunderArrangement:startBattle( heroIdList ) 
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.plunder:plunderFightStartRequest(BattleTypeEnum.KUAFU_MINE, battleFormation, 
		    function(data)
				remote.user:addPropNumForKey("todayUnionPlunderFightCount")--记录极北之地攻击次数
		        self:startBattle_begin(heroIdList,data.gfStartResponse.battleVerify)
		end,function(data)
		end)
end

function QPlunderArrangement:startBattle_begin(heroIdList, battleVerifyKey)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	local mineId = self._mineId
	local mineOwnerId = self._mineOwnerId
	local isPVPMode = mineOwnerId ~= nil
	local isPlunder = self._isPlunder

	self.super.setAllTeams(self, heroIdList)

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("sunwell")
	config.verifyKey = battleVerifyKey
	config.mineId = mineId
	config.mineOwnerId = mineOwnerId
	config.isPlunder = true
	config.isSilverMine = true
	config.isSectHunting = true --告诉战斗是否是极北之地功能
	config.isPVPMode = isPVPMode

	-- 设置双方的用户名和头像
	config.team1Name = remote.user.nickname
	config.team1Icon = remote.user.avatar
	config.team1Level = remote.user.level
	if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
		config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end

	remote.plunder:plunderQueryFighterRequest(self._mineOwnerId, function( data )
		local fighter = data.kuafuMineQueryFighterResponse.fighter
		if fighter then
			fighter.heros = fighter.heros or {} --防止为空
			config.team2Name = fighter.name
			config.team2Icon = fighter.avatar
			config.team2Level = fighter.level
			if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
				config.team2Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
			end
		end

		config.myTeam = heroIdList[1]
	    config.teamName = self._teamKey
	 	config.myInfo = {}
		config.myInfo.silvermineMoney = remote.user.silvermineMoney or 0
		config.myInfo.money = remote.user.money or 0
		config.rivalsInfo = fighter
		config.battleDT = 1 / 30
		config.battleFormation = battleFormation
	    
		config.heroRecords = remote.user.collectedHeros or {}
		config.pvpRivalHeroRecords = (fighter and fighter.collectedHero) or {}

		self:_initDungeonConfig(config, fighter)

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
	    if isPlunder then
	    	remote.plunder:plunderLootFightEndRequest(
		    	mineId, -- mineId
		    	mineOwnerId, -- mineOwnerId
		    	fightReportData, -- fightReportData
		    	config.verifyKey, -- battleVerify
		    	nil, -- isWin
		    	true, -- isQuick
		    	battleFormation,
			    function (data) -- success
			    	record.dungeonConfig.fightEndResponse = data
			    	-- local isWin = data.kuafuMineLootFightEndResponse.success and 1 or 0
			    	local isWin = data.gfEndResponse.isWin and 1 or 0
			    	record.dungeonConfig.quickFightResult = {isWin = isWin}
			    	local myInfo = clone(config.myInfo)
			    	myInfo.heros = self:_constructAttackHero()
			    	myInfo.name = remote.user.nickname
					myInfo.avatar = remote.user.avatar
					myInfo.level = remote.user.level
					if myInfo.team1Icon == nil or string.len(myInfo.team1Icon) == 0 then
						myInfo.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
					end
			    	local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin == 1 and 1 or 2, self._teamKey)
			    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
					app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
					local loader = QDungeonResourceLoader.new(record.dungeonConfig)
					app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
					-- QReplayUtil:uploadReplay(data.kuafuMineLootFightEndResponse.fightReportId, replayInfo, function() end, function() end, REPORT_TYPE.PLUNDER)
					QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.PLUNDER)
			    end, function(data) -- false
			    	-- do nothing
				end)
	    else
	    	remote.plunder:plunderOccupyFightEndRequest(
		    	mineId, -- mineId
		    	mineOwnerId, -- mineOwnerId
		    	fightReportData, -- fightReportData
		    	config.verifyKey, -- battleVerify
		    	nil, -- isWin
		    	true, -- isQuick
		    	battleFormation,
			    function (data) -- success
			    	record.dungeonConfig.fightEndResponse = data
			    	-- local isWin = data.kuafuMineOccupyFightEndResponse.success and 1 or 0
			    	local isWin = data.gfEndResponse.isWin and 1 or 0
			    	record.dungeonConfig.quickFightResult = {isWin = isWin}
			    	local myInfo = clone(config.myInfo)
			    	myInfo.heros = self:_constructAttackHero()
			    	myInfo.name = remote.user.nickname
					myInfo.avatar = remote.user.avatar
					myInfo.level = remote.user.level
					if myInfo.team1Icon == nil or string.len(myInfo.team1Icon) == 0 then
						myInfo.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
					end
			    	local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin == 1 and 1 or 2, self._teamKey)
			    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
					app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
					local loader = QDungeonResourceLoader.new(record.dungeonConfig)
					app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
					-- QReplayUtil:uploadReplay(data.kuafuMineOccupyFightEndResponse.fightReportId, replayInfo, function() end, function() end, REPORT_TYPE.PLUNDER)
					QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.PLUNDER)
			    end, function(data) -- false
			    	-- do nothing
			    end)
	    end
    end)
end

function QPlunderArrangement:getPrompt()
	return QPlunderArrangement.MIN_LEVEL.."级以上魂师方可参加海神岛战斗"
end

function QPlunderArrangement:getHeroes()
	local heroIdList = {}
	for k, v in ipairs(remote.herosUtil:getHaveHero()) do
		if remote.herosUtil:getHeroByID(v).level >= QPlunderArrangement.MIN_LEVEL then
			table.insert(heroIdList, v)
		end
	end
	return heroIdList
end

return QPlunderArrangement
