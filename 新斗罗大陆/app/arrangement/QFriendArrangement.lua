--
-- Author: nzhang
-- Date: 2016-01-04 
-- 

local QBaseArrangement = import(".QBaseArrangement")
local QFriendArrangement = class("QFriendArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")


function QFriendArrangement:ctor(options)
	QFriendArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey)

	self._rivalInfo = options.rivalInfo
	self._myInfo = options.myInfo
end

function QFriendArrangement:startBattle(heroIdList, heroIdList2)
	local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
	if self._teamKey == remote.teamManager.STORM_ARENA_ATTACK_TEAM1 or self._teamKey == remote.teamManager.STORM_ARENA_ATTACK_TEAM2 then
		self:startBattleToMuiltipleTeam(heroIdList, heroIdList2)
		return 
	end

	self.super.setAllTeams(self, heroIdList)
	remote.teamManager:sortTeam(self._rivalInfo.heros, true)

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("arena")
	config.isPVPMode = true
	config.isArena = true
	config.isFriend = true

	config.team1Name = remote.user.nickname
	config.team1Icon = remote.user.avatar
	if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
		config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end
	config.team2Name = self._rivalInfo.name
	config.team2Icon = self._rivalInfo.avatar
	if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
		config.team2Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end
	config.battleFormation = battleFormation
	config.rivalId = self._rivalInfo.userId
	config.rivalsInfo = self._rivalInfo

	config.skipBattleWithWin = false
    config.teamName = self._teamKey
    
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}

	self:_initDungeonConfig(config, self._rivalInfo)

	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
   	local loader = QDungeonResourceLoader.new(config)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
end

function QFriendArrangement:startBattleToMuiltipleTeam(heroIdList)
	local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)

	remote.teamManager:sortTeam(self._rivalInfo.heros, true)
	remote.teamManager:sortTeam(self._rivalInfo.subheros, true)
	remote.teamManager:sortTeam(self._rivalInfo.sub2heros, true)
	remote.teamManager:sortTeam(self._rivalInfo.main1Heros, true)
	remote.teamManager:sortTeam(self._rivalInfo.sub1heros, true)

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("storm_arena")
	config.isPvpMultipleNew = true
	config.isArena = true
	config.isPVPMode = true
	config.isFriend = true

	config.team1Name = remote.user.nickname
	config.team1Icon = remote.user.avatar
	if config.team1Icon == nil or string.len(config.team1Icon) == 0 then
		config.team1Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end
	config.team2Name = self._rivalInfo.name
	config.team2Icon = self._rivalInfo.avatar
	if config.team2Icon == nil or string.len(config.team2Icon) == 0 then
		config.team2Icon = QStaticDatabase:sharedDatabase():getDefaultAvatarIcon()
	end
	remote.herosUtil:addPeripheralSkills(self._rivalInfo.heros)

	config.battleFormation = battleFormation1
	config.battleFormation2 = battleFormation2

	config.pvp_archaeology = self._rivalInfo.apiArchaeologyInfoResponse
	config.rivalId = self._rivalInfo.userId
	config.myInfo = self._myInfo
	config.rivalsInfo = self._rivalInfo
	-- config.battleDT = 1 / 30

	config.skipBattleWithWin = false
    config.teamName = self._teamKey
    
	config.heroRecords = remote.user.collectedHeros or {}
	config.pvpRivalHeroRecords = self._rivalInfo.collectedHero or {}

    self:_initNewPVPTeamInfo(config, self._rivalInfo, remote.teamManager.STORM_ARENA_ATTACK_TEAM1, remote.teamManager.STORM_ARENA_ATTACK_TEAM2)
    self:_initDungeonConfig(config, self._rivalInfo)

	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
   	local loader = QDungeonResourceLoader.new(config)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
end

function QFriendArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

function QFriendArrangement:getUnlockSlots(index, trailNum)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHerosMaxCountByIndex(index, trailNum)
end

function QFriendArrangement:getUnlockLevel(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHelpUnlockLevel(index)
end

return QFriendArrangement
