local QBaseArrangement = import(".QBaseArrangement")
local QBlackRockArragement = class("QBlackRockArragement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")


function QBlackRockArragement:ctor(options)
	QBlackRockArragement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.INSTANCE_TEAM)

	self._dungeonId = options.dungeonId
	self._progress = options.progress
	self._stepInfo = options.stepInfo
	self._soulSpiritId = options.soulSpiritId or 0
	self._battleVerify = options.battleVerify
	self._isRecommend = options.isRecommend
	self._force = options.force
end

function QBlackRockArragement:showHeroState()
	return true
end

function QBlackRockArragement:getHeroInfoById(actorId)
	if self._progress.herosHpMp ~= nil then
		for _,heroInfo in ipairs(self._progress.herosHpMp) do
			if heroInfo.actorId == actorId then
				return heroInfo
			end
		end
	end
	return nil
end

function QBlackRockArragement:startBattle(heroIdList)
	self.super.setAllTeams(self, heroIdList)
	if self._teamKey == remote.teamManager.BLACK_ROCK_FRIST_TEAM then
		local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.BLACK_ROCK_SECOND_TEAM, false)
		if teamVO ~= nil then
			teamVO:setTeamData(heroIdList)
		end	
	end
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.blackrock:blackRockMemberStepFightStartRequest(self._dungeonId, remote.blackrock:getProgressId(), battleFormation, function (data)
		local strDungeonId = QStaticDatabase:sharedDatabase():convertDungeonID(self._dungeonId)
		local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID(strDungeonId)

		config = q.cloneShrinkedObject(config)
		config.blackRockBossId = self._soulSpiritId
	    config.teamName = self._teamKey
	    config.verifyKey = data.gfStartResponse.battleVerify 


		config.heroRecords = remote.user.collectedHeros or {}
		config.isBlackRock = true
		config.blackrockProgress = self._progress
		config.blackrockStepInfo = self._stepInfo
	    config.isRecommend = self._isRecommend
	    config.force = self._force
		config.monstersHp = self._stepInfo.npcsHpMp
		config.heroesHp = self._progress.herosHpMp
		config.progressId = remote.blackrock:getProgressId()
		config.battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
		local buffConfig = db:getBlackRockBuffId(remote.blackrock:getBuff())
		if buffConfig and buffConfig.buff_id then
			config.buffs = config.buffs or {}
			table.insert(config.buffs, buffConfig.buff_id)
		end

	   	local teamInfo = remote.blackrock:getTeamInfo()
	    local startTime = teamInfo.teamProgress.fightStartAt/1000
		config.countdown = math.floor(remote.blackrock:getTotalFightTime() - (q.serverTime() - startTime))
	
		-- 添加战力压制
		local maxPower = tonumber(config.commonly_upper_limit or 0)
		config.isEasy = false
		if self._force > maxPower then
			config.isEasy = true
		end

		self:_initDungeonConfig(config)

		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		
		local loader = QDungeonResourceLoader.new(config)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
	end)
end

return QBlackRockArragement
