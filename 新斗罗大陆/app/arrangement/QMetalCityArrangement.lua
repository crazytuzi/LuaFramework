-- @Author: xurui
-- @Date:   2018-08-09 14:20:38
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-13 20:33:14


local QBaseArrangement = import(".QBaseArrangement")
local QMetalCityArrangement = class("QMetalCityArrangement", QBaseArrangement)

local QUIViewController = import("..ui.QUIViewController")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QReplayUtil = import("..utils.QReplayUtil")


function QMetalCityArrangement:ctor(options)
	QMetalCityArrangement.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.METAL_CIRY_ATTACK_TEAM1)

	self._info = options.info
end


function QMetalCityArrangement:startBattle( heroIdList1, heroIdList2 )
	local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
	local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)

	local config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("metal_city_"..self._info.num.."_1")
    if q.isEmpty(config) then
        config = QStaticDatabase:sharedDatabase():getDungeonConfigByID("metal_city_1_1")
    end
	config.isPveMultiple = true
	config.isMetalCity = true

	local trailInfo1 = remote.metalCity:getMetalCityMapConfigById(self._info.dungeon_id_1)
	local trailInfo2 = remote.metalCity:getMetalCityMapConfigById(self._info.dungeon_id_2)
	local monsterInfo1 = QStaticDatabase:sharedDatabase():getDungeonConfigByID(trailInfo1.dungeon_id)
	local monsterInfo2 = QStaticDatabase:sharedDatabase():getDungeonConfigByID(trailInfo2.dungeon_id)
    local monster = QStaticDatabase:sharedDatabase():getMonstersById(monsterInfo1.monster_id)
	
	config.pveMultipleInfos = { 
		{heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, monsterId = monsterInfo1.monster_id, force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.METAL_CIRY_ATTACK_TEAM1)}, 
		{heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, monsterId = monsterInfo2.monster_id, force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.METAL_CIRY_ATTACK_TEAM2)} 
	}

    local teamName1 = remote.teamManager.METAL_CIRY_ATTACK_TEAM1
    local teamName2 = remote.teamManager.METAL_CIRY_ATTACK_TEAM2

    local heroTeam1 = remote.teamManager:getActorIdsByKey(teamName1, 1)
	for _, heroId in ipairs(heroTeam1) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(config.pveMultipleInfos[1].heroes, self:_getHeroInfo(heroInfo))
	end

    local helpTeam1 = remote.teamManager:getActorIdsByKey(teamName1, 2)
	for _, heroId in ipairs(helpTeam1) do
   		local heroInfo = remote.herosUtil:getHeroByID(heroId)
 	   table.insert(config.pveMultipleInfos[1].supports, self:_getHeroInfo(heroInfo))
	end

    local godArmTeam1 = remote.teamManager:getGodArmIdsByKey(teamName1, 5)
    for _, heroId in ipairs(godArmTeam1) do
        local godArmInfo = remote.godarm:getGodarmById(heroId)
        table.insert(config.pveMultipleInfos[1].godArmIdList, tostring(godArmInfo.id..";"..(godArmInfo.grade or 0)))
    end

    local soulSpiritIds = remote.teamManager:getSpiritIdsByKey(teamName1, 1)
    for i, soulSpiritId in ipairs(soulSpiritIds) do
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
        table.insert(config.pveMultipleInfos[1].soulSpirits, self:_getSoulSpiritInfo(soulSpiritInfo))
    end

    local heroTeam2 = remote.teamManager:getActorIdsByKey(teamName2, 1)
	for _, heroId in ipairs(heroTeam2) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(config.pveMultipleInfos[2].heroes, self:_getHeroInfo(heroInfo))
	end

    local helpTeam2 = remote.teamManager:getActorIdsByKey(teamName2, 2)
	for _, heroId in ipairs(helpTeam2) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(config.pveMultipleInfos[2].supports, self:_getHeroInfo(heroInfo))
	end

    local godArmTeam2 = remote.teamManager:getGodArmIdsByKey(teamName2, 5)
    for _, heroId in ipairs(godArmTeam2) do
        local godArmInfo = remote.godarm:getGodarmById(heroId)
        table.insert(config.pveMultipleInfos[2].godArmIdList, tostring(godArmInfo.id..";"..(godArmInfo.grade or 0)))
    end
	
    local soulSpiritIds = remote.teamManager:getSpiritIdsByKey(teamName2, 1)
    for i, soulSpiritId in ipairs(soulSpiritIds) do
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
        table.insert(config.pveMultipleInfos[2].soulSpirits, self:_getSoulSpiritInfo(soulSpiritInfo))
    end

	-- 援助技能
	local function tableIndexof(supports, actorId)
		for i, v in pairs(supports) do
			if v.actorId == actorId then
				return i
			end
		end
	end
	local supportSkillHeroIndex = tableIndexof(config.pveMultipleInfos[1].supports, battleFormation1.activeSub1HeroId) or 0
    config.pveMultipleInfos[1].supportSkillHeroIndex = supportSkillHeroIndex
	local supportSkillHeroIndex2 = tableIndexof(config.pveMultipleInfos[1].supports, battleFormation1.activeSub2HeroId) or 0
    config.pveMultipleInfos[1].supportSkillHeroIndex2 = supportSkillHeroIndex2

	local supportSkillHeroIndex = tableIndexof(config.pveMultipleInfos[2].supports, battleFormation2.activeSub1HeroId) or 0
    config.pveMultipleInfos[2].supportSkillHeroIndex = supportSkillHeroIndex
	local supportSkillHeroIndex2 = tableIndexof(config.pveMultipleInfos[2].supports, battleFormation2.activeSub2HeroId) or 0
    config.pveMultipleInfos[2].supportSkillHeroIndex2 = supportSkillHeroIndex2

	config.battleFormation = battleFormation1
	config.battleFormation2 = battleFormation2
    config.teamName = remote.teamManager.METAL_CIRY_ATTACK_TEAM1
	config.metalCityNum = self._info.num
    config.monster_id = monsterInfo1.monster_id
	config.heroRecords = remote.user.collectedHeros or {}

    self:_initDungeonConfig(config)

    remote.metalCity:requestMetalCityFightStart(config.metalCityNum, battleFormation1, battleFormation2, function(data)
			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)

			config.verifyKey = data.gfStartResponse.battleVerify

			-- local buffer, record = self:_createReplayBuffer(config)
			-- writeToBinaryFile("last.reppb", buffer)

		   	local loader = QDungeonResourceLoader.new(config)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
    	end)

end

function QMetalCityArrangement:getHeroes()
	return remote.herosUtil:getHaveHero()
end

function QMetalCityArrangement:getUnlockSlots(index, trailNum)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHerosMaxCountByIndex(index, trailNum)
end

function QMetalCityArrangement:getUnlockLevel(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getHelpUnlockLevel(index)
end

return QMetalCityArrangement
