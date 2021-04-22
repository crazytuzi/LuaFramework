--
-- zxs
-- 全大陆精英赛防守阵容
--
local QBaseArrangement = import(".QBaseArrangement")
local QSanctuaryDefenseArrangement = class("QSanctuaryDefenseArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QReplayUtil = import("..utils.QReplayUtil")

QSanctuaryDefenseArrangement.NO_DEFEND_HEROES = "第%s队尚未设置防守阵容，无法保存防守整容！"
QSanctuaryDefenseArrangement.ALL_HEAL_HEROES = "第%d队出战魂师不能全部为治疗魂师"

function QSanctuaryDefenseArrangement:ctor(options)
	QSanctuaryDefenseArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.SANCTUARY_DEFEND_TEAM1)

	self._isSign = options.isSign
end

function QSanctuaryDefenseArrangement:getBackPagePath(index)
	return QSpriteFrameByKey("sanctuary_arrangement_bg", 1)
end

function QSanctuaryDefenseArrangement:getEffectPagePath(index)
	return QSpriteFrameByKey("sanctuary_arrangement_bg", 2)
end

function QSanctuaryDefenseArrangement:getOpponent()
	return self._fighter or {}
end

function QSanctuaryDefenseArrangement:getOpponentTeamByIndex(index)
	local opponent = self:getOpponent()
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		return opponent.heros,true
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		return nil,false
	end
end

function QSanctuaryDefenseArrangement:getUnlockSlots(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHerosMaxCountByIndex(index, trailNum)
end

function QSanctuaryDefenseArrangement:getUnlockLevel(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHelpUnlockLevel(index)
end

function QSanctuaryDefenseArrangement:getIsBattle()
	return false
end

--刷新战队
function QSanctuaryDefenseArrangement:refreshTeam(battleFormation1, battleFormation2, callBack, fail)
	local replayData = QReplayUtil:createReplayFighterBuffer(remote.teamManager.SANCTUARY_DEFEND_TEAM1, remote.teamManager.SANCTUARY_DEFEND_TEAM2)
	replayData = crypto.encodeBase64(replayData)
	remote.sanctuary:sanctuaryWarModifyArmyRequest(battleFormation1, battleFormation2, replayData, function ()
		app.tip:floatTip("刷新战队成功！")
		if callBack ~= nil then
			callBack()
		end
	end, function()
		if fail ~= nil then
			fail()
		end
	end)
end

function QSanctuaryDefenseArrangement:startBattle(heroIdList1, heroIdList2)
	local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)

	local replayData = QReplayUtil:createReplayFighterBuffer(remote.teamManager.SANCTUARY_DEFEND_TEAM1, remote.teamManager.SANCTUARY_DEFEND_TEAM2)
	replayData = crypto.encodeBase64(replayData)
	if self._isSign then
		remote.sanctuary:sanctuaryWarSignUpRequest(battleFormation1, battleFormation2, replayData, function ()
			app.tip:floatTip("报名成功！")
			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		end)
	else
		remote.sanctuary:sanctuaryWarModifyArmyRequest(battleFormation1, battleFormation2, replayData, function ()
			app.tip:floatTip("保存战队成功！")
			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		end)
	end
end

function QSanctuaryDefenseArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QSanctuaryDefenseArrangement
