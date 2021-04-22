-- @Author: xurui
-- @Date:   2016-10-26 17:01:15
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-13 21:57:17
local QBaseArrangement = import(".QBaseArrangement")
local QWorldBossArrangement = class("QWorldBossArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")

function QWorldBossArrangement:ctor(options)
	QWorldBossArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.WORLDBOSS_TEAM)

 --    local maxLevel = QStaticDatabase:sharedDatabase():getIntrusionMaximumLevel(options.actorId)
 --    local level = math.min(options.level, maxLevel)
 --    local displayLevel = options.level

	-- self._worldBossID = options.actorId
	self._worldBossLevel = options.level
	self._attackPercent = 1 -- world boss attack percent is always 1
	self._worldBossBuffList = {}
	for _, buffId in ipairs(options.buffList or {}) do
		table.insert(self._worldBossBuffList, buffId)
	end
end

function QWorldBossArrangement:startBattle(heroIdList)
	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("yaosai_boss")
	-- TOFIX: SHRINK
	config = q.cloneShrinkedObject(config)

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    remote.worldBoss:requestWorldBossFightStart(self._worldBossLevel, battleFormation,
      	function(data) 

            remote.user:addPropNumForKey("todayWorldBossFightCount")--记录魔鲸攻击次数
			self.super.setAllTeams(self, heroIdList)
			local worldBoss = data.userWorldBossResponse
	        config.awards = data.awards
	        config.awards2 = data.awards2
	        config.teamName = self._teamKey
	        -- config.verifyKey = data.battleVerify
	        config.verifyKey = data.gfStartResponse.battleVerify
	        config.isInWorldBossFight = true
	        config.worldBossID = worldBoss.bossId

		    local maxLevel = QStaticDatabase:sharedDatabase():getIntrusionMaximumLevel(worldBoss.bossId)
		    local level = math.min(worldBoss.bossLevel, maxLevel)
	        config.worldBossLevel = level
	        config.worldBossDisplayLevel = worldBoss.bossLevel
	        config.worldBossHP =  worldBoss.bossHp
	        config.worldBossAttackPercent = self._attackPercent 
	        config.worldBossMerit = worldBoss.allHurt
	        config.worldBossDamage = worldBoss.maxHurt
	        config.worldBoss = worldBoss
			config.heroRecords = remote.user.collectedHeros or {}
			config.worldBossBuffList = self._worldBossBuffList
			config.worldBossScoreRate = 1
			config.battleFormation = battleFormation or {}

    		self:_initDungeonConfig(config)

		  	if data.heros ~= nil then
		  		remote.teamManager:checkIsNoNeedHero(data.heros)
		  	end

       		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

	       	local loader = QDungeonResourceLoader.new(config)
       		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
       		-- app:getNavigationManager():getController(app.mainUILayer):getTopPage():loadBattleResources()
       		remote.invasion:setAfterBattle(true)
  		end,function (data)
  			--战斗开始失败也要保存战队
			self.super.setAllTeams(self, heroIdList)
  			-- self._invasion.bossId = 0
  			-- remote.invasion:getInvasionRequest()
  			-- if data.error == "INTRUSION_BOSS_NOT_EXIST" then
  			-- 	self._invasion.bossId = 0 
  			-- 	remote.invasion:getInvasionRequest()
  			-- else
  			-- 	remote.invasion:setInvasionUpdate(true)
  			-- end
  		end)
end

-- test code for quick play
function QWorldBossArrangement:startQuickBattle(heroIdList, success, fail)
	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("yaosai_boss")
	-- TOFIX: SHRINK
	config = q.cloneShrinkedObject(config)

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    remote.worldBoss:requestWorldBossFightStart(self._worldBossLevel, battleFormation,
      	function(data) 
			self.super.setAllTeams(self, heroIdList)
		  	if data.heros ~= nil then
		  		remote.teamManager:checkIsNoNeedHero(data.heros)
		  	end
            
			local worldBoss = data.userWorldBossResponse
	        config.awards = data.awards
	        config.awards2 = data.awards2
	        config.teamName = self._teamKey
	        -- config.verifyKey = data.battleVerify
	        config.verifyKey = data.gfStartResponse.battleVerify
	        config.isInWorldBossFight = true
	        config.worldBossID = worldBoss.bossId

		    local maxLevel = QStaticDatabase:sharedDatabase():getIntrusionMaximumLevel(worldBoss.bossId)
		    local level = math.min(worldBoss.bossLevel, maxLevel)
	        config.worldBossLevel = level
	        config.worldBossDisplayLevel = worldBoss.bossLevel
	        config.worldBossHP =  worldBoss.bossHp
	        config.worldBossAttackPercent = self._attackPercent 
	        config.worldBossMerit = worldBoss.allHurt
	        config.worldBossDamage = worldBoss.maxHurt
	        config.worldBoss = worldBoss
			config.heroRecords = remote.user.collectedHeros or {}
			config.worldBossBuffList = self._worldBossBuffList
			config.worldBossScoreRate = 1
			config.battleFormation = battleFormation or {}
			
	   		self:_initDungeonConfig(config)

			local buffer, record = self:_createReplayBuffer(config)
			writeToBinaryFile("last.reppb", buffer)

			remote.worldBoss:requestWorldBossFightEnd(config.worldBossHP, worldBoss.bossLevel, data.gfStartResponse.battleVerify, success, fail)

       		remote.invasion:setAfterBattle(true)
  		end,function (data)
  			self.super.setAllTeams(self, heroIdList)
  		end)
end

function QWorldBossArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QWorldBossArrangement