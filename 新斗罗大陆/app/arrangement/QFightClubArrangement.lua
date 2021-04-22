--
-- zxs
-- 战斗阵容
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QFightClubArrangement = class("QFightClubArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")

function QFightClubArrangement:ctor(options)
	QFightClubArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), remote.teamManager.FIGHT_CLUB_ATTACK_TEAM)

	self._rivalInfo = options.rivalInfo
	self._rivalsPos = options.rivalsPos
	self._myInfo = options.myInfo
	self._info = options.info
	self._callback = options.callback

	--加上 工会 头像 等属性
	self:addOtherPropForArena(self._rivalInfo)
	self:setIsLocal(true)
end

function QFightClubArrangement:getOpponent()
	return self._rivalInfo or {}
end

function QFightClubArrangement:getBackPagePath(index)
	return QSpriteFrameByKey("fight_club_arrangement_bg", 1)
end

function QFightClubArrangement:getEffectPagePath(index)
	return QSpriteFrameByKey("fight_club_arrangement_bg", 2)
end

function QFightClubArrangement:getOpponentTeamByIndex(index)
	local opponent = self:getOpponent()
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		return opponent.heros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		return nil,false
	elseif index == remote.teamManager.TEAM_INDEX_HELP2 then
		return nil,false
	elseif index == remote.teamManager.TEAM_INDEX_HELP3 then
		return nil,false
	end
end

function QFightClubArrangement:startBattle(heroIdList)
	self.super.setAllTeams(self, heroIdList)

	--快速挑战
	if self._callback then
		self._callback()
		return
	else
		local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
		remote.fightClub:requestFightClubFightStart(self._rivalInfo.userId, battleFormation, function(data)
			remote.user:addPropNumForKey("todayFighClubFightCount")

			self:endBattle(heroIdList, data.gfStartResponse.battleVerify)
		end)
	end
end

function QFightClubArrangement:endBattle(heroIdList, battleVerify, isShow)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    local config = db:getDungeonConfigByID("fight_club")
	config.isPVPMode = true
	config.isArena = true
	config.isFightClub = true
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
	config.myInfo.jewelryMoney = remote.user.jewelryMoney or 0
	config.rivalsInfo = self._rivalInfo
	config.rivalsPos = self._rivalsPos
	config.battleDT = 1 / 30
	config.battleFormation = battleFormation
	config.verifyKey = battleVerifyKey
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

    remote.fightClub:updateMainLastInfo()
    remote.fightClub:updateMyLastInfo()
    
    remote.fightClub:requestFightClubFightEnd(config.rivalsInfo.userId, config.battleFormation, battleVerify, 
    	function (data)
	    	local isWin = data.fightClubResponse.success
	    	record.dungeonConfig.quickFightResult = {isWin = isWin}
	    	record.dungeonConfig.fightEndResponse = data
	    	--记录直升挑战次数
			remote.user:addPropNumForKey("todayFightClubCount")

       		app.taskEvent:updateTaskEventProgress(app.taskEvent.FIGHT_CLUB_TASK_EVENT, 1, false, isWin)

			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
			local loader = QDungeonResourceLoader.new(record.dungeonConfig)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = dungeonConfig, isKeepOldPage = true, loader = loader}})
	        
	        local myInfo = clone(config.myInfo)
	        myInfo.heros = self:_constructAttackHero()
	        local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin and 1 or 2, self._teamKey)
			QReplayUtil:uploadReplay(data.fightClubResponse.fightReportId, replayInfo, function() end, function() end, REPORT_TYPE.FIGHT_CLUB)
	    end, function(data)		
			if data.error ~= nil then --如果后台返回错误码 则刷新竞技场信息
				
			end
	    end, true)
end

function QFightClubArrangement:startQuickFight(fightType, success, fail, isShow)	
	local teamVO = remote.teamManager:getTeamByKey(self:getTeamKey(), false)
	local heroIdList = teamVO:getAllTeam()
	self.super.setAllTeams(self, heroIdList)

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.fightClub:requestFightClubFightStart(self._rivalInfo.userId, battleFormation, function(data)
		remote.user:addPropNumForKey("todayFighClubFightCount")
		
		self:endQuickFight(heroIdList, data.gfStartResponse.battleVerify, fightType, success, fail, isShow)
	end, nil, isShow)
end

function QFightClubArrangement:endQuickFight(heroIdList, battleVerify, fightType, success, fail, isShow)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    local config = db:getDungeonConfigByID("fight_club")
	config.isPVPMode = true
	config.isArena = true
	config.isFightClub = true
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
	config.myInfo.jewelryMoney = remote.user.jewelryMoney or 0
	config.rivalsInfo = self._rivalInfo
	config.rivalsPos = self._rivalsPos
	config.battleDT = 1 / 30
	config.battleFormation = battleFormation
	config.verifyKey = battleVerifyKey
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

    remote.fightClub:setInBattle(true)


    local successFunc = function (data)
    	local isWin = data.fightClubResponse.success
    	record.dungeonConfig.quickFightResult = {isWin = isWin}
    	record.dungeonConfig.fightEndResponse = data
    	--记录直升挑战次数
		remote.user:addPropNumForKey("todayFightClubCount")
		
   		app.taskEvent:updateTaskEventProgress(app.taskEvent.FIGHT_CLUB_TASK_EVENT, 1, false, isWin)

    	local info = {}
    	info.rivalId = config.rivalsInfo.userId
    	info.isWin = isWin
    	if success then
   			success(info)
   		end
   		local myInfo = clone(config.myInfo)
    	myInfo.heros = self:_constructAttackHero()
		local replayInfo = QReplayUtil:generateReplayInfo(myInfo, config.rivalsInfo, isWin and 1 or 2, self._teamKey)
		QReplayUtil:uploadReplay(data.fightClubResponse.fightReportId, replayInfo, function() end, function() end, REPORT_TYPE.FIGHT_CLUB)
    end

    local failFunc = function (data)
    	remote.fightClub:setInBattle(false)
    	if fail then
   			fail(false)
   		end
    end

    remote.fightClub:requestFightClubQuickFightEnd(config.rivalsInfo.userId, config.rivalsPos, config.battleFormation, battleVerify, 
    	function (data)
	    	successFunc(data)
		end, 
	    function(data)	
			failFunc(data)
	    end,
	    isShow
	)
end

function QFightClubArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QFightClubArrangement
