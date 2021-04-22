-- @Author: liaoxianbo
-- @Date:   2019-11-13 16:47:01
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-02 20:35:15

local QBaseTrainArrangement = class("QBaseTrainArrangement")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QReplayUtil = import("..utils.QReplayUtil")
local QMyAppUtils = import("..utils.QMyAppUtils")

QBaseTrainArrangement.NO_FIGHT_HEROES = "还未设置战队，无法参加战斗！现在就设置战队？"
QBaseTrainArrangement.ALL_HEAL_HEROES = "出战魂师不能全部为治疗魂师"
QBaseTrainArrangement.NO_FIGHT_HEROES_TEAM = "第%s战队还未设置战队，无法参加战斗！现在就设置战队？"
QBaseTrainArrangement.ALL_HEAL_HEROES_TEAM = "第%s战队出战魂师不能全部为治疗魂师"

function QBaseTrainArrangement:ctor(chapterId, heroIdList, soulSpiritList,remoteUtils,teamKey)
	self._heroes = heroIdList or {}
	self._soulSpiritList = soulSpiritList or {}
	self._teamKey = teamKey	
	self._arragementConfig = {}

    self._chapterId = chapterId
    self._remoteUtils = remoteUtils 
end

function QBaseTrainArrangement:viewDidAppear()
	
end

function QBaseTrainArrangement:viewWillDisappear()
	
end

function QBaseTrainArrangement:getRemoteUtils( )
    return self._remoteUtils
end

function QBaseTrainArrangement:getChapterId( )
    return self._chapterId
end

-- return all heroes
function QBaseTrainArrangement:getHeroes()
	return self._heroes
end

function QBaseTrainArrangement:getSoulSpirits()
    return self._soulSpiritList
end

--[[
	是否是战斗阵容
]]
function QBaseTrainArrangement:getIsBattle()
	return true
end

-- heroes are the ID(actorId) list of the battle heroes
function QBaseTrainArrangement:startBattle(heroIdList)
	assert(false, "No implement for QBaseTrainArrangement startBattle")
end

-- check if battle heroes are able to fight
function QBaseTrainArrangement:teamValidity(actorIds, teamIndex, callback, hideAlert)
	if actorIds == nil or #actorIds == 0 then
        local alertCallback = function(state)
            if state == ALERT_TYPE.CONFIRM then
                if callback then
                    callback()
                end
            end
        end
        if hideAlert then
            return false
        end
        if teamIndex then
            app:alert({content = string.format(QBaseTrainArrangement.NO_FIGHT_HEROES_TEAM, teamIndex), title = "系统提示", callback = alertCallback}, false)
        else
		    app:alert({content = QBaseTrainArrangement.NO_FIGHT_HEROES, title = "系统提示", callback = alertCallback}, false)
        end
	    return false
	end

	--检查是否包含非治疗职业
	local isAllHeath = true
	for k, actorId in pairs(actorIds) do
		local heroConfig = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
		if heroConfig.func ~= 'health' then
			isAllHeath = false
			break
		end
	end

	if isAllHeath then
        if teamIndex then
            app.tip:floatTip(string.format(QBaseTrainArrangement.ALL_HEAL_HEROES_TEAM, teamIndex))
        else
            app.tip:floatTip(QBaseTrainArrangement.ALL_HEAL_HEROES)
        end
	  	return false
	end

	return true
end

function QBaseTrainArrangement:getOpponent()
	return {}
end

function QBaseTrainArrangement:getHeroInfoById(actorId)
	return nil
end

-- -- 2v2数据
-- function QBaseTrainArrangement:_initNewPVPTeamInfo(config, enemyFighter, teamName1, teamName2)
--     local teamForce1 = 0
--     local teamForce2 = 0

--     config.pvpMultipleTeams = { 
--         {hero = {heroes = {}, supports = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}, 
--         enemy = {heroes = {}, supports = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}},
--         {hero = {heroes = {}, supports = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}, 
--         enemy = {heroes = {}, supports = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}},
--     }
    
--     local heroTeam1 = remote.teamManager:getActorIdsByKey(teamName1, 1)
--     for _, heroId in ipairs(heroTeam1) do
--         local heroInfo = remote.herosUtil:getHeroByID(heroId)
--         teamForce1 = teamForce1 + heroInfo.force
--         table.insert(config.pvpMultipleTeams[1].hero.heroes, self:_getHeroInfo(heroInfo))
--     end

--     local helpTeam1 = remote.teamManager:getActorIdsByKey(teamName1, 2)
--     for _, heroId in ipairs(helpTeam1) do
--         local heroInfo = remote.herosUtil:getHeroByID(heroId)
--         teamForce1 = teamForce1 + heroInfo.force
--         table.insert(config.pvpMultipleTeams[1].hero.supports, self:_getHeroInfo(heroInfo))
--     end

--     local soulSpiritIds = remote.teamManager:getSpiritIdsByKey(teamName1, 1)
--     for i, soulSpiritId in ipairs(soulSpiritIds) do
--         local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
--         teamForce1 = teamForce1 + soulSpiritInfo.force
--         table.insert(config.pvpMultipleTeams[1].hero.soulSpirits, self:_getSoulSpiritInfo(soulSpiritInfo))
--     end

--     local heroTeam2 = remote.teamManager:getActorIdsByKey(teamName2, 1)
--     for _, heroId in ipairs(heroTeam2) do
--         local heroInfo = remote.herosUtil:getHeroByID(heroId)
--         teamForce2 = teamForce2 + heroInfo.force
--         table.insert(config.pvpMultipleTeams[2].hero.heroes, self:_getHeroInfo(heroInfo))
--     end

--     local helpTeam2 = remote.teamManager:getActorIdsByKey(teamName2, 2)
--     for _, heroId in ipairs(helpTeam2) do
--         local heroInfo = remote.herosUtil:getHeroByID(heroId)
--         teamForce2 = teamForce2 + heroInfo.force
--         table.insert(config.pvpMultipleTeams[2].hero.supports, self:_getHeroInfo(heroInfo))
--     end

--     local soulSpiritIds = remote.teamManager:getSpiritIdsByKey(teamName2, 1)
--     for i, soulSpiritId in ipairs(soulSpiritIds) do
--         local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
--         teamForce2 = teamForce2 + soulSpiritInfo.force
--         table.insert(config.pvpMultipleTeams[2].hero.soulSpirits, self:_getSoulSpiritInfo(soulSpiritInfo))
--     end
--     config.pvpMultipleTeams[1].hero.force = teamForce1
--     config.pvpMultipleTeams[2].hero.force = teamForce2

--     -- 援助技能
--     local function tableIndexof(supports, actorId)
--         for i, v in pairs(supports) do
--             if v.actorId == actorId then
--                 return i
--             end
--         end
--     end
--     local teamSkills = remote.teamManager:getSkillByKey(teamName1, 2)
--     local supports = config.pvpMultipleTeams[1].hero.supports
--     local supportSkillHeroIndex = tableIndexof(supports, teamSkills[1])
--     local supportSkillHeroIndex2 = tableIndexof(supports, teamSkills[2])
--     if not supportSkillHeroIndex and #supports >= 1 then
--         supportSkillHeroIndex = 1
--     end
--     if not supportSkillHeroIndex2 and #supports >= 2 then
--         supportSkillHeroIndex2 = 2
--     end
--     config.pvpMultipleTeams[1].hero.supportSkillHeroIndex = supportSkillHeroIndex
--     config.pvpMultipleTeams[1].hero.supportSkillHeroIndex2 = supportSkillHeroIndex2

--     local teamSkills = remote.teamManager:getSkillByKey(teamName2, 2)
--     local supports = config.pvpMultipleTeams[2].hero.supports
--     local supportSkillHeroIndex = tableIndexof(supports, teamSkills[1])
--     local supportSkillHeroIndex2 = tableIndexof(supports, teamSkills[2])
--     if not supportSkillHeroIndex and #supports >= 1 then
--         supportSkillHeroIndex = 1
--     end
--     if not supportSkillHeroIndex2 and #supports >= 2 then
--         supportSkillHeroIndex2 = 2
--     end
--     config.pvpMultipleTeams[2].hero.supportSkillHeroIndex = supportSkillHeroIndex
--     config.pvpMultipleTeams[2].hero.supportSkillHeroIndex2 = supportSkillHeroIndex2

--     local enemyTeamForce1 = 0
--     local enemyTeamForce2 = 0
--     for _, member in ipairs(enemyFighter.heros or {}) do
--         local info = clone(member)
--         enemyTeamForce1 = enemyTeamForce1 + info.force
--         table.insert(config.pvpMultipleTeams[1].enemy.heroes, info)
--     end

--     if enemyFighter.soulSpirit then
--         enemyTeamForce1 = enemyTeamForce1 + (enemyFighter.soulSpirit.force or 0)
--         table.insert(config.pvpMultipleTeams[1].enemy.soulSpirits, self:_getSoulSpiritInfo(enemyFighter.soulSpirit))
--     end

--     if q.isEmpty(enemyFighter.subheros) == false then
--         local activeSubActorId = 1
--         local active1SubActorId = 2
--         for _, member in ipairs(enemyFighter.subheros) do
--             local info = clone(member)
--             enemyTeamForce1 = enemyTeamForce1 + info.force
--             table.insert(config.pvpMultipleTeams[1].enemy.supports, info)
--         end
--         local supports = config.pvpMultipleTeams[1].enemy.supports
--         local supportSkillHeroIndex = tableIndexof(supports, enemyFighter.activeSubActorId)
--         local supportSkillHeroIndex2 = tableIndexof(supports, enemyFighter.active1SubActorId)
--         if not supportSkillHeroIndex and #supports >= 1 then
--             supportSkillHeroIndex = 1
--         end
--         if not supportSkillHeroIndex2 and #supports >= 2 then
--             supportSkillHeroIndex2 = 2
--         end
--         config.pvpMultipleTeams[1].enemy.supportSkillHeroIndex = supportSkillHeroIndex
--         config.pvpMultipleTeams[1].enemy.supportSkillHeroIndex2 = supportSkillHeroIndex2
--     end
    
--     for _, member in ipairs(enemyFighter.main1Heros or {}) do
--         local info = clone(member)
--         enemyTeamForce2 = enemyTeamForce2 + info.force
--         table.insert(config.pvpMultipleTeams[2].enemy.heroes, info)
--     end

--     if enemyFighter.soulSpirit2 then
--         enemyTeamForce2 = enemyTeamForce2 + (enemyFighter.soulSpirit2.force or 0)
--         table.insert(config.pvpMultipleTeams[2].enemy.soulSpirits, self:_getSoulSpiritInfo(enemyFighter.soulSpirit2))
--     end

--     if q.isEmpty(enemyFighter.sub1heros) == false then
--         for _, member in ipairs(enemyFighter.sub1heros) do
--             local info = clone(member)
--             enemyTeamForce2 = enemyTeamForce2 + info.force
--             table.insert(config.pvpMultipleTeams[2].enemy.supports, info)
--         end
--         local supports = config.pvpMultipleTeams[2].enemy.supports
--         local supportSkillHeroIndex = tableIndexof(supports, enemyFighter.activeSub2ActorId)
--         local supportSkillHeroIndex2 = tableIndexof(supports, enemyFighter.active1Sub2ActorId)
--         if not supportSkillHeroIndex and #supports >= 1 then
--             supportSkillHeroIndex = 1
--         end
--         if not supportSkillHeroIndex2 and #supports >= 2 then
--             supportSkillHeroIndex2 = 2
--         end
--         config.pvpMultipleTeams[2].enemy.supportSkillHeroIndex = supportSkillHeroIndex
--         config.pvpMultipleTeams[2].enemy.supportSkillHeroIndex2 = supportSkillHeroIndex2
--     end

--     config.pvpMultipleTeams[1].enemy.force = enemyTeamForce1
--     config.pvpMultipleTeams[2].enemy.force = enemyTeamForce2
-- end

--[[
	初始化玩家的一些战斗能力参数
]]
function QBaseTrainArrangement:_initDungeonConfig(dungeonConfig,heroTeams)
    -- 技能
    self:_addTeamHeroSkill(dungeonConfig)
    self:_addUserHeroes(dungeonConfig,heroTeams)

    -- 版本
    dungeonConfig.gameVersion = app:getBattleVersion()
    -- 名字
    dungeonConfig.userName = remote.user.nickname

	dungeonConfig.supportSkillEnemyIndex = 1
    if dungeonConfig.pvp_rivals3 then
    	local supportSkillRival = dungeonConfig.pvp_rivals3
        for index, info in ipairs(dungeonConfig.pvp_rivals2) do
            if tonumber(info.actorId) == tonumber(supportSkillRival.actorId) then
                dungeonConfig.supportSkillEnemyIndex = index
            end
        end
    end

	dungeonConfig.supportSkillEnemyIndex2 = 1
    if dungeonConfig.pvp_rivals5 then
    	local supportSkillRival = dungeonConfig.pvp_rivals5
        for index, info in ipairs(dungeonConfig.pvp_rivals4) do
            if tonumber(info.actorId) == tonumber(supportSkillRival.actorId) then
                dungeonConfig.supportSkillEnemyIndex2 = index
            end
        end
    end

    dungeonConfig.supportSkillEnemyIndex3 = 1
    if dungeonConfig.pvp_rivals7 then
        local supportSkillRival = dungeonConfig.pvp_rivals7
        for index, info in ipairs(dungeonConfig.pvp_rivals6) do
            if tonumber(info.actorId) == tonumber(supportSkillRival.actorId) then
                dungeonConfig.supportSkillEnemyIndex3 = index
            end
        end
    end
end

-- 两队战队英雄和技能
function QBaseTrainArrangement:_addTeamHeroSkill(dungeonConfig)
    local enemyInfo = {}
    local enemyInfo2 = {}
    local skillInfo = nil
    local enemyInfo3 = {}
    local skillInfo2 = nil
    local enemyInfo4 = {}
    local skillInfo3 = nil
    local enemySoulSpirits = {}
    local enemyAlternateInfos = {}
    local enemyAlternateTargetOrder = {}

    if dungeonConfig.pveMultipleInfos then
        for _, value in ipairs(dungeonConfig.pveMultipleInfos) do
            remote.herosUtil:addPeripheralSkills(value.heroes)
            remote.herosUtil:addPeripheralSkills(value.supports)
        end
    end

    dungeonConfig.pvp_rivals = enemyInfo
    dungeonConfig.pvp_rivals2 = enemyInfo2
    dungeonConfig.pvp_rivals3 = skillInfo
    dungeonConfig.pvp_rivals4 = enemyInfo3
    dungeonConfig.pvp_rivals5 = skillInfo2
    dungeonConfig.pvp_rivals6 = enemyInfo4
    dungeonConfig.pvp_rivals7 = skillInfo3
    dungeonConfig.enemySoulSpirits = enemySoulSpirits
    dungeonConfig.enemyAlternateInfos = enemyAlternateInfos

    remote.teamManager:sortTeam(enemyAlternateTargetOrder)
    dungeonConfig.enemyAlternateTargetOrder = enemyAlternateTargetOrder
end

function QBaseTrainArrangement:_addUserHeroes(dungeonConfig,tems)
    local teams = tems

    QPrintTable(tems)

    if dungeonConfig.teamName ~= nil then
        teamName = dungeonConfig.teamName
    end
    dungeonConfig.heroInfos = {}
    dungeonConfig.userAlternateInfos = {}
    dungeonConfig.supportHeroInfos = {}
    dungeonConfig.supportHeroInfos2 = {}
    dungeonConfig.supportHeroInfos3 = {}
    dungeonConfig.userSoulSpirits = {}

    -- local userAlternateTargetOrder = {}

    -- 主力
    local mainHeros = teams[self._remoteUtils.TEAM_INDEX_MAIN].actorIds or {}
    for k, heroId in ipairs(mainHeros) do
        local heroInfo = self._remoteUtils:getHeroInfoById(self._chapterId,heroId)
        table.insert(dungeonConfig.heroInfos, heroInfo)
        -- table.insert(userAlternateTargetOrder, heroId)
    end

    -- 援助1
    local supports = teams[self._remoteUtils.TEAM_INDEX_HELP].actorIds or {}
    for k, heroId in ipairs(supports) do
        local heroInfo = self._remoteUtils:getHeroInfoById(self._chapterId,heroId)
        table.insert(dungeonConfig.supportHeroInfos, heroInfo)
    end
    -- 援助2
    local supports2 = teams[self._remoteUtils.TEAM_INDEX_HELP2].actorIds or {}
    for k, heroId in ipairs(supports2) do
        local heroInfo = self._remoteUtils:getHeroInfoById(self._chapterId,heroId)
        table.insert(dungeonConfig.supportHeroInfos2, heroInfo)
    end
    -- 援助3
    local supports3 = teams[self._remoteUtils.TEAM_INDEX_HELP3].actorIds or {}
    for k, heroId in ipairs(supports3) do
        local heroInfo = self._remoteUtils:getHeroInfoById(self._chapterId,heroId)
        table.insert(dungeonConfig.supportHeroInfos3, heroInfo)
    end
    -- 魂灵
    local soulSpiritIds = teams[self._remoteUtils.TEAM_INDEX_MAIN].spiritIds or {}
    for i, soulSpiritId in ipairs(soulSpiritIds) do
        local soulSpiritInfo = self._remoteUtils:getSpritInfoById(self._chapterId,soulSpiritId)
        table.insert(dungeonConfig.userSoulSpirits, self:_getSoulSpiritInfo(soulSpiritInfo))
    end
    
    -- 非3v3技能副将1
    local supportsSkill = teams[self._remoteUtils.TEAM_INDEX_HELP].skill or {}
    if next(supportsSkill) ~= nil then
        local supportSkillHeroIndex = table.indexof(supports, tonumber(supportsSkill[1])) or 1
        dungeonConfig.supportSkillHeroIndex = supportSkillHeroIndex
    end
    -- 非3v3技能副将2
    local supportsSkill2 = teams[self._remoteUtils.TEAM_INDEX_HELP2].skill or {}
    if next(supportsSkill2) ~= nil then
        local supportSkillHeroIndex2 = table.indexof(supports2, tonumber(supportsSkill2[1])) or 1
        dungeonConfig.supportSkillHeroIndex2 = supportSkillHeroIndex2
    end
    -- 非3v3技能副将3
    local supportsSkill3 = teams[self._remoteUtils.TEAM_INDEX_HELP3].skill or {}
    if next(supportsSkill3) ~= nil then
        local supportSkillHeroIndex3 = table.indexof(supports3, tonumber(supportsSkill3[1])) or 1
        dungeonConfig.supportSkillHeroIndex3 = supportSkillHeroIndex3
    end


    remote.teamManager:sortTeam(dungeonConfig.heroInfos)
    -- dungeonConfig.userAlternateTargetOrder = userAlternateTargetOrder
    
end

function QBaseTrainArrangement:_getHeroInfo(heroInfo)
    return QMyAppUtils:getHeroInfo(heroInfo)
end

function QBaseTrainArrangement:_getSoulSpiritInfo(soulSpiritInfo)
    return QMyAppUtils:getBaseSoulSpiritInfo(soulSpiritInfo)
end

return QBaseTrainArrangement