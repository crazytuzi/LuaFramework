-- @Author: zhouxiaoshu
-- @Date:   2019-04-28 11:40:41
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-08-29 15:05:04

local QBaseArrangement = import(".QBaseArrangement")
local QConsortiaWarDefenseArrangement = class("QConsortiaWarDefenseArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QReplayUtil = import("..utils.QReplayUtil")

QConsortiaWarDefenseArrangement.NO_DEFEND_HEROES = "第%s队尚未设置防守阵容，无法保存防守整容！"
QConsortiaWarDefenseArrangement.ALL_HEAL_HEROES = "第%d队出战魂师不能全部为治疗魂师"

function QConsortiaWarDefenseArrangement:ctor(options)
	QConsortiaWarDefenseArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM1)
end

function QConsortiaWarDefenseArrangement:getBackPagePath(index)
	return QSpriteFrameByKey("sanctuary_arrangement_bg", 1)
end

function QConsortiaWarDefenseArrangement:getEffectPagePath(index)
	return QSpriteFrameByKey("sanctuary_arrangement_bg", 2)
end

function QConsortiaWarDefenseArrangement:getOpponent()
	return self._fighter or {}
end

function QConsortiaWarDefenseArrangement:getOpponentTeamByIndex(index)
	local opponent = self:getOpponent()
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		return opponent.heros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		return nil,false
	end
end

function QConsortiaWarDefenseArrangement:getUnlockSlots(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHerosMaxCountByIndex(index, trailNum)
end

function QConsortiaWarDefenseArrangement:getUnlockLevel(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHelpUnlockLevel(index)
end

function QConsortiaWarDefenseArrangement:getIsBattle()
	return false
end

function QConsortiaWarDefenseArrangement:startBattle(heroIdList1, heroIdList2)
	local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)
	remote.consortiaWar:consortiaWarSetDefenseArmyRequest(battleFormation1, battleFormation2, function ()
		app.tip:floatTip("保存战队成功！")
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end)
end

function QConsortiaWarDefenseArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QConsortiaWarDefenseArrangement
