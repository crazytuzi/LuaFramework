--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QArenaDefenseArrangement = class("QArenaDefenseArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")


function QArenaDefenseArrangement:ctor(options)
	QArenaDefenseArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.ARENA_DEFEND_TEAM)

	self._selectSkillHero = options.selectSkillHero
end

-- function QArenaDefenseArrangement:getSkillTeams()
-- 	return {self._selectSkillHero}
-- end

function QArenaDefenseArrangement:getIsBattle()
	return false
end

function QArenaDefenseArrangement:startBattle(heroIdList)
	self.super.setAllTeams(self, heroIdList)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.arena:requestSetDefenseHero(battleFormation, function()
			remote.arena:requestArenaInfo()
		end)
end

function QArenaDefenseArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QArenaDefenseArrangement
