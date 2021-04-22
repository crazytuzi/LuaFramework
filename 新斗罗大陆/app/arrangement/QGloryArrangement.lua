--
-- Author: Your Name
-- Date: 2015-07-03 10:21:11
--
local QBaseArrangement = import(".QBaseArrangement")
local QGloryArrangement = class("QGloryArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")


function QGloryArrangement:ctor(options)
	QGloryArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.GLORY_TEAM)

	self._fighter = options.fighter
	self._towerData = options.towerData
end

function QGloryArrangement:startBattle(heroIdList)
	
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    remote.tower:towerFightStartRequest(self._fighter.userId, battleFormation, 
      	function(data) 
			self.super.setAllTeams(self, heroIdList)

	        local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("tower")
			config.isPVPMode = true
			config.isArena = true
			config.isGlory = true

			config.team1Name = remote.user.nickname
			config.team1Icon = remote.user.avatar
			if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
				config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
			end
			config.team2Name = self._fighter.name
			config.team2Icon = self._fighter.avatar
			if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
				config.team2Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
			end

	        config.teamName = self._teamKey
	        -- config.verifyKey = data.battleVerify
	        config.verifyKey = data.gfStartResponse.battleVerify
	        config.rivalsInfo = self._fighter
	        config.selfHeros = heroIdList[1].actorIds
	        config.score = self._towerData.score
	        config.towerMoney = remote.user.towerMoney
	        config.token = remote.user.token
	        config.battleFormation = battleFormation or {}
	        
			config.heroRecords = remote.user.collectedHeros or {}
			config.pvpRivalHeroRecords = self._fighter.collectedHero or {}

    		self:_initDungeonConfig(config, self._fighter)

	   		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	       	local loader = QDungeonResourceLoader.new(config)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
		end)
end

function QGloryArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QGloryArrangement