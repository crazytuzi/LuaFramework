local QBaseArrangementWithDataHandle = import(".QBaseArrangementWithDataHandle")
local QMetalAbyssArrangement = class("QMetalAbyssArrangement", QBaseArrangementWithDataHandle)

local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")


function QMetalAbyssArrangement:ctor(options)
	QMetalAbyssArrangement.super.ctor(self, options)

end

function QMetalAbyssArrangement:getIsBattle()
	return false
end

function QMetalAbyssArrangement:startBattle()
	local fightInfo = remote.metalAbyss:getAbyssWaveFighterInfo()

	local heroIdList1 = self:getTeamInfoByTrialNum(1)
	local heroIdList2 = self:getTeamInfoByTrialNum(2)
	local heroIdList3 = self:getTeamInfoByTrialNum(3)
	remote.teamManager:updateTeamData(self._teamKeys[1], heroIdList1)
	remote.teamManager:updateTeamData(self._teamKeys[2], heroIdList2)
	remote.teamManager:updateTeamData(self._teamKeys[3], heroIdList3)

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)
	local battleFormation3 = remote.teamManager:encodeBattleFormation(heroIdList3)

	remote.metalAbyss:abyssFightStartRequest(fightInfo.waveId,self._enemyFighter.userId, battleFormation, battleFormation2, battleFormation3, 
		function(data)
			self:quickStartEndBattle(fightInfo.waveId,self._enemyFighter.userId, battleFormation, battleFormation2, battleFormation3,data.gfStartResponse.battleVerify)
		end)
end

function QMetalAbyssArrangement:saveFormation()
	local heroIdList1 = self:getTeamInfoByTrialNum(1)
	local heroIdList2 = self:getTeamInfoByTrialNum(2)
	local heroIdList3 = self:getTeamInfoByTrialNum(3)
	remote.teamManager:updateTeamData(self._teamKeys[1], heroIdList1)
	remote.teamManager:updateTeamData(self._teamKeys[2], heroIdList2)
	remote.teamManager:updateTeamData(self._teamKeys[3], heroIdList3)
end


function QMetalAbyssArrangement:quickStartEndBattle(waveId,userId, battleFormation, battleFormation2, battleFormation3,battleVerifyKey,success,failed)
	local difficulty = 1
	local fightInfo = remote.metalAbyss:getAbyssWaveFighterInfo()
	for i,v in ipairs(fightInfo.fighters or {}) do
		if v.userId == userId then
			difficulty = i
		end
	end

 	local config = db:getDungeonConfigByID("arena")
    config.isMetalAbyss = true
    config.pvpMultipleTeams ={}

    for i,v in ipairs(self._teamKeys) do
    	local hero = self:getMyMultiTeamFighterInfo(i)
    	local enemy = self:getEnemyMultiTeamFighterInfo(i)
    	config.pvpMultipleTeams[i]= {hero = hero,enemy = enemy}
    end

	config.isPVPMode = true
	config.team1Name = remote.user.nickname
	config.team1Icon = remote.user.avatar
	config.isPvpMultipleNew = true


	config.myInfo = {name = remote.user.nickname}
	config.rivalsInfo = {name = self._enemyFighter.name}

	if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
		config.team1Icon = db:getDefaultAvatarIcon()
	end
	config.team2Name = self._enemyFighter.name
	config.team2Icon = self._enemyFighter.avatar
	if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
		config.team2Icon = db:getDefaultAvatarIcon()
	end

	config.pvp_archaeology = self._enemyFighter.apiArchaeologyInfoResponse
	config.battleDT = 1 / 30
	config.battleFormation = battleFormation
	config.verifyKey = battleVerifyKey
	config.teamName = self._teamKey
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._enemyFighter.collectedHero or {}
	self:_initDungeonConfig(config, self._enemyFighter)

	local buffer, record = self:_createReplayBuffer(config)
	writeToBinaryFile("last.reppb", buffer)

    record.dungeonConfig.replayTimeSlices = record.recordTimeSlices
    record.dungeonConfig.replayRandomSeed = record.recordRandomSeed
  	for key, value in pairs(config) do
        record.dungeonConfig[key] = value
    end
	record.dungeonConfig.isReplay = true
    record.dungeonConfig.isQuick = true

    remote.metalAbyss:abyssFightEndRequest(waveId , difficulty, battleVerifyKey, battleFormation, battleFormation2, battleFormation3, 
    	function (data)
	    	local isWin = data.gfEndResponse and data.gfEndResponse.isWin
	    	record.dungeonConfig.quickFightResult = {isWin = isWin}
	    	record.dungeonConfig.fightEndResponse = data
	    	record.dungeonConfig.tempDifficulty = difficulty
	    	if isWin then
	    		remote.metalAbyss:setAbyssLastDifficult(difficulty)
	    	end

			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
			local loader = QDungeonResourceLoader.new(record.dungeonConfig)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
	    end, function(data)		
			if data.error ~= nil then --如果后台返回错误码 则刷新竞技场信息
				
			end
	    end, true)

end

function QMetalAbyssArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end


function QMetalAbyssArrangement:getBackPagePath(index) 
	if index == remote.teamManager.TEAM_INDEX_GODARM then
		return QSpriteFrameByKey("godarm_arrangement_bg", 4)
	end

	return QSpriteFrameByKey("collegeTrain_arrangement_bg", 1)
end

function QMetalAbyssArrangement:getEffectPagePath(index)
	return QSpriteFrameByKey("collegeTrain_arrangement_bg", 2)
end


return QMetalAbyssArrangement