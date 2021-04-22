-- zxs
-- 搏击俱乐部防守阵容
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QFightClubDefenseArrangement = class("QFightClubDefenseArrangement", QBaseArrangement)

local QNavigationController = import("..controllers.QNavigationController")

function QFightClubDefenseArrangement:ctor(options)
	QFightClubDefenseArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), remote.teamManager.FIGHT_CLUB_DEFEND_TEAM)
end

function QFightClubDefenseArrangement:getOpponent()
	return self._fighter or {}
end

function QFightClubDefenseArrangement:getBackPagePath(index)
	return QSpriteFrameByKey("fight_club_arrangement_bg", 1)
end

function QFightClubDefenseArrangement:getEffectPagePath(index)
	return QSpriteFrameByKey("fight_club_arrangement_bg", 2)
end

function QFightClubDefenseArrangement:getIsBattle()
	return false
end

function QFightClubDefenseArrangement:startBattle(heroIdList)
	self.super.setAllTeams(self, heroIdList)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	remote.fightClub:requestModifyFightClubDefenseTeam(battleFormation, function()
			remote.fightClub:requestFightClubInfo()
		end)
end

function QFightClubDefenseArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QFightClubDefenseArrangement
