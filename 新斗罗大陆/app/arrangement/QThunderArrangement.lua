
local QBaseArrangement = import(".QBaseArrangement")
local QThunderArrangement = class("QThunderArrangement", QBaseArrangement)
local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")

function QThunderArrangement:ctor(options)
	QThunderArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.THUNDER_TEAM)
	self._waveType = options.waveType
	self._hard = options.hard
	self._floor = options.floor
	self._wave = options.wave
	self._dungeonId = options.dungeonId
	-- self._NPCLevel = options.NPCLevel
	self._buffs = options.buffs
	self._rivalUserId = options.rivalUserId
	self._eliteWave = options.eliteWave
end

function QThunderArrangement:startBattle(heroIdList)
	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._dungeonId)
	-- TOFIX: SHRINK
	config = q.cloneShrinkedObject(config)

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    remote.thunder:thunderFightStartRequest(self._waveType, self._floor, self._wave, battleFormation,
      	function(data) 
			self.super.setAllTeams(self, heroIdList)
	        -- config.awards = data.awards
	        -- config.awards2 = data.awards2
	        
	        -- config.verifyKey = data.battleVerify
	        config.verifyKey = data.gfStartResponse.battleVerify
	        config.teamName = self._teamKey
	        config.isThunder = true

			config.waveType = self._waveType
			config.hard = self._hard
			config.floor = self._floor
			config.wave = self._wave
			config.dungeonId = self._dungeonId
			-- config.NPCLevel = self._NPCLevel
			config.buffs = self._buffs
			config.rivalUserId = self._rivalUserId
			config.eliteWave = self._eliteWave
			config.heroRecords = remote.user.collectedHeros or {}
			config.battleFormation = battleFormation or {}
			
			local _, _, force = remote.herosUtil:getMaxForceHeros()
			local recommendPower = tonumber(config.thunder_force or 0)
			local maxPower = tonumber(config.commonly_upper_limit or 0)
			config.isEasy = false
			config.isRecommend = (not not config.thunder_force) and force >= recommendPower
			config.force = force
			if force > maxPower then
				if config.thunder_force then
					config.isEasy = true
				end
			end

    		self:_initDungeonConfig(config)

       		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
       		if self._waveType == "LEVEL_WAVE" then
       			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
       		end

	       	local loader = QDungeonResourceLoader.new(config)
       		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
       		-- app:getNavigationManager():getController(app.mainUILayer):getTopPage():loadBattleResources()
       		if self._waveType == "LEVEL_WAVE" then
				remote.thunder:startBattle()
			end
  		end)
end

function QThunderArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QThunderArrangement