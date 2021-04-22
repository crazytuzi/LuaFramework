-- @Author: xurui
-- @Date:   2016-12-28 19:52:15
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-08-29 15:06:00

local QBaseArrangement = import(".QBaseArrangement")
local QMaritimeDefenseArrangement = class("QMaritimeDefenseArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")

QMaritimeDefenseArrangement.NO_DEFEND_HEROES = "第%s队尚未设置防守阵容，无法保存防守整容！"
QMaritimeDefenseArrangement.ALL_HEAL_HEROES = "第%d队出战魂师不能全部为治疗魂师"

function QMaritimeDefenseArrangement:ctor(options)
	QMaritimeDefenseArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.MARITIME_DEFEND_TEAM)

end

function QMaritimeDefenseArrangement:getOpponent()
	return self._fighter or {}
end

function QMaritimeDefenseArrangement:getOpponentTeamByIndex(index)
	local opponent = self:getOpponent()
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		return opponent.heros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		return nil,false
	elseif index == remote.teamManager.TEAM_INDEX_HELP2 then
		return nil,false
	elseif index == remote.teamManager.TEAM_INDEX_HELP3 then
		return nil,false
	end
end

function QMaritimeDefenseArrangement:getUnlockSlots(index, trailNum)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHerosMaxCountByIndex(index, trailNum)
end

function QMaritimeDefenseArrangement:getUnlockLevel(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHelpUnlockLevel(index)
end

function QMaritimeDefenseArrangement:getIsBattle()
	return false
end

function QMaritimeDefenseArrangement:startBattle(heroIdList1, heroIdList2)
	local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)

	remote.maritime:requestSetMaritimeDefenseTeam(battleFormation1, battleFormation2)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QMaritimeDefenseArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QMaritimeDefenseArrangement