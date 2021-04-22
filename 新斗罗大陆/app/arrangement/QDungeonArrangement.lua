--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QDungeonArrangement = class("QDungeonArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QBuriedPoint = import("..utils.QBuriedPoint")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")


function QDungeonArrangement:ctor(options)
	QDungeonArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.INSTANCE_TEAM)

	self._dungeonId = options.dungeonId
	self._isEasy = options.isEasy
	self._isRecommend = options.isRecommend
	self._force = options.force
	self._battleType = options.battleType
	self:setIsLocal(true)
end

function QDungeonArrangement:startBattle(heroIdList)
	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._dungeonId)
	-- TOFIX: SHRINK
	config = q.cloneShrinkedObject(config)

	-- 埋点: “进入关卡X-Y点击”
	app:triggerBuriedPoint(QBuriedPoint:getDungeonStartBuriedPointID(self._dungeonId))

	local dungeonType = remote.welfareInstance:getDungeonTypeByDungeonID( self._dungeonId )
    config.isActiveDungeon = false
    config.activeDungeonType = dungeonType

	local activeDungeonInfo = remote.activityInstance:getDungeonById(config.id)
    if activeDungeonInfo ~= nil then
        config.isActiveDungeon = true
        config.activeDungeonType = activeDungeonInfo.dungeon_type
        config.instanceId = activeDungeonInfo.instance_id
    end

    remote.instance.isIsBattle = true
    
	if dungeonType == DUNGEON_TYPE.WELFARE then
		local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
		remote.welfareInstance:welfareFightStartRequest(BattleTypeEnum.DUNGEON_WELFARE, self._dungeonId, battleFormation, 
	      	function(data) 
				self.super.setAllTeams(self, heroIdList)
				config.dailyAwards = data.batchAwards
		        config.awards = data.awards
		        config.awards2 = data.awards2
		        config.prizeWheelMoneyGot = data.prizeWheelMoneyGot
		        config.teamName = self._teamKey
		        config.lostCount = remote.welfareInstance:getLostCount()
		        config.isEasy = self._isEasy
		        config.isRecommend = self._isRecommend
		        config.force = self._force
		        -- config.verifyKey = data.battleVerify
		        config.verifyKey = data.gfStartResponse.battleVerify
		        config.battleFormation = battleFormation
		        config.isWelfare = true
		        config.heroExp = math.floor(config.hero_exp * QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level).hero_exp / table.nums(heroIdList[1].actorIds))
				config.heroRecords = remote.user.collectedHeros or {}
			  	remote.teamManager:unlockTeamForDungeon(self._dungeonId)

		  		remote.teamManager:checkIsNoNeedHero()
		  		
    			self:_initDungeonConfig(config)

		        -- remote.instance:setDungeonStartFrist(self._dungeonId)

	       		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	       		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

	       		
				--xurui:这里只在popDialog的时候使用，所以在这里重新设置
			    remote.instance.isIsBattle = false

	       		local loader = QDungeonResourceLoader.new(config)
	       		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
	       		-- app:getNavigationManager():getController(app.mainUILayer):getTopPage():loadBattleResources()
	  		end)
	else

			-- local battleType = BattleTypeEnum.DUNGEON_NORMAL
			-- if dungeonType == DUNGEON_TYPE.ELITE then
			-- 	battleType = BattleTypeEnum.DUNGEON_ELITE
			-- elseif dungeonType == DUNGEON_TYPE.ACTIVITY_TIME or dungeonType == DUNGEON_TYPE.ACTIVITY_CHALLENGE then
			-- 	battleType = BattleTypeEnum.DUNGEON_ACTIVITY
			-- end
			local battleType = BattleTypeEnum.DUNGEON_NORMAL
			if dungeonType == DUNGEON_TYPE.NORMAL then
				battleType = BattleTypeEnum.DUNGEON_NORMAL
			elseif dungeonType == DUNGEON_TYPE.ELITE then
				battleType = BattleTypeEnum.DUNGEON_ELITE
			else
				local activeDungeonInfo = remote.activityInstance:getDungeonById(self._dungeonId)
				if activeDungeonInfo ~= nil and (activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME or activeDungeonInfo.dungeon_type == DUNGEON_TYPE.ACTIVITY_CHALLENGE) then
					battleType = BattleTypeEnum.DUNGEON_ACTIVITY
				end
			end

			if self._battleType then
				battleType = self._battleType -- 魂力试炼专用，强制改写，不通过dungeonType判断(1/3)
			end

		local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
		app:getClient():dungeonFightStart(battleType, self._dungeonId, battleFormation,
	      	function(data) 
				self.super.setAllTeams(self, heroIdList)
				config.dailyAwards = data.batchAwards
		        config.awards = data.awards
		        config.awards2 = data.awards2
		        config.prizeWheelMoneyGot = data.prizeWheelMoneyGot

		        config.teamName = self._teamKey
		        config.battleFormation = battleFormation
		        -- config.verifyKey = data.battleVerify
		        config.verifyKey = data.gfStartResponse.battleVerify
				config.lostCount = remote.instance:getLostCountById(self._dungeonId)
		        config.isEasy = self._isEasy
		        config.isRecommend = self._isRecommend
		        config.force = self._force
		        config.heroExp = math.floor(config.hero_exp * QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level).hero_exp / table.nums(heroIdList[1].actorIds))
				config.heroRecords = remote.user.collectedHeros or {}
				if self._battleType then
					-- 魂力试炼专用，强制改写，不通过dungeonType判断(2/3)
					config.battleType = self._battleType
				end
			  	remote.teamManager:unlockTeamForDungeon(self._dungeonId)

		  		remote.teamManager:checkIsNoNeedHero()

    			self:_initDungeonConfig(config)

		        remote.instance:setDungeonStartFrist(self._dungeonId)

	       		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	       		if not self._battleType then
	       			-- 魂力试炼专用，少pop一层（1/1）
	       			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	       		else
	       			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	       		end


				--xurui:这里只在popDialog的时候使用，所以在这里重新设置
			    remote.instance.isIsBattle = false

	       		local loader = QDungeonResourceLoader.new(config)
	       		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
	  		end)
	end

	-- random npc
	config.battleRandomNPC = app:getBattleRandomNumberByDungeonID(config.id)
	-- npc probability
	config.battleProbability = app:getBattleProbabilityByDungeonID(config.id)

	remote.instance.arrangement = self
end

function QDungeonArrangement:getHeroes()
	remote.nightmare:addPropToTeam(false)
	return remote.herosUtil:getHaveHero()
end

return QDungeonArrangement
