--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QGloryDefenseArrangement = class("QGloryDefenseArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")


function QGloryDefenseArrangement:ctor(options)
	QGloryDefenseArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.ARENA_ATTACK_TEAM)

end

function QGloryDefenseArrangement:getIsBattle()
	return false
end

function QGloryDefenseArrangement:startBattle(heroIdList)
	self.super.setAllTeams(self, heroIdList)

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.tower:towerChangeDefenseHeroesRequest(battleFormation, 
		function ( ... )
			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		end)
end

function QGloryDefenseArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QGloryDefenseArrangement
