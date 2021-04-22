-- 
-- 本地龙战

local QBaseArrangement = import(".QBaseArrangement")
local QUnionDragonWarArrangementLocal = class("QUnionDragonWarArrangementLocal", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")


function QUnionDragonWarArrangementLocal:ctor(options)
	QUnionDragonWarArrangementLocal.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.UNION_DRAGON_WAR_ATTACK_TEAM)

	self._isEasy = true
	self._force = options.force
end

function QUnionDragonWarArrangementLocal:setInfo(info)
	if q.isEmpty(info) then
		return
	end

	self._bossId = info.fight.id or 1
	self._level = info.fight.level or 1
	self._time = info.fight.time or 90
	self._weather = info.weather.id or 1
	self._enabledSacred = info.markUp.enabledSacred or false
	self._winningStreakCount = info.markUp.winningStreakCount or 1

	db:getConfiguration()["sociaty_dragon_fight_initial"].value = info.fight.count		-- 战斗次数
	db:getConfiguration()["sociaty_dragon_holy_bonous"].value = info.markUp.sacred		-- 神圣加成

	--  连胜加成
	db:getConfiguration()["union_dragon_war_victory_time_2"].value = info.markUp.winningStreak_2
	db:getConfiguration()["union_dragon_war_victory_time_3"].value = info.markUp.winningStreak_3
	db:getConfiguration()["union_dragon_war_victory_time_4"].value = info.markUp.winningStreak_4
	db:getConfiguration()["union_dragon_war_victory_time_5"].value = info.markUp.winningStreak_5


	local bossInfo = db:getUnionDragonInfoByLevel(self._level)
	self._bossHp = bossInfo.hp_value or 0
end

function QUnionDragonWarArrangementLocal:startBattle(heroIdList)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	self.super.setAllTeams(self, heroIdList)

	local dragonSkill = db:getUnionDragonSkillByIdAndLevel(self._bossId, self._level)
	local config = db:getDungeonConfigByID(dragonSkill.dungeon_id or "gonghui_julong_boss")

	config.unionDragonWarBossId = self._bossId
	config.unionDragonWarBossLevel = self._level
	config.unionDragonWarBossHp = self._bossHp
	config.unionDragonWarBossFullHp = self._bossHp
	config.unionDragonWarHolyBuffer = self._enabledSacred
	config.unionDragonWarWinStreakNum = self._winningStreakCount
	config.unionDragonWarWeatherId = self._weather or 1
	
	config.duration = self._time
	--config.awards = data.awards
	--config.awards2 = data.awards2
	config.teamName = self._teamKey
	--config.verifyKey = data.gfStartResponse.battleVerify
	config.isEasy = self._isEasy
	config.force = self._force
	config.isUnionDragonWar = true
	config.heroRecords = remote.user.collectedHeros or {}
	config.todayHurt = remote.unionDragonWar:getMyInfo().todayHurt

	-- 本地战斗
	config.isLocalFight = true

	config.battleFormation = battleFormation or {}
	config.team1Name = remote.user.nickname
	config.team1Icon = remote.user.avatar or -1
	if config.team1Icon == -1 then
		config.team1Icon = db:getDefaultAvatarIcon()
	end
	config.team2Name = ""
	config.team2Icon = db:getDefaultUnionIcon()

	config.boss_hp_infinite = true --全局

	config.isPlayerComeback = remote.playerRecall:isOpen()
	
	self:_initDungeonConfig(config)

	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

	local loader = QDungeonResourceLoader.new(config)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
end

function QUnionDragonWarArrangementLocal:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QUnionDragonWarArrangementLocal