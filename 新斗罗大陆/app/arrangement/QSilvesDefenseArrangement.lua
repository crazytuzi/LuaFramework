-- 
-- Kumo.Wang
-- Silves大斗魂场阵容
--

local QBaseArrangement = import(".QBaseArrangement")
local QSilvesDefenseArrangement = class("QSilvesDefenseArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")


function QSilvesDefenseArrangement:ctor(options)
	QSilvesDefenseArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.ARENA_DEFEND_TEAM)

	self._selectSkillHero = options.selectSkillHero
end

function QSilvesDefenseArrangement:getIsBattle()
	return false
end

function QSilvesDefenseArrangement:startBattle(heroIdList)
	self.super.setAllTeams(self, heroIdList)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.silvesArena:silvesArenaChangeDefenseArmyRequest(battleFormation, function()
			remote.silvesArena:silvesArenaGetMainInfoRequest()
		end)
end

function QSilvesDefenseArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QSilvesDefenseArrangement
