--
-- Author: MOUSECUTE
-- Date: 2016-Jul-25
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QSilverMineArrangement = class("QSilverMineArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QUIWidget = import("..ui.widgets.QUIWidget")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")

QSilverMineArrangement.MIN_LEVEL = 0

function QSilverMineArrangement:ctor(options)
	local heroIdList = {}
	for k, v in ipairs(remote.herosUtil:getHaveHero()) do
		if remote.herosUtil:getHeroByID(v).level >= QSilverMineArrangement.MIN_LEVEL then
			table.insert(heroIdList, v)
		end
	end

	QSilverMineArrangement.super.ctor(self, heroIdList, options.teamKey or remote.teamManager.SILVERMINE_ATTACK_TEAM)

	-- todo options.dungeonInfo
	self._mineId = options.mineId
	self._mineOwnerId = options.mineOwnerId
end

-- Sunwell team arrangement needs to show hero states to decide if can go on fighting
function QSilverMineArrangement:showHeroState()
	return false
end

function QSilverMineArrangement:availableHeroPrompt( ... )
	return false
end

function QSilverMineArrangement:startBattle(heroIdList)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	local mineId = self._mineId
	local mineOwnerId = self._mineOwnerId
	local isPVPMode = mineOwnerId ~= nil

	if ENABLE_SILVERMINE_PVP_QUICK_BATTLE and isPVPMode then 
		return self:quickStartBattle(heroIdList)
	end

	remote.silverMine:silvermineFightStartRequest(mineId, mineOwnerId, battleFormation,
		function (data)
			remote.silverMine:responseHandler(data)

			local fightLock = data.gfStartResponse.silverMineFightStartResponse.fightLock
			if fightLock and table.nums(fightLock) > 0 then
				if fightLock.lockUserId and fightLock.lockUserId == remote.user:getPropForKey("userId") then
					-- 可以挑战
				else
					-- app.tip:floatTip("魂师大人，玩家"..fightLock.lockUserName.."正在挑战")
					app.tip:floatTip("魂师大人，您战斗准备时间过长，魂兽区信息已刷新，请返回查看~")
					return
				end
			end

			local fighter = data.gfStartResponse.silverMineFightStartResponse.fighter

			self.super.setAllTeams(self, heroIdList)
			local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("sunwell")
			-- config.verifyKey = data.battleVerify
			config.verifyKey = data.gfStartResponse.battleVerify
			config.mineId = mineId
			config.mineOwnerId = mineOwnerId
			config.isSilverMine = true
			config.isPVPMode = isPVPMode
			config.battleFormation = battleFormation

			config.team1Name = remote.user.nickname
			config.team1Icon = remote.user.avatar
			config.team1Level = remote.user.level
			if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
				config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
			end

			if fighter then
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
			config.myInfo.name = remote.user.nickname
			config.myInfo.avatar = remote.user.avatar
			config.myInfo.level = remote.user.level
	        
			config.heroRecords = remote.user.collectedHeros or {}
			config.pvpRivalHeroRecords = (fighter and fighter.collectedHero) or {}

    		self:_initDungeonConfig(config, fighter)
			-- remote.user:update({sunwarLastFightAt = q.serverTime() * 1000})

	   		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	   		-- print("[Kumo] 警告！ 删除QUIDialogSilverMineMineInfo界面")
	   		app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

	       	local loader = QDungeonResourceLoader.new(config)
   			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}}) 
		end,
		function (data)
			
		end, nil)
end

function QSilverMineArrangement:quickStartBattle(heroIdList)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	local mineId = self._mineId
	local mineOwnerId = self._mineOwnerId
	local isPVPMode = mineOwnerId ~= nil

	remote.silverMine:silvermineFightStartRequest(mineId, mineOwnerId, battleFormation,
		function (data)
			remote.silverMine:responseHandler(data)

			local fightLock = data.gfStartResponse.silverMineFightStartResponse.fightLock
			if fightLock and table.nums(fightLock) > 0 then
				if fightLock.lockUserId and fightLock.lockUserId == remote.user:getPropForKey("userId") then
					-- 可以挑战
				else
					-- app.tip:floatTip("魂师大人，玩家"..fightLock.lockUserName.."正在挑战")
					app.tip:floatTip("魂师大人，您战斗准备时间过长，魂兽区信息已刷新，请返回查看~")
					return
				end
			end

			local fighter = data.gfStartResponse.silverMineFightStartResponse.fighter

			self.super.setAllTeams(self, heroIdList)
			local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("sunwell")
			-- config.verifyKey = data.battleVerify
			config.verifyKey = data.gfStartResponse.battleVerify
			config.mineId = mineId
			config.mineOwnerId = mineOwnerId
			config.isSilverMine = true
			config.isPVPMode = isPVPMode

			config.team1Name = remote.user.nickname
			config.team1Icon = remote.user.avatar
			config.team1Level = remote.user.level
			if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
				config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
			end

			if fighter then
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
			config.myInfo.name = remote.user.nickname
			config.myInfo.avatar = remote.user.avatar
			config.myInfo.level = remote.user.level
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
		    remote.silverMine:silvermineFightEndRequest(
		    	mineId, -- mineId
		    	mineOwnerId, -- mineOwnerId
		    	fightReportData, -- fightReportData
		    	config.verifyKey, -- battleVerify
		    	nil, -- isWin
		    	true, -- isQuick
		    function (data) -- success
		    	record.dungeonConfig.fightEndResponse = data
		    	-- local isWin = data.silverMineFightEndResponse.success and 1 or 0
		    	local isWin = data.gfEndResponse.isWin and 1 or 0
		    	record.dungeonConfig.quickFightResult = {isWin = isWin}
		    	local myInfo = clone(config.myInfo)
		    	myInfo.heros = self:_constructAttackHero()
		    	local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin == 1 and 1 or 2, self._teamKey)
		    	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	   			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	   			local loader = QDungeonResourceLoader.new(record.dungeonConfig)
	   			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
	   			-- QReplayUtil:uploadReplay(data.silverMineFightEndResponse.fightReportId, replayInfo, function() end, function() end, REPORT_TYPE.SILVERMINE)
	   			QReplayUtil:uploadReplay(data.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.SILVERMINE)
		    end, function(data) -- false
		    	-- do nothing
		    end)
		end,
		function (data)
			
		end, nil)
end

function QSilverMineArrangement:getPrompt()
	return QSilverMineArrangement.MIN_LEVEL.."级以上魂师方可参加海神岛战斗"
end

function QSilverMineArrangement:getHeroes()
	local heroIdList = {}
	for k, v in ipairs(remote.herosUtil:getHaveHero()) do
		if remote.herosUtil:getHeroByID(v).level >= QSilverMineArrangement.MIN_LEVEL then
			table.insert(heroIdList, v)
		end
	end
	return heroIdList
end

return QSilverMineArrangement
