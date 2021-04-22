--
-- Author: MOUSECUTE
-- Date: 2016-Jul-26 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QPlunderDefenseArrangement = class("QPlunderDefenseArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")


function QPlunderDefenseArrangement:ctor(options)
	QPlunderDefenseArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.PLUNDER_DEFEND_TEAM)
end

function QPlunderDefenseArrangement:getIsBattle()
	return false
end

function QPlunderDefenseArrangement:startBattle(heroIdList)
	self.super.setAllTeams(self, heroIdList)
	remote.plunder:plunderChangeDefenseHerosRequest(heroIdList)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QPlunderDefenseArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QPlunderDefenseArrangement
