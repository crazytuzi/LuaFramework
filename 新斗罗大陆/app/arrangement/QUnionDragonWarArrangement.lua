-- 
-- zxs
-- 武魂战布阵
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QUnionDragonWarArrangement = class("QUnionDragonWarArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")


function QUnionDragonWarArrangement:ctor(options)
	QUnionDragonWarArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.UNION_DRAGON_WAR_ATTACK_TEAM)

	self._isEasy = true
	self._force = options.force
end

function QUnionDragonWarArrangement:startBattle(heroIdList)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
    remote.unionDragonWar:dragonWarFightStartRequest(battleFormation, function(data) 
			self.super.setAllTeams(self, heroIdList)

	        local weatherId = remote.unionDragonWar:getUnionDragonWarWeatherId()
	        local myFighterInfo = remote.unionDragonWar:getMyDragonFighterInfo()
	        local enemyDragonInfo = remote.unionDragonWar:getEnemyDragonFighterInfo() 
	        local dragonSkill = db:getUnionDragonSkillByIdAndLevel(enemyDragonInfo.dragonId, enemyDragonInfo.dragonLevel)
			local config = db:getDungeonConfigByID(dragonSkill.dungeon_id or "gonghui_julong_boss")

	        config.unionDragonWarBossId = enemyDragonInfo.dragonId or 1
	        config.unionDragonWarBossLevel = enemyDragonInfo.dragonLevel
	        config.unionDragonWarBossHp = enemyDragonInfo.dragonCurrHp or 0
	        config.unionDragonWarBossFullHp = enemyDragonInfo.dragonFullHp or 0
	        config.unionDragonWarHolyBuffer = remote.unionDragonWar:checkMyHolyBuffer()
	        config.unionDragonWarWinStreakNum = myFighterInfo.streakWin or 0
	        config.unionDragonWarWeatherId = weatherId or 1
			
			config.awards = data.awards
	        config.awards2 = data.awards2
	        config.teamName = self._teamKey
	        config.verifyKey = data.gfStartResponse.battleVerify
	        config.isEasy = self._isEasy
	        config.force = self._force
	        config.isUnionDragonWar = true
			config.heroRecords = remote.user.collectedHeros or {}
			config.todayHurt = remote.unionDragonWar:getMyInfo().todayHurt

			config.battleFormation = battleFormation or {}
			config.team1Name = remote.user.nickname
			config.team1Icon = remote.user.avatar or -1
			if config.team1Icon == -1 then
				config.team1Icon = db:getDefaultAvatarIcon()
			end
			config.team2Name = enemyDragonInfo.consortiaName or ""
			config.team2Icon = enemyDragonInfo.icon
			if config.team2Icon == nil then
				config.team2Icon = db:getDefaultUnionIcon()
			end
			-- local isCurChapterPass = remote.union:getCurBossHpByChapter(remote.union:getFightChapter()) == 0
			-- local totalChapter = table.nums(QStaticDatabase.sharedDatabase():getAllScoietyChapter())
			-- local finalBossInfo, finalBossConfig = remote.union:getConsortiaFinalBossInfo()

			-- if isCurChapterPass and remote.union:getFightChapter() == totalChapter and q.isEmpty(finalBossInfo) == false then
			-- 	config.boss_hp_infinite = true
			-- end
			config.boss_hp_infinite = true --全局

			config.isPlayerComeback = remote.playerRecall:isOpen()
			
			self:_initDungeonConfig(config)

       		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

       		local loader = QDungeonResourceLoader.new(config)
       		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
		end)
end

function QUnionDragonWarArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

return QUnionDragonWarArrangement