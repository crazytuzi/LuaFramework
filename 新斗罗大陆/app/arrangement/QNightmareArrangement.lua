--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QNightmareArrangement = class("QNightmareArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QBuriedPoint = import("..utils.QBuriedPoint")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")


function QNightmareArrangement:ctor(options)
	QNightmareArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.INSTANCE_TEAM)

	self._dungeonId = options.dungeonId
	self._isEasy = options.isEasy
	self._isRecommend = options.isRecommend
	self._force = options.force
	self:setIsLocal(true)
end

function QNightmareArrangement:startBattle(heroIdList)
	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._dungeonId)
	-- TOFIX: SHRINK
	config = q.cloneShrinkedObject(config)

    config.isActiveDungeon = false

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.nightmare:nightmareFightStartRequest(config.int_id, battleFormation,
      	function(data) 
			self.super.setAllTeams(self, heroIdList)
	        config.awards = data.awards
	        config.awards2 = data.awards2
	        config.teamName = self._teamKey
	        -- config.verifyKey = data.battleVerify
	        config.verifyKey = data.gfStartResponse.battleVerify
	        config.isNightmare = true
			-- config.lostCount = remote.instance:getLostCountById(self._dungeonId)
	        config.isEasy = self._isEasy
	        config.isRecommend = self._isRecommend

	        config.force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.INSTANCE_TEAM)--self._force
	        -- config.heroExp = math.floor(config.hero_exp * QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level).hero_exp / table.nums(heroIdList[1].actorIds))
			config.heroRecords = remote.user.collectedHeros or {}
			self:_initDungeonConfig(config)
		  	remote.teamManager:unlockTeamForDungeon(self._dungeonId)

	  		remote.teamManager:checkIsNoNeedHero()

       		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
       		-- app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

       		local loader = QDungeonResourceLoader.new(config)
       		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
       		-- app:getNavigationManager():getController(app.mainUILayer):getTopPage():loadBattleResources()
       		-- local passInfo = remote.instance:getPassInfoForDungeonID(self._dungeonId)
       		-- if passInfo ~= nil and passInfo.lastPassAt > 0 then
	        -- 	remote.instance:setLastPassId(nil)
	        -- else
	        -- 	remote.instance:setLastPassId(self._dungeonId)
	        -- end
	        local instanceConfig = remote.nightmare:getConfigByDungeonId(config.int_id)
	        remote.nightmare:setBattleId(instanceConfig.configs[1].instance_id) --保存本次战斗的噩梦副本id
  		end)

	-- random npc
	config.battleRandomNPC = app:getBattleRandomNumberByDungeonID(config.id)
	-- npc probability
	config.battleProbability = app:getBattleProbabilityByDungeonID(config.id)
end

function QNightmareArrangement:getHeroes()
	remote.nightmare:addPropToTeam(false)
	return remote.herosUtil:getHaveHero()
end

return QNightmareArrangement
