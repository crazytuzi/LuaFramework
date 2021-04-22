--
-- Author: MOUSECUTE
-- Date: 2016-Jul-26 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QSilverMineDefenseArrangement = class("QSilverMineDefenseArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")


function QSilverMineDefenseArrangement:ctor(options)
	QSilverMineDefenseArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.SILVERMINE_DEFEND_TEAM)
end

function QSilverMineDefenseArrangement:getIsBattle()
	return false
end

function QSilverMineDefenseArrangement:startBattle(heroIdList)
	self.super.setAllTeams(self, heroIdList)
	remote.silverMine:requestSetDefenseHero(heroIdList)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QSilverMineDefenseArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QSilverMineDefenseArrangement
