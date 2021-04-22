-- @Author: liaoxianbo
-- @Date:   2020-08-06 10:11:42
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-12 15:44:56

local QBaseArrangement = import(".QBaseArrangement")
local QMazeExploreArrangement = class("QMazeExploreArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")

function QMazeExploreArrangement:ctor(options)
	QMazeExploreArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.MAZE_EXPLORE_TEAM)
	self._gridInfo = options.gridInfo
	self._teamKey = options.teamKey
	self._proxyClass = remote.activityRounds:getMazeExplore()
	self._chapterId = self._proxyClass:getJoinDungeonId()
end

function QMazeExploreArrangement:startBattle(heroIdList)
	local config = db:getDungeonConfigByID(self._gridInfo.parameter)
	-- TOFIX: SHRINK
	config = q.cloneShrinkedObject(config)

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	if self._proxyClass then
	    self._proxyClass:MazeExploreFightStartRequest(self._chapterId, battleFormation,
	      	function(data) 

				self.super.setAllTeams(self, heroIdList)

		        config.teamName = self._teamKey
		        -- config.verifyKey = data.battleVerify
		        config.verifyKey = data.gfStartResponse.battleVerify
				config.heroRecords = remote.user.collectedHeros or {}
				config.battleFormation = battleFormation or {}
				config.isMazeExplore = true
				config.boss_hp_infinite = true
				
	    		self:_initDungeonConfig(config)

			  	-- if data.heros ~= nil then
			  	-- 	remote.teamManager:checkIsNoNeedHero(data.heros)
			  	-- end

	       		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

		       	local loader = QDungeonResourceLoader.new(config)
	       		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})

	       
	  		end,function (data)
	  			--战斗开始失败也要保存战队
				self.super.setAllTeams(self, heroIdList)
	  		end)
    end
end

function QMazeExploreArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QMazeExploreArrangement