--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QSotoTeamDefenseArrangement = class("QSotoTeamDefenseArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")


function QSotoTeamDefenseArrangement:ctor(options)
	QSotoTeamDefenseArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.SOTO_TEAM_DEFEND_TEAM)
end

function QSotoTeamDefenseArrangement:getBackPagePath(index)
	return QSpriteFrameByKey("soto_team_arrangement_bg", 1)
end

function QSotoTeamDefenseArrangement:getEffectPagePath(index)
	return QSpriteFrameByKey("soto_team_arrangement_bg", 2)
end

function QSotoTeamDefenseArrangement:getIsBattle()
	return false
end

function QSotoTeamDefenseArrangement:startBattle(heroIdList)
	self.super.setAllTeams(self, heroIdList)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.sotoTeam:sotoTeamChangeDefenseHeroRequest(battleFormation)
end

function QSotoTeamDefenseArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QSotoTeamDefenseArrangement
