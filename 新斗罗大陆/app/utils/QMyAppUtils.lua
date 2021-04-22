--
-- Author: zxs
-- Myapp Utils
--
local QMyAppUtils = {}

function QMyAppUtils.generateMaigcHerbInfo(heroInfo)
    if heroInfo.magicHerbs then
        local magicHerbs = {}
        for i,v in ipairs(heroInfo.magicHerbs) do
            local magicHerb = {}
            magicHerb.sid = v.sid
            magicHerb.itemId = v.itemId
            magicHerb.level = v.level
            magicHerb.grade = v.grade
            magicHerb.breedLevel = v.breedLevel
            magicHerb.attributes = v.attributes
            table.insert(magicHerbs, magicHerb)
        end
        return magicHerbs
    end
    return nil
end

function QMyAppUtils:getProp(propInfo)
    local _prop = {}
    _prop.attack_value = propInfo.attack_value
    _prop.attack_percent = propInfo.attack_percent
    _prop.hp_value = propInfo.hp_value
    _prop.hp_percent = propInfo.hp_percent
    _prop.armor_physical = propInfo.armor_physical
    _prop.armor_magic = propInfo.armor_magic
    _prop.hit_rating = propInfo.hit_rating
    _prop.hit_chance = propInfo.hit_chance
    _prop.dodge_rating = propInfo.dodge_rating
    _prop.dodge_chance = propInfo.dodge_chance
    _prop.block_rating = propInfo.block_rating
    _prop.block_chance = propInfo.block_chance
    _prop.critical_rating = propInfo.critical_rating
    _prop.critical_chance = propInfo.critical_chance
    _prop.critical_damage = propInfo.critical_damage
    _prop.cri_reduce_rating = propInfo.cri_reduce_rating
    _prop.cri_reduce_chance = propInfo.cri_reduce_chance
    _prop.movespeed_value = propInfo.movespeed_value
    _prop.movespeed_percent = propInfo.movespeed_percent
    _prop.haste_rating = propInfo.haste_rating
    _prop.attackspeed_chance = propInfo.attackspeed_chance
    _prop.physical_damage_percent_attack = propInfo.physical_damage_percent_attack
    _prop.physical_damage_percent_beattack = propInfo.physical_damage_percent_beattack
    _prop.physical_damage_percent_beattack_reduce = propInfo.physical_damage_percent_beattack_reduce
    _prop.magic_damage_percent_attack =  propInfo.magic_damage_percent_attack
    _prop.magic_damage_percent_beattack =  propInfo.magic_damage_percent_beattack
    _prop.magic_damage_percent_beattack_reduce = propInfo.magic_damage_percent_beattack_reduce
    _prop.magic_treat_percent_attack = propInfo.magic_treat_percent_attack
    _prop.magic_treat_percent_beattack = propInfo.magic_treat_percent_beattack
    _prop.pvp_physical_damage_percent_beattack_reduce = propInfo.pvp_physical_damage_percent_beattack_reduce
    _prop.pvp_magic_damage_percent_beattack_reduce = propInfo.pvp_magic_damage_percent_beattack_reduce
    _prop.pvp_physical_damage_percent_attack = propInfo.pvp_physical_damage_percent_attack
    _prop.pvp_magic_damage_percent_attack = propInfo.pvp_magic_damage_percent_attack
    return _prop
end

function QMyAppUtils:getBaseHeroInfo(heroInfo)
    local info = {}
    info.actorId = heroInfo.actorId
    info.level = heroInfo.level
    info.breakthrough = heroInfo.breakthrough
    info.grade = heroInfo.grade
    info.force = heroInfo.force
    info.skinId = heroInfo.skinId
    info.godSkillGrade = heroInfo.godSkillGrade
    return info
end

--前端统一构造战斗魂灵数值时处理额外数据使用
function QMyAppUtils:getBaseSoulSpiritInfo(soulSpiritInfo)
    soulSpiritInfo.addCoefficient = self:getSoulSpiritAddCoefficient(soulSpiritInfo)
    soulSpiritInfo.additionSkills = self:getSoulSpiritAddition(soulSpiritInfo) or {}
    return self:getSoulSpiritInfo(soulSpiritInfo)
end


function QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo)
    local info = {}
    info.id = soulSpiritInfo.id
    info.grade = soulSpiritInfo.grade
    info.level = soulSpiritInfo.level
    info.exp = soulSpiritInfo.exp
    info.currMp = soulSpiritInfo.currMp
    info.force = soulSpiritInfo.force
    info.soulSpiritMapInfo = soulSpiritInfo.soulSpiritMapInfo
    info.addCoefficient = soulSpiritInfo.addCoefficient
    info.additionSkills = soulSpiritInfo.additionSkills or {}
    info.devour_level = soulSpiritInfo.devour_level
    return info
end

function QMyAppUtils:getSoulSpiritAddCoefficient(data)
    local result = 0

    if not data then
        return result
    end
    local characterConfig = db:getCharacterByID(data.id)

    local constantCoefficient = 0.25
    local aptitudeCoefficient = 0
    local sabcInfo = db:getSABCByQuality(characterConfig.aptitude)
    if sabcInfo then
        local key = sabcInfo.qc.."_SOUL_COMBAT_SUCCESSION"
        aptitudeCoefficient = db:getConfigurationValue(key) or 0
    end
    local num = constantCoefficient * aptitudeCoefficient

    result = result + num
    local curGradeConfig = db:getGradeByHeroActorLevel(data.id, data.grade)
    if curGradeConfig and curGradeConfig.soul_combat_succession then
        result = result + curGradeConfig.soul_combat_succession
    end

    local awaken_level = data.awaken_level or 0
    local curAwakenConfig = db:getSoulSpiritAwakenConfig(awaken_level,characterConfig.aptitude)
    if curAwakenConfig and curAwakenConfig.conmbat_succession then
        result = result + curAwakenConfig.conmbat_succession
    end

    return  result
end

function QMyAppUtils:getSoulSpiritAddition(data)
    local devourLv = data.devour_level or 0
    local inheritMod = db:getSoulSpiritInheritConfig(devourLv ,data.id)
    local  additionSkills = {}
    if inheritMod and inheritMod.skill then
        local  skillIdVec = string.split(inheritMod.skill, ";")
        for i,v in ipairs(skillIdVec or {}) do
            local  skillIdValue = string.split(inheritMod.skill, ":")
            if skillIdValue[1] and skillIdValue[2] then
                local skill = {key = skillIdValue[1] , value=skillIdValue[2]}
                table.insert(additionSkills ,skill)
            end
        end
    end
    return additionSkills
end


function QMyAppUtils:getGodarmInfo(godarmInfo)
    -- local info = {}
    -- info.id = godarmInfo.id
    -- info.grade = godarmInfo.grade
    -- info.level = godarmInfo.level
    -- info.exp = godarmInfo.exp
    -- info.force = godarmInfo.main_force
    return tostring(godarmInfo.id..";"..(godarmInfo.grade or 0))
end

function QMyAppUtils:getBaseGodarmInfo(godarmInfo)
    local info = {}
    info.id = godarmInfo.id
    info.grade = godarmInfo.grade
    info.level = godarmInfo.level
    info.exp = godarmInfo.exp
    info.force = godarmInfo.main_force
    return info
end


function QMyAppUtils:getHeroInfo(heroInfo)
    local info = self:getBaseHeroInfo(heroInfo)
    -- info.rankCode = heroInfo.rankCode
    info.equipments = heroInfo.equipments or {}
    info.slots = heroInfo.slots or {}
    info.trainAttr = heroInfo.trainAttr
    info.peripheralSkills = heroInfo.peripheralSkills or {}
    info.skills = heroInfo.skills or {}
    info.currHp = heroInfo.currHp
    info.currMp = heroInfo.currMp
    info.heroInfoInSunwell = heroInfo.heroInfoInSunwell
    info.zuoqi = heroInfo.zuoqi
    info.refineAttrs = heroInfo.refineAttrs or {}
    info.artifact = heroInfo.artifact
    if heroInfo.soulSpirit then
        info.soulSpirit = self:getSoulSpiritInfo(heroInfo.soulSpirit)
    end
    info.totemInfos = heroInfo.totemInfos or {}
    info.magicHerbs = QMyAppUtils.generateMaigcHerbInfo(heroInfo)
    info.spar = {}
    for _, v in ipairs(heroInfo.spar or {}) do
        table.insert(info.spar, {sparId = v.sparId, itemId = v.itemId, level = v.level,
            grade = v.grade, exp = v.exp, actorId = v.actorId, inheritLv = v.inheritLv})
    end
    if heroInfo.archaeologyProp then
        info.archaeologyProp = self:getProp(heroInfo.archaeologyProp)
    end
    if heroInfo.unionSkillProp then
        info.unionSkillProp = self:getProp(heroInfo.unionSkillProp)
    end
    if heroInfo.avatarProp then
        info.avatarProp = self:getProp(heroInfo.avatarProp)
    end
    info.glyphs = {}
    for _, glyph in ipairs(heroInfo.glyphs or {}) do
        info.glyphs[#info.glyphs + 1] = {glyphId = glyph.glyphId, level = glyph.level}
    end
    info.gemstones = {}
    for _, gemstone in ipairs(heroInfo.gemstones or {}) do
        info.gemstones[#info.gemstones + 1] = {sid = gemstone.sid, itemId = gemstone.itemId, level = gemstone.level, craftLevel = gemstone.craftLevel,godLevel = gemstone.godLevel
        ,mix_level = gemstone.mix_level}
    end
    return info
end

function QMyAppUtils:generateDungeonConfig(dungeonConfig)
    -- 我方
    local heroInfoes = {}
    for _, heroInfo in ipairs(dungeonConfig.heroInfos or {}) do
        table.insert(heroInfoes, QMyAppUtils:getHeroInfo(heroInfo))
    end
    local userAlternateInfos = {}
    for _, heroInfo in ipairs(dungeonConfig.userAlternateInfos or {}) do
        table.insert(userAlternateInfos, QMyAppUtils:getHeroInfo(heroInfo))
    end
    local supportHeroInfos = {}
    for _, heroInfo in ipairs(dungeonConfig.supportHeroInfos or {}) do
        table.insert(supportHeroInfos, QMyAppUtils:getHeroInfo(heroInfo))
    end
    local supportHeroInfos2 = {}
    for _, heroInfo in ipairs(dungeonConfig.supportHeroInfos2 or {}) do
        table.insert(supportHeroInfos2, QMyAppUtils:getHeroInfo(heroInfo))
    end
    local supportHeroInfos3 = {}
    for _, heroInfo in ipairs(dungeonConfig.supportHeroInfos3 or {}) do
        table.insert(supportHeroInfos3, QMyAppUtils:getHeroInfo(heroInfo))
    end
    local userSoulSpirits = {} 
    for _, soulSpiritInfo in ipairs(dungeonConfig.userSoulSpirits or {}) do
        table.insert(userSoulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
    end

    -- 敌方
    local pvp_rivals = {}
    for _, enemyInfo in ipairs(dungeonConfig.pvp_rivals or {}) do
        table.insert(pvp_rivals, QMyAppUtils:getHeroInfo(enemyInfo))
    end
    local pvp_rivals2 = {}
    for _, enemyInfo in ipairs(dungeonConfig.pvp_rivals2 or {}) do
        table.insert(pvp_rivals2, QMyAppUtils:getHeroInfo(enemyInfo))
    end
    local pvp_rivals3 
    if dungeonConfig.pvp_rivals3 ~= nil then
        pvp_rivals3 = QMyAppUtils:getHeroInfo(dungeonConfig.pvp_rivals3)
    end
    local pvp_rivals4 = {}
    for _, enemyInfo in ipairs(dungeonConfig.pvp_rivals4 or {}) do
        table.insert(pvp_rivals4, QMyAppUtils:getHeroInfo(enemyInfo))
    end
    local pvp_rivals5
    if dungeonConfig.pvp_rivals5 ~= nil then
        pvp_rivals5 = QMyAppUtils:getHeroInfo(dungeonConfig.pvp_rivals5)
    end
    local pvp_rivals6 = {}
    for _, enemyInfo in ipairs(dungeonConfig.pvp_rivals6 or {}) do
        table.insert(pvp_rivals6, QMyAppUtils:getHeroInfo(enemyInfo))
    end
    local pvp_rivals7
    if dungeonConfig.pvp_rivals7 ~= nil then
        pvp_rivals7 = QMyAppUtils:getHeroInfo(dungeonConfig.pvp_rivals7)
    end
    local enemySoulSpirits = {} 
    for _, soulSpiritInfo in ipairs(dungeonConfig.enemySoulSpirits or {}) do
        table.insert(enemySoulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
    end
    local enemyAlternateInfos = {}
    for _, heroInfo in ipairs(dungeonConfig.enemyAlternateInfos or {}) do
        table.insert(enemyAlternateInfos, QMyAppUtils:getHeroInfo(heroInfo))
    end

    local pvpMultipleTeams = {}
    if dungeonConfig.pvpMultipleTeams then
        for i,info in ipairs(dungeonConfig.pvpMultipleTeams) do
            local t = {hero = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}}, 
                    enemy = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}}}
            for k,heroInfo in ipairs(info.hero.heroes or {}) do
                table.insert(t.hero.heroes, QMyAppUtils:getHeroInfo(heroInfo))
            end
            for k,heroInfo in ipairs(info.hero.supports or {}) do
                table.insert(t.hero.supports, QMyAppUtils:getHeroInfo(heroInfo))
            end
            for k,soulSpiritInfo in ipairs(info.hero.soulSpirits or {}) do
                table.insert(t.hero.soulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
            end
            for k,godArmIdList in ipairs(info.hero.godArmIdList or {}) do
                table.insert(t.hero.godArmIdList, godArmIdList)
            end

            for k,heroInfo in ipairs(info.enemy.heroes or {}) do
                table.insert(t.enemy.heroes, QMyAppUtils:getHeroInfo(heroInfo))
            end
            for k,heroInfo in ipairs(info.enemy.supports or {}) do
                table.insert(t.enemy.supports, QMyAppUtils:getHeroInfo(heroInfo))
            end
            for k,soulSpiritInfo in ipairs(info.enemy.soulSpirits or {}) do
                table.insert(t.enemy.soulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
            end
            for k,godArmIdList in ipairs(info.enemy.godArmIdList or {}) do
                table.insert(t.enemy.godArmIdList, godArmIdList)
            end

            t.hero.force = info.hero.force
            t.hero.supportSkillHeroIndex = info.hero.supportSkillHeroIndex
            t.hero.supportSkillHeroIndex2 = info.hero.supportSkillHeroIndex2
            t.enemy.force = info.enemy.force
            t.enemy.supportSkillHeroIndex = info.enemy.supportSkillHeroIndex
            t.enemy.supportSkillHeroIndex2 = info.enemy.supportSkillHeroIndex2
            table.insert(pvpMultipleTeams, t)
        end
    end

    local dungeon = {}
    dungeon.dungeon_id = dungeonConfig.int_id
    dungeon.heroInfos = heroInfoes
    dungeon.pvp_rivals = pvp_rivals
    dungeon.isPVPMode = dungeonConfig.isPVPMode 
    dungeon.isPVPMultipleWave = dungeonConfig.isPVPMultipleWave
    dungeon.isPveMultiple = dungeonConfig.isPveMultiple
    dungeon.isArena = dungeonConfig.isArena
    dungeon.isSunwell = dungeonConfig.isSunwell
    dungeon.isGlory = dungeonConfig.isGlory
    dungeon.isStormArena = dungeonConfig.isStormArena
    dungeon.isSparField = dungeonConfig.isSparField
    dungeon.isMaritime = dungeonConfig.isMaritime
    dungeon.isMetalCity = dungeonConfig.isMetalCity
    dungeon.isFightClub = dungeonConfig.isFightClub
    dungeon.team1Name = dungeonConfig.team1Name
    dungeon.team1Icon = dungeonConfig.team1Icon
    dungeon.team2Name = dungeonConfig.team2Name
    dungeon.team2Icon = dungeonConfig.team2Icon
    dungeon.supportHeroInfos = supportHeroInfos
    dungeon.supportHeroInfos2 = supportHeroInfos2
    dungeon.supportHeroInfos3 = supportHeroInfos3
    dungeon.userSoulSpirits = userSoulSpirits
    dungeon.userAlternateInfos = userAlternateInfos
    dungeon.replay_pseudo_id = dungeonConfig.replay_pseudo_id
    dungeon.pvp_rivals2 = pvp_rivals2
    dungeon.pvp_rivals3 = pvp_rivals3
    dungeon.pvp_rivals4 = pvp_rivals4
    dungeon.pvp_rivals5 = pvp_rivals5
    dungeon.pvp_rivals6 = pvp_rivals6
    dungeon.pvp_rivals7 = pvp_rivals7
    dungeon.enemySoulSpirits = enemySoulSpirits
    dungeon.enemyAlternateInfos = enemyAlternateInfos
    dungeon.pvpMultipleTeams = pvpMultipleTeams
    dungeon.isPvpMultipleNew = dungeonConfig.isPvpMultipleNew
    dungeon.pveMultipleInfos = dungeonConfig.pveMultipleInfos
    dungeon.pveMultipleWave = dungeonConfig.pveMultipleWave
    dungeon.battleRandomNPC = dungeonConfig.battleRandomNPC or {}
    dungeon.battleProbability = dungeonConfig.battleProbability or {}
    dungeon.heroRecords = dungeonConfig.heroRecords or {}
    dungeon.pvpRivalHeroRecords = dungeonConfig.pvpRivalHeroRecords or {}
    dungeon.buffs = dungeonConfig.buffs or {}
    dungeon.isInRebelFight = dungeonConfig.isInRebelFight
    dungeon.rebelAttackPercent = dungeonConfig.rebelAttackPercent
    dungeon.rebelID = tonumber(dungeonConfig.rebelID)
    dungeon.rebelLevel = dungeonConfig.rebelLevel
    dungeon.rebelDisplayLevel = dungeonConfig.rebelDisplayLevel
    dungeon.rebelHP = dungeonConfig.rebelHP
    dungeon.isInWorldBossFight = dungeonConfig.isInWorldBossFight
    dungeon.worldBossAttackPercent = dungeonConfig.worldBossAttackPercent
    dungeon.worldBossID = tonumber(dungeonConfig.worldBossID)
    dungeon.worldBossLevel = dungeonConfig.worldBossLevel
    dungeon.worldBossDisplayLevel = dungeonConfig.worldBossDisplayLevel
    dungeon.worldBossHP = dungeonConfig.worldBossHP
    dungeon.worldBossBuffList = dungeonConfig.worldBossBuffList or {}
    dungeon.isRecommend = dungeonConfig.isRecommend
    dungeon.force = dungeonConfig.force
    dungeon.enemyForce = dungeonConfig.enemyForce
    dungeon.isEasy = dungeonConfig.isEasy
    dungeon.lostCount = dungeonConfig.lostCount
    dungeon.isActiveDungeon = dungeonConfig.isGlory
    dungeon.activeDungeonType = dungeonConfig.activeDungeonType
    dungeon.sunwarChapter = dungeonConfig.sunwarChapter
    dungeon.sunwarWave = dungeonConfig.sunwarWave
    dungeon.sunwarTodayPassedWaveCount = dungeonConfig.sunwarTodayPassedWaveCount
    dungeon.sunwarBonusForDefender = dungeonConfig.sunwarBonusForDefender
    dungeon.isSocietyDungeon = dungeonConfig.isSocietyDungeon
    dungeon.societyDungeonChapter = dungeonConfig.societyDungeonChapter
    dungeon.societyDungeonWave = dungeonConfig.societyDungeonWave
    dungeon.societyDungeonBossID = dungeonConfig.societyDungeonBossID
    dungeon.societyDungeonBossLevel = dungeonConfig.societyDungeonBossLevel
    dungeon.societyDungeonBossHp = dungeonConfig.societyDungeonBossHp
    dungeon.societyDungeonLittleMonster = dungeonConfig.societyDungeonLittleMonster
    dungeon.isSilverMine = dungeonConfig.isSilverMine
    dungeon.isSectHunting = dungeonConfig.isSectHunting
    dungeon.mineId = dungeonConfig.mineId
    dungeon.mineOwnerId = dungeonConfig.mineOwnerId
    -- todo other battle modules
    dungeon.battleDT = dungeonConfig.battleDT
    dungeon.userConsortiaSkill = dungeonConfig.userConsortiaSkill or {}
    dungeon.userAvatar = dungeonConfig.userAvatar
    dungeon.userLastEnableFragmentId = dungeonConfig.userLastEnableFragmentId
    dungeon.userSoulTrial = dungeonConfig.userSoulTrial
    dungeon.enemyConsortiaSkill = dungeonConfig.enemyConsortiaSkill or {}
    dungeon.enemyAvatar = dungeonConfig.enemyAvatar
    dungeon.enemyLastEnableFragmentId = dungeonConfig.enemyLastEnableFragmentId
    dungeon.enemySoulTrial = dungeonConfig.enemySoulTrial
    dungeon.userLevel = dungeonConfig.userLevel
    dungeon.enemyLevel = dungeonConfig.enemyLevel
    dungeon.userTitle = dungeonConfig.userTitle
    dungeon.userTitles = dungeonConfig.userTitles
    dungeon.enemyTitle = dungeonConfig.enemyTitle
    dungeon.enemyTitles = dungeonConfig.enemyTitles
    dungeon.userAttrList = dungeonConfig.userAttrList
    dungeon.enemyAttrList = dungeonConfig.enemyAttrList
    dungeon.userNightmareDungeonPassCount = dungeonConfig.userNightmareDungeonPassCount or 0
    dungeon.enemyNightmareDungeonPassCount = dungeonConfig.enemyNightmareDungeonPassCount or 0
    dungeon.userHeroTeamGlyphs = dungeonConfig.userHeroTeamGlyphs or {}
    dungeon.enemyHeroTeamGlyphs = dungeonConfig.enemyHeroTeamGlyphs or {}
    dungeon.mountRecords = dungeonConfig.mountRecords or {}
    dungeon.pvpRivalMountRecords = dungeonConfig.pvpRivalMountRecords or {}
    dungeon.heroesHp = dungeonConfig.heroesHp or {}
    dungeon.monstersHp = dungeonConfig.monstersHp or {}
    dungeon.countdown = dungeonConfig.countdown
    dungeon.isPlunder = dungeonConfig.isPlunder
    dungeon.forceAuto = dungeonConfig.forceAuto
    dungeon.isUnionDragonWar = dungeonConfig.isUnionDragonWar
    dungeon.unionDragonWarBossId = dungeonConfig.unionDragonWarBossId
    dungeon.unionDragonWarBossLevel = dungeonConfig.unionDragonWarBossLevel
    dungeon.unionDragonWarBossHp = dungeonConfig.unionDragonWarBossHp
    dungeon.unionDragonWarBossFullHp = dungeonConfig.unionDragonWarBossFullHp
    dungeon.unionDragonWarHolyBuffer = dungeonConfig.unionDragonWarHolyBuffer
    dungeon.unionDragonWarWinStreakNum = dungeonConfig.unionDragonWarWinStreakNum
    dungeon.societyDungeonBuffList = dungeonConfig.societyDungeonBuffList
    dungeon.legendHeroIds = dungeonConfig.legendHeroIds or {}
    dungeon.heroSkillBonuses = dungeonConfig.heroSkillBonuses or {}
    dungeon.isInDragon = dungeonConfig.isInDragon
    dungeon.unionDragonWarWeatherId = dungeonConfig.unionDragonWarWeatherId
    dungeon.instanceId = dungeonConfig.instanceId
    dungeon.userForce = dungeonConfig.userForce
    dungeon.userVip = dungeonConfig.userVip
    dungeon.enemyVip = dungeonConfig.enemyVip
    dungeon.userName = dungeonConfig.userName
    dungeon.enemyName = dungeonConfig.enemyName
    dungeon.userConsortiaName = dungeonConfig.userConsortiaName
    dungeon.enemyConsortiaName = dungeonConfig.enemyConsortiaName
    dungeon.isThunder = dungeonConfig.isThunder
    dungeon.rebelScoreRate = dungeonConfig.rebelScoreRate
    dungeon.isClientWin = dungeonConfig.isClientWin
    dungeon.bossMinimumHp = dungeonConfig.bossMinimumHp or -1
    dungeon.killEnemyCount = dungeonConfig.killEnemyCount or 0
    dungeon.isConsortiaWar = dungeonConfig.isConsortiaWar
    dungeon.consortiaWarHallIdNum = dungeonConfig.consortiaWarHallIdNum
    dungeon.isPVP2TeamBattle = dungeonConfig.isPVP2TeamBattle
    dungeon.gameVersion = dungeonConfig.gameVersion
    dungeon.blackRockBossId = dungeonConfig.blackRockBossId
    dungeon.userSoulSpiritCollectInfo = dungeonConfig.userSoulSpiritCollectInfo
    dungeon.enemySoulSpiritCollectInfo = dungeonConfig.enemySoulSpiritCollectInfo
    dungeon.userAlternateTargetOrder = dungeonConfig.userAlternateTargetOrder
    dungeon.enemyAlternateTargetOrder = dungeonConfig.enemyAlternateTargetOrder
    dungeon.isSotoTeam = dungeonConfig.isSotoTeam
    dungeon.isBlackRock = dungeonConfig.isBlackRock
    dungeon.blackRockTimeEnd = dungeonConfig.blackRockTimeEnd
    dungeon.isPlayerComeback = dungeonConfig.isPlayerComeback
    dungeon.isPassUnlockDungeon = dungeonConfig.isPassUnlockDungeon
    dungeon.boss_hp_infinite = dungeonConfig.boss_hp_infinite
    dungeon.isSotoTeamInherit = dungeonConfig.isSotoTeamInherit
    dungeon.isCollegeTrain = dungeonConfig.isCollegeTrain
    dungeon.isSotoTeamEquilibrium = dungeonConfig.isSotoTeamEquilibrium
    dungeon.isMockBattle = dungeonConfig.isMockBattle
    dungeon.forceYield = dungeonConfig.forceYield
    dungeon.totemChallengeBuffId = dungeonConfig.totemChallengeBuffId
    dungeon.isTotemChallenge = dungeonConfig.isTotemChallenge
    dungeon.heroGodArmIdList = dungeonConfig.heroGodArmIdList
    dungeon.allHeroGodArmIdList = dungeonConfig.allHeroGodArmIdList
    dungeon.enemyGodArmIdList = dungeonConfig.enemyGodArmIdList
    dungeon.allEnemyGodArmIdList = dungeonConfig.allEnemyGodArmIdList
    dungeon.totemChallengePos = dungeonConfig.totemChallengePos
    dungeon.userGodArmList = dungeonConfig.userGodArmList
    dungeon.enemyGodArmList = dungeonConfig.enemyGodArmList
    dungeon.isTotemChallengeQuick = dungeonConfig.isTotemChallengeQuick
    dungeon.extraProp = dungeonConfig.extraProp
    dungeon.enemyExtraProp = dungeonConfig.enemyExtraProp
    dungeon.isSoulTower = dungeonConfig.isSoulTower
    dungeon.soultowerDungenLevel = dungeonConfig.soultowerDungenLevel
    dungeon.holyPressureWave = dungeonConfig.holyPressureWave
    dungeon.isSilvesArena = dungeonConfig.isSilvesArena
    dungeon.towerForceId = dungeonConfig.towerForceId
    dungeon.isMazeExplore = dungeonConfig.isMazeExplore
    dungeon.isMetalAbyss = dungeonConfig.isMetalAbyss
    
    -- local checkTable
    -- local newDungeon = {}
    -- --线上有玩家dungeonCofig中会多出pos字段，所以现在这里进行检查
    -- checkTable = function(newDungeon, data, parentKey)
    --     for key, value in pairs(data) do
    --         if type(value) == "table" then
    --             if newDungeon[key] == nil then
    --                 newDungeon[key] = {}
    --             end
    --             checkTable(newDungeon[key], value, key)
    --         else
    --             if key ~= "pos" then
    --                 newDungeon[key] = value
    --             else
    --                 app:getClient():crashReport("LUA DEBUG", table.tostring({content = {key = parentKey, value = data}}))
    --             end
    --         end
    --     end
    -- end
    -- checkTable(newDungeon, dungeon, "dungeon")

    return dungeon
end

function QMyAppUtils:generateBattleRecord(battleRecord)
    local dungeon = self:generateDungeonConfig(battleRecord.dungeonConfig) 

    dungeon.supportSkillHeroIndex = battleRecord.dungeonConfig.supportSkillHeroIndex
    dungeon.supportSkillHeroIndex2 = battleRecord.dungeonConfig.supportSkillHeroIndex2
    dungeon.supportSkillHeroIndex3 = battleRecord.dungeonConfig.supportSkillHeroIndex3
    dungeon.supportSkillEnemyIndex = battleRecord.dungeonConfig.supportSkillEnemyIndex
    dungeon.supportSkillEnemyIndex2 = battleRecord.dungeonConfig.supportSkillEnemyIndex2
    dungeon.supportSkillEnemyIndex3 = battleRecord.dungeonConfig.supportSkillEnemyIndex3
    
    dungeon.last_enable_fragment_id = battleRecord.dungeonConfig.last_enable_fragment_id
    dungeon.sunWarBuffID = battleRecord.dungeonConfig.sunWarBuffID
    dungeon.sunwarTargetOrder = battleRecord.dungeonConfig.sunwarTargetOrder or {}
    dungeon.gloryTargetOrder = battleRecord.dungeonConfig.gloryTargetOrder or {}

    local timeGearChange = {}
    for frameIndexStr, timeGear in pairs(battleRecord.dungeonConfig.timeGearChange or {}) do
        table.insert(timeGearChange, {frameIndex = tonumber(frameIndexStr), timeGear = timeGear})
    end
    dungeon.timeGearChange = timeGearChange

    local disableAIChange = {}
    for frameIndexStr, isDisable in pairs(battleRecord.dungeonConfig.disableAIChange or {}) do
        table.insert(disableAIChange, {frameIndex = tonumber(frameIndexStr), isDisable = isDisable})
    end
    dungeon.disableAIChange = disableAIChange

    local playerAction = {}
    for udid, _actorPlayerAction in pairs(battleRecord.dungeonConfig.playerAction or {}) do
        local actorPlayerAction = {}
        table.insert(playerAction, {udid = udid, actorPlayerAction = actorPlayerAction})
        for frameIndexStr, _frameActorPlayerAction in pairs(_actorPlayerAction) do
            local frameActorPlayerAction = {}
            table.insert(actorPlayerAction, {frameIndex = tonumber(frameIndexStr), frameActorPlayerAction = frameActorPlayerAction})
            for _, _action in ipairs(_frameActorPlayerAction) do
                table.insert(frameActorPlayerAction, _action)
            end
        end
    end
    dungeon.playerAction = playerAction

    local forceAutoChange = {}
    for actor_id, _actorForceAutoChange in pairs(battleRecord.dungeonConfig.forceAutoChange or {}) do
        local actorForceAutoChange = {}
        table.insert(forceAutoChange, {actor_id = actor_id, actorForceAutoChange = actorForceAutoChange})
        for frameIndexStr, force in pairs(_actorForceAutoChange) do
            table.insert(actorForceAutoChange, {frameIndex = tonumber(frameIndexStr), force = force})
        end
    end
    dungeon.forceAutoChange = forceAutoChange

    -- TODO: performance enhance
    local recordTimeSlices = {}
    local size = #battleRecord.recordTimeSlices
    local index = 1
    local pack_number = math.floor(32 / BATTLE_RECORD_DT_PACK_BITS) - 1
    while index <= size do
        local t = 0
        for i = 0, pack_number do
            if index <= size then
                local r = battleRecord.recordTimeSlices[index]
                t = t + r*2^(i*BATTLE_RECORD_DT_PACK_BITS)
                index = index + 1
            else
                break 
            end
        end
        table.insert(recordTimeSlices, t)
    end

    local record = {}
    record.dungeonConfig = dungeon
    record.recordRandomSeed = battleRecord.recordRandomSeed
    record.recordFrameCount = #battleRecord.recordTimeSlices
    record.recordTimeSlices = recordTimeSlices
    -- record.recordTimeSlices = battleRecord.recordTimeSlices
    record.gameVersion = tostring(GAME_VERSION)
    record.gameBuildTime = tostring(GAME_BUILD_TIME)

    return record
end


function QMyAppUtils:saveBattleRecordIntoProtobuf(battleRecordList)
    local replayCord = {}
    replayCord.replayList = {}
    for _, battleRecord in ipairs(battleRecordList) do
        local record = self:generateBattleRecord(battleRecord)
        table.insert(replayCord.replayList, record)
    end

    local buff = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayList", replayCord)
    writeToBinaryFile("last.reppb", buff)
end

-- 载入战斗回放流为普通战斗记录()
function QMyAppUtils:loadBattleRecordFromStream()
    -- 从last.repx流文件读入到self._battleRecord中去
    local fileutil = CCFileUtils:sharedFileUtils()
    local filepath = fileutil:getWritablePath() .. "last.repx"
    if not fileutil:isFileExist(filepath) then
        return
    end

    local content = fileutil:getFileData(filepath)
    local frames = string.split(content, "!@#$")

    local frame_1 = json.decode(frames[1])
    local dungeonConfig = frame_1.dungeonConfig
    local recordRandomSeed = frame_1.recordRandomSeed
    local forceAutoChange = {}
    local playerAction = {}
    local timeGearChange = {}
    local disableAIChange = {}
    local recordTimeSlices = {}

    for i = 2, #frames do
        local frame = json.decode(frames[i])
        local frame_index = tostring(i - 1)

        -- 把uint32都memory copy转换成正常的浮点数
        frame.dt = QUtility:uint32_to_float(frame.dt)
        if frame.timeGearChange then
            frame.timeGearChange = QUtility:uint32_to_float(frame.timeGearChange)
        end

        table.insert(recordTimeSlices, frame.dt)

        if frame.forceAutoChange then
            for actor_id, forceAuto in pairs(frame.forceAutoChange) do
                q.mt(forceAutoChange, actor_id)[frame_index] = forceAuto
            end
        end

        if frame.playerAction then
            for  _, obj in ipairs(frame.playerAction) do
                local udid = obj[1]
                local category = obj[2]
                local param = obj[3]
                table.insert(q.mt(playerAction, udid, frame_index), {c = category, p = param})
            end
        end

        if frame.timeGearChange then
            timeGearChange[frame_index] = frame.timeGearChange
        end

        if frame.disableAIChange then
            disableAIChange[frame_index] = frame.disableAIChange
        end
    end

    dungeonConfig.forceAutoChange = forceAutoChange
    dungeonConfig.playerAction = playerAction
    dungeonConfig.timeGearChange = timeGearChange
    dungeonConfig.disableAIChange = disableAIChange

    local battleRecord = {dungeonConfig = dungeonConfig, recordTimeSlices = recordTimeSlices, recordRandomSeed = recordRandomSeed}
    return battleRecord
end

function QMyAppUtils:loadBattleRecordFromProtobufContent(battleRecord)
    local dungeonId = db:convertDungeonID(battleRecord.dungeonConfig.dungeon_id)
    -- TOFIX: SHRINK
    local config = q.cloneShrinkedObject(db:getDungeonConfigByID(dungeonId))
    for key, value in pairs(config) do
        battleRecord.dungeonConfig[key] = value
    end

    local timeGearChange = {}
    for _, obj in ipairs(battleRecord.dungeonConfig.timeGearChange or {}) do
        timeGearChange[tostring(obj.frameIndex)] = obj.timeGear
    end
    battleRecord.dungeonConfig.timeGearChange = timeGearChange

    local disableAIChange = {}
    for _, obj in ipairs(battleRecord.dungeonConfig.disableAIChange or {}) do
        disableAIChange[tostring(obj.frameIndex)] = obj.isDisable
    end
    battleRecord.dungeonConfig.disableAIChange = disableAIChange

    local playerAction = {}
    for _, _actorPlayerAction in ipairs(battleRecord.dungeonConfig.playerAction or {}) do
        local actorPlayerAction = {}
        playerAction[_actorPlayerAction.udid] = actorPlayerAction
        for _, _frameActorPlayerAction in ipairs(_actorPlayerAction.actorPlayerAction) do
            local frameActorPlayerAction = {}
            actorPlayerAction[tostring(_frameActorPlayerAction.frameIndex)] = frameActorPlayerAction
            for _, _action in ipairs(_frameActorPlayerAction.frameActorPlayerAction) do
                table.insert(frameActorPlayerAction, _action)
            end
        end
    end
    battleRecord.dungeonConfig.playerAction = playerAction

    local forceAutoChange = {}
    for _, _actorForceAutoChange in ipairs(battleRecord.dungeonConfig.forceAutoChange or {}) do
        local actorForceAutoChange = {}
        forceAutoChange[_actorForceAutoChange.actor_id] = actorForceAutoChange
        for _, obj in ipairs(_actorForceAutoChange.actorForceAutoChange) do
            actorForceAutoChange[tostring(obj.frameIndex)] = not not obj.force
        end
    end
    battleRecord.dungeonConfig.forceAutoChange = forceAutoChange

    -- TODO: performance enhance
    local recordTimeSlices = {}
    local size = battleRecord.recordTimeSlices and #battleRecord.recordTimeSlices or 0
    local index = 1
    local pack_number = math.floor(32 / BATTLE_RECORD_DT_PACK_BITS)
    local t1
    while index <= size do
        local t = battleRecord.recordTimeSlices[index]
        for i = 1, pack_number do
            local temp = t
            t1 = math.floor(t/(2^BATTLE_RECORD_DT_PACK_BITS))
            t = t1*(2^BATTLE_RECORD_DT_PACK_BITS)
            local r = temp - t
            t = t1
            table.insert(recordTimeSlices, r)
        end

        index = index + 1
    end
    if #recordTimeSlices > battleRecord.recordFrameCount then
        local count = #recordTimeSlices - battleRecord.recordFrameCount
        for i = 1, count do
            table.remove(recordTimeSlices, #recordTimeSlices)
        end
    end
    battleRecord.recordTimeSlices = recordTimeSlices

    return battleRecord
end

return QMyAppUtils
