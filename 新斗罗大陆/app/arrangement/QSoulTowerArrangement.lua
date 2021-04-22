-- @Author: liaoxianbo
-- @Date:   2020-04-09 14:42:52
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-29 19:50:42
local QBaseArrangement = import(".QBaseArrangement")
local QSoulTowerArrangement = class("QSoulTowerArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")


function QSoulTowerArrangement:ctor(options)
	QSoulTowerArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.INSTANCE_TEAM)

	self._floorInfo = options.floorInfo
	self._force = options.force
end


function QSoulTowerArrangement:startBattle(heroIdList)
	self.super.setAllTeams(self, heroIdList)

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.soultower:soulTowerFightStartRequest(self._floorInfo.floor,self._floorInfo.dungeon, battleFormation, function (data)

		local tabWave = string.split(self._floorInfo.wave,"^")
		local dungeonId = tabWave[1]
		local config = db:getDungeonConfigByID(dungeonId)
		
		local soulTowerForceInfo = remote.soultower:getSoulTowerForce(self._floorInfo.floor,self._floorInfo.dungeon)
		
		config = q.cloneShrinkedObject(config)
		config.bg = self._floorInfo.show_pic

		config.verifyKey = data.gfStartResponse.battleVerify
	    config.teamName = self._teamKey
	    -- config.soulwaves = self._waveInfo
		config.heroRecords = remote.user.collectedHeros or {}
		config.isSoulTower = true
		-- config.soultowerFloor = self._floorInfo.floor
		-- config.soultowerDungenNum = self._floorInfo.dungeon
		config.soultowerDungenLevel = tonumber(tabWave[2])
		config.force = self._force

		config.towerForceId = soulTowerForceInfo and soulTowerForceInfo.id or -1

		self:_initDungeonConfig(config)

		remote.user:addPropNumForKey("todaySoulTowerFightCount")
		
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		
		local loader = QDungeonResourceLoader.new(config)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
	end)
end

return QSoulTowerArrangement
