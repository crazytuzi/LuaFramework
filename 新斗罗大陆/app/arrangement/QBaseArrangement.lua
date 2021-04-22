--
-- Author: Qinyuanji
-- Date: 2015-01-15 
-- This class is the base dialog for Rank detailed list

local QBaseArrangement = class("QBaseArrangement")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QReplayUtil = import("..utils.QReplayUtil")
local QMyAppUtils = import("..utils.QMyAppUtils")

QBaseArrangement.NO_FIGHT_HEROES = "还未设置战队，无法参加战斗！现在就设置战队？"
QBaseArrangement.ALL_HEAL_HEROES = "出战魂师不能全部为治疗魂师"
QBaseArrangement.NO_FIGHT_HEROES_TEAM = "第%s战队还未设置战队，无法参加战斗！现在就设置战队？"
QBaseArrangement.ALL_HEAL_HEROES_TEAM = "第%s战队出战魂师不能全部为治疗魂师"

function QBaseArrangement:ctor(heroIdList, teamKey)
	self._heroes = heroIdList or {}
	self._teamKey = teamKey	
	self._arragementConfig = {}

    remote.teamManager:checkTeamByKey(teamKey)
end

function QBaseArrangement:viewDidAppear()
	
end

function QBaseArrangement:viewWillDisappear() 
	
end

-- return all heroes
function QBaseArrangement:getHeroes()
	return self._heroes
end

function QBaseArrangement:getSoulSpirits()
    return remote.soulSpirit:getMySoulSpiritInfoList()
end

function QBaseArrangement:getIsLocal()
    return self._isLocal == true
end

function QBaseArrangement:setIsLocal(b)
	self._isLocal = b
end

function QBaseArrangement:handlerDialog(dialog)
	dialog._ccbOwner.node_buff_up:setVisible(false)
end

-- return the existing heroes that were saved in previous battles
function QBaseArrangement:getExistingHeroes()
	local actorIds = {}
	local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
	if teamVO == nil then return end
	local maxIndex = teamVO:getTeamMaxIndex()
	for i=1,maxIndex do
		local heros = teamVO:getTeamActorsByIndex(i)
		if heros ~= nil then
			for _,actorId in ipairs(heros) do
				table.insert(actorIds, actorId)
			end
		end
	end
	return actorIds
end

function QBaseArrangement:getUnlockSlots(index)
    print("QBaseArrangement:getUnlockSlots----index=",index)
	local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
	return teamVO:getHerosMaxCountByIndex(index)
end

function QBaseArrangement:getSoulSpiritUnlock(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getSpiritsMaxCountByIndex(index)
end

function QBaseArrangement:getAlternateUnlock(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getAlternateMaxCountByIndex(index)
end

-- if arrangement needs widget frame to show state
function QBaseArrangement:showHeroState()
	return false
end

function QBaseArrangement:getTeamKey()
	assert(self._teamKey, "No team type for QBaseArrangement")
	return self._teamKey
end

function QBaseArrangement:setTeamKey(teamKey)
	if teamKey == nil then return end
	self._teamKey = teamKey
end

-- if prompt when there is hero available to fight
function QBaseArrangement:availableHeroPrompt()
	return true
end

function QBaseArrangement:getBackPagePath(index)
	return nil
end

function QBaseArrangement:getEffectPagePath(index)
	return nil
end

--[[
	是否是战斗阵容
]]
function QBaseArrangement:getIsBattle()
	return true
end

-- heroes are the ID(actorId) list of the battle heroes
function QBaseArrangement:startBattle(heroIdList)
	assert(false, "No implement for QBaseArrangement startBattle")
end

-- check if battle heroes are able to fight
function QBaseArrangement:teamValidity(actorIds, teamIndex, callback, hideAlert, failCallback)
	if actorIds == nil or #actorIds == 0 then
        local alertCallback = function(state)
            if state == ALERT_TYPE.CONFIRM then
                if callback then
                    callback()
                end
            elseif state == ALERT_TYPE.CANCEL or state == ALERT_TYPE.CLOSE then
                if failCallback then
                    failCallback()
                end
            end
        end
        if hideAlert then
            return false
        end
        if teamIndex then
            app:alert({content = string.format(QBaseArrangement.NO_FIGHT_HEROES_TEAM, teamIndex), title = "系统提示", callback = alertCallback}, false)
        else
		    app:alert({content = QBaseArrangement.NO_FIGHT_HEROES, title = "系统提示", callback = alertCallback}, false)
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
            app.tip:floatTip(string.format(QBaseArrangement.ALL_HEAL_HEROES_TEAM, teamIndex))
        else
            app.tip:floatTip(QBaseArrangement.ALL_HEAL_HEROES)
        end
	  	return false
	end

	return true
end

function QBaseArrangement:getOpponent()
	return {}
end

--获取对手战队指定位置的魂师，是否显示该位置魂师
function QBaseArrangement:getOpponentTeamByIndex(index)
	if index == remote.teamManager.TEAM_INDEX_MAIN then
		return nil,false
	elseif index == remote.teamManager.TEAM_INDEX_HELP then
		return nil,false
	elseif index == remote.teamManager.TEAM_INDEX_HELP2 then
		return nil,false
    elseif index == remote.teamManager.TEAM_INDEX_HELP3 then
        return nil,false
	end
end

function QBaseArrangement:setAllTeams(teams)
	remote.teamManager:updateTeamData(self._teamKey, teams)
end

function QBaseArrangement:setAllTeamsWithBattleFormation(battleFormation)
	local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
	if teamVO ~= nil then
		teamVO:setTeamDataWithBattleFormation(battleFormation)
	end
end

function QBaseArrangement:getSkillTeams(index)
	local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
	return teamVO:getTeamSkillByIndex(index)
end

function QBaseArrangement:setSkillTeams(index, teams)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:setTeamSkillByIndex(index, teams)
end

function QBaseArrangement:getActorTeams(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getTeamActorsByIndex(index)
end

function QBaseArrangement:setActorTeams(index, actorIds)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:setTeamActorsByIndex(index, actorIds)
end

function QBaseArrangement:setSoulSpiritTeams(index, soulSpiritIds)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:setTeamSpiritsByIndex(index, soulSpiritIds)
end

function QBaseArrangement:setGodarmTeams(index, godarmIds)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:setTeamGodarmByIndex(index, godarmIds)
end

function QBaseArrangement:getAlternateTeams(index)
    local teamVO = remote.teamManager:getTeamByKey(self._teamKey, false)
    return teamVO:getTeamAlternatesByIndex(index)
end

function QBaseArrangement:getPrompt()
	return ""
end

function QBaseArrangement:getHeroInfoById(actorId)
	return nil
end

function QBaseArrangement:getMaxHp(maxHp)
	return maxHp
end

function QBaseArrangement:_createReplayBuffer(dungeonConfig)
	return QReplayUtil:createReplayBuffer(self._teamKey, dungeonConfig)
end

-- 2v2数据
function QBaseArrangement:_initNewPVPTeamInfo(config, enemyFighter, teamName1, teamName2)
    local teamForce1 = 0
    local teamForce2 = 0

    config.pvpMultipleTeams = { 
        {hero = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}, 
        enemy = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}},
        {hero = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}, 
        enemy = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}},
    }
    
    local heroTeam1 = remote.teamManager:getActorIdsByKey(teamName1, 1)
    for _, heroId in ipairs(heroTeam1) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        teamForce1 = teamForce1 + heroInfo.force
        table.insert(config.pvpMultipleTeams[1].hero.heroes, self:_getHeroInfo(heroInfo))
    end

    local helpTeam1 = remote.teamManager:getActorIdsByKey(teamName1, 2)
    for _, heroId in ipairs(helpTeam1) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        teamForce1 = teamForce1 + heroInfo.force
        table.insert(config.pvpMultipleTeams[1].hero.supports, self:_getHeroInfo(heroInfo))
    end

    local godArmTeam1 = remote.teamManager:getGodArmIdsByKey(teamName1, 5)
    for _, heroId in pairs(godArmTeam1) do
        local godArmInfo = remote.godarm:getGodarmById(heroId)
        teamForce1 = teamForce1 + (godArmInfo.main_force or 0)
        -- table.insert(config.pvpMultipleTeams[1].hero.godArmIdList, tostring(godArmInfo.id..";"..(godArmInfo.grade or 0)))
        table.insert(config.pvpMultipleTeams[1].hero.godArmIdList,self:_getGodarmInfo(godArmInfo))
    end

    local soulSpiritIds = remote.teamManager:getSpiritIdsByKey(teamName1, 1)
    for i, soulSpiritId in ipairs(soulSpiritIds) do
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
        teamForce1 = teamForce1 + soulSpiritInfo.force
        table.insert(config.pvpMultipleTeams[1].hero.soulSpirits, self:_getSoulSpiritInfo(soulSpiritInfo))
    end

    local heroTeam2 = remote.teamManager:getActorIdsByKey(teamName2, 1)
    for _, heroId in ipairs(heroTeam2) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        teamForce2 = teamForce2 + heroInfo.force
        table.insert(config.pvpMultipleTeams[2].hero.heroes, self:_getHeroInfo(heroInfo))
    end

    local helpTeam2 = remote.teamManager:getActorIdsByKey(teamName2, 2)
    for _, heroId in ipairs(helpTeam2) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        teamForce2 = teamForce2 + heroInfo.force
        table.insert(config.pvpMultipleTeams[2].hero.supports, self:_getHeroInfo(heroInfo))
    end

    local godArmTeam2 = remote.teamManager:getGodArmIdsByKey(teamName2, 5)
    for _, godArmId in pairs(godArmTeam2) do
        local godArmInfo = remote.godarm:getGodarmById(godArmId)
        teamForce2 = teamForce2 + (godArmInfo.main_force or 0)
        -- table.insert(config.pvpMultipleTeams[2].hero.godArmIdList, tostring(godArmInfo.id..";"..(godArmInfo.grade or 0)))
        table.insert(config.pvpMultipleTeams[2].hero.godArmIdList,self:_getGodarmInfo(godArmInfo))
    end

    local soulSpiritIds = remote.teamManager:getSpiritIdsByKey(teamName2, 1)
    for i, soulSpiritId in ipairs(soulSpiritIds) do
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
        teamForce2 = teamForce2 + soulSpiritInfo.force
        table.insert(config.pvpMultipleTeams[2].hero.soulSpirits, self:_getSoulSpiritInfo(soulSpiritInfo))
    end
    config.pvpMultipleTeams[1].hero.force = teamForce1
    config.pvpMultipleTeams[2].hero.force = teamForce2

    -- 援助技能
    local function tableIndexof(supports, actorId)
        for i, v in pairs(supports) do
            if v.actorId == actorId then
                return i
            end
        end
    end
    local teamSkills = remote.teamManager:getSkillByKey(teamName1, 2)
    local supports = config.pvpMultipleTeams[1].hero.supports
    local supportSkillHeroIndex = tableIndexof(supports, teamSkills[1])
    local supportSkillHeroIndex2 = tableIndexof(supports, teamSkills[2])
    if not supportSkillHeroIndex and #supports >= 1 then
        supportSkillHeroIndex = 1
    end
    if not supportSkillHeroIndex2 and #supports >= 2 then
        supportSkillHeroIndex2 = 2
    end
    config.pvpMultipleTeams[1].hero.supportSkillHeroIndex = supportSkillHeroIndex
    config.pvpMultipleTeams[1].hero.supportSkillHeroIndex2 = supportSkillHeroIndex2

    local teamSkills = remote.teamManager:getSkillByKey(teamName2, 2)
    local supports = config.pvpMultipleTeams[2].hero.supports
    local supportSkillHeroIndex = tableIndexof(supports, teamSkills[1])
    local supportSkillHeroIndex2 = tableIndexof(supports, teamSkills[2])
    if not supportSkillHeroIndex and #supports >= 1 then
        supportSkillHeroIndex = 1
    end
    if not supportSkillHeroIndex2 and #supports >= 2 then
        supportSkillHeroIndex2 = 2
    end
    config.pvpMultipleTeams[2].hero.supportSkillHeroIndex = supportSkillHeroIndex
    config.pvpMultipleTeams[2].hero.supportSkillHeroIndex2 = supportSkillHeroIndex2

    local enemyTeamForce1 = 0
    local enemyTeamForce2 = 0
    for _, member in ipairs(enemyFighter.heros or {}) do
        local info = clone(member)
        enemyTeamForce1 = enemyTeamForce1 + info.force
        table.insert(config.pvpMultipleTeams[1].enemy.heroes, info)
    end

    for _,v in pairs(enemyFighter.soulSpirit or {}) do
        enemyTeamForce1 = enemyTeamForce1 + (v.force or 0)
        table.insert(config.pvpMultipleTeams[1].enemy.soulSpirits, self:_getSoulSpiritInfo(v))
    end

    for _, member in ipairs(enemyFighter.godArm1List or {}) do
        local info = clone(member)
        enemyTeamForce1 = enemyTeamForce1 + info.main_force
        -- table.insert(config.pvpMultipleTeams[1].enemy.godArmIdList, tostring(info.id..";"..(info.grade or 0)))
        table.insert(config.pvpMultipleTeams[1].enemy.godArmIdList,self:_getGodarmInfo(info))
    end

    if q.isEmpty(enemyFighter.subheros) == false then
        local activeSubActorId = 1
        local active1SubActorId = 2
        for _, member in ipairs(enemyFighter.subheros) do
            local info = clone(member)
            enemyTeamForce1 = enemyTeamForce1 + info.force
            table.insert(config.pvpMultipleTeams[1].enemy.supports, info)
        end
        local supports = config.pvpMultipleTeams[1].enemy.supports
        local supportSkillHeroIndex = tableIndexof(supports, enemyFighter.activeSubActorId)
        local supportSkillHeroIndex2 = tableIndexof(supports, enemyFighter.active1SubActorId)
        if not supportSkillHeroIndex and #supports >= 1 then
            supportSkillHeroIndex = 1
        end
        if not supportSkillHeroIndex2 and #supports >= 2 then
            supportSkillHeroIndex2 = 2
        end
        config.pvpMultipleTeams[1].enemy.supportSkillHeroIndex = supportSkillHeroIndex
        config.pvpMultipleTeams[1].enemy.supportSkillHeroIndex2 = supportSkillHeroIndex2
    end
    
    for _, member in ipairs(enemyFighter.main1Heros or {}) do
        local info = clone(member)
        enemyTeamForce2 = enemyTeamForce2 + info.force
        table.insert(config.pvpMultipleTeams[2].enemy.heroes, info)
    end

    for _, member in ipairs(enemyFighter.godArm2List or {}) do
        local info = clone(member)
        enemyTeamForce2 = enemyTeamForce2 + info.main_force
        -- table.insert(config.pvpMultipleTeams[2].enemy.godArmIdList, tostring(info.id..";"..(info.grade or 0)))
        table.insert(config.pvpMultipleTeams[2].enemy.godArmIdList,self:_getGodarmInfo(info))

    end

    for _,v in pairs(enemyFighter.soulSpirit2 or {}) do
        enemyTeamForce2 = enemyTeamForce2 + (v.force or 0)
        table.insert(config.pvpMultipleTeams[2].enemy.soulSpirits, self:_getSoulSpiritInfo(v))
    end

    if q.isEmpty(enemyFighter.sub1heros) == false then
        for _, member in ipairs(enemyFighter.sub1heros) do
            local info = clone(member)
            enemyTeamForce2 = enemyTeamForce2 + info.force
            table.insert(config.pvpMultipleTeams[2].enemy.supports, info)
        end
        local supports = config.pvpMultipleTeams[2].enemy.supports
        local supportSkillHeroIndex = tableIndexof(supports, enemyFighter.activeSub2ActorId)
        local supportSkillHeroIndex2 = tableIndexof(supports, enemyFighter.active1Sub2ActorId)
        if not supportSkillHeroIndex and #supports >= 1 then
            supportSkillHeroIndex = 1
        end
        if not supportSkillHeroIndex2 and #supports >= 2 then
            supportSkillHeroIndex2 = 2
        end
        config.pvpMultipleTeams[2].enemy.supportSkillHeroIndex = supportSkillHeroIndex
        config.pvpMultipleTeams[2].enemy.supportSkillHeroIndex2 = supportSkillHeroIndex2
    end

    config.pvpMultipleTeams[1].enemy.force = enemyTeamForce1
    config.pvpMultipleTeams[2].enemy.force = enemyTeamForce2
end

--[[
	初始化玩家的一些战斗能力参数
]]
function QBaseArrangement:_initDungeonConfig(dungeonConfig, enemyFighter)
    -- 主力排序
    if enemyFighter and enemyFighter.heros then
        remote.teamManager:sortTeam(enemyFighter.heros, true)
    end

    -- 技能
    self:_addTeamHeroSkill(dungeonConfig, enemyFighter)
    self:_addUserHeroes(dungeonConfig)

    -- 版本
    dungeonConfig.gameVersion = app:getBattleVersion()
    -- 宗门技能
	dungeonConfig.userConsortiaSkill = remote.union:hasUnion() and remote.user.userConsortiaSkill or {}
	-- 头像
	dungeonConfig.userAvatar = remote.user.avatar
	-- 称号
	dungeonConfig.userTitle = remote.user.title
	-- 头像属性
	dungeonConfig.userTitles = remote.headProp:getHeadList()
	-- 考古碎片
	dungeonConfig.userLastEnableFragmentId = remote.archaeology:getLastEnableFragmentID()
	-- 魂力试炼
	dungeonConfig.userSoulTrial = remote.user.soulTrial
	-- 战队等级
	dungeonConfig.userLevel = remote.user.level
    -- vip等级
    dungeonConfig.userVip = app.vipUtil:VIPLevel()
    -- 战力
    dungeonConfig.userForce = remote.user:getTopNForce()
    -- 名字
    dungeonConfig.userName = remote.user.nickname
	-- 宗门名字
    dungeonConfig.userConsortiaName = remote.user.userConsortia and remote.user.userConsortia.consortiaName
    -- 雕纹全队属性
	dungeonConfig.userHeroTeamGlyphs = remote.herosUtil:getGlyphTeamProp()
	-- 噩梦副本通关记录（徽章相关）
	dungeonConfig.userNightmareDungeonPassCount = ((ENABLE_BADGE_IN_PVP or not dungeonConfig.isPVPMode) and (remote.user.nightmareDungeonPassCount or 0) or -1)
	-- 魂师暗器记录
	dungeonConfig.mountRecords = remote.user.collectedZuoqis or {}
	-- 晶石场传奇魂师列表
	dungeonConfig.legendHeroIds = remote.sparField:getLegendHeroIds()
    -- 魂灵图鉴
    dungeonConfig.userSoulSpiritCollectInfo = remote.soulSpirit:getMySoulSpiritHandBookInfoList()
    -- 解锁副本关卡
    dungeonConfig.isPassUnlockDungeon = remote.instance:checkIsPassByDungeonId("wailing_caverns_12")
    -- 全局属性
    dungeonConfig.userAttrList = QReplayUtil:getUserAttrList()
    -- --上阵神器
    -- if dungeonConfig.battleFormation then
    --     dungeonConfig.heroGodArmIdList = dungeonConfig.battleFormation.godArmIdList or {}
    -- else 
    --     dungeonConfig.heroGodArmIdList = {}
    -- end

    -- 已获取的神器
    dungeonConfig.allHeroGodArmIdList = remote.godarm:getHaveGodarmListForBattle() or {}

    dungeonConfig.userGodArmList = remote.godarm:getHaveGodarmLists() or {}

    dungeonConfig.extraProp = app.extraProp:getSelfExtraProp()

	if enemyFighter then
		-- 敌人宗门技能
		dungeonConfig.enemyConsortiaSkill = enemyFighter.consortiaSkillList or {}
		-- 敌人头像
		dungeonConfig.enemyAvatar = enemyFighter.avatar
		-- 敌人称号
		dungeonConfig.enemyTitle = enemyFighter.title
		-- 敌人头像属性
		dungeonConfig.enemyTitles = enemyFighter.userTitle
		-- 敌人考古碎片
		dungeonConfig.enemyLastEnableFragmentId = enemyFighter.archaeology and enemyFighter.archaeology.last_enable_fragment_id
		-- 敌人魂力试炼
		dungeonConfig.enemySoulTrial = enemyFighter.soulTrial
		-- 敌人战队等级
		dungeonConfig.enemyLevel = enemyFighter.level
        -- 敌人vip等级
        dungeonConfig.enemyVip = enemyFighter.vip
        -- 战力
        dungeonConfig.enemyForce = enemyFighter.force
        -- 名字
        dungeonConfig.enemyName = enemyFighter.nickname
        -- 宗门名字
        dungeonConfig.enemyConsortiaName = enemyFighter.consortiaName
		-- 敌人雕纹全队属性
		dungeonConfig.enemyHeroTeamGlyphs = enemyFighter.heroTeamGlyphs
		-- 敌人噩梦副本通关记录（徽章相关）
		dungeonConfig.enemyNightmareDungeonPassCount = ((ENABLE_BADGE_IN_PVP or not dungeonConfig.isPVPMode) and (enemyFighter.nightmareDungeonPassCount or 0) or -1)
		-- 敌人暗器记录
		dungeonConfig.pvpRivalMountRecords = enemyFighter.collectedZuoqi or {}
        -- 魂灵图鉴
        dungeonConfig.enemySoulSpiritCollectInfo = enemyFighter.soulSpiritCollectInfo or {}
        -- 额外属性
        dungeonConfig.enemyAttrList = enemyFighter.attrList or {}
        local armListInfo = {}
        for _,v in pairs(dungeonConfig.enemyAttrList.godArmList or {}) do
            table.insert(armListInfo, v.id..";"..(v.grade or 0))
        end
        dungeonConfig.allEnemyGodArmIdList = armListInfo

        dungeonConfig.enemyGodArmList = dungeonConfig.enemyAttrList.godArmList or {}
        dungeonConfig.enemyAttrList = QReplayUtil:getAttrListByFighterAttrList(dungeonConfig.enemyAttrList)

        dungeonConfig.enemyExtraProp = app.extraProp:getExtraPropByFighter(enemyFighter)

		-- 敌人龙纹图腾
		if enemyFighter.dragonDesignInfo then
		    if dungeonConfig.pvp_rivals ~= nil then
                for _,hero in ipairs(dungeonConfig.pvp_rivals) do
                    hero.totemInfos = enemyFighter.dragonDesignInfo
            end
            end
            if dungeonConfig.pvp_rivals2 ~= nil then
                for _,hero in ipairs(dungeonConfig.pvp_rivals2) do
                    hero.totemInfos = enemyFighter.dragonDesignInfo
                end
            end
            if dungeonConfig.pvp_rivals4 ~= nil then
                for _,hero in ipairs(dungeonConfig.pvp_rivals4) do
                    hero.totemInfos = enemyFighter.dragonDesignInfo
                end
            end
            if dungeonConfig.pvp_rivals6 ~= nil then
                for _,hero in ipairs(dungeonConfig.pvp_rivals6) do
                    hero.totemInfos = enemyFighter.dragonDesignInfo
                end
            end
            -- 两小队
            if dungeonConfig.pvpMultipleTeams ~= nil then
                for _, team in ipairs(dungeonConfig.pvpMultipleTeams) do
                    if team.enemy ~= nil and team.enemy.heroes ~= nil then
                        for _, hero in ipairs(team.enemy.heroes) do
                            hero.totemInfos = enemyFighter.dragonDesignInfo
                        end
                    end
                    if team.enemy ~= nil and team.enemy.supports ~= nil then
                        for _, hero in ipairs(team.enemy.supports) do
                            hero.totemInfos = enemyFighter.dragonDesignInfo
                        end
                    end
                end
            end
		end
	end

	dungeonConfig.supportSkillEnemyIndex = 1
    if dungeonConfig.pvp_rivals3 then
    	local supportSkillRival = dungeonConfig.pvp_rivals3
        for index, info in ipairs(dungeonConfig.pvp_rivals2) do
            if info.actorId == supportSkillRival.actorId then
                dungeonConfig.supportSkillEnemyIndex = index
            end
        end
    end

	dungeonConfig.supportSkillEnemyIndex2 = 1
    if dungeonConfig.pvp_rivals5 then
    	local supportSkillRival = dungeonConfig.pvp_rivals5
        for index, info in ipairs(dungeonConfig.pvp_rivals4) do
            if info.actorId == supportSkillRival.actorId then
                dungeonConfig.supportSkillEnemyIndex2 = index
            end
        end
    end

    dungeonConfig.supportSkillEnemyIndex3 = 1
    if dungeonConfig.pvp_rivals7 then
        local supportSkillRival = dungeonConfig.pvp_rivals7
        for index, info in ipairs(dungeonConfig.pvp_rivals6) do
            if info.actorId == supportSkillRival.actorId then
                dungeonConfig.supportSkillEnemyIndex3 = index
            end
        end
    end
end

-- 两队战队英雄和技能
function QBaseArrangement:_addTeamHeroSkill(dungeonConfig, rivalInfo)
    local enemyInfo = {}
    local enemyInfo2 = {}
    local skillInfo = nil
    local enemyInfo3 = {}
    local skillInfo2 = nil
    local enemyInfo4 = {}
    local skillInfo3 = nil
    local enemySoulSpirits = {}
    local enemyGodArmIdList = {}
    local enemyAlternateInfos = {}
    local enemyAlternateTargetOrder = {}

    if rivalInfo then
        if rivalInfo.heros then
            remote.herosUtil:addPeripheralSkills(rivalInfo.heros)
            if rivalInfo.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(rivalInfo.heros,false,rivalInfo.attrList.mapInfo)
            end
            for _, member in ipairs(rivalInfo.heros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(enemyInfo, info)
                    table.insert(enemyAlternateTargetOrder, info.actorId)
                end
            end
        end
        for _,soulspiritInfo in pairs(rivalInfo.soulSpirit or {})  do
            table.insert(enemySoulSpirits, self:_getSoulSpiritInfo(soulspiritInfo))
        end
        
        for _, member in ipairs(rivalInfo.godArm1List or {}) do
            local info = clone(member)
            table.insert(enemyGodArmIdList, self:_getGodarmInfo(info))
        end

        if rivalInfo.alternateHeros then
            remote.herosUtil:addPeripheralSkills(rivalInfo.alternateHeros)
            if rivalInfo.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(rivalInfo.alternateHeros,false,rivalInfo.attrList.mapInfo)
            end            
            for _, member in ipairs(rivalInfo.alternateHeros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(enemyAlternateInfos, info)
                    table.insert(enemyAlternateTargetOrder, info.actorId)
                end
            end
        end
        if rivalInfo.subheros then
            remote.herosUtil:addPeripheralSkills(rivalInfo.subheros)
            if rivalInfo.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(rivalInfo.subheros,false,rivalInfo.attrList.mapInfo)
            end            
            for _, member in ipairs(rivalInfo.subheros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(enemyInfo2, info)
                end
                if member.actorId == rivalInfo.activeSubActorId then
                    skillInfo = info
                end
            end
            if not skillInfo and #enemyInfo2 ~= 0 then
                skillInfo = enemyInfo2[1]
            end
        end
        if rivalInfo.sub2heros then
            remote.herosUtil:addPeripheralSkills(rivalInfo.sub2heros)
            if rivalInfo.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(rivalInfo.sub2heros,false,rivalInfo.attrList.mapInfo)
            end            
            for _, member in ipairs(rivalInfo.sub2heros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(enemyInfo3, info)
                end
                if member.actorId == rivalInfo.activeSub2ActorId then
                    skillInfo2 = info
                end
            end
            if not skillInfo2 and #enemyInfo3 ~= 0 then
                skillInfo2 = enemyInfo3[1]
            end
        end
        if rivalInfo.sub3heros then
            remote.herosUtil:addPeripheralSkills(rivalInfo.sub3heros)

            if rivalInfo.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(rivalInfo.sub3heros,false,rivalInfo.attrList.mapInfo)
            end      

            for _, member in ipairs(rivalInfo.sub3heros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(enemyInfo4, info)
                end
                if member.actorId == rivalInfo.activeSub3ActorId then
                    skillInfo3 = info
                end
            end
            if not skillInfo3 and #enemyInfo4 ~= 0 then
                skillInfo3 = enemyInfo4[1]
            end
        end
    end

    if dungeonConfig.pveMultipleInfos then
        for _, value in ipairs(dungeonConfig.pveMultipleInfos) do
            remote.herosUtil:addPeripheralSkills(value.heroes)
            remote.herosUtil:addPeripheralSkills(value.supports)
            if dungeonConfig.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(value.heroes,false,dungeonConfig.attrList.mapInfo)
                remote.herosUtil:addSoulSpiritOccultProp(value.supports,false,dungeonConfig.attrList.mapInfo)
            end            
        end
    end

    if dungeonConfig.pvpMultipleTeams then
        for _, value in ipairs(dungeonConfig.pvpMultipleTeams) do
            remote.herosUtil:addPeripheralSkills(value.hero.heroes)
            remote.herosUtil:addPeripheralSkills(value.hero.supports)
            remote.herosUtil:addPeripheralSkills(value.enemy.heroes)
            remote.herosUtil:addPeripheralSkills(value.enemy.supports)
            if dungeonConfig.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(value.hero.heroes,false,dungeonConfig.attrList.mapInfo)
                remote.herosUtil:addSoulSpiritOccultProp(value.hero.supports,false,dungeonConfig.attrList.mapInfo)
            end       
            if rivalInfo.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(value.enemy.heroes,false,rivalInfo.attrList.mapInfo)
                remote.herosUtil:addSoulSpiritOccultProp(value.enemy.supports,false,rivalInfo.attrList.mapInfo)    
            end   
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
    dungeonConfig.enemyGodArmIdList = enemyGodArmIdList

    remote.teamManager:sortTeam(enemyAlternateTargetOrder)
    dungeonConfig.enemyAlternateTargetOrder = enemyAlternateTargetOrder
end

function QBaseArrangement:_initSilvesDungeonConfig(dungeonConfig, userFighter, enemyFighter)
    -- 主力排序
    if userFighter and userFighter.heros then
        remote.teamManager:sortTeam(userFighter.heros, true)
    end

    if enemyFighter and enemyFighter.heros then
        remote.teamManager:sortTeam(enemyFighter.heros, true)
    end

    -- 技能
    self:_addSilvesTeamHeroSkill(dungeonConfig, userFighter, enemyFighter)
    
    -- 版本
    dungeonConfig.gameVersion = app:getBattleVersion()

    if userFighter then
        -- 我方宗门技能
        dungeonConfig.userConsortiaSkill = userFighter.consortiaSkillList or {}
        -- 我方头像
        dungeonConfig.userAvatar = userFighter.avatar
        -- 我方称号
        dungeonConfig.userTitle = userFighter.title
        -- 我方头像属性
        dungeonConfig.userTitles = userFighter.userTitle
        -- 我方考古碎片
        dungeonConfig.userLastEnableFragmentId = userFighter.archaeology and userFighter.archaeology.last_enable_fragment_id
        -- 我方魂力试炼
        dungeonConfig.userSoulTrial = userFighter.soulTrial
        -- 我方战队等级
        dungeonConfig.userLevel = userFighter.level
        -- 我方vip等级
        dungeonConfig.userVip = userFighter.vip
        -- 战力
        dungeonConfig.userForce = userFighter.force
        -- 名字
        dungeonConfig.userName = userFighter.nickname
        -- 宗门名字
        dungeonConfig.userConsortiaName = userFighter.consortiaName
        -- 我方雕纹全队属性
        dungeonConfig.userHeroTeamGlyphs = userFighter.heroTeamGlyphs
        -- 我方噩梦副本通关记录（徽章相关）
        dungeonConfig.userNightmareDungeonPassCount = ((ENABLE_BADGE_IN_PVP or not dungeonConfig.isPVPMode) and (userFighter.nightmareDungeonPassCount or 0) or -1)
        -- 我方暗器记录
        dungeonConfig.mountRecords = userFighter.collectedZuoqi or {}
        -- 魂灵图鉴
        dungeonConfig.userSoulSpiritCollectInfo = userFighter.soulSpiritCollectInfo or {}
        -- 解锁副本关卡
        dungeonConfig.isPassUnlockDungeon = remote.instance:checkIsPassByDungeonId("wailing_caverns_12")
        -- 额外属性
        dungeonConfig.userAttrList = userFighter.attrList or {}

        dungeonConfig.heroRecords = userFighter.collectedHero or {}

        local armListInfo = {}
        for _,v in pairs(dungeonConfig.userAttrList.godArmList or {}) do
            table.insert(armListInfo, v.id..";"..(v.grade or 0))
        end
        dungeonConfig.allHeroGodArmIdList = armListInfo

        dungeonConfig.userGodArmList = userFighter.attrList and userFighter.attrList.godArmList or {}
        dungeonConfig.userAttrList = QReplayUtil:getAttrListByFighterAttrList(dungeonConfig.userAttrList)

        dungeonConfig.extraProp = app.extraProp:getExtraPropByFighter(userFighter)

        -- 我方龙纹图腾
        if userFighter.dragonDesignInfo then
            if dungeonConfig.heroInfos ~= nil then
                for _,hero in ipairs(dungeonConfig.heroInfos) do
                    hero.totemInfos = userFighter.dragonDesignInfo
            end
            end
            if dungeonConfig.supportHeroInfos ~= nil then
                for _,hero in ipairs(dungeonConfig.supportHeroInfos) do
                    hero.totemInfos = userFighter.dragonDesignInfo
                end
            end
            if dungeonConfig.supportHeroInfos2 ~= nil then
                for _,hero in ipairs(dungeonConfig.supportHeroInfos2) do
                    hero.totemInfos = userFighter.dragonDesignInfo
                end
            end
            if dungeonConfig.supportHeroInfos3 ~= nil then
                for _,hero in ipairs(dungeonConfig.supportHeroInfos3) do
                    hero.totemInfos = userFighter.dragonDesignInfo
                end
            end
        end
    end

    if enemyFighter then
        -- 敌人宗门技能
        dungeonConfig.enemyConsortiaSkill = enemyFighter.consortiaSkillList or {}
        -- 敌人头像
        dungeonConfig.enemyAvatar = enemyFighter.avatar
        -- 敌人称号
        dungeonConfig.enemyTitle = enemyFighter.title
        -- 敌人头像属性
        dungeonConfig.enemyTitles = enemyFighter.userTitle
        -- 敌人考古碎片
        dungeonConfig.enemyLastEnableFragmentId = enemyFighter.archaeology and enemyFighter.archaeology.last_enable_fragment_id
        -- 敌人魂力试炼
        dungeonConfig.enemySoulTrial = enemyFighter.soulTrial
        -- 敌人战队等级
        dungeonConfig.enemyLevel = enemyFighter.level
        -- 敌人vip等级
        dungeonConfig.enemyVip = enemyFighter.vip
        -- 战力
        dungeonConfig.enemyForce = enemyFighter.force
        -- 名字
        dungeonConfig.enemyName = enemyFighter.nickname
        -- 宗门名字
        dungeonConfig.enemyConsortiaName = enemyFighter.consortiaName
        -- 敌人雕纹全队属性
        dungeonConfig.enemyHeroTeamGlyphs = enemyFighter.heroTeamGlyphs
        -- 敌人噩梦副本通关记录（徽章相关）
        dungeonConfig.enemyNightmareDungeonPassCount = ((ENABLE_BADGE_IN_PVP or not dungeonConfig.isPVPMode) and (enemyFighter.nightmareDungeonPassCount or 0) or -1)
        -- 敌人暗器记录
        dungeonConfig.pvpRivalMountRecords = enemyFighter.collectedZuoqi or {}
        -- 魂灵图鉴
        dungeonConfig.enemySoulSpiritCollectInfo = enemyFighter.soulSpiritCollectInfo or {}
        -- 额外属性
        dungeonConfig.enemyAttrList = enemyFighter.attrList or {}

        dungeonConfig.heroRecords = enemyFighter.collectedHero or {}
        
        local armListInfo = {}
        for _,v in pairs(dungeonConfig.enemyAttrList.godArmList or {}) do
            table.insert(armListInfo, v.id..";"..(v.grade or 0))
        end
        dungeonConfig.allEnemyGodArmIdList = armListInfo

        dungeonConfig.enemyGodArmList = enemyFighter.attrList and enemyFighter.attrList.godArmList or {}
        dungeonConfig.enemyAttrList = QReplayUtil:getAttrListByFighterAttrList(dungeonConfig.enemyAttrList)

        dungeonConfig.enemyExtraProp = app.extraProp:getExtraPropByFighter(enemyFighter)

        -- 敌人龙纹图腾
        if enemyFighter.dragonDesignInfo then
            if dungeonConfig.pvp_rivals ~= nil then
                for _,hero in ipairs(dungeonConfig.pvp_rivals) do
                    hero.totemInfos = enemyFighter.dragonDesignInfo
            end
            end
            if dungeonConfig.pvp_rivals2 ~= nil then
                for _,hero in ipairs(dungeonConfig.pvp_rivals2) do
                    hero.totemInfos = enemyFighter.dragonDesignInfo
                end
            end
            if dungeonConfig.pvp_rivals4 ~= nil then
                for _,hero in ipairs(dungeonConfig.pvp_rivals4) do
                    hero.totemInfos = enemyFighter.dragonDesignInfo
                end
            end
            if dungeonConfig.pvp_rivals6 ~= nil then
                for _,hero in ipairs(dungeonConfig.pvp_rivals6) do
                    hero.totemInfos = enemyFighter.dragonDesignInfo
                end
            end
        end
    end
end


-- 两队战队英雄和技能
function QBaseArrangement:_addSilvesTeamHeroSkill(dungeonConfig, userFighter, enemyFighter)
    local userInfo = {}
    local userInfo2 = {}
    local userInfo3 = {}
    local userInfo4 = {}
    local userSkillIndex = nil
    local userSkillIndex2 = nil
    local userSkillIndex3 = nil
    local userSoulSpirits = {}
    local userGodArmIdList = {}
    local userAlternateInfos = {}
    local userAlternateTargetOrder = {}

    local enemyInfo = {}
    local enemyInfo2 = {}
    local enemyInfo3 = {}
    local enemyInfo4 = {}
    local enemySkillInfo = nil
    local enemySkillInfo2 = nil
    local enemySkillInfo3 = nil
    local enemySoulSpirits = {}
    local enemyGodArmIdList = {}
    local enemyAlternateInfos = {}
    local enemyAlternateTargetOrder = {}
    local supportSkillEnemyIndex = nil
    local supportSkillEnemyIndex2 = nil
    local supportSkillEnemyIndex3 = nil

    if userFighter then
        if userFighter.heros then
            remote.herosUtil:addPeripheralSkills(userFighter.heros)
            if userFighter.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(userFighter.heros,false,userFighter.attrList.mapInfo)
            end
            for _, member in ipairs(userFighter.heros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(userInfo, info)
                    table.insert(userAlternateTargetOrder, info.actorId)
                end
            end
        end
        for _,soulspiritInfo in pairs(userFighter.soulSpirit or {})  do
            table.insert(userSoulSpirits, self:_getSoulSpiritInfo(soulspiritInfo))
        end
        
        for _, member in ipairs(userFighter.godArm1List or {}) do
            local info = clone(member)
            table.insert(userGodArmIdList, self:_getGodarmInfo(info))
        end

        if userFighter.alternateHeros then
            remote.herosUtil:addPeripheralSkills(userFighter.alternateHeros)
            if userFighter.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(userFighter.alternateHeros,false,userFighter.attrList.mapInfo)
            end            
            for _, member in ipairs(userFighter.alternateHeros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(userAlternateInfos, info)
                    table.insert(userAlternateTargetOrder, info.actorId)
                end
            end
        end
        if userFighter.subheros then
            remote.herosUtil:addPeripheralSkills(userFighter.subheros)
            if userFighter.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(userFighter.subheros,false,userFighter.attrList.mapInfo)
            end            
            for index, member in ipairs(userFighter.subheros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(userInfo2, info)
                end
                if member.actorId == userFighter.activeSubActorId then
                    userSkillIndex = index
                end
            end
            if not userSkillIndex and #userInfo2 ~= 0 then
                userSkillIndex = 1
            end
        end
        if userFighter.sub2heros then
            remote.herosUtil:addPeripheralSkills(userFighter.sub2heros)
            if userFighter.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(userFighter.sub2heros,false,userFighter.attrList.mapInfo)
            end            
            for index, member in ipairs(userFighter.sub2heros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(userInfo3, info)
                end
                if member.actorId == userFighter.activeSub2ActorId then
                    userSkillIndex2 = index
                end
            end
            if not userSkillIndex2 and #userInfo3 ~= 0 then
                userSkillIndex2 = 1
            end
        end
        if userFighter.sub3heros then
            remote.herosUtil:addPeripheralSkills(userFighter.sub3heros)

            if userFighter.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(userFighter.sub3heros,false,userFighter.attrList.mapInfo)
            end      

            for index, member in ipairs(userFighter.sub3heros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(userInfo4, info)
                end
                if member.actorId == userFighter.activeSub3ActorId then
                    userSkillIndex3 = index
                end
            end
            if not userSkillIndex3 and #userInfo4 ~= 0 then
                userSkillIndex3 = 1
            end
        end
    end

    if enemyFighter then
        if enemyFighter.heros then
            remote.herosUtil:addPeripheralSkills(enemyFighter.heros)
            if enemyFighter.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(enemyFighter.heros,false,enemyFighter.attrList.mapInfo)
            end
            for _, member in ipairs(enemyFighter.heros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(enemyInfo, info)
                    table.insert(enemyAlternateTargetOrder, info.actorId)
                end
            end
        end
        for _,soulspiritInfo in pairs(enemyFighter.soulSpirit or {})  do
            table.insert(enemySoulSpirits, self:_getSoulSpiritInfo(soulspiritInfo))
        end
        
        for _, member in ipairs(enemyFighter.godArm1List or {}) do
            local info = clone(member)
            table.insert(enemyGodArmIdList, self:_getGodarmInfo(info))
        end

        if enemyFighter.alternateHeros then
            remote.herosUtil:addPeripheralSkills(enemyFighter.alternateHeros)
            if enemyFighter.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(enemyFighter.alternateHeros,false,enemyFighter.attrList.mapInfo)
            end            
            for _, member in ipairs(enemyFighter.alternateHeros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(enemyAlternateInfos, info)
                    table.insert(enemyAlternateTargetOrder, info.actorId)
                end
            end
        end
        if enemyFighter.subheros then
            remote.herosUtil:addPeripheralSkills(enemyFighter.subheros)
            if enemyFighter.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(enemyFighter.subheros,false,enemyFighter.attrList.mapInfo)
            end            
            for index, member in ipairs(enemyFighter.subheros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(enemyInfo2, info)
                end
                if member.actorId == enemyFighter.activeSubActorId then
                    enemySkillInfo = info
                    supportSkillEnemyIndex = index
                end
            end
            if not enemySkillInfo and #enemyInfo2 ~= 0 then
                enemySkillInfo = enemyInfo2[1]
                supportSkillEnemyIndex = 1
            end
        end
        if enemyFighter.sub2heros then
            remote.herosUtil:addPeripheralSkills(enemyFighter.sub2heros)
            if enemyFighter.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(enemyFighter.sub2heros,false,enemyFighter.attrList.mapInfo)
            end            
            for index, member in ipairs(enemyFighter.sub2heros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(enemyInfo3, info)
                end
                if member.actorId == enemyFighter.activeSub2ActorId then
                    enemySkillInfo2 = info
                    supportSkillEnemyIndex2 = index
                end
            end
            if not enemySkillInfo2 and #enemyInfo3 ~= 0 then
                enemySkillInfo2 = enemyInfo3[1]
                supportSkillEnemyIndex2 = 1
            end
        end
        if enemyFighter.sub3heros then
            remote.herosUtil:addPeripheralSkills(enemyFighter.sub3heros)

            if enemyFighter.attrList then
                remote.herosUtil:addSoulSpiritOccultProp(enemyFighter.sub3heros,false,enemyFighter.attrList.mapInfo)
            end      

            for index, member in ipairs(enemyFighter.sub3heros) do
                local info = clone(member)
                if info.currHp == nil or info.currHp > 0 then
                    table.insert(enemyInfo4, info)
                end
                if member.actorId == enemyFighter.activeSub3ActorId then
                    enemySkillInfo3 = info
                    supportSkillEnemyIndex3 = index
                end
            end
            if not enemySkillInfo3 and #enemyInfo4 ~= 0 then
                enemySkillInfo3 = enemyInfo4[1]
                supportSkillEnemyIndex3 = 1
            end
        end
    end


    dungeonConfig.pvp_rivals = enemyInfo
    dungeonConfig.pvp_rivals2 = enemyInfo2
    dungeonConfig.pvp_rivals3 = enemySkillInfo
    dungeonConfig.pvp_rivals4 = enemyInfo3
    dungeonConfig.pvp_rivals5 = enemySkillInfo2
    dungeonConfig.pvp_rivals6 = enemyInfo4
    dungeonConfig.pvp_rivals7 = enemySkillInfo3
    dungeonConfig.enemySoulSpirits = enemySoulSpirits
    dungeonConfig.enemyAlternateInfos = enemyAlternateInfos
    dungeonConfig.enemyGodArmIdList = enemyGodArmIdList
    dungeonConfig.supportSkillEnemyIndex = supportSkillEnemyIndex
    dungeonConfig.supportSkillEnemyIndex2 = supportSkillEnemyIndex2
    dungeonConfig.supportSkillEnemyIndex3 = supportSkillEnemyIndex3

    remote.teamManager:sortTeam(enemyAlternateTargetOrder)
    dungeonConfig.enemyAlternateTargetOrder = enemyAlternateTargetOrder


    dungeonConfig.heroInfos = userInfo
    dungeonConfig.supportHeroInfos = userInfo2
    dungeonConfig.supportSkillHeroIndex = userSkillIndex
    dungeonConfig.supportHeroInfos2 = userInfo3
    dungeonConfig.supportSkillHeroIndex2 = userSkillIndex2
    dungeonConfig.supportHeroInfos3 = userInfo4
    dungeonConfig.supportSkillHeroIndex3 = userSkillIndex3
    dungeonConfig.userSoulSpirits = userSoulSpirits
    dungeonConfig.userAlternateInfos = userAlternateInfos
    dungeonConfig.heroGodArmIdList = userGodArmIdList

    remote.teamManager:sortTeam(userAlternateTargetOrder)
    dungeonConfig.userAlternateTargetOrder = userAlternateTargetOrder
end

function QBaseArrangement:_addUserHeroes(dungeonConfig)
    local teamName = remote.teamManager.INSTANCE_TEAM
    if dungeonConfig.teamName ~= nil then
        teamName = dungeonConfig.teamName
    end
    dungeonConfig.heroInfos = {}
    dungeonConfig.userAlternateInfos = {}
    dungeonConfig.supportHeroInfos = {}
    dungeonConfig.supportHeroInfos2 = {}
    dungeonConfig.supportHeroInfos3 = {}
    dungeonConfig.userSoulSpirits = {}
    dungeonConfig.heroGodArmIdList = {}

    local userAlternateTargetOrder = {}

    -- 主力
    for k, heroId in ipairs(remote.teamManager:getActorIdsByKey(teamName, 1)) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(dungeonConfig.heroInfos, heroInfo)
        table.insert(userAlternateTargetOrder, heroId)
    end
    -- 替补
    for k, heroId in ipairs(remote.teamManager:getAlternateIdsByKey(teamName, 1)) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(dungeonConfig.userAlternateInfos, heroInfo)
        table.insert(userAlternateTargetOrder, heroId)
    end
    -- 援助1
    local supports = remote.teamManager:getActorIdsByKey(teamName, 2)
    for k, heroId in ipairs(supports) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(dungeonConfig.supportHeroInfos, heroInfo)
    end
    -- 副将2的获取
    local supports2 = remote.teamManager:getActorIdsByKey(teamName, 3)
    for k, heroId in ipairs(supports2) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(dungeonConfig.supportHeroInfos2, heroInfo)
    end
    -- 副将3的获取
    local supports3 = remote.teamManager:getActorIdsByKey(teamName, 4)
    for k, heroId in ipairs(supports3) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(dungeonConfig.supportHeroInfos3, heroInfo)
    end
    -- 魂灵
    local soulSpiritIds = remote.teamManager:getSpiritIdsByKey(teamName, 1)
    for i, soulSpiritId in ipairs(soulSpiritIds) do
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
        table.insert(dungeonConfig.userSoulSpirits, self:_getSoulSpiritInfo(soulSpiritInfo))
    end

    --神器
    local godarmList = remote.teamManager:getGodArmIdsByKey(teamName,5)
    for i,godarmId in ipairs(godarmList) do
        local godarmInfo = remote.godarm:getGodarmById(godarmId)
        table.insert(dungeonConfig.heroGodArmIdList,self:_getGodarmInfo(godarmInfo))
    end
    
    -- 非3v3技能副将1
    local skillSupports = remote.teamManager:getSkillByKey(teamName, 2)
    local supportSkillHeroIndex = table.indexof(supports, skillSupports[1]) or 1
    dungeonConfig.supportSkillHeroIndex = supportSkillHeroIndex
    -- 非3v3技能副将2
    local skillSupports2 = remote.teamManager:getSkillByKey(teamName, 3)
    local supportSkillHeroIndex2 = table.indexof(supports2, skillSupports2[1]) or 1
    dungeonConfig.supportSkillHeroIndex2 = supportSkillHeroIndex2
    -- 非3v3技能副将3
    local skillSupports3 = remote.teamManager:getSkillByKey(teamName, 4)
    local supportSkillHeroIndex3 = table.indexof(supports3, skillSupports3[1]) or 1
    dungeonConfig.supportSkillHeroIndex3 = supportSkillHeroIndex3

    remote.teamManager:sortTeam(userAlternateTargetOrder)
    dungeonConfig.userAlternateTargetOrder = userAlternateTargetOrder
    
    -- 新手引导中加入的新英雄，阑尾
    if remote.teamManager._joinHero then
        for _, joinHeroId in pairs(remote.teamManager._joinHero) do
            local already_there = false
            for k, heroId in ipairs(remote.teamManager:getActorIdsByKey(teamName, 1)) do
                if heroId == joinHeroId then
                    already_there = true
                    break
                end
            end
            if not already_there then
                local heroInfo = remote.teamManager._joinHeroInfo or remote.herosUtil:getHeroByID(joinHeroId)
                heroInfo = clone(heroInfo)
                table.insert(dungeonConfig.heroInfos, heroInfo)
            end
        end
    end
end

--
function QBaseArrangement:addOtherPropForArena(fighter)
	-- 宗门技能
	if not fighter then
		return
	end
	local archaeologyProp = {}
    local avatarProp = {}
    local unionSkillProp = {}
    if fighter.archaeology ~= nil then
        archaeologyProp = getArchaeologyPropByFragmentID(fighter.archaeology.last_enable_fragment_id)
    end 
    avatarProp = QStaticDatabase:sharedDatabase():calculateAvatarProp(fighter.avatar, fighter.title)
    if fighter.consortiaSkillList then
        unionSkillProp = remote.union:getUnionSkillProp(fighter.consortiaSkillList)
    end

    if fighter.heros ~= nil then
        for _,hero in ipairs(fighter.heros) do
            hero.archaeologyProp = archaeologyProp
            hero.avatarProp = avatarProp
            hero.unionSkillProp = unionSkillProp
        end
    end
    if fighter.alternateInfos ~= nil then
        for _,hero in ipairs(fighter.alternateInfos) do
            hero.archaeologyProp = archaeologyProp
            hero.avatarProp = avatarProp
            hero.unionSkillProp = unionSkillProp
        end
    end
    if fighter.subheros ~= nil then
        for _,hero in ipairs(fighter.subheros) do
            hero.archaeologyProp = archaeologyProp
            hero.avatarProp = avatarProp
            hero.unionSkillProp = unionSkillProp
        end
    end
    if fighter.sub2heros ~= nil then
        for _,hero in ipairs(fighter.sub2heros) do
            hero.archaeologyProp = archaeologyProp
            hero.avatarProp = avatarProp
            hero.unionSkillProp = unionSkillProp
        end
    end
    if fighter.sub3heros ~= nil then
        for _,hero in ipairs(fighter.sub3heros) do
            hero.archaeologyProp = archaeologyProp
            hero.avatarProp = avatarProp
            hero.unionSkillProp = unionSkillProp
        end
    end
end


function QBaseArrangement:_constructAttackHero(index)
	if index == nil then 
		index = 1
	end
    local attackHeroInfo = {}
    for k, v in ipairs(remote.teamManager:getActorIdsByKey(self._teamKey, index)) do
        local heroInfo = remote.herosUtil:getHeroByID(v)
        table.insert(attackHeroInfo, heroInfo)
    end

    return attackHeroInfo
end

function QBaseArrangement:_getHeroInfo(heroInfo)
    return QMyAppUtils:getHeroInfo(heroInfo)
end

function QBaseArrangement:_getSoulSpiritInfo(soulSpiritInfo)
    return QMyAppUtils:getBaseSoulSpiritInfo(soulSpiritInfo)
end

function QBaseArrangement:_getGodarmInfo(godarmInfo)
    return QMyAppUtils:getGodarmInfo(godarmInfo)
end
return QBaseArrangement
