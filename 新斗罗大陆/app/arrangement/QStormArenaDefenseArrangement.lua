

--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QStormArenaDefenseArrangement = class("QStormArenaDefenseArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")

QStormArenaDefenseArrangement.NO_DEFEND_HEROES = "第%s队尚未设置防守阵容，无法保存防守整容！"
QStormArenaDefenseArrangement.ALL_HEAL_HEROES = "第%d队出战魂师不能全部为治疗魂师"

function QStormArenaDefenseArrangement:ctor(options)
	QStormArenaDefenseArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.STORM_ARENA_DEFEND_TEAM1)


end

function QStormArenaDefenseArrangement:getOpponent()
	return self._fighter or {}
end

function QStormArenaDefenseArrangement:getOpponentTeamByIndex(index)
	local opponent = self:getOpponent()
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		return opponent.heros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		return nil,false
	elseif index == remote.teamManager.TEAM_INDEX_HELP2 then
		return nil,false
	elseif index == remote.teamManager.TEAM_INDEX_HELP3 then
		return nil,true
	end
end

function QStormArenaDefenseArrangement:getUnlockSlots(index, trailNum)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHerosMaxCountByIndex(index, trailNum)
end

function QStormArenaDefenseArrangement:getUnlockLevel(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHelpUnlockLevel(index)
end

function QStormArenaDefenseArrangement:getIsBattle()
	return false
end

function QStormArenaDefenseArrangement:startBattle(heroIdList1, heroIdList2)
	local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)

	remote.stormArena:requestChangeStormDefendTeam(battleFormation1, battleFormation2)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QStormArenaDefenseArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QStormArenaDefenseArrangement
