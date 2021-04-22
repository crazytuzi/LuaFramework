local QBattleManager
if IsServerSide then
    local EventProtocol = import("EventProtocol")
    QBattleManager = class("QBattleManager", EventProtocol)
else
    local QModelBase = import("..models.QModelBase")
    QBattleManager = class("QBattleManager", QModelBase)
end
local QActor = import("..models.QActor")
local QSoulSpiritModel = import("..models.QSoulSpiritModel")
local QCopyHeroModel = import("..models.QCopyHeroModel")
local QActorProp = import("..models.QActorProp")
local QSkill = import("..models.QSkill")
local QAIDirector = import("..ai.QAIDirector")
local static
if IsServerSide then
    static = QStaticDatabase
else
    static = import(".QStaticDatabase")
end
local QStaticDatabase = static
local QFileCache = import("..utils.QFileCache")
local QMap = import("..utils.QMap") 
-- local QNotificationCenter = import(".QNotificationCenter")
-- local QSkeletonViewController = import(".QSkeletonViewController")
local QTutorialStageEnrolling
if not IsServerSide then
    QTutorialStageEnrolling = import("..tutorial.enrolling.QTutorialStageEnrolling")
end
local QTutorialStoryLine
if not IsServerSide then
    QTutorialStoryLine = import("..tutorial.storyline.QTutorialStoryLine")
end
local QBattleLog = import(".QBattleLog")
local QDebugBattleInfo
if not IsServerSide then
    QDebugBattleInfo = import(".QDebugBattleInfo")
end
-- local QBattleVCR = import("..vcr.controllers.QBattleVCR")
local QTrapDirector = import("..trap.QTrapDirector")
-- local QThunder = import("..network.models.QThunder")
local QUserData
if not IsServerSide then
    QUserData = import("..utils.QUserData")
end
-- local QBaseEffectView = import("..views.QBaseEffectView")
local QBattleDialogAgainstRecord
if not IsServerSide then
    QBattleDialogAgainstRecord = import("..ui.battle.QBattleDialogAgainstRecord")
end
local QBuriedPoint
if not IsServerSide then
    QBuriedPoint = import("..utils.QBuriedPoint")
end

local totem_challenge_affx_config = import("..battle.config.totemchallenge_config")


QBattleManager.NPC_CREATED = "NPC_CREATED"
QBattleManager.NPC_CLEANUP = "NPC_CLEANUP"
QBattleManager.CANDIDATE_ACTOR_ENTER = "CANDIDATE_ACTOR_ENTER"
QBattleManager.NPC_DEATH_LOGGED = "NPC_DEATH_LOGGED"
QBattleManager.HERO_CLEANUP = "HERO_CLEANUP"
QBattleManager.START = "BATTLE_START"
QBattleManager.PAUSE = "BATTLE_PAUSE"
QBattleManager.RESUME = "BATTLE_RESUME"
QBattleManager.END = "BATTLE_END"
QBattleManager.STOP = "BATTLE_STOP"
QBattleManager.WAVE_CONFIRMED = "WAVE_CONFIRMED"
QBattleManager.WAVE_STARTED = "WAVE_STARTED"
QBattleManager.WAVE_ENDED = "WAVE_ENDED"
QBattleManager.WAVE_ENDED_FOR_ACTOR = "WAVE_ENDED_FOR_ACTOR"
QBattleManager.WIN = "BATTLE_WIN"
QBattleManager.LOSE = "BATTLE_LOSE"
QBattleManager.PVP_WAVE_END = "PVP_WAVE_END"
QBattleManager.PVE_MULTIPLE_WAVE_END = "PVE_MULTIPLE_WAVE_END"
QBattleManager.PVP_MULTIPLE_WAVE_END = "PVP_MULTIPLE_WAVE_END"
QBattleManager.ONTIMER = "BATTLE_ONTIMER"
QBattleManager.BATTLE_TIMER_INTERVAL = 0.1 -- seconds
QBattleManager.ONFRAME = "BATTLE_ONFRAME"
QBattleManager.USE_MANUAL_SKILL = "USE_MANUAL_SKILL"
QBattleManager.CUTSCENE_START = "BATTLE_CUTSCENE_START"
QBattleManager.CUTSCENE_END = "BATTLE_CUTSCENE_END"
QBattleManager.ON_SET_TIME_GEAR = "ON_SET_TIME_GEAR"
QBattleManager.ON_CHANGE_DAMAGE_COEFFICIENT = "ON_CHANGE_DAMAGE_COEFFICIENT"
QBattleManager.UFO_CREATED = "UFO_CREATED"
QBattleManager.HOLY_PRESSURE_WAVE = "HOLY_PRESSURE_WAVE"
QBattleManager.NEW_ENEMY = "NEW_ENEMY"

QBattleManager.EVENT_BULLET_TIME_TURN_ON = "NOTIFICATION_EVENT_BULLET_TIME_TURN_ON"
QBattleManager.EVENT_BULLET_TIME_TURN_OFF = "NOTIFICATION_EVENT_BULLET_TIME_TURN_OFF"

QBattleManager.EVENT_BULLET_TIME_TURN_START = "NOTIFICATION_EVENT_BULLET_TIME_TURN_START"
QBattleManager.EVENT_BULLET_TIME_TURN_FINISH = "NOTIFICATION_EVENT_BULLET_TIME_TURN_FINISH"

local function dummyTimeFunction(dt)
    return dt
end

function QBattleManager:ctor(dungeonConfig)
    self.super.ctor(self)

    if not IsServerSide then
        if device.platform == "mac" then
            self._debugBattleInfo = QDebugBattleInfo.new()
        end
    end

    self:_initRecordAndReplay(dungeonConfig)

    self._battleTime = 0
    self._battleTimeForEffect = 0
    self._battleTimeNoTimeGear = 0
    self._naturalStartTime = q.time()

    self._heroes = {}
    self._heroesWave1 = {}
    self._heroesWave2 = {}
    self._heroesWave3 = {}
    self._supportHeroes = {}
    self._supportHeroes2 = {}
    self._supportHeroes3 = {}
    self._supportSkillHero = nil
    self._supportSkillHero2 = nil
    self._supportSkillHero3 = nil
    self._supportHeroSkillTime = {}
    self._deadHeroes = {}
    self._enemies = {}
    self._enemiesWave1 = {}
    self._enemiesWave2 = {}
    self._enemiesWave3 = {}
    self._supportEnemies = {}
    self._supportEnemies2 = {}
    self._supportEnemies3 = {}
    self._supportSkillEnemy = nil
    self._supportSkillEnemy2 = nil
    self._supportSkillEnemy3 = nil
    self._supportEnemySkillTime = {}
    self._deadEnemies = {}
    self._heroGhosts = {}
    self._enemyGhosts = {}
    self._appearActors = {}
    self._actorsByUDID = {}
    self.entered_actor = {}
    self._heroTeamSkillProperty = {}
    self._enemyTeamSkillProperty = {}

    self._userSoulSpritsList = {} --用于存放己方魂灵的列表
    self._enemySoulSpritsList = {} -- 用于存放地方魂灵的列表

    self._hero_skin_infos = {}
    self._enemy_skin_infos = {}

    self._paused = false
    self.__pauseRecord = false
    self._pauseRecord = false -- 暂停录像标志，用于等待下一波确认和游戏暂停期间。在_pauseRecord期间不得做任何影响恢复录像之后执行序列的事情。
    self._currentFrameRecord = nil -- 当前帧的记录，最后会append到repx文件中去

    self._dungeonConfig = dungeonConfig
    self._dungeonConfig.bossMinimumHp = -1000
    self._dungeonConfig.killEnemyCount = 0
    self._is_ghost_cache = {}

    -- 神器ID列表
    self._dungeonConfig.heroGodArmIdList = self._dungeonConfig.heroGodArmIdList or {}
    self._dungeonConfig.allHeroGodArmIdList = self._dungeonConfig.allHeroGodArmIdList or {}
    self._dungeonConfig.enemyGodArmIdList = self._dungeonConfig.enemyGodArmIdList or {}
    self._dungeonConfig.allEnemyGodArmIdList = self._dungeonConfig.allEnemyGodArmIdList or {}

    self._heroYZGodArmList = {}
    self._enmeyYZGodArmList = {}
    self._heroGodArmSkillIds1 = {}
    self._heroGodArmSkillIds2 = {}
    self._heroGodArmSkillIds3 = {}
    self._heroYZGodArmSkillIds = {}
    self._enemyGodArmSkillIds1 = {}
    self._enemyGodArmSkillIds2 = {}
    self._enemyGodArmSkillIds3 = {}
    self._enemyYZGodArmSkillIds = {}

    self._map_cache = QMap.new()

    -- 初始化生灵台战力压制
    if self._dungeonConfig.towerForceId and self._dungeonConfig.towerForceId ~= -1 then
        local forceConfig = db:getSoulTowerForceConfigById(self._dungeonConfig.towerForceId)
        self._dungeonConfig.difficulty_level = forceConfig.difficulty_level
        self._dungeonConfig.dbuff_value = forceConfig.dbuff_value
    end

    self._dungeonConfig.recordList = self._dungeonConfig.recordList or {} -- 记录多场战斗的record(不是多波次，例如2v2pve)
    if self:isPVEMultipleWave() then
        if dungeonConfig.pveMultipleWave then
            self._pveMultipleWave = dungeonConfig.pveMultipleWave
        else
            self._pveMultipleWave = 1
            self._dungeonConfig.heroInfos = {}
            self._dungeonConfig.supportHeroInfos = {}
            self._dungeonConfig.userSoulSpirits = {}
            self._dungeonConfig.heroGodArmIdList = {}

            table.mergeForArray(self._dungeonConfig.heroInfos, self._dungeonConfig.pveMultipleInfos[1].heroes or {})
            table.mergeForArray(self._dungeonConfig.supportHeroInfos, self._dungeonConfig.pveMultipleInfos[1].supports or {})
            table.mergeForArray(self._dungeonConfig.userSoulSpirits, self._dungeonConfig.pveMultipleInfos[1].soulSpirits or {})
            table.mergeForArray(self._dungeonConfig.heroGodArmIdList, self._dungeonConfig.pveMultipleInfos[1].godArmIdList or {})
            self._dungeonConfig.supportSkillHeroIndex = self._dungeonConfig.pveMultipleInfos[1].supportSkillHeroIndex
            self._dungeonConfig.supportSkillHeroIndex2 = self._dungeonConfig.pveMultipleInfos[1].supportSkillHeroIndex2
        end
    end
    ----[[这段代码是不是应该让前端传一下
    if self:isPVPMultipleWaveNew() then
        if dungeonConfig.pvpMultipleWave then
            self._pvpMultipleWave = dungeonConfig.pvpMultipleWave
        else
            self._pvpMultipleWave = 1
            
            self._dungeonConfig.heroInfos = {}
            self._dungeonConfig.supportHeroInfos = {}
            self._dungeonConfig.userSoulSpirits = {}
            self._dungeonConfig.heroGodArmIdList = {}

            table.mergeForArray(self._dungeonConfig.heroInfos, self._dungeonConfig.pvpMultipleTeams[1].hero.heroes or {})
            table.mergeForArray(self._dungeonConfig.supportHeroInfos, self._dungeonConfig.pvpMultipleTeams[1].hero.supports or {})
            table.mergeForArray(self._dungeonConfig.userSoulSpirits, self._dungeonConfig.pvpMultipleTeams[1].hero.soulSpirits or {})
            table.mergeForArray(self._dungeonConfig.heroGodArmIdList, self._dungeonConfig.pvpMultipleTeams[1].hero.godArmIdList or {})
            self._dungeonConfig.supportSkillHeroIndex = self._dungeonConfig.pvpMultipleTeams[1].hero.supportSkillHeroIndex
            self._dungeonConfig.supportSkillHeroIndex2 = self._dungeonConfig.pvpMultipleTeams[1].hero.supportSkillHeroIndex2

            self._dungeonConfig.pvp_rivals = {}
            self._dungeonConfig.pvp_rivals2 = {}
            self._dungeonConfig.enemySoulSpirits = {}
            self._dungeonConfig.enemyGodArmIdList = {}

            table.mergeForArray(self._dungeonConfig.pvp_rivals, self._dungeonConfig.pvpMultipleTeams[1].enemy.heroes or {})
            table.mergeForArray(self._dungeonConfig.pvp_rivals2, self._dungeonConfig.pvpMultipleTeams[1].enemy.supports or {})
            table.mergeForArray(self._dungeonConfig.enemySoulSpirits, self._dungeonConfig.pvpMultipleTeams[1].enemy.soulSpirits or {})
            table.mergeForArray(self._dungeonConfig.enemyGodArmIdList, self._dungeonConfig.pvpMultipleTeams[1].enemy.godArmIdList or {})
            self._dungeonConfig.supportSkillEnemyIndex = self._dungeonConfig.pvpMultipleTeams[1].enemy.supportSkillHeroIndex
            self._dungeonConfig.supportSkillEnemyIndex2 = self._dungeonConfig.pvpMultipleTeams[1].enemy.supportSkillHeroIndex2
        end
    end
    --]]

    self:_initYZGodArmIdList(self._dungeonConfig.heroGodArmIdList, self._dungeonConfig.enemyGodArmIdList)

    -- TOFIX: SHRINK

    self._pveHeroWaves = {}
    if self:isPVPMode() then
        self._monsters = {} 
    else
        self._monsters = {}
        if self:isInSilverMine() then
            local mineId = self._dungeonConfig.mineId
            local mineConfig = db:getSilvermineMineConfigs()[tostring(mineId)]
            for _, monster in ipairs(db:getMonstersById(mineConfig.dungeon_monster_id) or {}) do
                table.insert(self._monsters, q.cloneShrinkedObject(monster))
            end
        elseif self:isInBlackRock() then
            local monsterId = self._dungeonConfig.monster_id
            for _, monster in ipairs(db:getMonstersById(monsterId) or {}) do
                table.insert(self._monsters, q.cloneShrinkedObject(monster))
            end
            local br_monster_id = db:getBlackRockSoulSpriteMonsterId(self._dungeonConfig.monster_id, self._dungeonConfig.blackRockBossId)
            if br_monster_id then
                for _, monster in ipairs(db:getMonstersById(br_monster_id) or {}) do
                    table.insert(self._monsters, q.cloneShrinkedObject(monster))
                end
            end
        else
            local monsterId = self._dungeonConfig.monster_id
            if self:isPVEMultipleWave() then
                monsterId = self._dungeonConfig.pveMultipleInfos[self._pveMultipleWave].monsterId
            end
            for _, monster in ipairs(db:getMonstersById(monsterId) or {}) do
                local monsterInfo = q.cloneShrinkedObject(monster)
                if self:isSoulTower() then
                    monsterInfo.npc_level = self._dungeonConfig.soultowerDungenLevel
                end
                table.insert(self._monsters, monsterInfo)
            end
        end
    end

    self._waveCount = self:_calculateWaveCount()
    self._pvpWaveCount = 3
    self._timeLeft = self:getDungeonDuration()

    self._damageHistory = {}
    self._treatHistory = {}

    self._aiDirector = QAIDirector.new()

    self._trapDirectors = {}

    self._bullets = {}
    self._lasers = {}
    self._ufos = {}

    self._exceptActor = {}
    self._bulletTimeReferenceCount = 0
    self._isFirstNPCCreated = false
    self._isHaveEnemyInAppearEffectDelay = false
    self._ended = false -- 记录是否结束了，在WIN或者LOSE的消息发出的时候设置，防止消息重复发出。
    self._pauseAI = true

    self._nextSchedulerHandletId = 1
    self._delaySchedulers = {}

    self._curWave = 0
    self._curWaveStartTime = 0
    self._pauseBetweenWaves = true
    self._startCountDown = false
    self._curPVPWave = 0
    self._curPVEWave = 0
    self._pvpMultipleWaveHeroScore = 0
    self._pvpMultipleWaveEnemyScore = 0
    self._pvpMultipleWaveHeroScoreList = {}
    self._neutralEnemies = {} --无法被攻击的敌人
    self._neutralHeroes = {}
    self._pveMutlipleActorCheck = {}

    if not IsServerSide then
        self._enrollingStage = QTutorialStageEnrolling.new()
    end

    self._battleLog = QBattleLog.new(self._dungeonConfig.id)
    self._normalAttackRecord = {}

    self._isActiveDungeon = self._dungeonConfig.isActiveDungeon
    self._activeDungeonType = self._dungeonConfig.activeDungeonType

    -- app:resetBattleNpgcProbability(self._dungeonConfig.id)

    if not IsServerSide then
        self:_assignReward()
        self:_resetDailyBossAwards()
    end

    self._timeGear = 1.0

    self._registerdCharges = {}

    self._candidateHeroes = {}
    self._candidateEnemies = {}
    if self._dungeonConfig.isSotoTeam then
        self._dungeonConfig.supportSkillHeroIndex = nil
        self._dungeonConfig.supportSkillHeroIndex2 = nil
        self._dungeonConfig.supportSkillHeroIndex3 = nil
        self._dungeonConfig.supportSkillEnemyIndex = nil
        self._dungeonConfig.supportSkillEnemyIndex2 = nil
        self._dungeonConfig.supportSkillEnemyIndex3 = nil
    end

    self._damageCoefficient = 1.0
    if QBattleManager.ARENA_BEATTACK_30_COEFFICIENT == nil then
        local coefficient = 3
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.ARENA_BEATTACK_30_COEFFICIENT ~= nil and globalConfig.ARENA_BEATTACK_30_COEFFICIENT.value ~= nil then
            coefficient = globalConfig.ARENA_BEATTACK_30_COEFFICIENT.value 
        end
        QBattleManager.ARENA_BEATTACK_30_COEFFICIENT = coefficient
    end
    if QBattleManager.ARENA_BEATTACK_60_COEFFICIENT == nil then
        local coefficient = 3
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.ARENA_BEATTACK_60_COEFFICIENT ~= nil and globalConfig.ARENA_BEATTACK_60_COEFFICIENT.value ~= nil then
            coefficient = globalConfig.ARENA_BEATTACK_60_COEFFICIENT.value 
        end
        QBattleManager.ARENA_BEATTACK_60_COEFFICIENT = coefficient
    end
    if QBattleManager.ARENA_BEATTACK_75_COEFFICIENT == nil then
        local coefficient = 3
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.ARENA_BEATTACK_75_COEFFICIENT ~= nil and globalConfig.ARENA_BEATTACK_75_COEFFICIENT.value ~= nil then
            coefficient = globalConfig.ARENA_BEATTACK_75_COEFFICIENT.value 
        end
        QBattleManager.ARENA_BEATTACK_75_COEFFICIENT = coefficient
    end
    if QBattleManager.SUNWELL_BEATTACK_30_COEFFICIENT == nil then
        local coefficient = 3
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.SUNWELL_BEATTACK_30_COEFFICIENT ~= nil and globalConfig.SUNWELL_BEATTACK_30_COEFFICIENT.value ~= nil then
            coefficient = globalConfig.SUNWELL_BEATTACK_30_COEFFICIENT.value 
        end
        QBattleManager.SUNWELL_BEATTACK_30_COEFFICIENT = coefficient
    end
    if QBattleManager.SUNWELL_BEATTACK_60_COEFFICIENT == nil then
        local coefficient = 3
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.SUNWELL_BEATTACK_60_COEFFICIENT ~= nil and globalConfig.SUNWELL_BEATTACK_60_COEFFICIENT.value ~= nil then
            coefficient = globalConfig.SUNWELL_BEATTACK_60_COEFFICIENT.value 
        end
        QBattleManager.SUNWELL_BEATTACK_60_COEFFICIENT = coefficient
    end
    if QBattleManager.SUNWELL_BEATTACK_75_COEFFICIENT == nil then
        local coefficient = 3
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.SUNWELL_BEATTACK_75_COEFFICIENT ~= nil and globalConfig.SUNWELL_BEATTACK_75_COEFFICIENT.value ~= nil then
            coefficient = globalConfig.SUNWELL_BEATTACK_75_COEFFICIENT.value 
        end
        QBattleManager.SUNWELL_BEATTACK_75_COEFFICIENT = coefficient
    end
    if QBattleManager.SILVERMINE_BEATTACK_30_COEFFICIENT == nil then
        local coefficient = 3
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.SILVERMINE_BEATTACK_30_COEFFICIENT ~= nil and globalConfig.SILVERMINE_BEATTACK_30_COEFFICIENT.value ~= nil then
            coefficient = globalConfig.SILVERMINE_BEATTACK_30_COEFFICIENT.value 
        end
        QBattleManager.SILVERMINE_BEATTACK_30_COEFFICIENT = coefficient
    end
    if QBattleManager.SILVERMINE_BEATTACK_60_COEFFICIENT == nil then
        local coefficient = 3
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.SILVERMINE_BEATTACK_60_COEFFICIENT ~= nil and globalConfig.SILVERMINE_BEATTACK_60_COEFFICIENT.value ~= nil then
            coefficient = globalConfig.SILVERMINE_BEATTACK_60_COEFFICIENT.value 
        end
        QBattleManager.SILVERMINE_BEATTACK_60_COEFFICIENT = coefficient
    end
    if QBattleManager.SILVERMINE_BEATTACK_75_COEFFICIENT == nil then
        local coefficient = 3
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.SILVERMINE_BEATTACK_75_COEFFICIENT ~= nil and globalConfig.SILVERMINE_BEATTACK_75_COEFFICIENT.value ~= nil then
            coefficient = globalConfig.SILVERMINE_BEATTACK_75_COEFFICIENT.value 
        end
        QBattleManager.SILVERMINE_BEATTACK_75_COEFFICIENT = coefficient
    end
    if QBattleManager.SUPPORT_HERO_RAGE_PER_SECOND == nil then
        local value = 0
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.SUPPORT_HERO_RAGE_PER_SECOND ~= nil and globalConfig.SUPPORT_HERO_RAGE_PER_SECOND.value ~= nil then
            value = globalConfig.SUPPORT_HERO_RAGE_PER_SECOND.value 
        end
        QBattleManager.SUPPORT_HERO_RAGE_PER_SECOND = value
    end
    if QBattleManager.SUPPORT_HERO_RAGE_PER_SECOND_IN_PVP == nil then
        local value = 0
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.SUPPORT_HERO_RAGE_PER_SECOND_IN_PVP ~= nil and globalConfig.SUPPORT_HERO_RAGE_PER_SECOND_IN_PVP.value ~= nil then
            value = globalConfig.SUPPORT_HERO_RAGE_PER_SECOND_IN_PVP.value 
        end
        QBattleManager.SUPPORT_HERO_RAGE_PER_SECOND_IN_PVP = value
    end
    if QBattleManager.SUPPORT_HERO_MAX_SECONDS == nil then
        local value = 5.0
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.SUPPORT_HERO_MAX_SECONDS ~= nil and globalConfig.SUPPORT_HERO_MAX_SECONDS.value ~= nil then
            value = globalConfig.SUPPORT_HERO_MAX_SECONDS.value
        end
        QBattleManager.SUPPORT_HERO_MAX_SECONDS = value
    end

    --世界斗魂场
    if QBattleManager.STORM_ARENA_BEATTACK_30_COEFFICIENT == nil then
        local value = 0.5
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.STORM_ARENA_BEATTACK_30_COEFFICIENT ~= nil and globalConfig.STORM_ARENA_BEATTACK_30_COEFFICIENT.value ~= nil then
            value = globalConfig.STORM_ARENA_BEATTACK_30_COEFFICIENT.value
        end
        QBattleManager.STORM_ARENA_BEATTACK_30_COEFFICIENT = value
    end

    if QBattleManager.STORM_ARENA_BEATTACK_60_COEFFICIENT == nil then
        local value = 1.5
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.STORM_ARENA_BEATTACK_60_COEFFICIENT ~= nil and globalConfig.STORM_ARENA_BEATTACK_60_COEFFICIENT.value ~= nil then
            value = globalConfig.STORM_ARENA_BEATTACK_60_COEFFICIENT.value
        end
        QBattleManager.STORM_ARENA_BEATTACK_60_COEFFICIENT = value
    end

    if QBattleManager.ABYSS_BEATTACK_30_COEFFICIENT == nil then
        local value = 0.5
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.ABYSS_BEATTACK_30_COEFFICIENT ~= nil and globalConfig.ABYSS_BEATTACK_30_COEFFICIENT.value ~= nil then
            value = globalConfig.ABYSS_BEATTACK_30_COEFFICIENT.value
        end
        QBattleManager.ABYSS_BEATTACK_30_COEFFICIENT = value
    end

    if QBattleManager.ABYSS_BEATTACK_60_COEFFICIENT == nil then
        local value = 1.5
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if globalConfig.ABYSS_BEATTACK_60_COEFFICIENT ~= nil and globalConfig.ABYSS_BEATTACK_60_COEFFICIENT.value ~= nil then
            value = globalConfig.ABYSS_BEATTACK_60_COEFFICIENT.value
        end
        QBattleManager.ABYSS_BEATTACK_60_COEFFICIENT = value
    end

    if self._dungeonConfig.isSotoTeam then
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if QBattleManager.SOTO_85_COEFFICIENT == nil then
            local value = 0.5
            if globalConfig.SOTO_85_COEFFICIENT ~= nil and globalConfig.SOTO_85_COEFFICIENT.value ~= nil then
                value = globalConfig.SOTO_85_COEFFICIENT.value
            end
            QBattleManager.SOTO_85_COEFFICIENT = value
        end
        if QBattleManager.SOTO_70_COEFFICIENT == nil then
            local value = 0.5
            if globalConfig.SOTO_70_COEFFICIENT ~= nil and globalConfig.SOTO_70_COEFFICIENT.value ~= nil then
                value = globalConfig.SOTO_70_COEFFICIENT.value
            end
            QBattleManager.SOTO_70_COEFFICIENT = value
        end
        if QBattleManager.SOTO_60_COEFFICIENT == nil then
            local value = 1.0
            if globalConfig.SOTO_60_COEFFICIENT ~= nil and globalConfig.SOTO_60_COEFFICIENT.value ~= nil then
                value = globalConfig.SOTO_60_COEFFICIENT.value
            end
            QBattleManager.SOTO_60_COEFFICIENT = value
        end
        if QBattleManager.SOTO_30_COEFFICIENT == nil then
            local value = 1.5
            if globalConfig.SOTO_30_COEFFICIENT ~= nil and globalConfig.SOTO_30_COEFFICIENT.value ~= nil then
                value = globalConfig.SOTO_30_COEFFICIENT.value
            end
            QBattleManager.SOTO_30_COEFFICIENT = value
        end
    end

    if self:isInTotemChallenge() then
        local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
        if QBattleManager.TOTEM_CHALLENGE_85_COEFFICIENT == nil then
            local value = 0.5
            if globalConfig.TOTEM_CHALLENGE_85_COEFFICIENT ~= nil and globalConfig.TOTEM_CHALLENGE_85_COEFFICIENT.value ~= nil then
                value = globalConfig.TOTEM_CHALLENGE_85_COEFFICIENT.value
            end
            QBattleManager.TOTEM_CHALLENGE_85_COEFFICIENT = value
        end
        if QBattleManager.TOTEM_CHALLENGE_70_COEFFICIENT == nil then
            local value = 0.5
            if globalConfig.TOTEM_CHALLENGE_70_COEFFICIENT ~= nil and globalConfig.TOTEM_CHALLENGE_70_COEFFICIENT.value ~= nil then
                value = globalConfig.TOTEM_CHALLENGE_70_COEFFICIENT.value
            end
            QBattleManager.TOTEM_CHALLENGE_70_COEFFICIENT = value
        end
        if QBattleManager.TOTEM_CHALLENGE_60_COEFFICIENT == nil then
            local value = 1.0
            if globalConfig.TOTEM_CHALLENGE_60_COEFFICIENT ~= nil and globalConfig.TOTEM_CHALLENGE_60_COEFFICIENT.value ~= nil then
                value = globalConfig.TOTEM_CHALLENGE_60_COEFFICIENT.value
            end
            QBattleManager.TOTEM_CHALLENGE_60_COEFFICIENT = value
        end
        if QBattleManager.TOTEM_CHALLENGE_30_COEFFICIENT == nil then
            local value = 1.5
            if globalConfig.TOTEM_CHALLENGE_30_COEFFICIENT ~= nil and globalConfig.TOTEM_CHALLENGE_30_COEFFICIENT.value ~= nil then
                value = globalConfig.TOTEM_CHALLENGE_30_COEFFICIENT.value
            end
            QBattleManager.TOTEM_CHALLENGE_30_COEFFICIENT = value
        end
    end

    QActor.setPVPCoefficientByLevel(math.ceil(((self._dungeonConfig.userLevel or 0) + (self._dungeonConfig.enemyLevel or 0)) / 2))

    self.actorHitAndAttackLogs = {}

    self:_prepareDungeonProp(self._dungeonConfig.societyDungeonBuffList)
    self:_prepareDungeonProp(self._dungeonConfig.worldBossBuffList)
    self:_prepareConsortiaWarProp()
    if self._dungeonConfig.isPlayerComeback then
        self:_prepareComebackProp()
    end
    if self:isInTotemChallenge() then
        self:initTotemChallengeAffix()
    end
end

function QBattleManager:_prepareComebackProp()
    local num = 0
    if self:isInUnionDragonWar() then
        num = num + db:getPlayerComebackBuffByType(3).buff_num
    elseif self:isInSocietyDungeon() then
        num = num + db:getPlayerComebackBuffByType(2).buff_num
    end
    if num > 0 then
        self._heroTeamSkillProperty["physical_damage_percent_attack"] = (self._heroTeamSkillProperty["physical_damage_percent_attack"] or 0) + (num/100)
        self._heroTeamSkillProperty["magic_damage_percent_attack"] = (self._heroTeamSkillProperty["magic_damage_percent_attack"] or 0) + (num/100)
    end
end

function QBattleManager:_prepareConsortiaWarProp()
    if not self:isInConsortiaWar() then return end
    local break_value = self._dungeonConfig.consortiaWarHallIdNum or 0
    local db = QStaticDatabase:sharedDatabase()
    local consortia_war_hall = db:getConsortiaWarHall()
    local check_tab = QActorProp._field
    local teamProperty = self._heroTeamSkillProperty
    for _,cfg in pairs(consortia_war_hall) do
        if bit.band(break_value, bit.lshift(1, cfg.id - 1)) ~= 0 then
            for k,v in pairs(cfg) do
                if check_tab[k] then
                    teamProperty[k] = (teamProperty[k] or 0) + v
                end
            end
        end
    end
end

function QBattleManager:_prepareDungeonProp(list)
    if not list then return end
    local heroSkills = {}
    local db = QStaticDatabase:sharedDatabase()
    local cache = {} --相同的buff不叠加

    for wave,buffID in pairs(list) do
        if not cache[buffID] then
            cache[buffID] = true
            local tab = {}
            tab.id = db:getScoietyDungeonBuff(buffID).skill_id
            tab.level = 1
            table.insert(heroSkills,tab)
        end
    end
    
    if heroSkills then
        for _, skill in ipairs(heroSkills) do
            local skillId, level = skill.id, skill.level
            local skillDataConfig = db:getSkillDataByIdAndLevel(skillId, level)
            if skillDataConfig then
                local skillConfig = db:getSkillByID(skillId)
                local teamSkillProperty = skillConfig.target_type == QSkill.ENEMY and self._enemyTeamSkillProperty or self._heroTeamSkillProperty
                local count = 1
                while true do
                    local key = skillDataConfig["addition_type_"..count]
                    local value = skillDataConfig["addition_value_"..count]
                    if key == nil then
                        break
                    end
                    teamSkillProperty[key] = (teamSkillProperty[key] or 0) + value
                    count = count + 1
                end
            end
        end
    end
end

function QBattleManager:_initRecordAndReplay(dungeonConfig)
    local isReplay = dungeonConfig.isReplay
    local recordTimeSlices = {} -- 用于记录的帧片段table
    local replayTimeSlices = dungeonConfig.replayTimeSlices -- 用于回放的帧片段table
    local replayRandomSeed = dungeonConfig.replayRandomSeed -- 用于回放的随机种子
    local recordRandomSeed
    if not isReplay then -- 正常跑
        recordRandomSeed = q.OSTime()
        app.randomseed(recordRandomSeed)
        function self:onTick(dt)
            local battleDT = self._dungeonConfig.battleDT
            if battleDT then
                return battleDT
            end
            local dtMin, dtMax = 1/60, 1/15
            local step = (dtMax - dtMin) / (BATTLE_RECORD_DT_STEP_NUMBER - 1)
            dt = math.clamp(dt, dtMin, dtMax)
            local floor = math.floor((dt - dtMin) / step)
            dt = dtMin + floor * step
            table.insert(recordTimeSlices, floor)
            return dt
        end
    else -- 回放跑
        recordRandomSeed = replayRandomSeed
        app.randomseed(recordRandomSeed)
        function self:hasReplayFrame()
            return replayTimeSlices[#recordTimeSlices] ~= nil
        end
        local naturalDT = nil
        function self:onTick(dt)
            local battleDT = self._dungeonConfig.battleDT
            if battleDT then
                return battleDT, naturalDT
            end
            local floor = replayTimeSlices[#recordTimeSlices + 1]
            if floor == nil then
                table.insert(recordTimeSlices, 1/60)
                return 1/60, naturalDT -- 由于最多只保存了战斗胜利决定的那一帧，所以回访时到这里就直接用用默认的1/60秒的时长
            end
            local dtMin, dtMax = 1/60, 1/15
            local step = (dtMax - dtMin) / (BATTLE_RECORD_DT_STEP_NUMBER - 1)
            dt = dtMin + floor * step
            table.insert(recordTimeSlices, dt)
            return dt, naturalDT
        end
        if not IsServerSide then
            scheduler.setTimeFunction(function(dt)
                naturalDT = dt
                local battleDT = self._dungeonConfig.battleDT
                if battleDT then
                    return battleDT
                end
                return dt
            end)
        end
    end
    local record = {}
    record.recordTimeSlices = recordTimeSlices
    record.recordRandomSeed = recordRandomSeed
    record.dungeonConfig = dungeonConfig
    self._record = record
end

function QBattleManager:_getBossCount()
    if self._bossCount == nil then
        self._bossCount = 0
        for _, monsterInfo in ipairs(self._monsters) do
            if monsterInfo.is_boss == true then
                self._bossCount = self._bossCount + 1
            end
        end
    end

    return self._bossCount

end

function QBattleManager:_assignReward()
    if self._dungeonConfig.awards == nil then self._dungeonConfig.awards = {} end
    if self._dungeonConfig.awards2 == nil then self._dungeonConfig.awards2 = {} end

    if #self._dungeonConfig.awards == 0 and #self._dungeonConfig.awards2 == 0 then
        return
    end

    -- get monster who have rewards
    local monsters = {}
    for i, monsterInfo in ipairs(self._monsters) do
        local charactorInfo = db:getCharacterByID(self:getBattleRandomNpc(self._dungeonConfig.monster_id, i, monsterInfo.npc_id))
        if charactorInfo ~= nil then
            table.insert(monsters, monsterInfo)
        end
    end

    local monsterCount = #monsters
    for _, reward in pairs(self._dungeonConfig.awards) do
        if reward.npcId ~= nil then
            if reward.index ~= nil then
                local index = reward.index
                local monsterInfo = monsters[index]
                if monsterInfo ~= nil then
                    if monsterInfo.rewards == nil then
                        monsterInfo.rewards = {}
                    end
                    monsterInfo.rewardIndex = index
                    table.insert(monsterInfo.rewards, {reward = reward, isGarbage = false})
                end
            end
        end
    end
    for _, reward in pairs(self._dungeonConfig.awards2) do
        if reward.npcId ~= nil then
            if reward.index ~= nil then
                local index = reward.index
                local monsterInfo = monsters[index]
                if monsterInfo ~= nil then
                    if monsterInfo.rewards == nil then
                        monsterInfo.rewards = {}
                    end
                    monsterInfo.rewardIndex = index
                    table.insert(monsterInfo.rewards, {reward = reward, isGarbage = true})
                end
            end
        end
    end

    -- find if have boss
    local bosses = {}
    local enemies = {}
    for _, monsterInfo in ipairs(monsters) do
        if monsterInfo.wave >= 1 then
            if monsterInfo.is_boss == true then
                table.insert(bosses, monsterInfo)
            else
                table.insert(enemies, monsterInfo)
            end
        end
    end

    local bossCount = #bosses
    local enemyCount = #enemies

    if bossCount > 0 then
        local rewards = {}
        local garbage = {}
        if self._dungeonConfig.awards ~= nil then
            for _, reward in pairs(self._dungeonConfig.awards) do
                if reward.npcId == nil and (remote.items:getItemType(reward.type) == ITEM_TYPE.MONEY or remote.items:getItemType(reward.type) == ITEM_TYPE.ITEM) then
                    table.insert(rewards, {reward = reward, isGarbage = false})
                end
            end
        end
        if self._dungeonConfig.awards2 ~= nil then
            for _, reward in pairs(self._dungeonConfig.awards2) do
                if reward.npcId == nil and (remote.items:getItemType(reward.type) == ITEM_TYPE.MONEY or remote.items:getItemType(reward.type) == ITEM_TYPE.ITEM) then
                    table.insert(garbage, {reward = reward, isGarbage = true})
                end
            end
        end

        -- boss
        if bossCount == 1 then
            bosses[1].rewards = rewards
        else
            local index = math.random(1, bossCount)
            local rewardCount = #rewards
            while rewardCount > 0 do
                if rewardCount == 1 then
                    if bosses[index].rewards == nil then
                        bosses[index].rewards = {}
                    end
                    table.insert(bosses[index].rewards, rewards[1])
                    break
                else
                    local itemIndex = math.random(1, rewardCount)
                    if bosses[index].rewards == nil then
                        bosses[index].rewards = {}
                    end
                    table.insert(bosses[index].rewards, rewards[itemIndex])
                    table.remove(rewards, itemIndex)
                    rewardCount = rewardCount - 1
                    index = math.random(1, bossCount)
                end
            end
        end

        -- enemy
        if enemyCount == 1 then
            enemies[1].rewards = garbage
        elseif enemyCount > 0 then
            local index = math.random(1, enemyCount)
            local garbageCount = #garbage
            while garbageCount > 0 do
                if garbageCount == 1 then
                    if enemies[index].rewards == nil then
                        enemies[index].rewards = {}
                    end
                    table.insert(enemies[index].rewards, garbage[1])
                    break
                else
                    local itemIndex = math.random(1, garbageCount)
                    if enemies[index].rewards == nil then
                        enemies[index].rewards = {}
                    end
                    table.insert(enemies[index].rewards, garbage[itemIndex])
                    table.remove(garbage, itemIndex)
                    garbageCount = garbageCount - 1
                    index = math.random(1, enemyCount)
                end
            end
        else
            -- no enemy
            if bossCount == 1 then
                for _, item in pairs(garbage) do
                    table.insert(bosses[1].rewards, item)
                end
            else
                local index = math.random(1, bossCount)
                local rewardCount = #garbage
                while rewardCount > 0 do
                    if rewardCount == 1 then
                        if bosses[index].rewards == nil then
                            bosses[index].rewards = {}
                        end
                        table.insert(bosses[index].rewards, garbage[1])
                        break
                    else
                        local itemIndex = math.random(1, rewardCount)
                        if bosses[index].rewards == nil then
                            bosses[index].rewards = {}
                        end
                        table.insert(bosses[index].rewards, garbage[itemIndex])
                        table.remove(garbage, itemIndex)
                        rewardCount = rewardCount - 1
                        index = math.random(1, bossCount)
                    end
                end
            end
        end
    else
        local rewards = {}
        if self._dungeonConfig.awards ~= nil then
            for _, reward in pairs(self._dungeonConfig.awards) do
                if reward.npcId == nil and (remote.items:getItemType(reward.type) == ITEM_TYPE.MONEY or remote.items:getItemType(reward.type) == ITEM_TYPE.ITEM) then
                    table.insert(rewards, {reward = reward, isGarbage = false})
                end
            end
        end
        if self._dungeonConfig.awards2 ~= nil then
            for _, reward in pairs(self._dungeonConfig.awards2) do
                if reward.npcId == nil and (remote.items:getItemType(reward.type) == ITEM_TYPE.MONEY or remote.items:getItemType(reward.type) == ITEM_TYPE.ITEM) then
                    table.insert(rewards, {reward = reward, isGarbage = true})
                end
            end
        end

        if enemyCount == 1 then
            enemies[1].rewards = rewards
        elseif enemyCount > 0 then
            local index = math.random(1, enemyCount)
            local rewardCount = #rewards
            while rewardCount > 0 do
                if rewardCount == 1 then
                    if enemies[index].rewards == nil then
                        enemies[index].rewards = {}
                    end
                    table.insert(enemies[index].rewards, rewards[1])
                    break
                else
                    local itemIndex = math.random(1, rewardCount)
                    if enemies[index].rewards == nil then
                        enemies[index].rewards = {}
                    end
                    table.insert(enemies[index].rewards, rewards[itemIndex])
                    table.remove(rewards, itemIndex)
                    rewardCount = rewardCount - 1
                    index = math.random(1, enemyCount)
                end
            end
        end
    end

    if DEBUG > 0 then
        print("Assign rewards = ")
        for _, monsterInfo in ipairs(monsters) do
            if monsterInfo.rewards ~= nil then
                print("npc id = " .. monsterInfo.npc_id)
                printTable(monsterInfo.rewards)
            end
        end
    end

end

function QBattleManager:getDeadEnemyRewards(isPrint)
    local rewards = {}
    for i, item in ipairs(self._monsters) do
        if item.created == true and item.death_logged == true and item.rewards ~= nil then
            -- if isPrint == true and item.rewards ~= nil and #item.rewards > 0 then
            --     if self._isActiveDungeon == true and self._activeDungeonType == DUNGEON_TYPE.ACTIVITY_TIME and item.rewardIndex ~= nil then 
            --         print(item.npc:getActorID() .. " at index " .. tostring(item.rewardIndex) .. " has reward:")
            --     else
            --         print(item.npc:getActorID() .. " has reward:")
            --     end
            -- end
            for _, reward in ipairs(item.rewards) do
                table.insert(rewards, reward.reward)
                -- if isPrint == true then
                --     printTable(reward)
                -- end
            end
        end
    end
    return rewards
end

function QBattleManager:getDungeonConfig()
    return self._dungeonConfig
end

function QBattleManager:isActiveDungeon()
    return self._isActiveDungeon
end

function QBattleManager:getActiveDungeonType()
    return self._activeDungeonType
end

function QBattleManager:isBattleEnded()
    return self._ended
end

function QBattleManager:getResult()
    return self._result
end

function QBattleManager:isPVPMode()
    return self._dungeonConfig.isPVPMode or false
end

function QBattleManager:isPVPMultipleWave()
    -- return true
    return self._dungeonConfig.isPVPMultipleWave
end

function QBattleManager:isInArena()
    return self._dungeonConfig.isArena or false
end

function QBattleManager:isInSilvesArena()
    return self._dungeonConfig.isSilvesArena or false
end

function QBattleManager:isInFightClub()
    return self._dungeonConfig.isFightClub or false
end

function QBattleManager:isInSparField()
    return self._dungeonConfig.isSparField or false
end

function QBattleManager:isInSancruary()
    return self._dungeonConfig.isSancruary or false
end

function QBattleManager:isArenaAllowControl()
    if self._dungeonConfig.isGlory then
        return ENABLE_GLORY_CONTROL
    elseif self._dungeonConfig.isTotemChallenge then
        return true
    elseif self._dungeonConfig.isFightClub then
        return ENABLE_FIGHT_CLUB_CONTROL
    else
        return ENABLE_AREAN_CONTROL
    end
end

function QBattleManager:isForceAuto()
    return self._dungeonConfig.forceAuto or false
end

function QBattleManager:isInSunwell()
    return self._dungeonConfig.isSunwell or false
end

function QBattleManager:isInGlory()
    return self._dungeonConfig.isGlory or false
end

function QBattleManager:isInGloryArena()
    return self._dungeonConfig.isGloryArena or false
end

function QBattleManager:isInStormArena()
    return self._dungeonConfig.isStormArena or false
end

function QBattleManager:isInFriend()
    return self._dungeonConfig.isFriend or false
end

function QBattleManager:isInSilverMine()
    return self._dungeonConfig.isSilverMine or false
end

function QBattleManager:isInPlunder()
    return self._dungeonConfig.isPlunder or false
end

function QBattleManager:isInThunder()
    if self:isInEditor() then
        return self._dungeonConfig.isThunder or db:getThunderWinConditionByDungeonId(self._dungeonConfig.id)
    else
        return self._dungeonConfig.isThunder
    end
end

function QBattleManager:isInThunderElite()
    return self._dungeonConfig.isThunder and self._dungeonConfig.waveType == "ELITE_WAVE"
end

function QBattleManager:isInMaritime()
    return self._dungeonConfig.isMaritime or false
end

function QBattleManager:isInBlackRock()
    return self._dungeonConfig.isBlackRock or false
end

function QBattleManager:isInUnionDragonWar()
    return self._dungeonConfig.isUnionDragonWar or false
end

function QBattleManager:isInMetalCity()
    return self._dungeonConfig.isMetalCity or false
end

function QBattleManager:isLocalFight()
    return self._dungeonConfig.isLocalFight or false
end

function QBattleManager:isInDragon()
    return self._dungeonConfig.isInDragon or false
end

function QBattleManager:isSunwellAllowControl()
    if QBattleManager.SUNWELL_ALLOW_CONTROL == nil then
        local result = true
        local globalConfig = db:getConfiguration()
        if globalConfig.SUNWELL_ALLOW_CONTROL ~= nil and globalConfig.SUNWELL_ALLOW_CONTROL.value ~= nil then
            result = globalConfig.SUNWELL_ALLOW_CONTROL.value 
        end
        QBattleManager.SUNWELL_ALLOW_CONTROL = result
    end
    return QBattleManager.SUNWELL_ALLOW_CONTROL
end

function QBattleManager:isInTutorial()
    return self._dungeonConfig.isTutorial or false
end

function QBattleManager:isPaused()
    return self._paused
end

function QBattleManager:isPausedBetweenWave()
    return self._pauseBetweenWaves
end

function QBattleManager:isPauseRecord()
    return self._pauseRecord
end

function QBattleManager:isInEditor()
    return self._dungeonConfig.isEditor or false
end

function QBattleManager:isInReplay()
    return self._dungeonConfig.isReplay or false
end

function QBattleManager:isInQuick()
    return self._dungeonConfig.isQuick or false
end

function QBattleManager:isInSilvesArenaReplayBattleModule()
    return self._dungeonConfig.isSilvesArenaBattle or false
end

function QBattleManager:isInWelfare()
    return self._dungeonConfig.isWelfare or false
end

function QBattleManager:isInNightmare()
    return self._dungeonConfig.isNightmare or false
end

function QBattleManager:getTime()
    return self._battleTime
end

function QBattleManager:getTimeForEffect()
    return self._battleTimeForEffect
end

function QBattleManager:getTimeNoTimeGear()
    return self._battleTimeNoTimeGear
end

function QBattleManager:getDungeonEnemyCount()
    if self._dungeonEnemyCount == nil then
        self._dungeonEnemyCount = 0
        for _, item in ipairs(self._monsters) do
            if item.probability == nil and item.npc_summoned == nil then
                self._dungeonEnemyCount = self._dungeonEnemyCount + 1
            end
        end
    end
    return self._dungeonEnemyCount
end

function QBattleManager:getDungeonDeadEnemyCount()
    local count = 0
    for _, item in ipairs(self._monsters) do
        if item.probability == nil and item.npc_summoned == nil and item.created == true and item.death_logged == true then
            count = count + 1
        end
    end
    return count
end

function QBattleManager:_applyNotRecommendDebuff()
    local _force = self._dungeonConfig.force
    if not self._dungeonConfig.isRecommend and _force then
        local difficulty_level = self._dungeonConfig.difficulty_level
        local dbuff_value = self._dungeonConfig.dbuff_value
        if difficulty_level and dbuff_value then
            difficulty_level = tostring(difficulty_level)
            dbuff_value = tostring(dbuff_value)
            local force = _force
            local levels = string.split(difficulty_level, ";")
            local values = string.split(dbuff_value, ";")
            if #levels == #values then
                local select_value = nil
                local select_level = nil
                for i, level in ipairs(levels) do
                    level = tonumber(level)
                    if force < level then
                        if select_level == nil or select_level > level then
                            select_value = values[i]
                        end
                    end
                end
                if select_value then
                    local index = string.find(select_value, "%", 1, true)
                    if index == nil then
                        select_value = tonumber(select_value)
                    else
                        select_value = tonumber(string.sub(select_value, 1, index - 1)) / 100
                    end
                    for _, hero in ipairs(self._heroes) do
                        hero:removePropertyValue("physical_damage_percent_beattack", "difficultyDebuff")
                        hero:removePropertyValue("magic_damage_percent_beattack", "difficultyDebuff")
                        hero:insertPropertyValue("physical_damage_percent_beattack", "difficultyDebuff", "+", select_value)
                        hero:insertPropertyValue("magic_damage_percent_beattack", "difficultyDebuff", "+", select_value)
                    end
                    for _, enemy in ipairs(self._enemies) do
                        enemy:removePropertyValue("physical_damage_percent_beattack_reduce", "difficultyDebuff")
                        enemy:removePropertyValue("magic_damage_percent_beattack_reduce", "difficultyDebuff")
                        enemy:insertPropertyValue("physical_damage_percent_beattack_reduce", "difficultyDebuff", "+", select_value)
                        enemy:insertPropertyValue("magic_damage_percent_beattack_reduce", "difficultyDebuff", "+", select_value)
                    end
                    self._difficultyDebuffValue = select_value
                end
            end
        end
    end
end

function QBattleManager:_applyNotRecommendDebuffForMonster(enemy)
    local value = self._difficultyDebuffValue
    if value then
        enemy:removePropertyValue("physical_damage_percent_beattack_reduce", "difficultyDebuff")
        enemy:removePropertyValue("magic_damage_percent_beattack_reduce", "difficultyDebuff")
        enemy:insertPropertyValue("physical_damage_percent_beattack_reduce", "difficultyDebuff", "+", value)
        enemy:insertPropertyValue("magic_damage_percent_beattack_reduce", "difficultyDebuff", "+", value)
    end
end

function QBattleManager:_applyRecommendBuff()
    if self._dungeonConfig.isRecommend then
        local buffAmmount = self._dungeonConfig.active_buff or 0
        for _, hero in ipairs(self._heroes) do
            hero:removePropertyValue("attack_percent", "activeBuff")
            hero:removePropertyValue("hp_percent", "activeBuff")
            hero:removePropertyValue("armor_physical", "activeBuff")
            hero:removePropertyValue("armor_magic", "activeBuff")
            hero:insertPropertyValue("attack_percent", "activeBuff", "+", buffAmmount)
            hero:insertPropertyValue("hp_percent", "activeBuff", "+", buffAmmount)
            hero:insertPropertyValue("armor_physical", "activeBuff", "+", hero:getPhysicalArmor() * buffAmmount)
            hero:insertPropertyValue("armor_magic", "activeBuff", "+", hero:getMagicArmor() * buffAmmount)
            if not IsServerSide then
                local view = app.scene:getActorViewFromModel(hero)
                if view then view:hideHpView() end
            end
        end
    end
end

function QBattleManager:_applyLostCountBuff()
    local lostCount = math.min(self._dungeonConfig.lostCount or 0, 5)
    local buffAmmount = self._dungeonConfig.defeat_buff or 0
    if lostCount > 0 and self._dungeonConfig.isPassUnlockDungeon then
        for _, hero in ipairs(self._heroes) do
            hero:removePropertyValue("attack_percent", "lostCount")
            hero:removePropertyValue("hp_percent", "lostCount")
            hero:removePropertyValue("armor_physical", "lostCount")
            hero:removePropertyValue("armor_magic", "lostCount")
            hero:insertPropertyValue("attack_percent", "lostCount", "+", lostCount * buffAmmount)
            hero:insertPropertyValue("hp_percent", "lostCount", "+", lostCount * buffAmmount)
            hero:insertPropertyValue("armor_physical", "lostCount", "+", hero:getPhysicalArmor() * lostCount * buffAmmount)
            hero:insertPropertyValue("armor_magic", "lostCount", "+", hero:getMagicArmor() * lostCount * buffAmmount)
            if not IsServerSide then
                local view = app.scene:getActorViewFromModel(hero)
                if view then view:hideHpView() end
            end
        end
    end
end

function QBattleManager:_applyEasyBuff()
    if self._dungeonConfig.isEasy then
        local buff_value = self._dungeonConfig.buff_value
        if buff_value then
            for _, hero in ipairs(self._heroes) do
                hero:removePropertyValue("attack_percent", "easyBuff")
                hero:removePropertyValue("hp_percent", "easyBuff")
                hero:removePropertyValue("armor_physical", "easyBuff")
                hero:removePropertyValue("armor_magic", "easyBuff")
                hero:insertPropertyValue("attack_percent", "easyBuff", "+", buff_value)
                hero:insertPropertyValue("hp_percent", "easyBuff", "+", buff_value)
                hero:insertPropertyValue("armor_physical", "easyBuff", "+", hero:getPhysicalArmor() * buff_value)
                hero:insertPropertyValue("armor_magic", "easyBuff", "+", hero:getMagicArmor() * buff_value)
                if not IsServerSide then
                    local view = app.scene:getActorViewFromModel(hero)
                    if view then view:hideHpView() end
                end
                hero:setFullHp()
            end
        end
    end
end

function QBattleManager:_applySunwarEasyBuff()
    if self:isInSunwell() then
        local dungeon = self._dungeonConfig
        local force, wave, chapter, sunwarTodayPassedWaveCount = dungeon.force, dungeon.sunwarWave, dungeon.sunwarChapter, dungeon.sunwarTodayPassedWaveCount
        sunwarTodayPassedWaveCount = sunwarTodayPassedWaveCount or 0
        if force and wave and chapter and sunwarTodayPassedWaveCount then
            local db = QStaticDatabase:sharedDatabase()
            local config = db:getSunWarDungeonRageConfig(chapter, wave)
            local coefficient = db:getSunWarEnemyCoefficient(sunwarTodayPassedWaveCount)
            local upperForce = config.standard_upper * coefficient
            if self._dungeonConfig.force >= upperForce then
                local buff_value = config.buff_value
                if buff_value then
                    for _, hero in ipairs(self._heroes) do
                        hero:removePropertyValue("attack_percent", "SunwarEasyBuff")
                        hero:removePropertyValue("hp_percent", "SunwarEasyBuff")
                        hero:removePropertyValue("armor_physical", "SunwarEasyBuff")
                        hero:removePropertyValue("armor_magic", "SunwarEasyBuff")
                        hero:insertPropertyValue("attack_percent", "SunwarEasyBuff", "+", buff_value)
                        hero:insertPropertyValue("hp_percent", "SunwarEasyBuff", "+", buff_value)
                        hero:insertPropertyValue("armor_physical", "SunwarEasyBuff", "+", hero:getPhysicalArmor() * buff_value)
                        hero:insertPropertyValue("armor_magic", "SunwarEasyBuff", "+", hero:getMagicArmor() * buff_value)
                        if not IsServerSide then
                            local view = app.scene:getActorViewFromModel(hero)
                            if view then view:hideHpView() end
                        end
                    end
                end
            end
        end
    end
end

function QBattleManager:_applySunwarHardDebuff()
    if self:isInSunwell() then
        local dungeon = self._dungeonConfig
        local force, enemyForce, wave, chapter, sunwarTodayPassedWaveCount = dungeon.force, dungeon.enemyForce, dungeon.sunwarWave, dungeon.sunwarChapter, dungeon.sunwarTodayPassedWaveCount
        sunwarTodayPassedWaveCount = sunwarTodayPassedWaveCount or 0
        if force and enemyForce and wave and chapter and sunwarTodayPassedWaveCount then
            local db = QStaticDatabase:sharedDatabase()
            local config = db:getSunWarDungeonRageConfig(chapter, wave)
            local coefficient = db:getSunWarEnemyCoefficient(sunwarTodayPassedWaveCount)
            local difficulty_level = tostring(config.difficulty_level_lower)
            local debuff_value = tostring(config.debuff_value)
            local levels = string.split(difficulty_level, ";")
            local values = string.split(debuff_value, ";")
            if #levels == #values then
                local select_value = nil
                local select_level = nil
                for i, level in ipairs(levels) do
                    level = enemyForce * tonumber(level)
                    if force < level then
                        if select_level == nil or select_level > level then
                            select_value = values[i]
                        end
                    end
                end
                if select_value then
                    local index = string.find(select_value, "%", 1, true)
                    if index == nil then
                        select_value = tonumber(select_value)
                    else
                        select_value = tonumber(string.sub(select_value, 1, index - 1)) / 100
                    end
                    for _, hero in ipairs(self._heroes) do
                        hero:removePropertyValue("physical_damage_percent_beattack", "sunwarHardDebuff")
                        hero:removePropertyValue("magic_damage_percent_beattack", "sunwarHardDebuff")
                        hero:insertPropertyValue("physical_damage_percent_beattack", "sunwarHardDebuff", "+", select_value)
                        hero:insertPropertyValue("magic_damage_percent_beattack", "sunwarHardDebuff", "+", select_value)
                    end
                    for _, enemy in ipairs(self._enemies) do
                        enemy:removePropertyValue("physical_damage_percent_beattack_reduce", "sunwarHardDebuff")
                        enemy:removePropertyValue("magic_damage_percent_beattack_reduce", "sunwarHardDebuff")
                        enemy:insertPropertyValue("physical_damage_percent_beattack_reduce", "sunwarHardDebuff", "+", select_value)
                        enemy:insertPropertyValue("magic_damage_percent_beattack_reduce", "sunwarHardDebuff", "+", select_value)
                    end
                    self._sunwarDebuffValue = select_value
                end
            end
        end
        -- local sunwarBonusForDefender = self._dungeonConfig.sunwarBonusForDefender
        -- if sunwarBonusForDefender then
        --     for _, enemy in ipairs(self._enemies) do
        --         enemy:removePropertyValue("hp_percent", "sunwarHardDebuff")
        --         enemy:removePropertyValue("attack_percent", "sunwarHardDebuff")
        --         enemy:removePropertyValue("armor_physical_percent", "sunwarHardDebuff")
        --         enemy:removePropertyValue("armor_magic_percent", "sunwarHardDebuff")
        --         enemy:insertPropertyValue("hp_percent", "sunwarHardDebuff", "+", sunwarBonusForDefender)
        --         enemy:insertPropertyValue("attack_percent", "sunwarHardDebuff", "+", sunwarBonusForDefender)
        --         enemy:insertPropertyValue("armor_physical_percent", "sunwarHardDebuff", "+", sunwarBonusForDefender)
        --         enemy:insertPropertyValue("armor_magic_percent", "sunwarHardDebuff", "+", sunwarBonusForDefender)
        --     end
        -- end
    end
end

function QBattleManager:_applySunwarHardDebuffForEnemy(enemy)
    local value = self._sunwarDebuffValue
    if value then
        enemy:removePropertyValue("physical_damage_percent_beattack_reduce", "sunwarHardDebuff")
        enemy:removePropertyValue("magic_damage_percent_beattack_reduce", "sunwarHardDebuff")
        enemy:insertPropertyValue("physical_damage_percent_beattack_reduce", "sunwarHardDebuff", "+", value)
        enemy:insertPropertyValue("magic_damage_percent_beattack_reduce", "sunwarHardDebuff", "+", value)
    end
    local value = self._dungeonConfig.sunwarBonusForDefender
    if value then
        enemy:removePropertyValue("hp_percent", "sunwarHardDebuff")
        enemy:removePropertyValue("attack_percent", "sunwarHardDebuff")
        enemy:removePropertyValue("armor_physical_percent", "sunwarHardDebuff")
        enemy:removePropertyValue("armor_magic_percent", "sunwarHardDebuff")
        enemy:insertPropertyValue("hp_percent", "sunwarHardDebuff", "+", value)
        enemy:insertPropertyValue("attack_percent", "sunwarHardDebuff", "+", value)
        enemy:insertPropertyValue("armor_physical_percent", "sunwarHardDebuff", "+", value)
        enemy:insertPropertyValue("armor_magic_percent", "sunwarHardDebuff", "+", value)
    end
end

function QBattleManager:_applyDungeonBuffs()
    local function applyBuff(actor, buffs)
        for _, buff_id in pairs(buffs) do
            actor:applyBuff(buff_id)
        end
    end
    if (self:isInThunder() and not self:isInThunderElite())
        or self:isInBlackRock()
    then
        local buffs = self._dungeonConfig.buffs
        if type(buffs) == "table" then
            for _, actor in ipairs(self._heroes) do
                applyBuff(actor, buffs)
            end
            for _, actor in ipairs(self._supportHeroes) do
                applyBuff(actor, buffs)
            end
            for _, actor in ipairs(self._supportHeroes2) do
                applyBuff(actor, buffs)
            end
            for _, actor in ipairs(self._supportHeroes3) do
                applyBuff(actor, buffs)
            end
        end
    end
end

function QBattleManager:_applySunWarBuffs(actor)
    if self:isInSunwell() then
        if IsServerSide or self:isInReplay() then
            local id = self._dungeonConfig.sunWarBuffID
            if id then
                local prop = db:getSunWarBuffConfigByID(id)
                actor:addExtendsProp(prop, "SunWarBuff")
            end
        else
            local prop, id = remote.sunWar:getHeroBuffPropTable()
            actor:addExtendsProp(prop, "SunWarBuff")
            self._dungeonConfig.sunWarBuffID = id
        end
    end
end

function QBattleManager:_applySparfieldLengendaryBuff(actor)
    local legendHeroIds = self._dungeonConfig.legendHeroIds
    if legendHeroIds and self:isInSparField() then
        local prop = db:getSparFieldLegend()
        for _, legendHeroId in ipairs(legendHeroIds) do
            if actor:getActorID() == legendHeroId then
                actor._actorProp:addExtendsProp(prop, "EXTENDS_PROP_SPARFIELD")
                break
            end
        end
    end
end

function QBattleManager:getSunwellEnemyHP(enemy)
    return self._sunwellEnemyHP[enemy]
end

function QBattleManager:getSunwellEnemyMaxHP(enemy)
    return self._sunwellEnemyMaxHP[enemy]
end

function QBattleManager:_applySupportHeroAttributes()
    if self:isSotoTeamInherit() then
        for _, actor in ipairs(self._heroes) do
            self:_applyAttributesForHero(actor, self._candidateHeroes)
        end
    end
    for _, supp in ipairs(self._supportHeroes) do
        self:_applyAttributesForHero(supp, self._heroes)
        self:_applyAttributesForHero(supp, self._candidateHeroes) -- 替补英雄
    end
    for _, supp in ipairs(self._supportHeroes2) do
        self:_applyAttributesForHero(supp, self._heroes)
        self:_applyAttributesForHero(supp, self._candidateHeroes)
    end
    for _, supp in ipairs(self._supportHeroes3) do
        self:_applyAttributesForHero(supp, self._heroes)
        self:_applyAttributesForHero(supp, self._candidateHeroes)
    end
    if self:isSotoTeamEquilibrium() then
        self:applyPropertiesForEquilibrium(self._heroes[1]:getPropertyDict(), self._heroes, self._candidateHeroes)
    end
end

function QBattleManager:_applySupportEnemyAttributes(hpFromServerIDs)
    if self:isSotoTeamInherit() then
        for _, enemy in ipairs(self._enemies) do
            self:_applyAttributesForHero(enemy, self._candidateEnemies, hpFromServerIDs)
        end
    end
    for _, supp in ipairs(self._supportEnemies) do
        self:_applyAttributesForHero(supp, self._enemies, hpFromServerIDs)
        self:_applyAttributesForHero(supp, self._candidateEnemies, hpFromServerIDs)
    end
    for _, supp in ipairs(self._supportEnemies2) do
        self:_applyAttributesForHero(supp, self._enemies, hpFromServerIDs)
        self:_applyAttributesForHero(supp, self._candidateEnemies, hpFromServerIDs)
    end
    for _, supp in ipairs(self._supportEnemies3) do
        self:_applyAttributesForHero(supp, self._enemies, hpFromServerIDs)
        self:_applyAttributesForHero(supp, self._candidateEnemies, hpFromServerIDs)
    end
    if self:isSotoTeamEquilibrium() then
        self:applyPropertiesForEquilibrium(self._enemies[1]:getPropertyDict(), self._enemies, self._candidateEnemies)
    end
end

function QBattleManager:_applyAttributesForHero(supp, targetHeros, hpFromServerIDs)
    local attack_value = supp:_getActorNumberPropertyValue("attack_value")
    local attack_percent = supp:_getActorNumberPropertyValue("attack_percent")
    local hp_value = supp:_getActorNumberPropertyValue("hp_value")
    local hp_percent = supp:_getActorNumberPropertyValue("hp_percent")
    local armor_physical = supp:getPhysicalArmor()
    local armor_magic = supp:getMagicArmor()
    local hit_chance = supp:getHit() / 100
    local dodge_chance = supp:getDodge() / 100
    local hit_rating = supp:getHitLevel()
    local dodge_rating = supp:getDodgeLevel()
    local block_rating = supp:getBlockLevel()
    local wreck_rating = supp:getWreckLevel()
    local critical_chance = supp:getCrit() / 100
    local critical_reduce_chance = supp:getCritReduce() / 100
    local critical_rating = supp:getCritLevel()
    local critical_reduce_rating = supp:getCritReduceLevel()
    local critical_damage = supp:getBaseCritDamage() - 1
    local critical_damage_resist = supp:getBaseCritDamageResist()
    local attackspeed_chance = supp:getMaxHaste() / 100
    local block_chance = supp:getBlock()/100
    local wreck_chance = supp:getWreck()/100
    local physical_damage_percent_beattack = supp:getPhysicalDamagePercentBeattack()
    local physical_damage_percent_beattack_reduce = supp:getPhysicalDamagePercentBeattackReduce()
    local physical_damage_percent_attack = supp:getOriginPhysicalDamagePercentAttack()
    local magic_damage_percent_beattack = supp:getMagicDamagePercentBeattack()
    local magic_damage_percent_beattack_reduce = supp:getMagicDamagePercentBeattackReduce()
    local magic_damage_percent_attack = supp:getOriginMagicDamagePercentAttack()
    local magic_treat_percent_attack = supp:getOriginMagicTreatPercentAttack()
    local magic_treat_percent_beattack = supp:getOriginMagicTreatPercentUnderAttack()
    local magic_penetration_value = supp:_getActorNumberPropertyValue("magic_penetration_value")
    local magic_penetration_percent = supp:_getActorNumberPropertyValue("magic_penetration_percent")
    local physical_penetration_value = supp:_getActorNumberPropertyValue("physical_penetration_value")
    local physical_penetration_percent = supp:_getActorNumberPropertyValue("physical_penetration_percent")
    local soul_damage_percent_beattack_reduce = supp:_getActorNumberPropertyValue("soul_damage_percent_beattack_reduce")
    local soul_damage_percent_attack = supp:_getActorNumberPropertyValue("soul_damage_percent_attack")

    local suppPropInfo = supp:getActorPropInfo()

    local pve_damage_percent_attack = supp:getPVEDamagePercentAttack() - suppPropInfo:getPVEDamageAttackPercent() * 1
    local pve_damage_percent_beattack = supp:getPVEDamagePercentBeattack() - suppPropInfo:getPVEDamageBeattackPercent() * 1

    local pvp_physical_damage_percent_attack = supp:getPVPPhysicalAttackPercent() - suppPropInfo:getArchaeologyPVPPhysicalAttackPercent() * 1
    local pvp_magic_damage_percent_attack = supp:getPVPMagicAttackPercent() - suppPropInfo:getArchaeologyPVPMagicAttackPercent() * 1
    local pvp_physical_damage_percent_beattack_reduce = supp:getOriginPVPPhysicalReducePercent() - suppPropInfo:getArchaeologyPVPPhysicalReducePercent() * 1
    local pvp_magic_damage_percent_beattack_reduce = supp:getOriginPVPMagicReducePercent() - suppPropInfo:getArchaeologyPVPMagicReducePercent() * 1
    for _, hero in ipairs(targetHeros) do
        hero:removePropertyValue("attack_value_support", supp)
        hero:removePropertyValue("hp_value_support", supp)
        hero:removePropertyValue("armor_physical", supp)
        hero:removePropertyValue("armor_magic", supp)
        hero:removePropertyValue("hit_chance", supp)
        hero:removePropertyValue("dodge_chance", supp)
        hero:removePropertyValue("hit_rating", supp)
        hero:removePropertyValue("dodge_rating", supp)
        hero:removePropertyValue("block_rating", supp)
        hero:removePropertyValue("wreck_rating", supp)
        hero:removePropertyValue("critical_chance", supp)
        hero:removePropertyValue("crit_reduce_chance", supp)
        hero:removePropertyValue("critical_rating", supp)
        hero:removePropertyValue("crit_reduce_rating", supp)
        hero:removePropertyValue("critical_damage", supp)
        hero:removePropertyValue("critical_damage_resist", supp)
        hero:removePropertyValue("attackspeed_chance", supp)
        hero:removePropertyValue("block_chance", supp)
        hero:removePropertyValue("wreck_chance", supp)
        hero:removePropertyValue("physical_damage_percent_beattack", supp)
        hero:removePropertyValue("physical_damage_percent_beattack_reduce", supp)
        hero:removePropertyValue("physical_damage_percent_attack", supp)
        hero:removePropertyValue("magic_damage_percent_beattack", supp)
        hero:removePropertyValue("magic_damage_percent_beattack_reduce", supp)
        hero:removePropertyValue("magic_damage_percent_attack", supp)
        hero:removePropertyValue("magic_treat_percent_attack", supp)
        hero:removePropertyValue("magic_treat_percent_beattack", supp)
        hero:removePropertyValue("pvp_physical_damage_percent_attack", supp)
        hero:removePropertyValue("pvp_magic_damage_percent_attack", supp)
        hero:removePropertyValue("pvp_physical_damage_percent_beattack_reduce", supp)
        hero:removePropertyValue("pvp_magic_damage_percent_beattack_reduce", supp)

        hero:removePropertyValue("pve_damage_percent_attack", supp)
        hero:removePropertyValue("pve_damage_percent_beattack", supp)

        hero:removePropertyValue("magic_penetration_value", supp)
        hero:removePropertyValue("magic_penetration_percent", supp)
        hero:removePropertyValue("physical_penetration_value", supp)
        hero:removePropertyValue("physical_penetration_percent", supp)
        hero:removePropertyValue("soul_damage_percent_beattack_reduce", supp)
        hero:removePropertyValue("soul_damage_percent_attack", supp)

        hero:insertPropertyValue("attack_value_support", supp, "+",  (attack_value * (attack_percent + 1)) / 4)
        if nil ~= hpFromServerIDs and hpFromServerIDs[hero:getActorID()] then 
            hero:_disableHpChangeByPropertyChange()
        end

        hero:insertPropertyValue("hp_value_support", supp, "+", (hp_value * (hp_percent + 1)) / 4)
        if nil ~= hpFromServerIDs and hpFromServerIDs[hero:getActorID()] then 
            hero:_enableHpChangeByPropertyChange()
        end

        hero:insertPropertyValue("armor_physical", supp, "+", armor_physical / 4)
        hero:insertPropertyValue("armor_magic", supp, "+", armor_magic / 4)
        hero:insertPropertyValue("hit_chance", supp, "+", hit_chance / 4)
        hero:insertPropertyValue("dodge_chance", supp, "+", dodge_chance / 4)
        hero:insertPropertyValue("hit_rating", supp, "+", hit_rating / 4)
        hero:insertPropertyValue("dodge_rating", supp, "+", dodge_rating / 4)
        hero:insertPropertyValue("block_rating", supp, "+", block_rating / 4)
        hero:insertPropertyValue("wreck_rating", supp, "+", wreck_rating / 4)
        hero:insertPropertyValue("critical_chance", supp, "+", critical_chance / 4)
        hero:insertPropertyValue("crit_reduce_chance", supp, "+", critical_reduce_chance / 4)
        hero:insertPropertyValue("critical_rating", supp, "+", critical_rating / 4)
        hero:insertPropertyValue("crit_reduce_rating", supp, "+", critical_reduce_rating / 4)
        hero:insertPropertyValue("critical_damage", supp, "+", critical_damage / 4)
        hero:insertPropertyValue("critical_damage_resist", supp, "+", critical_damage_resist / 4)
        hero:insertPropertyValue("attackspeed_chance", supp, "+", attackspeed_chance / 4)
        hero:insertPropertyValue("block_chance", supp, "+", block_chance / 4)
        hero:insertPropertyValue("wreck_chance", supp, "+", wreck_chance / 4)
        hero:insertPropertyValue("physical_damage_percent_beattack", supp, "+", physical_damage_percent_beattack / 4)
        hero:insertPropertyValue("physical_damage_percent_beattack_reduce", supp, "+", physical_damage_percent_beattack_reduce / 4)
        hero:insertPropertyValue("physical_damage_percent_attack", supp, "+", physical_damage_percent_attack / 4)
        hero:insertPropertyValue("magic_damage_percent_beattack", supp, "+", magic_damage_percent_beattack / 4)
        hero:insertPropertyValue("magic_damage_percent_beattack_reduce", supp, "+", magic_damage_percent_beattack_reduce / 4)
        hero:insertPropertyValue("magic_damage_percent_attack", supp, "+", magic_damage_percent_attack / 4)
        hero:insertPropertyValue("magic_treat_percent_attack", supp, "+", magic_treat_percent_attack / 4)
        hero:insertPropertyValue("magic_treat_percent_beattack", supp, "+", magic_treat_percent_beattack / 4)
        hero:insertPropertyValue("pvp_physical_damage_percent_attack", supp, "+", pvp_physical_damage_percent_attack / 4)
        hero:insertPropertyValue("pvp_magic_damage_percent_attack", supp, "+", pvp_magic_damage_percent_attack / 4)
        hero:insertPropertyValue("pvp_physical_damage_percent_beattack_reduce", supp, "+", pvp_physical_damage_percent_beattack_reduce / 4)
        hero:insertPropertyValue("pvp_magic_damage_percent_beattack_reduce", supp, "+", pvp_magic_damage_percent_beattack_reduce / 4)
        
        hero:insertPropertyValue("pve_damage_percent_attack", supp, "+", pve_damage_percent_attack / 4)
        hero:insertPropertyValue("pve_damage_percent_beattack", supp, "+", pve_damage_percent_beattack / 4)
        hero:insertPropertyValue("magic_penetration_support", supp, "+", magic_penetration_value * (magic_penetration_percent + 1) / 4)
        hero:insertPropertyValue("physical_penetration_support", supp, "+", physical_penetration_value * (physical_penetration_percent + 1) / 4)
        hero:insertPropertyValue("soul_damage_percent_beattack_reduce", supp, "+", soul_damage_percent_beattack_reduce / 4)
        hero:insertPropertyValue("soul_damage_percent_attack", supp, "+", soul_damage_percent_attack / 4)

        if not IsServerSide then
            local view = app.scene:getActorViewFromModel(hero)
            if view then view:hideHpView() end
        end
    end
end

function QBattleManager:getHeroes()
    if #self._heroes > 0 or #self._deadHeroes > 0 or #self._neutralHeroes > 0 then return self._heroes end

    local hero
    self._heroes = {}

    if self:isInDragon() then
        local heroInfo = 
        {
            actorId = 1002,
            breakthrough = 1,
            level = 1,
            skills = {17, 18, 19}, -- 必须按照 普1、普2、手、其余技能的顺序填写
            exp = 100
        }
        hero = self:_createHero(heroInfo, setmetatable({}, {__index = function(t,k,v)return {} end}), false, true)
        hero:setFixMaxHp(1000000)
        hero:setFullHp()
        hero:resetStateForBattle()
        hero:checkCDReduce()
        table.insert(self._heroes, hero)
        self._actorsByUDID[hero:getUDID()] = hero
        self._battleLog:onHeroDoDHP(hero:getActorID(), 0, hero)
        self._battleLog:addHeroOnStage(hero, hero:getBattleForce())
        return self._heroes
    end
    
    -- 计算羁绊技能，以及组合属性
    local additionalInfos = self:getHeroAdditionInfos() 
    local extraProp = self._dungeonConfig.extraProp or {}

    if self._dungeonConfig.heroInfos ~= nil then
        for _, heroInfo in ipairs(self._dungeonConfig.heroInfos) do
            hero = self:_createHero(heroInfo, additionalInfos, false, true, nil, self:isInTotemChallenge(), self._heroGodArmSkillIds1, extraProp)
            self._hero_skin_infos[heroInfo.actorId] = heroInfo.skinId
            hero:resetStateForBattle()
            -- pvp special skills
            hero:checkCDReduce()
            if self:isPVPMode() and self:isPVPMultipleWave() then
                table.insert(self._heroesWave1, hero)
            end
            table.insert(self._heroes, hero)
            self:_applyHeroAttrEnterRage(hero)
            self._actorsByUDID[hero:getUDID()] = hero
            self._battleLog:onHeroDoDHP(hero:getActorID(), 0, hero)
            self._battleLog:addHeroOnStage(hero, hero:getBattleForce())

        end
    end
    if self._dungeonConfig.supportHeroInfos ~= nil then
        for _, heroInfo in ipairs(self._dungeonConfig.supportHeroInfos) do
            hero = self:_createHero(heroInfo, additionalInfos, not self:isPVPMultipleWave(), true, nil, self:isInTotemChallenge(), self._heroGodArmSkillIds2, extraProp)
            self._hero_skin_infos[heroInfo.actorId] = heroInfo.skinId
            hero:setIsSupportHero(not self:isPVPMode() or not self:isPVPMultipleWave())
            hero:resetStateForBattle()
            if not self:isPVPMultipleWave() then
                hero:setRage(0, true)
            end
            if self:isInArena() then
                hero:setForceAuto(true)
            end
            -- pvp special skills
            hero:checkCDReduce()
            if self:isPVPMode() and self:isPVPMultipleWave() then
                table.insert(self._heroesWave2, hero)
                self:_applyHeroAttrEnterRage(hero)
            else
                table.insert(self._supportHeroes, hero)
            end
            self._actorsByUDID[hero:getUDID()] = hero
            self._battleLog:onHeroDoDHP(hero:getActorID(), 0, hero)
            self._battleLog:addHeroOnStage(hero, hero:getBattleForce())
        end
    end
    if self._dungeonConfig.supportHeroInfos2 ~= nil then
        for _, heroInfo in ipairs(self._dungeonConfig.supportHeroInfos2) do
            hero = self:_createHero(heroInfo, additionalInfos, not self:isPVPMultipleWave(), true, nil, self:isInTotemChallenge(), self._heroGodArmSkillIds3, extraProp)
            self._hero_skin_infos[heroInfo.actorId] = heroInfo.skinId
            hero:setIsSupportHero(not self:isPVPMode() or not self:isPVPMultipleWave())
            hero:resetStateForBattle()
            if not self:isPVPMultipleWave() then
                hero:setRage(0, true)
            end
            if self:isInArena() then
                hero:setForceAuto(true)
            end
            -- pvp special skills
            hero:checkCDReduce()
            if self:isPVPMode() and self:isPVPMultipleWave() then
                table.insert(self._heroesWave3, hero)
                self:_applyHeroAttrEnterRage(hero)
            else
                table.insert(self._supportHeroes2, hero)
            end
            self._actorsByUDID[hero:getUDID()] = hero
            self._battleLog:onHeroDoDHP(hero:getActorID(), 0, hero)
            self._battleLog:addHeroOnStage(hero, hero:getBattleForce())
        end
    end

    if self._dungeonConfig.supportHeroInfos3 ~= nil then
        for _, heroInfo in ipairs(self._dungeonConfig.supportHeroInfos3) do
            hero = self:_createHero(heroInfo, additionalInfos, not self:isPVPMultipleWave(), true, nil, nil, nil, extraProp)
            self._hero_skin_infos[heroInfo.actorId] = heroInfo.skinId
            hero:setIsSupportHero(not self:isPVPMode() or not self:isPVPMultipleWave())
            hero:resetStateForBattle()
            if not self:isPVPMultipleWave() then
                hero:setRage(0, true)
            end
            if self:isInArena() then
                hero:setForceAuto(true)
            end
            -- pvp special skills
            hero:checkCDReduce()
            if self:isPVPMode() and self:isPVPMultipleWave() then
                -- table.insert(self._heroesWave4, hero)
            else
                table.insert(self._supportHeroes3, hero)
            end
            self._actorsByUDID[hero:getUDID()] = hero
            self._battleLog:onHeroDoDHP(hero:getActorID(), 0, hero)
            self._battleLog:addHeroOnStage(hero, hero:getBattleForce())
        end
    end

    if self._dungeonConfig.userAlternateInfos ~= nil then
        for i, heroInfo in ipairs(self._dungeonConfig.userAlternateInfos) do
            hero = self:_createHero(heroInfo, additionalInfos, false, true, nil, nil, self._heroGodArmSkillIds1, extraProp)
            hero:setIsSupportHero(false)
            hero:resetStateForBattle()
            hero:checkCDReduce()
            hero:setIsCandidate(true)
            -- 云顶传承不需要
            if self:isSotoTeam() and not self:isSotoTeamEquilibrium() and not self:isSotoTeamInherit() then
                hero:setRage(global.candidate_actor_initial_rage[i])
            end
            table.insert(self._candidateHeroes, hero)
            self:_applyHeroAttrEnterRage(hero)
            self._actorsByUDID[hero:getUDID()] = hero
            self._battleLog:onHeroDoDHP(hero:getActorID(), 0, hero)
            self._battleLog:addHeroOnStage(hero, hero:getBattleForce())
        end
    end

    if not self:isPVPMode() or not self:isPVPMultipleWave() then
        if self:isPVPMultipleWaveNew() or self:isPVEMultipleWave() then
            if self._dungeonConfig.supportSkillHeroIndex then
                self._supportSkillHero = self._supportHeroes[self._dungeonConfig.supportSkillHeroIndex]
                self._battleLog:setSupportSkillHero(self._supportSkillHero)
            end
            if self._dungeonConfig.supportSkillHeroIndex2 then
                self._supportSkillHero2 = self._supportHeroes[self._dungeonConfig.supportSkillHeroIndex2]
                self._battleLog:setSupportSkillHero2(self._supportSkillHero2)
            end
        else
            if self._dungeonConfig.supportSkillHeroIndex then
                self._supportSkillHero = self._supportHeroes[self._dungeonConfig.supportSkillHeroIndex]
                self._battleLog:setSupportSkillHero(self._supportSkillHero)
            end
            if self._dungeonConfig.supportSkillHeroIndex2 then
                self._supportSkillHero2 = self._supportHeroes2[self._dungeonConfig.supportSkillHeroIndex2]
                self._battleLog:setSupportSkillHero2(self._supportSkillHero2)
            end
            if self._dungeonConfig.supportSkillHeroIndex3 then
                self._supportSkillHero3 = self._supportHeroes3[self._dungeonConfig.supportSkillHeroIndex3]
                self._battleLog:setSupportSkillHero3(self._supportSkillHero3)
            end
        end
    end

    -- summon hunter pet
    for _, hero in ipairs(self._heroes) do
        local pet = hero:summonHunterPet()
    end
    if not self:isPVPMode() or not self:isPVPMultipleWave() then
        for _, hero in ipairs(self._supportHeroes) do
            table.insert(self._heroes, hero) -- 为了能找出宝宝，先把援助魂师放入self._heroes中。然后再移除出去。
            local pet = hero:summonHunterPet(true) -- 援助魂师宝宝不使用ai
            table.remove(self._heroes, #self._heroes)
            if pet then
                app.grid:setActorTo(pet, qccp(-BATTLE_AREA.width / 2, BATTLE_AREA.height / 2))
            end
        end
        for _, hero in ipairs(self._supportHeroes2) do
            table.insert(self._heroes, hero) -- 为了能找出宝宝，先把援助魂师放入self._heroes中。然后再移除出去。
            local pet = hero:summonHunterPet(true) -- 援助魂师宝宝不使用ai
            table.remove(self._heroes, #self._heroes)
            if pet then
                app.grid:setActorTo(pet, qccp(-BATTLE_AREA.width / 2, BATTLE_AREA.height / 2))
            end
        end
        for _, hero in ipairs(self._supportHeroes3) do
            table.insert(self._heroes, hero) -- 为了能找出宝宝，先把援助魂师放入self._heroes中。然后再移除出去。
            local pet = hero:summonHunterPet(true) -- 援助魂师宝宝不使用ai
            table.remove(self._heroes, #self._heroes)
            if pet then
                app.grid:setActorTo(pet, qccp(-BATTLE_AREA.width / 2, BATTLE_AREA.height / 2))
            end
        end
    end

    self:_applyPassiveSkillPropertyForMainHero()
    if not self:isPVPMode() or not self:isPVPMultipleWave() then
        self:_applySupportHeroAttributes()
    end
    if self:isMockBattle() then
        self:_applyMockBattlePropHero()
    end
    self:_applyDungeonBuffs()
    self:_applyRebelFightHeroAttackMultiplier(self._dungeonConfig.rebelAttackPercent)
    self:_applyRebelFightHeroAttackMultiplier(self._dungeonConfig.worldBossAttackPercent)
    self:_applyNotRecommendDebuff()
    self:_applyRecommendBuff()
    self:_applyLostCountBuff()
    self:_applyEasyBuff()
    self:_applySunwarEasyBuff()
    -- self:_applySunwarHardDebuff()

    -- 保存己方的考古学id与回放文件中，虽然在复盘和回放中并不去直接使用考古学id。
    -- if not IsServerSide and not self:isInEditor() and not self:isInReplay() then
    --     if remote.user.archaeologyInfo and remote.user.archaeologyInfo.last_enable_fragment_id then
    --         self._dungeonConfig.last_enable_fragment_id = remote.user.archaeologyInfo.last_enable_fragment_id
    --     end
    -- end

    self._dungeonConfig.heroModels = nil

    -- 副本以及非海神岛首次enter_cd
    if not self:isInSunwell() and not self:isInTutorial() then
        for _, hero in ipairs(self._heroes) do
            for _, skill in pairs(hero:getSkills()) do
                if skill:get("enter_cd") ~= nil then
                    skill:coolDown()
                end
            end
        end
        if not self:isPVPMode() or not self:isPVPMultipleWave() then
            for _, hero in ipairs(self._supportHeroes) do
                for _, skill in pairs(hero:getSkills()) do
                    if skill:get("enter_cd") ~= nil then
                        skill:coolDown()
                    end
                end
            end
            for _, hero in ipairs(self._supportHeroes2) do
                for _, skill in pairs(hero:getSkills()) do
                    if skill:get("enter_cd") ~= nil then
                        skill:coolDown()
                    end
                end
            end
            for _, hero in ipairs(self._supportHeroes3) do
                for _, skill in pairs(hero:getSkills()) do
                    if skill:get("enter_cd") ~= nil then
                        skill:coolDown()
                    end
                end
            end
        end
    end

    if not IsServerSide then
        local currentTime = q.time()
        for _, hero in ipairs(self._heroes) do
            self._battleLog:onHeroCreated(hero:getActorID(), currentTime)
            hero:dump()
        end
        for _, hero in ipairs(self._supportHeroes) do
            self._battleLog:onHeroCreated(hero:getActorID(), currentTime)
            hero:dump()
        end
        for _, hero in ipairs(self._supportHeroes2) do
            self._battleLog:onHeroCreated(hero:getActorID(), currentTime)
            hero:dump()
        end
        for _, hero in ipairs(self._supportHeroes3) do
            self._battleLog:onHeroCreated(hero:getActorID(), currentTime)
            hero:dump()
        end
    end

    return self._heroes
end

-- return all support heroes
function QBattleManager:getSupportHeroes()
    return self._supportHeroes
end

function QBattleManager:getSupportHeroes2()
    return self._supportHeroes2
end

function QBattleManager:getSupportHeroes3()
    return self._supportHeroes3
end

function QBattleManager:getDeadHeroes()
    return self._deadHeroes
end

function QBattleManager:getEnemies()
    return self._enemies
end

function QBattleManager:getDeadEnemies()
    return self._deadEnemies
end

function QBattleManager:getSupportEnemies()
    return self._supportEnemies
end

function QBattleManager:getSupportEnemies2()
    return self._supportEnemies2
end

function QBattleManager:getSupportEnemies3()
    return self._supportEnemies3
end

function QBattleManager:getActorByUDID(udid)
    return self._actorsByUDID[udid]
end

local function func_dead_filter(actor)
    return (not actor:isDead()) and (not actor:isExile())
end
local function func_nonghost_filter(ghost)
    if not ghost.actor:isDead() and ghost.actor:isGhost() and ghost.actor:isAttackedGhost() and not ghost.actor:isPet() and not ghost.actor:isSoulSpirit() then
        return true
    end
    return false
end
local function func_actor_get(ghost)
    return ghost.actor
end
local function func_pet_get(actor)
    return actor:getHunterPet()
end

function QBattleManager:getMyEnemies(actor, justHero)
    local actorType = actor:getType()
    local enemies = nil
    local ghosts = nil
    if actorType == ACTOR_TYPES.HERO or actorType == ACTOR_TYPES.HERO_NPC then
        enemies = self:getEnemies()
        ghosts = self._enemyGhosts
    else
        enemies = self:getHeroes()
        ghosts = self._heroGhosts
    end

    local result = {}
    if not justHero then
        table.mergeForArray(result, ghosts, func_nonghost_filter, func_actor_get)
    end
    table.mergeForArray(result, enemies, func_dead_filter)
    return result
end

function QBattleManager:getAllMyEnemies(actor)
    local actorType = actor:getType()
    local enemies = nil
    local ghosts = nil
    if actorType == ACTOR_TYPES.HERO or actorType == ACTOR_TYPES.HERO_NPC then
        enemies = self:getEnemies()
        ghosts = self._enemyGhosts
    else
        enemies = self:getHeroes()
        ghosts = self._heroGhosts
    end

    local result = {}
    table.mergeForArray(result, enemies, func_dead_filter)
    table.mergeForArray(result, enemies, func_dead_filter, func_pet_get)
    table.mergeForArray(result, ghosts, func_nonghost_filter, func_actor_get)
    return result
end

function QBattleManager:getMyTeammates(actor, includeSelf, justHero)
    local actorType = actor:getType()
    local teammates = nil
    local ghosts = nil
    if actorType == ACTOR_TYPES.HERO or actorType == ACTOR_TYPES.HERO_NPC then
        teammates = self:getHeroes()
        ghosts = self._heroGhosts
    else
        teammates = self:getEnemies()
        ghosts = self._enemyGhosts
    end

    local result = {}
    table.mergeForArray(result, teammates, function(teammate) return func_dead_filter(teammate) and teammate ~= actor end)
    if not justHero then
        table.mergeForArray(result, ghosts, function(teammate) return func_nonghost_filter(teammate) and teammate.actor ~= actor end, func_actor_get)
    end
    if includeSelf then
        table.insert(result, actor)
    end
    return result
end

function QBattleManager:getNeutralEnemies()
    return self._neutralEnemies
end

function QBattleManager:getNeutralHeroes()
    return self._neutralHeroes
end

function QBattleManager:getWaveCount()
    return self._waveCount
end

function QBattleManager:getTimeLeft()
    if self._timeLeft >= 0 then
        return self._timeLeft
    else
        return 0
    end
end

--获取战斗持续时间
function QBattleManager:getBattleDuration()
    return self:getDungeonDuration() - self:getTimeLeft()
end

function QBattleManager:getBlackRockCountDown()
    return math.max(0, (self._dungeonConfig.countdown or 600) - (q.time() - self._naturalStartTime))
end

function QBattleManager:update(dt)
    if self._paused then
        return
    end
    if self._executeNextWave then
        self._executeNextWave()
        self._executeNextWave = nil
    end
    --[[ test battle code disenable
    self:_updateWithRegular(self._onFrame, dt, 1 / 30)
    self:_updateWithRegular(self._onTimer, dt, QBattleManager.BATTLE_TIMER_INTERVAL)
    self:_updateWithRegular(self._onBattleFrame, dt, 1 / 30)
    --]]
    ---[[
    self:_updateWithRegular(self._onFrame, dt, 1 / 30)
    self:_updateWithRegular(self._onTimer, dt, QBattleManager.BATTLE_TIMER_INTERVAL)
    self:_updateWithRegular(self._onBattleFrame, dt, 1 / 30)
    self:_updateWithRegular(self._onThirtyFrame, dt, 1 / 30)
    --]]
end

function QBattleManager:_onThirtyFrame(dt)
    self._battleTimeForEffect = self._battleTimeForEffect + dt

    if self._bulletTimeReferenceCount == 0 then
        for _, bullet in ipairs(self._bullets) do
            bullet:visit(dt)
        end
        for i, bullet in ipairs(self._bullets) do
            if bullet:isFinished() == true then
                table.remove(self._bullets, i)
                break
            end
        end
    else
        -- 黑屏期间，可以活动的actor的子弹不静止
        for _, bullet in ipairs(self._bullets) do
            if bullet:getAttacker():isInTimeStop() == false then
                bullet:visit(dt)
            end
        end
        for i, bullet in ipairs(self._bullets) do
            if bullet:isFinished() == true and bullet:getAttacker():isInTimeStop() == false then
                table.remove(self._bullets, i)
                break
            end
        end
    end
end

function QBattleManager:_updateWithRegular(selector, dt, interval)
    if self._regular == nil then
        self._regular = {}
    end
    local regular = self._regular
    if regular[selector] == nil then
        regular[selector] = 0
    end
    regular[selector] = regular[selector] + dt
    if regular[selector] >= interval then
        -- regular[selector] = regular[selector] - interval
        -- selector(self, interval)
        selector(self, regular[selector])
        regular[selector] = 0
    end
end

function QBattleManager:start()
    if self._enrollingStage then
        self._enrollingStage:start(self) -- 12/23 wk 临时修改
    end

    self:addEventListener(QBattleManager.EVENT_BULLET_TIME_TURN_ON, handler(self, self._onBulletTimeEvent))
    self:addEventListener(QBattleManager.EVENT_BULLET_TIME_TURN_OFF, handler(self, self._onBulletTimeEvent))
    self:addEventListener(QBattleManager.NPC_CREATED, handler(self, self._onNpcCreated))
    if IsServerSide then
        self:addEventListener(QBattleManager.WAVE_ENDED, handler(self, self._onWaveEnded))
    end
    self:addEventListener(QBattleManager.ON_SET_TIME_GEAR, handler(self, self._onSetTimeGear))

    local datebase = QStaticDatabase:sharedDatabase()
    if IsServerSide or self:isPVPMode() or self:isPVPMultipleWave() then
        self:_startBattle()
    else
        if true ~= remote.instance:checkIsPassByDungeonId(self._dungeonConfig.id) or self:isInUnionDragonWar() then
            self._storyLine = QTutorialStoryLine.new()
            self._storyLine:setPauseCallback(function() self:_startBattle() end)
            self._storyLine:start()
        else
            self:_startBattle()
        end
    end

    if self:isPVPMode() then
        for _, enemy in ipairs(self._enemies) do
            for _, skill in pairs(enemy._activeSkills) do
                if skill:isChargeSkill() then
                    skill:coolDown()
                    if not skill:isReady() then
                        skill:reduceCoolDownTime(skill._cd_time - 1.0)
                    end
                end
            end
        end
    end
end

function QBattleManager:checkHpChangeBeforStartBattle(actorList, teamPropertyDict)
    local isChange = false
    for propertyName, propertyValue in pairs(teamPropertyDict) do
        if propertyName == "hp_percent" and propertyValue ~= 0 then
            isChange = true
            break
        end
    end
    if isChange then
        for _, actor in ipairs(actorList) do
            actor:setFullHp()
        end
    end
end

function QBattleManager:_startBattle()
    self:_prepareEnemiesInPVPMode()
    self:_prepareHeroes()
    self:_totemChallengeFindTarget()

    -- self:checkHpChangeBeforStartBattle(self:getHeroes(), self._heroTeamSkillProperty)
    -- self:checkHpChangeBeforStartBattle(self:getEnemies(), self._enemyTeamSkillProperty)

    self:dispatchEvent({name = QBattleManager.START})
    self._battleLog:setStartTime(q.time())

    self._pauseBetweenWaves = false

    if self:isPVPMode() then
        local enter_time = 3.5
        if #self:getSupportHeroes() + #self:getSupportHeroes2() + #self:getSupportHeroes3()
            + #self:getSupportEnemies() + #self:getSupportEnemies2() + #self:getSupportEnemies3() == 0 then
            enter_time = 2.3
        end
        self._startCountDown = false
        self._aiDirector:pause()
        self:performWithDelay(function()
            if self._aiDirector then
                self._startCountDown = true
                self._aiDirector:resume()
            end
        end, enter_time)
    elseif self:isInUnionDragonWar() then
        self._startCountDown = true
        self._curWave = 1
        self._curWaveStartTime = self:getTime()
        self._pauseAI = false
        self:_checkWave()
    else
        self:performWithDelay(function()
            self._startCountDown = true
        end, global.hero_enter_time)
    end

    -- create AI for heroes
    if self:isInTutorial() == false then
        for i, hero in ipairs(self:getHeroes()) do
            local ai = self._aiDirector:createBehaviorTree(hero:getAIType(), hero)
            hero.behaviorNode = ai
            self._aiDirector:addBehaviorTree(ai)
        end
    end

    -- if not self:isInSunwell() then
        -- recharge combo points to full points
        for i, hero in ipairs(self:getHeroes()) do
            if hero:isNeedComboPoints() then
                hero:gainComboPoints(hero:getComboPointsMax())
            end
        end
        for i, hero in ipairs(self:getEnemies()) do
            if hero:isNeedComboPoints() then
                hero:gainComboPoints(hero:getComboPointsMax())
            end
        end
    -- end

    if not IsServerSide then
        if device.platform == "mac" then
            self._debugBattleInfo:start()
        end
    end
end

function QBattleManager:ended(result) -- result: true for win, false for lose, nil for unknown
    -- remove ghosts (commit suicide)
    for _, ghost in ipairs(self._heroGhosts) do
        if not ghost.actor:isDead() and not ghost.actor:isPet() and (not ghost.actor:isSoulSpirit() or self._onLose_Time) then
            ghost.actor:suicide(ghost.is_no_deadAnimation)
            self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = ghost.actor, is_hero = true})
            self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = ghost.actor, is_hero = true})
        end
    end
    for _, ghost in ipairs(self._enemyGhosts) do
        if not ghost.actor:isDead() and not ghost.actor:isPet() and (not ghost.actor:isSoulSpirit() or self._onWin_Time) then
            ghost.actor:suicide(ghost.is_no_deadAnimation)
            self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = ghost.actor})
            self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = ghost.actor})
        end
    end

    self:_npcGoDie()

    -- remove trap
    for _, trapDirector in ipairs(self._trapDirectors) do
        if trapDirector:isCompleted() == false then
            trapDirector:cancel()
        end
    end
    self._trapDirectors = {}

    -- 移除导致玩家不能移动的debuff
    local actors = {}
    table.mergeForArray(actors, self._heroes)
    table.mergeForArray(actors, self._heroGhosts, nil, function(ghost) return ghost.actor end)
    for _, actor in ipairs(actors) do
        if not actor:isDead() then
            actor:removeCannotControlMoveBuff()
        end
    end

    self:_removeBulletsAndLasers()

    -- hide support skill enemy, if win
    if result and self._supportSkillEnemy then
        local actor = self._supportSkillEnemy
        app.grid:setActorTo(actor, qccp(1.5 * BATTLE_AREA.width, BATTLE_AREA.height / 2))
        app.grid:removeActor(actor)
        local pet = actor:getHunterPet()
        if pet then
            app.grid:setActorTo(pet, qccp(1.5 * BATTLE_AREA.width, BATTLE_AREA.height / 2))
            app.grid:removeActor(pet)
        end
    end
    if result and self._supportSkillEnemy2 then
        local actor = self._supportSkillEnemy2
        app.grid:setActorTo(actor, qccp(1.5 * BATTLE_AREA.width, BATTLE_AREA.height / 2))
        app.grid:removeActor(actor)
        local pet = actor:getHunterPet()
        if pet then
            app.grid:setActorTo(pet, qccp(1.5 * BATTLE_AREA.width, BATTLE_AREA.height / 2))
            app.grid:removeActor(pet)
        end
    end
    if result and self._supportSkillEnemy3 then
        local actor = self._supportSkillEnemy3
        app.grid:setActorTo(actor, qccp(1.5 * BATTLE_AREA.width, BATTLE_AREA.height / 2))
        app.grid:removeActor(actor)
        local pet = actor:getHunterPet()
        if pet then
            app.grid:setActorTo(pet, qccp(1.5 * BATTLE_AREA.width, BATTLE_AREA.height / 2))
            app.grid:removeActor(pet)
        end
    end

    self._aiDirector = nil

    self._timeGear = 1.0
    self:dispatchEvent({name = QBattleManager.ON_SET_TIME_GEAR, time_gear = 1.0})

    self:removeAllBattleTutorialHandtouches()

    self:dispatchEvent({name = QBattleManager.END})

    self:removeEventListener(QBattleManager.EVENT_BULLET_TIME_TURN_ON, self._onBulletTimeEvent, self)
    self:removeEventListener(QBattleManager.EVENT_BULLET_TIME_TURN_OFF, self._onBulletTimeEvent, self)
    self:removeEventListener(QBattleManager.NPC_CREATED, self._onNpcCreated, self)
    self:removeEventListener(QBattleManager.WAVE_ENDED, self._onWaveEnded, self)

    if not IsServerSide then
        scheduler.setTimeFunction(dummyTimeFunction)
    end

    if not IsServerSide then
        if device.platform == "mac" then
            self._debugBattleInfo:finish()
        end
    end
end

function QBattleManager:stop()
    self:dispatchEvent({name = QBattleManager.STOP})
end

function QBattleManager:pause()
    self._paused = true
    -- self:_checkEndCountDown()
    self:_hideAllBattleTutorialHandtouches()
    self:dispatchEvent({name = QBattleManager.PAUSE})
end

function QBattleManager:resume()
    self._paused = false
    -- self:_checkStartCountDown()
    self:_showAllBattleTutorialHandtouches()
    self:dispatchEvent({name = QBattleManager.RESUME})
end

function QBattleManager:startCutscene(cutsceneName)
    self._paused = true
    self:dispatchEvent({name = QBattleManager.CUTSCENE_START, cutscene = cutsceneName})
end

function QBattleManager:endCutscene()
    self._paused = false
    self:_startBattle()
    self:dispatchEvent({name = QBattleManager.CUTSCENE_END})
end

-- 静态帮助函数，获取攻击力最大的actor
function QBattleManager.getMaxAttacker(list)
    return table.max_fun(list, QActor.getAttack)
end


function QBattleManager:_onBattleFrame(dt)
    if self._pauseRecord == true and _G["_tutorial_allow_trap_play"] ~= true then
        return
    end
    
    if not self._pauseBetweenWaves and not self._pauseBetweenPVPWaves and not self._pauseBetweenPVEWaves then
        self._battleTimeNoTimeGear = self._battleTimeNoTimeGear + dt
    end

    dt = dt * self:getTimeGear()
    
    if not self._pauseBetweenWaves and not self._pauseBetweenPVPWaves and not self._pauseBetweenPVEWaves then
        self._battleTime = self._battleTime + dt
    end
    --[[ test battle code disenable
    self._battleTimeForEffect = self._battleTimeForEffect + dt
    --]]

    self:_handleSchedulerOnFrame(dt)
end

function QBattleManager:_handleSchedulerOnFrame(dt)
    if #self._delaySchedulers > 0 then
        for _, schedulerInfo in ipairs(self._delaySchedulers) do
            schedulerInfo.skipCurrentFrame = nil
        end

        if self._bulletTimeReferenceCount == 0 then
            for _, schedulerInfo in ipairs(self._delaySchedulers) do
                if not schedulerInfo.skipCurrentFrame and (not schedulerInfo.pauseBetweenWave or (not self:isPausedBetweenWave() and not self._pauseBetweenPVPWaves and not self._pauseBetweenPVEWaves)) then
                    schedulerInfo.delay = schedulerInfo.delay - (schedulerInfo.ignoreTimeGear and (dt / self:getTimeGear()) or dt)
                end
                if schedulerInfo.delay < 0 then
                    schedulerInfo.func()
                end
            end
        else
            for _, schedulerInfo in ipairs(self._delaySchedulers) do
                local isInBulletTime = true
                for _, actor in ipairs(self._exceptActor) do
                    if actor == schedulerInfo.actor then
                        isInBulletTime = false
                    end
                end
                if isInBulletTime == false then
                    if not schedulerInfo.skipCurrentFrame and (not schedulerInfo.pauseBetweenWave or (not self:isPausedBetweenWave() and not self._pauseBetweenPVPWaves and not self._pauseBetweenPVEWaves)) then
                        schedulerInfo.delay = schedulerInfo.delay - (schedulerInfo.ignoreTimeGear and (dt / self:getTimeGear()) or dt)
                    end
                    if schedulerInfo.delay < 0 then
                        schedulerInfo.func()
                    end
                end
            end
        end

        while true do
            local removeIndex = 0
            for i, schedulerInfo in ipairs(self._delaySchedulers) do
                if schedulerInfo.delay < 0 then
                    removeIndex = i
                    break
                end
            end
            if removeIndex ~= 0 then
                table.remove(self._delaySchedulers, removeIndex)
            else
                break
            end
        end
    end
end

function QBattleManager:_onFrame(dt)
    if self._pauseBetweenWaves == true or self._pauseBetweenPVPWaves == true or self._ended == true or self._pauseRecord == true then 
        return 
    end

    -- 更新time gear
    self:_updateTimeGearChange()
    -- 更新是否禁用寻路
    self:_updateDisableAIChange()

    if self._pauseBetweenPVEWaves == true then
        return
    end

    dt = dt * self:getTimeGear()

    if not IsServerSide then
        if device.platform ~= "android" and (self:isInUnionDragonWar() or self:isInGlory() or self:isInGloryArena() or self:isInTotemChallenge()) then
            collectgarbage("step", 10)
        end
    end

    if self._bulletTimeReferenceCount == 0 then
        for _, trapDirector in ipairs(self._trapDirectors) do
            trapDirector:visit(dt)
        end
        for i, trapDirector in ipairs(self._trapDirectors) do
            if trapDirector:isCompleted() == true then
                table.remove(self._trapDirectors, i)
                break
            end
        end
    end
    --[[ test battle code disenable
    if self._bulletTimeReferenceCount == 0 then
        for _, bullet in ipairs(self._bullets) do
            bullet:visit(dt)
        end
        for i, bullet in ipairs(self._bullets) do
            if bullet:isFinished() == true then
                table.remove(self._bullets, i)
                break
            end
        end
    else
        -- 黑屏期间，可以活动的actor的子弹不静止
        for _, bullet in ipairs(self._bullets) do
            if bullet:getAttacker():isInTimeStop() == false then
                bullet:visit(dt)
            end
        end
        for i, bullet in ipairs(self._bullets) do
            if bullet:isFinished() == true and bullet:getAttacker():isInTimeStop() == false then
                table.remove(self._bullets, i)
                break
            end
        end
    end
    --]]

    if self._bulletTimeReferenceCount == 0 then
        for _, laser in ipairs(self._lasers) do
            laser:visit(dt)
        end
        for i, laser in ipairs(self._lasers) do
            if laser:isFinished() == true then
                table.remove(self._lasers, i)
                break
            end
        end
    else
        -- 黑屏期间，可以活动的actor的激光不静止
        for _, laser in ipairs(self._lasers) do
            if laser:getAttacker():isInTimeStop() == false then
                laser:visit(dt)
            end
        end
        for i, laser in ipairs(self._lasers) do
            if laser:isFinished() == true and laser:getAttacker():isInTimeStop() == false then
                table.remove(self._lasers, i)
                break
            end
        end
    end

    if self._bulletTimeReferenceCount == 0 then
        for _, ufo in ipairs(self._ufos) do
            ufo:visit(dt)
        end
        for i, ufo in ipairs(self._ufos) do
            if ufo:isEnded() then
                ufo:release()
                table.remove(self._ufos, i)
                break
            end
        end
    end

    for _, monster in ipairs(self._monsters) do
        if monster.life_span then
            if monster.npc and not monster.npc:isDead() then
                if self:getTime() - monster.born_time > monster.life_span then
                    monster.npc:suicide()
                end
            elseif monster.npc_summoned then
                for _, summoned in pairs(monster.npc_summoned) do
                    if not summoned.npc:isDead() and self:getTime() - summoned.born_time > monster.life_span then
                        summoned.npc:suicide()
                    end
                end
            end
        end
    end

    if self._bulletTimeReferenceCount == 0 then
        for _, ghost in ipairs(self._heroGhosts) do
            local actor = ghost.actor
            local ai = ghost.ai
            if not actor:isDead() and ghost.life_span > 0 then
                ghost.life_countdown = ghost.life_countdown - dt
                if ghost.life_countdown <= 0 then
                    actor:suicide()
                    self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = actor, is_hero = true})
                    self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = actor, is_hero = true})
                    self._aiDirector:removeBehaviorTree(ai)
                    app.grid:removeActor(actor)
                end
            elseif actor:isDead() and not actor:isSuicided() and not actor:isDoingDeadSkill() then -- ghost被杀死了，也需要清理
                self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = actor, is_hero = true})
                self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = actor, is_hero = true})
                app.grid:removeActor(actor)
            end
        end
    end

    if self._bulletTimeReferenceCount == 0 then
        for _, ghost in ipairs(self._enemyGhosts) do
            local actor = ghost.actor
            local ai = ghost.ai
            if not actor:isDead() and ghost.life_span > 0 then
                ghost.life_countdown = ghost.life_countdown - dt
                if ghost.life_countdown <= 0 then
                    actor:suicide()
                    self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = actor, is_hero = false})
                    self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = actor, is_hero = false})
                    self._aiDirector:removeBehaviorTree(ai)
                    app.grid:removeActor(actor)
                end
            elseif actor:isDead() and not actor:isSuicided() and not actor:isDoingDeadSkill() then -- ghost被杀死了，也需要清理
                self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = actor, is_hero = false})
                self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = actor, is_hero = false})
                app.grid:removeActor(actor)
            end
        end
    end

    if self._enrollingStage then
        if self._enrollingStage:isStageFinished() == true then
            self._enrollingStage:ended()
        end
        self._enrollingStage:visit()
    end

    if self:isPVPMode() then
        local time = self:getDungeonDuration() - self:getTimeLeft()
        local old_coefficient = self._damageCoefficient
        if time >= 75 then
            if (self:isInArena() or self:isInSilvesArena()) and
                not self:isPVPMultipleWaveNew() and not self:isSotoTeam() then

                self._damageCoefficient = QBattleManager.ARENA_BEATTACK_75_COEFFICIENT + 1
            elseif self:isInSunwell() then
                self._damageCoefficient = QBattleManager.SUNWELL_BEATTACK_75_COEFFICIENT + 1
            elseif self:isInSilverMine() then
                self._damageCoefficient = QBattleManager.SILVERMINE_BEATTACK_75_COEFFICIENT + 1
            end
        elseif time >= 60 then
            if self:isInMetalAbyss() then
                self._damageCoefficient = QBattleManager.ABYSS_BEATTACK_60_COEFFICIENT + 1
            elseif self:isPVPMultipleWaveNew() then
                self._damageCoefficient = QBattleManager.STORM_ARENA_BEATTACK_60_COEFFICIENT + 1
            elseif (self:isInArena() or self:isInSilvesArena()) and
                not self:isPVPMultipleWaveNew() and not self:isSotoTeam() then

                self._damageCoefficient = QBattleManager.ARENA_BEATTACK_60_COEFFICIENT + 1
            elseif self:isInSunwell() then
                self._damageCoefficient = QBattleManager.SUNWELL_BEATTACK_60_COEFFICIENT + 1
            elseif self:isInSilverMine() then
                self._damageCoefficient = QBattleManager.SILVERMINE_BEATTACK_60_COEFFICIENT + 1
            end
        elseif time >= 30 then
            if self:isInMetalAbyss() then
                self._damageCoefficient = QBattleManager.ABYSS_BEATTACK_30_COEFFICIENT + 1
            elseif self:isPVPMultipleWaveNew() then
                self._damageCoefficient = QBattleManager.STORM_ARENA_BEATTACK_30_COEFFICIENT + 1
            elseif (self:isInArena() or self:isInSilvesArena()) and
                not self:isPVPMultipleWaveNew() and not self:isSotoTeam() then
                
                self._damageCoefficient = QBattleManager.ARENA_BEATTACK_30_COEFFICIENT + 1
            elseif self:isInSunwell() then
                self._damageCoefficient = QBattleManager.SUNWELL_BEATTACK_30_COEFFICIENT + 1
            elseif self:isInSilverMine() then
                self._damageCoefficient = QBattleManager.SILVERMINE_BEATTACK_30_COEFFICIENT + 1
            end
        end

        if self:isInSotoTeam() then
            if time >= 85 then
                self._damageCoefficient = QBattleManager.SOTO_85_COEFFICIENT + 1
            elseif time >= 70 then
                self._damageCoefficient = QBattleManager.SOTO_70_COEFFICIENT + 1
            elseif time >= 60 then
                self._damageCoefficient = QBattleManager.SOTO_60_COEFFICIENT + 1
            elseif time >= 30 then
                self._damageCoefficient = QBattleManager.SOTO_30_COEFFICIENT + 1
            end
        end

        if self:isInTotemChallenge() then
            if time >= 85 then
                self._damageCoefficient = QBattleManager.TOTEM_CHALLENGE_85_COEFFICIENT + 1
            elseif time >= 70 then
                self._damageCoefficient = QBattleManager.TOTEM_CHALLENGE_70_COEFFICIENT + 1
            elseif time >= 60 then
                self._damageCoefficient = QBattleManager.TOTEM_CHALLENGE_60_COEFFICIENT + 1
            elseif time >= 30 then
                self._damageCoefficient = QBattleManager.TOTEM_CHALLENGE_30_COEFFICIENT + 1
            end
        end

        if old_coefficient ~= self._damageCoefficient then
            self:dispatchEvent({name = QBattleManager.ON_CHANGE_DAMAGE_COEFFICIENT, damage_coefficient = self._damageCoefficient})
        end
    end

    self:_updateTotemChallengeAffix(dt)
    self:_updateBattleTutorial()
    self:_updateHeroHelper()
    self:_updateDungeonDialogs()
    self:_updateRegisteredCharges()
    self:_updateBattleRune(dt)
    self:_updateSupportHeroSkill(dt)
    self:_updateSupportEnemySkill(dt)
    self:_updateHeroicMonsterIntroduction()
    self:_updateMonsterString()

    self:dispatchEvent({name = QBattleManager.ONFRAME, deltaTime = dt})
end

function QBattleManager:_onTimer(dt)
    dt = dt * self:getTimeGear()
    if self._pauseRecord == true or self._ended == true or self._pauseBetweenWaves == true or self._pauseBetweenPVPWaves == true or self._pauseBetweenPVEWaves == true then 
        return 
    end

    -- check time left
    if self._startCountDown == true and self._bulletTimeReferenceCount == 0 and not self._isTimePauseInStoryLine then
        self._timeLeft = self._timeLeft - dt
    end

    self:dispatchEvent({name = QBattleManager.ONTIMER, dt = dt})

    local allDead, nextWave = self:_checkWave()

    local isAllEnemyDead = false
    if allDead == true and nextWave == nil then
        isAllEnemyDead = true
    end

    -- check enemy heroes
    if self:isPVPMode() then
        self:_checkEnemyHeroes()
    end

    if self:_checkWinOrLose(isAllEnemyDead) == true then 
        return 
    end

    if allDead == true then
        if nextWave ~= nil then
            if nextWave == 1 then
                self._curWave = nextWave
                self._curWaveStartTime = self:getTime() + global.hero_enter_time * 0.15

                local isBossComing = false
                for _, item in ipairs(self._monsters) do
                    if item.wave == self._curWave and item.created ~= true and item.is_boss == true then
                        if item.appear < global.wave_animation_time then
                            isBossComing = true 
                            break
                        end
                    end
                end

                self:performWithDelay(function()
                    self:dispatchEvent({name = QBattleManager.WAVE_STARTED, wave = self._curWave, isBossComing = isBossComing})
                end, global.wave_animation_time - global.wave_animation_time + 0.5)

                self:performWithDelay(function()
                    self._pauseAI = false
                end, global.hero_enter_time * 0.15)
            elseif self._nextWave ~= nextWave then
                self._nextWave = nextWave
                self:_checkEndCountDown()

                if self._dungeonConfig.mode == BATTLE_MODE.CONTINUOUS then
                    self._pauseBetweenWaves = true
                    self:onStartNewWave()
                else
                    self:setTimeGear(1.0)

                    self:performWithDelay(function()
                        self:_removeBulletsAndLasers()
                        self._pauseBetweenWaves = true
                        -- 当前帧已经被记录，所以不能直接暂停
                        self.__pauseRecord = true
                        self:dispatchEvent({name = QBattleManager.WAVE_ENDED_FOR_ACTOR, wave = self._curWave})
                        self:dispatchEvent({name = QBattleManager.WAVE_ENDED, wave = self._curWave})
                        self._pauseAI = true
                    end, --[[global.npc_view_dead_blink_time + 0.5]]0)
                end
            end

            self._isFirstNPCCreated = false
        end
    end

    -- check heroes
    if self:_checkHeroes() == false then 
        return 
    end

    -- run AI loop
    if self._pauseAI == false and self._aiDirector then
        self._aiDirector:visit()
    end
end

function QBattleManager:_checkWinOrLose_Thunder(isAllEnemyDead)
    -- check if win
    if isAllEnemyDead == true then
        -- 检查雷电王座的通关条件
        local target_type, target_value = db:getThunderWinConditionByDungeonId(self._dungeonConfig.id)
        if target_type == "hero_deaded" then
            local death_toll = 0
            for _, hero in ipairs(self._deadHeroes) do
                if not hero:isPet() and not hero:isGhost() then
                    death_toll = death_toll + 1
                end
            end
            if death_toll > target_value then
                self:_onLose()
                return true
            end
        elseif target_type == "dungeon_time" then
            if (self:getDungeonDuration() - self:getTimeLeft()) > target_value then
                self:_onLose()
                return true
            end
        elseif target_type == "hp_remain" then
            local hp, max_hp = 0, 0
            for _, hero in ipairs(self._heroes) do
                if not hero:isPet() and not hero:isGhost() then
                    hp = hp + hero:getHp()
                    max_hp = max_hp + hero:getMaxHp()
                end
            end
            for _, hero in ipairs(self._deadHeroes) do
                if not hero:isPet() and not hero:isGhost() then
                    hp = hp + hero:getHp()
                    max_hp = max_hp + hero:getMaxHp()
                end
            end
            if max_hp ~= 0 and (hp / max_hp) < (target_value / 100) then
                self:_onLose()
                return true
            end
        end

        self:_onWin({isAllEnemyDead = true})
        return true
    end

    -- check lose
    local heroCountExceptHealth = 0
    for i, hero in ipairs(self._heroes) do
        if not hero:isSupport() then
            heroCountExceptHealth = heroCountExceptHealth + 1
        end
    end

    if self._timeLeft <= 0 or heroCountExceptHealth <= 0 then
        self:_onLose()
        return true
    end

    return false
end

function QBattleManager:_checkWinOrLose(isAllEnemyDead)
    if IsServerSide then
        if self._serverSideCheckTutorialDungeonWinOrLose == nil then
            -- 有角色出场引导的关卡不复盘，直接OK
            local win = self._dungeonConfig.id == "wailing_caverns_3" or
                        self._dungeonConfig.id == "wailing_caverns_9" or
                        self._dungeonConfig.id == "wailing_caverns_12" or
                        self._dungeonConfig.id == "wailing_caverns_22"
            if win then
                self:_onWin{isAllEnemyDead = true}
                return
            end
            self._serverSideCheckTutorialDungeonWinOrLose = true
        end
    end

    if self:isSociatyWar() then
        return self:_checkWinOrLoseSociatyWar()
    end

    if self:isInThunder() then
        return self:_checkWinOrLose_Thunder(isAllEnemyDead)
    end

    if self:isPVPMode() and self:isPVPMultipleWave() then
        return self:_checkWinOrLose_PVPMultipleWave()
    end

    if self:isInDragon() then
        return self:_checkWinOrLoseDragon()
    end

    if self:isInBlackRock() then
        if IsServerSide then
            if self._dungeonConfig.blackRockTimeEnd then
                self:_onLose()
                return true
            end
        elseif self:getBlackRockCountDown() <= 0 then
            self._record.dungeonConfig.blackRockTimeEnd = true
            self:_onLose()
            return true
        end
    end

    if self._dungeonConfig.holyPressureWave 
        and self._dungeonConfig.holyPressureWave == self._pvpMultipleWave 
        and self._battleTime >= global.pvp_hero_move_time
        and self:isInTotemChallenge() then
        self:dispatchEvent({name = QBattleManager.HOLY_PRESSURE_WAVE})
        for k, enemy in ipairs(self._enemies) do
            enemy:suicide()
        end
        self:_onWin()
        return true
    end

    -- check if win
    if isAllEnemyDead == true then
        self:_onWin({isAllEnemyDead = true})
        return true
    end

    -- check lose
    local heroCountExceptHealth = 0
    for i, hero in ipairs(self._heroes) do
        if not hero:isSupport() then
            if --[[hero:getTalentFunc() ~= "health"]] true then
                heroCountExceptHealth = heroCountExceptHealth + 1
            end
        end
    end
    -- candidate hero
    for i, hero in ipairs(self._candidateHeroes) do
        if not hero:isDead() then
            heroCountExceptHealth = heroCountExceptHealth + 1
        end
    end

    if self._isActiveDungeon == true and self._activeDungeonType == DUNGEON_TYPE.ACTIVITY_TIME then 
        if self._timeLeft <= 0 or heroCountExceptHealth <= 0 then
            local rewards = self:getDeadEnemyRewards()
            local rewardCount = #rewards
            if rewardCount > 0 then
                self:_onWin({isAllEnemyDead = false})
            else
                self:_onLose()
            end
            return true
        end
    else
        if self:isPVPMode() == true then
            if self._timeLeft <= 0 then
                if self:isInSunwell() then
                    local heroes = self:getHeroes()
                    for _, hero in ipairs(heroes) do
                        if hero:isDead() == false then
                            hero:decreaseHp(hero:getHp())
                        end
                    end
                    self:_onLose({isTimeOver = true})
                    return true
                else
                    self:_onLose({isTimeOver = true})
                    return true
                end
            elseif heroCountExceptHealth <= 0 then
                self:_onLose()
                return true
            end
        else
            if self._timeLeft <= 0 or heroCountExceptHealth <= 0 then
                self:_onLose()
                return true
            end
        end
    end

    if self:isPVPMode() then
        local all_dead = true
        for _, enemy in ipairs(self._enemies) do
            if not enemy:isDead() and not enemy:isSupport() then
                all_dead = false
                break
            end
        end
        for _, enemy in ipairs(self._candidateEnemies) do
            if not enemy:isDead() then
                all_dead = false
                break
            end
        end
        if all_dead then
            self:_onWin({isAllEnemyDead = true})
            return false
        end
    end

    return false

end

function QBattleManager:_onWin(options)
    if self:isInTutorial() then
        return
    end

    if self._onWin_Time then
        return
    else
        self._onWin_Time = self:getTime()
    end

    -- 太阳井敌方魂师剩余血量记录
    if self:isInSunwell() then
        self._sunwellEnemyHP = {}
        self._sunwellEnemyMaxHP = {}
        for _, enemy in ipairs(self:getEnemies()) do
            self._sunwellEnemyHP[enemy] = enemy:getHp()
            self._sunwellEnemyMaxHP[enemy] = enemy:getMaxHp()
        end
    end

    -- 战斗胜利
    for _, hero in ipairs(self._heroes) do
        hero:changeRage(hero:getRageWin(), nil, true)
    end

    -- 保存要塞boss剩余血量
    if self:isInRebelFight() and self:getEnemies()[1] then
        self._rebelFightBossHp = self:getEnemies()[1]:getHp()
    end

    -- 保存世界boss剩余血量
    if self:isInWorldBoss() and self:getEnemies()[1] then
        self._worldBossFightBossHp = self:getEnemies()[1]:getHp()
    end

    -- 保存宗门boss剩余血量
    if self:isInSocietyDungeon() and self:getEnemies()[1] then
        self._societyBossHp = self:getEnemies()[1]:getHp()
    end

    -- 保存巨龙boss剩余血量
    if self:isInUnionDragonWar() and self:getEnemies()[1] then
        self._unionDragonBossHp = self:getEnemies()[1]:getHp()
    end

    if not self:isInReplay() and not self:isInQuick() then
        self._dungeonConfig.isClientWin = true
    end

    if self:isPVPMultipleWaveNew() then
        if self:isInMetalAbyss() then
            self:checkMetalAbyssNextWave(true)
        elseif self:isPVP2TeamBattle() then
            self:checkPVP2TeamBattleNextWave(true)
        elseif self:isTotemChallenge() then
            self:checkTotemChallengeNextWave(true)
        else
            self:checkPVPMultipleNextWave(true)
        end
    end

    if IsServerSide then
        self._ended = true
        self._result = 0
        if self:isMockBattle() and self:isPVPMultipleWaveNew() and
            self:getPVPMultipleNextConfig() == nil then
            self:saveMockBattle2Resulte(true)
        end
        createReplayOutput(true)
        print("verify result: WIN")
        return
    end

    self._battleLog:setIsWin(true)

    local handle
    local local_onWin
    handle = scheduler.scheduleGlobal(function()
        if (self:isPVPMode() or self:isDungeonDialogsAllFinished()) and self:isAllRoundFinished() and not app.scene:isNotSkillAnimationEnd()then
            
            if not self:isInReplay() then
                table.insert(self._dungeonConfig.recordList, clone(self._record))
                if self:isPVEMultipleWave() then
                    if self:getPVEMultipleCurWave() > 1 then
                        app:saveBattleRecordIntoProtobuf(self._dungeonConfig.recordList)
                    end
                elseif self:isPVPMultipleWaveNew() then
                    if self:isInTotemChallenge() then
                        if self:getPVPMultipleNewCurWave() > 1 then
                            app:saveBattleRecordIntoProtobuf(self._dungeonConfig.recordList)
                        else
                            self._nextPVPWaveDungeonConfig.recordList = self._dungeonConfig.recordList
                        end
                    elseif self:getPVPMultipleNextConfig() == nil then
                        app:saveBattleRecordIntoProtobuf(self._dungeonConfig.recordList)
                    end
                else
                    app:saveBattleRecordIntoProtobuf(self._dungeonConfig.recordList)
                end
            end

            local_onWin()
            scheduler.unscheduleGlobal(handle)
        end
    end, 0)

    local_onWin = function()
        if options == nil then
            options = {}
        end

        scheduler.setTimeFunction(dummyTimeFunction)

        if SAVE_BATTLE_RECORD and (not self:isInReplay()) then
            -- app:saveBattleRecord(clone(self._record))
            if self:isPVPMode() and self:isInArena() then
                -- app:saveBattleRecordIntoProtobuf(self._record)
            end
            if ENABLE_STREAM_REPLAY then
                self:performWithDelay(handler(app, app.saveBattleRecordStream), 0, nil, true, true) -- 犹豫当前帧是记录帧，所以要等当前帧被记录到流中（也就是下一帧的开始之后），才可以保存流
            end
        elseif (device.platform == "mac") and self:isInReplay() and not self:isInQuick() then
            print("#recordTimeSlices = %d, #replayTimeSlices = %d", #self._record.recordTimeSlices, #self._dungeonConfig.replayTimeSlices)
            CCMessageBox(string.format("#recordTimeSlices = %d, #replayTimeSlices = %d", #self._record.recordTimeSlices, #self._dungeonConfig.replayTimeSlices), "")
        end

        app:resetBattleNpcProbability(self._dungeonConfig.id)
        if not self:isInReplay() then
            app:resetBattleRandomNumber(self._dungeonConfig.id)
        end

        self._battleLog:setDuration(self:getDungeonDuration() - self:getTimeLeft())

        if self:isPVEMultipleWave() and self._pveMultipleWave == 1 then
            local event = {
                name = QBattleManager.PVE_MULTIPLE_WAVE_END,
                skipMove = options.skipMove,
                battleLog = self._battleLog,
                dungeonConfig = self._dungeonConfig
            }
            table.merge(event, options)
            self:_removeBulletsAndLasers()
            self:dispatchEvent(event)
            self:dispatchEvent({name = QBattleManager.WAVE_ENDED_FOR_ACTOR})
        elseif self:isInTotemChallenge() and self:getPVPMultipleNewCurWave() == 1 then
            local event = {
                name = QBattleManager.PVP_MULTIPLE_WAVE_END,
                isWin = true,
                dungeonConfig = self._dungeonConfig
            }
            table.merge(event, options)
            self:_removeBulletsAndLasers()
            self:dispatchEvent(event)
            self:dispatchEvent({name = QBattleManager.WAVE_ENDED_FOR_ACTOR})
        elseif self:isPVPMultipleWaveNew() and self:getPVPMultipleNextConfig() ~= nil then
            local event = {
                name = QBattleManager.PVP_MULTIPLE_WAVE_END,
                isWin = true,
                dungeonConfig = self._dungeonConfig
            }
            table.merge(event, options)
            self:_removeBulletsAndLasers()
            self:dispatchEvent(event)
            self:dispatchEvent({name = QBattleManager.WAVE_ENDED_FOR_ACTOR})
        else
            local event = {name = QBattleManager.WIN, skipMove = options.skipMove or self._force_skip_move}
            table.merge(event, options)
            self:dispatchEvent(event)
        end

        self._ended = true
        self:_checkEndCountDown()
        self._battleLog:setEndTime(q.time())

        -- self:_debugPrintCCB()
        -- self:_debugPrintSpine()
    end
end

function QBattleManager:checkPVP2TeamBattleNextWave(isWin)
    if not self:isPVP2TeamBattle() then return false end
    self._dungeonConfig._newPvpMultipleScoreInfo = self._dungeonConfig._newPvpMultipleScoreInfo or {scoreList = {}, heroScore = 0, enemyScore = 0, battleLogList = {}}
    table.insert(self._dungeonConfig._newPvpMultipleScoreInfo.battleLogList, self._battleLog)
    table.insert(self._dungeonConfig._newPvpMultipleScoreInfo.scoreList, isWin)

    if isWin then
        self._dungeonConfig._newPvpMultipleScoreInfo.heroScore = self._dungeonConfig._newPvpMultipleScoreInfo.heroScore + 1
    else
        self._dungeonConfig._newPvpMultipleScoreInfo.enemyScore = self._dungeonConfig._newPvpMultipleScoreInfo.enemyScore + 1
    end

    if #self._dungeonConfig._newPvpMultipleScoreInfo.scoreList >= 2 then
        return false
    end

    if self:isMockBattle() and self:getPVPMultipleNewCurWave() == 1 then
        self:saveMockBattle2Resulte(isWin)
    end

    local nextWave = self:getPVPMultipleNewCurWave() + 1
    local newConfig = clone(self._dungeonConfig)

    newConfig.pvpMultipleWave = nextWave
    newConfig.heroInfos = {}
    newConfig.supportHeroInfos = {}
    newConfig.supportHeroInfos2 = {}
    newConfig.userSoulSpirits = {}
    newConfig.heroGodArmIdList = {}

    newConfig.pvp_rivals = {}
    newConfig.pvp_rivals2 = {}
    newConfig.pvp_rivals4 = {}
    newConfig.enemySoulSpirits = {}
    newConfig.enemyGodArmIdList = {}

    if nextWave == 2 then
        local teamInfo = newConfig.pvpMultipleTeams[nextWave]
        table.mergeForArray(newConfig.heroInfos, teamInfo.hero.heroes)
        if teamInfo.hero.supports then
            table.mergeForArray(newConfig.supportHeroInfos, teamInfo.hero.supports)
        end
        if teamInfo.hero.soulSpirits then
            table.mergeForArray(newConfig.userSoulSpirits, teamInfo.hero.soulSpirits)
        end
        if teamInfo.hero.godArmIdList then
            table.mergeForArray(newConfig.heroGodArmIdList, teamInfo.hero.godArmIdList)
        end

        table.mergeForArray(newConfig.pvp_rivals, teamInfo.enemy.heroes)
        if teamInfo.enemy.supports then
            table.mergeForArray(newConfig.pvp_rivals2, teamInfo.enemy.supports)
        end
        if teamInfo.enemy.soulSpirits then
            table.mergeForArray(newConfig.enemySoulSpirits, teamInfo.enemy.soulSpirits)
        end
        if teamInfo.enemy.godArmIdList then
            table.mergeForArray(newConfig.enemyGodArmIdList, teamInfo.enemy.godArmIdList)
        end

        newConfig.supportSkillHeroIndex = teamInfo.hero.supportSkillHeroIndex
        newConfig.supportSkillHeroIndex2 = teamInfo.hero.supportSkillHeroIndex2
        newConfig.supportSkillEnemyIndex = teamInfo.enemy.supportSkillHeroIndex
        newConfig.supportSkillEnemyIndex2 = teamInfo.enemy.supportSkillHeroIndex2
        self._nextPVPWaveDungeonConfig = newConfig
        return true
    end
    return false
end

function QBattleManager:checkTotemChallengeNextWave(isWin)
    if not self:isInTotemChallenge() then return false end
    self._dungeonConfig._newPvpMultipleScoreInfo = self._dungeonConfig._newPvpMultipleScoreInfo or {scoreList = {}, heroScore = 0, enemyScore = 0, battleLogList = {}}
    table.insert(self._dungeonConfig._newPvpMultipleScoreInfo.battleLogList, self._battleLog)
    table.insert(self._dungeonConfig._newPvpMultipleScoreInfo.scoreList, isWin)

    if isWin then
        self._dungeonConfig._newPvpMultipleScoreInfo.heroScore = self._dungeonConfig._newPvpMultipleScoreInfo.heroScore + 1
    else
        return false
    end

    if #self._dungeonConfig._newPvpMultipleScoreInfo.scoreList >= 2 then
        return false
    end

    local nextWave = self:getPVPMultipleNewCurWave() + 1

    local newConfig = clone(self._dungeonConfig)
    newConfig.pvpMultipleWave = nextWave
    newConfig.heroInfos = {}
    newConfig.supportHeroInfos = {}
    newConfig.supportHeroInfos2 = {}
    newConfig.userSoulSpirits = {}
    newConfig.heroGodArmIdList = {}

    newConfig.pvp_rivals = {}
    newConfig.pvp_rivals2 = {}
    newConfig.pvp_rivals4 = {}
    newConfig.enemySoulSpirits = {}
    newConfig.enemyGodArmIdList = {}
    if nextWave == 2 then
        local teamInfo = newConfig.pvpMultipleTeams[nextWave]
        table.mergeForArray(newConfig.heroInfos, teamInfo.hero.heroes)
        if teamInfo.hero.supports then
            table.mergeForArray(newConfig.supportHeroInfos, teamInfo.hero.supports)
        end
        if teamInfo.hero.soulSpirits then
            table.mergeForArray(newConfig.userSoulSpirits, teamInfo.hero.soulSpirits)
        end
        if teamInfo.hero.godArmIdList then
            table.mergeForArray(newConfig.heroGodArmIdList, teamInfo.hero.godArmIdList)
        end

        table.mergeForArray(newConfig.pvp_rivals, teamInfo.enemy.heroes)
        if teamInfo.enemy.supports then
            table.mergeForArray(newConfig.pvp_rivals2, teamInfo.enemy.supports)
        end
        if teamInfo.enemy.soulSpirits then
            table.mergeForArray(newConfig.enemySoulSpirits, teamInfo.enemy.soulSpirits)
        end
        if teamInfo.enemy.godArmIdList then
            table.mergeForArray(newConfig.enemyGodArmIdList, teamInfo.enemy.godArmIdList)
        end

        newConfig.supportSkillHeroIndex = teamInfo.hero.supportSkillHeroIndex
        newConfig.supportSkillHeroIndex2 = teamInfo.hero.supportSkillHeroIndex2
        newConfig.supportSkillEnemyIndex = teamInfo.enemy.supportSkillHeroIndex
        newConfig.supportSkillEnemyIndex2 = teamInfo.enemy.supportSkillHeroIndex2
        self._nextPVPWaveDungeonConfig = newConfig
        return true
    end
    return false
end

function QBattleManager:checkMetalAbyssNextWave(isWin)
    if not self:isInMetalAbyss() then return false end
    self._dungeonConfig._newPvpMultipleScoreInfo = self._dungeonConfig._newPvpMultipleScoreInfo or {scoreList = {}, heroScore = 0, enemyScore = 0, battleLogList = {}}
    table.insert(self._dungeonConfig._newPvpMultipleScoreInfo.battleLogList, self._battleLog)
    table.insert(self._dungeonConfig._newPvpMultipleScoreInfo.scoreList, isWin)
    if isWin then
        self._dungeonConfig._newPvpMultipleScoreInfo.heroScore = self._dungeonConfig._newPvpMultipleScoreInfo.heroScore + 1
        if self._dungeonConfig._newPvpMultipleScoreInfo.heroScore >= 2 then
            return false
        end
    else
        self._dungeonConfig._newPvpMultipleScoreInfo.enemyScore = self._dungeonConfig._newPvpMultipleScoreInfo.enemyScore + 1
        if self._dungeonConfig._newPvpMultipleScoreInfo.enemyScore >= 2 then
            return false
        end
    end

    local nextWave = self:getPVPMultipleNewCurWave() + 1
    local newConfig = clone(self._dungeonConfig)
    newConfig.pvpMultipleWave = nextWave
    newConfig.heroInfos = {}
    newConfig.supportHeroInfos = {}
    newConfig.supportHeroInfos2 = {}
    newConfig.userSoulSpirits = {}
    newConfig.heroGodArmIdList = {}

    newConfig.pvp_rivals = {}
    newConfig.pvp_rivals2 = {}
    newConfig.pvp_rivals4 = {}
    newConfig.enemySoulSpirits = {}
    newConfig.enemyGodArmIdList = {}

    local heroTeamInfo = newConfig.pvpMultipleTeams[nextWave]
    local enemyTeamInfo = newConfig.pvpMultipleTeams[nextWave]

    table.mergeForArray(newConfig.heroInfos, heroTeamInfo.hero.heroes)
    if heroTeamInfo.hero.supports then
        table.mergeForArray(newConfig.supportHeroInfos, heroTeamInfo.hero.supports)
    end
    if heroTeamInfo.hero.soulSpirits then
        table.mergeForArray(newConfig.userSoulSpirits, heroTeamInfo.hero.soulSpirits)
    end
    if heroTeamInfo.hero.godArmIdList then
        table.mergeForArray(newConfig.heroGodArmIdList, heroTeamInfo.hero.godArmIdList)
    end

    newConfig.supportSkillHeroIndex = heroTeamInfo.hero.supportSkillHeroIndex
    newConfig.supportSkillHeroIndex2 = heroTeamInfo.hero.supportSkillHeroIndex2

    table.mergeForArray(newConfig.pvp_rivals, enemyTeamInfo.enemy.heroes)
    if enemyTeamInfo.enemy.supports then
        table.mergeForArray(newConfig.pvp_rivals2, enemyTeamInfo.enemy.supports)
    end
    if enemyTeamInfo.enemy.soulSpirits then
        table.mergeForArray(newConfig.enemySoulSpirits, enemyTeamInfo.enemy.soulSpirits)
    end
    if enemyTeamInfo.enemy.godArmIdList then
        table.mergeForArray(newConfig.enemyGodArmIdList, enemyTeamInfo.enemy.godArmIdList)
    end
    newConfig.supportSkillEnemyIndex = enemyTeamInfo.enemy.supportSkillHeroIndex
    newConfig.supportSkillEnemyIndex2 = enemyTeamInfo.enemy.supportSkillHeroIndex2

    self._nextPVPWaveDungeonConfig = newConfig

    return true 
end

function QBattleManager:checkPVPMultipleNextWave(isWin)
    if not self:isPVPMultipleWaveNew() then return false end
    self._dungeonConfig._newPvpMultipleScoreInfo = self._dungeonConfig._newPvpMultipleScoreInfo or {scoreList = {}, heroScore = 0, enemyScore = 0, battleLogList = {}}
    table.insert(self._dungeonConfig._newPvpMultipleScoreInfo.battleLogList, self._battleLog)
    table.insert(self._dungeonConfig._newPvpMultipleScoreInfo.scoreList, isWin)
    if isWin then
        self._dungeonConfig._newPvpMultipleScoreInfo.heroScore = self._dungeonConfig._newPvpMultipleScoreInfo.heroScore + 1
        if self._dungeonConfig._newPvpMultipleScoreInfo.heroScore >= 2 then
            return false
        end
    else
        self._dungeonConfig._newPvpMultipleScoreInfo.enemyScore = self._dungeonConfig._newPvpMultipleScoreInfo.enemyScore + 1
        if self._dungeonConfig._newPvpMultipleScoreInfo.enemyScore >= 2 then
            return false
        end
    end

    if self:isMockBattle() and self:getPVPMultipleNewCurWave() == 1 then
        self:saveMockBattle2Resulte(isWin)
    end

    local nextWave = self:getPVPMultipleNewCurWave() + 1
    local newConfig = clone(self._dungeonConfig)

    newConfig.pvpMultipleWave = nextWave
    newConfig.heroInfos = {}
    newConfig.supportHeroInfos = {}
    newConfig.supportHeroInfos2 = {}
    newConfig.userSoulSpirits = {}
    newConfig.heroGodArmIdList = {}

    newConfig.pvp_rivals = {}
    newConfig.pvp_rivals2 = {}
    newConfig.pvp_rivals4 = {}
    newConfig.enemySoulSpirits = {}
    newConfig.enemyGodArmIdList = {}

    local heroTeamInfo, enemyTeamInfo
    if nextWave == 2 then
        heroTeamInfo = newConfig.pvpMultipleTeams[nextWave]
        enemyTeamInfo = newConfig.pvpMultipleTeams[nextWave]
    elseif nextWave == 3 then
        heroTeamInfo = newConfig.pvpMultipleTeams[isWin and 1 or 2]
        enemyTeamInfo = newConfig.pvpMultipleTeams[isWin and 2 or 1]
    end

    table.mergeForArray(newConfig.heroInfos, heroTeamInfo.hero.heroes)
    if heroTeamInfo.hero.supports then
        table.mergeForArray(newConfig.supportHeroInfos, heroTeamInfo.hero.supports)
    end
    if heroTeamInfo.hero.soulSpirits then
        table.mergeForArray(newConfig.userSoulSpirits, heroTeamInfo.hero.soulSpirits)
    end
    if heroTeamInfo.hero.godArmIdList then
        table.mergeForArray(newConfig.heroGodArmIdList, heroTeamInfo.hero.godArmIdList)
    end

    newConfig.supportSkillHeroIndex = heroTeamInfo.hero.supportSkillHeroIndex
    newConfig.supportSkillHeroIndex2 = heroTeamInfo.hero.supportSkillHeroIndex2

    table.mergeForArray(newConfig.pvp_rivals, enemyTeamInfo.enemy.heroes)
    if enemyTeamInfo.enemy.supports then
        table.mergeForArray(newConfig.pvp_rivals2, enemyTeamInfo.enemy.supports)
    end
    if enemyTeamInfo.enemy.soulSpirits then
        table.mergeForArray(newConfig.enemySoulSpirits, enemyTeamInfo.enemy.soulSpirits)
    end
    if enemyTeamInfo.enemy.godArmIdList then
        table.mergeForArray(newConfig.enemyGodArmIdList, enemyTeamInfo.enemy.godArmIdList)
    end
    newConfig.supportSkillEnemyIndex = enemyTeamInfo.enemy.supportSkillHeroIndex
    newConfig.supportSkillEnemyIndex2 = enemyTeamInfo.enemy.supportSkillHeroIndex2

    self._nextPVPWaveDungeonConfig = newConfig

    return true 
end

function QBattleManager:getPVPMultipleNextConfig()
    return self._nextPVPWaveDungeonConfig
end

function QBattleManager:_onLose(options)
    -- 太阳井敌方魂师剩余血量记录
    if self:isInSunwell() then
        self._sunwellEnemyHP = {}
        self._sunwellEnemyMaxHP = {}
        for _, enemy in ipairs(self:getEnemies()) do
            self._sunwellEnemyHP[enemy] = enemy:getHp()
            self._sunwellEnemyMaxHP[enemy] = enemy:getMaxHp()
        end
    end

    for _, enemy in ipairs(self._enemies) do
        if not enemy:isDead() then
            function enemy:increaseHp(...)
                return self
            end
            function enemy:setFullHp(...)
                return self
            end
            function enemy:setHp(...)
                return self
            end
            break
        end
    end

    if self._onLose_Time then
        return
    else
        self._onLose_Time = self:getTime()
    end

    -- 保存要塞boss剩余血量
    if self:isInRebelFight() and self:getEnemies()[1] then
        self._rebelFightBossHp = self:getEnemies()[1]:getHp()
    end

    -- 保存世界boss剩余血量
    if self:isInWorldBoss() and self:getEnemies()[1] then
        self._worldBossFightBossHp = self:getEnemies()[1]:getHp()
    end

    -- 保存宗门boss剩余血量
    if self:isInSocietyDungeon() and self:getEnemies()[1] then
        self._societyBossHp = self:getEnemies()[1]:getHp()
    end

    -- 保存巨龙boss剩余血量
    if self:isInUnionDragonWar() and self:getEnemies()[1] then
        self._unionDragonBossHp = self:getEnemies()[1]:getHp()
    end

    if self:isPVPMultipleWaveNew() then
        if self:isInMetalAbyss() then
            self:checkMetalAbyssNextWave(false)
        elseif self:isPVP2TeamBattle() then
            self:checkPVP2TeamBattleNextWave(false)
        elseif self:isTotemChallenge() then
            self:checkTotemChallengeNextWave(false)
        else
            self:checkPVPMultipleNextWave(false)
        end
    end

    

    if (not self:isInReplay() and not self:isInQuick()) and (self:isPVPMultipleWaveNew() == false or self:getPVPMultipleNextConfig() == nil or self:isInTotemChallenge()) then
        self._dungeonConfig.isClientWin = false
        table.insert(self._dungeonConfig.recordList, clone(self._record))
        app:saveBattleRecordIntoProtobuf(self._dungeonConfig.recordList)
    end

    if IsServerSide then
        -- evil code for blackrock fight
        if self:isInBlackRock() and self._dungeonConfig.isClientWin then
            local enemy = self:getEnemies()[1]
            if enemy and enemy:getHp() / enemy:getMaxHp() < 0.1 then
                self._ended = true
                self._result = 0
                createReplayOutput(true)
                print("verify result: WIN")
                return
            end
        end
        if self:isMockBattle() then
            self:saveMockBattle2Resulte(false)
        end
        self._ended = true
        self._result = 1
        createReplayOutput(false, not not (options and options.isTimeOver))
        print("verify result: LOSE")
        return
    end
    
    self._battleLog:setIsWin(false)
    self._battleLog:setIsOvertime(not not (options and options.isTimeOver))

    local handle
    local local_onLose
    handle = scheduler.scheduleGlobal(function()
        if self:isAllRoundFinished() then
            local_onLose()
            scheduler.unscheduleGlobal(handle)
        end
    end, 0)

    local_onLose = function()
        if options == nil then
            options = {}
        end

        if (self:isInRebelFight() or self:isInWorldBoss() or self:isInSocietyDungeon() or self:isInUnionDragonWar() ) and self._timeLeft <= 0 then
            for _, hero in ipairs(self:getHeroes()) do
                hero:suicide()
            end
        end

        scheduler.setTimeFunction(dummyTimeFunction)

        if SAVE_BATTLE_RECORD and (not self:isInReplay()) then
            -- app:saveBattleRecord(clone(self._record))
            if self:isPVPMode() and self:isInArena() then
                -- app:saveBattleRecordIntoProtobuf(self._record)
            end
            if ENABLE_STREAM_REPLAY then
                self:performWithDelay(handler(app, app.saveBattleRecordStream), 0, nil, true, true) -- 犹豫当前帧是记录帧，所以要等当前帧被记录到流中（也就是下一帧的开始之后），才可以保存流
            end
        elseif (device.platform == "mac") and self:isInReplay() and not self:isInQuick() then
            print("#recordTimeSlices = %d, #replayTimeSlices = %d", #self._record.recordTimeSlices, #self._dungeonConfig.replayTimeSlices)
            CCMessageBox(string.format("#recordTimeSlices = %d, #replayTimeSlices = %d", #self._record.recordTimeSlices, #self._dungeonConfig.replayTimeSlices), "")
        end

        app:resetBattleNpcProbability(self._dungeonConfig.id)

        if self:isPVPMultipleWaveNew() and self:getPVPMultipleNextConfig() ~= nil and not self:isInTotemChallenge() then
            local event = {
                name = QBattleManager.PVP_MULTIPLE_WAVE_END,
                isWin = false,
                skipMove = options.skipMove,
            }
            table.merge(event, options)
            self:dispatchEvent(event)
            self:dispatchEvent({name = QBattleManager.WAVE_ENDED_FOR_ACTOR})
        else
            local event = {name = QBattleManager.LOSE}
            table.merge(event, options)
            self:dispatchEvent(event)
        end

        self._ended = true
        self:_checkEndCountDown()
        self._battleLog:setEndTime(q.time())
        app:resetBattleNpcProbability(self._dungeonConfig.id)

        -- self:_debugPrintCCB()
        -- self:_debugPrintSpine()
    end
end

function QBattleManager:onConfirmNewWave()
    -- app.grid:continueMoving()
    print("QBattleManager:onConfirmNewWave()")
    -- remove trap
    for _, trapDirector in ipairs(self._trapDirectors) do
        if trapDirector:isCompleted() == false then
            trapDirector:cancel()
        end
    end
    self._trapDirectors = {}

    -- 移除导致玩家不能移动的debuff
    local actors = {}
    table.mergeForArray(actors, self._heroes)
    table.mergeForArray(actors, self._heroGhosts, nil, function(ghost) return ghost.actor end)
    for _, actor in ipairs(actors) do
        if not actor:isDead() then
            actor:removeCannotControlMoveBuff()
        end
    end
    
    -- 中立npc过场死亡
    local netrualActors = {}
    table.mergeForArray(netrualActors, self._neutralHeroes)
    table.mergeForArray(netrualActors, self._neutralEnemies)
    for _, actor in ipairs(netrualActors) do
        actor:suicide()
        if actor:getType() == ACTOR_TYPES.NPC then 
            self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = actor,  isBoss = actor:isBoss(), isEliteBoss = actor:isEliteBoss()})
        else
            self:dispatchEvent({name = QBattleManager.HERO_CLEANUP, hero = actor})
        end
    end

    self:dispatchEvent({name = QBattleManager.WAVE_CONFIRMED, wave = self._curWave})
end

function QBattleManager:onStartNewWave()
    if self._nextWave == nil or self._pauseBetweenWaves == false then
        return
    end

    if self._nextWave <= self._curWave then
        assert(false, "QBattleManager:onStartNewWave next wave is equal to or small then current wave!")
        return
    end

    local startNewWave = function()
        self._pauseBetweenWaves = false

        self:_checkStartCountDown()

        self._pauseAI = false
        self._curWave = self._nextWave
        self._curWaveStartTime = self:getTime() -- + global.wave_animation_time

        local isBossComing = false
        for _, item in ipairs(self._monsters) do
            if item.wave == self._curWave and item.created ~= true and item.is_boss == true then
                if item.appear < global.wave_animation_time then
                    isBossComing = true 
                    break
                end
            end
        end

        self:performWithDelay(function()
            self:dispatchEvent({name = QBattleManager.WAVE_STARTED, wave = self._nextWave, isBossComing = isBossComing})
        end, 0)

        for _, hero in ipairs(self._heroes) do
            hero:setManualMode(QActor.AUTO)
            hero:clearLastAttackee()
        end
    end

    local datebase = QStaticDatabase:sharedDatabase()
    if not IsServerSide and self._storyLine and not self:isPVPMode() and not self:isPVPMultipleWave() then
        self._storyLine:setPauseCallback(function() startNewWave() end)
        self._storyLine:resume()
    else
        startNewWave()
    end 

end

function QBattleManager:createEnemiesInPVPMode()
    if self:isPVPMode() == false then
        return
    end

    -- collect team skills
    local skills = {}
    -- Get team skill from enemy totems
    local totemInfos = (self._dungeonConfig.pvp_rivals[1] or {}).totemInfos or {}
    for _, totemInfo in ipairs(totemInfos) do
        local config = db:getDragonTotemConfigByIdAndLevel(totemInfo.dragonDesignId, totemInfo.grade)
        if config then
            local skillId = config.skill_id
            local level = totemInfo.grade
            if skillId and level then
                local skillConfig = db:getSkillByID(skillId)
                if skillConfig.type == QSkill.TEAM then
                    table.insert(skills, {id = skillId, level = level})
                end
            end
        end
    end
    -- 战场技能
    local sunWarSKillIds = self._dungeonConfig.heroSkillBonuses or {}
    for _, skillId in ipairs(sunWarSKillIds) do
        table.insert(skills, {id = skillId, level = 1}) -- 技能等级暂时默认为1
    end
    -- get team skill from enemy
    (
        function(visitor, ...)
            local arrs = {...}
            for _, arr in ipairs(arrs) do
                for _, obj in ipairs(arr) do
                    visitor(obj)
                end
            end
        end
    )(
        function(actor)
            for _, skill in pairs(actor:getTeamSkills()) do
                table.insert(skills, {id = skill:getId(), level = skill:getSkillLevel()})
            end
        end,
        self:getEnemies(), self:getSupportEnemies(), self:getSupportEnemies2(), self:getSupportEnemies3()
    )

    -- apply team skill property
    for _, skill in ipairs(skills) do
        local skillId, level = skill.id, skill.level
        local skillDataConfig = db:getSkillDataByIdAndLevel(skillId, level)
        if skillDataConfig then
            local skillConfig = db:getSkillByID(skillId)
            local teamSkillProperty
            if skillConfig.target_type == QSkill.ENEMY then
                teamSkillProperty = self._heroTeamSkillProperty
            else
                teamSkillProperty = self._enemyTeamSkillProperty
            end

            local count = 1
            while true do
                local key = skillDataConfig["addition_type_"..count]
                local value = skillDataConfig["addition_value_"..count]
                if key == nil then
                    break
                end
                teamSkillProperty[key] = (teamSkillProperty[key] or 0) + value
                count = count + 1
            end
        end
    end
       
    -- 计算羁绊技能，以及组合属性，宗门技能属性，头像属性，考古属性
    local additionalInfos = self:getEnemyAdditionInfos() 
    local extraProp = self._dungeonConfig.enemyExtraProp or {}

    -- hp from server
    local hpFromServerIDs = {}

    for _, hero in ipairs(self._dungeonConfig.pvp_rivals or {}) do
        local actor = self:_createHero(hero, additionalInfos, false, false, nil, self:isInTotemChallenge(), self._enemyGodArmSkillIds1, extraProp)
        actor:setType(ACTOR_TYPES.NPC)
        self._enemy_skin_infos[hero.actorId] = hero.skinId
        actor:resetStateForBattle()
        self:_applyEnemyAttrEnterRage(actor)
        if hero.currMp ~= nil then
            if actor:isNeedComboPoints() then
                local cp = math.floor(hero.currMp / 1000 * actor:getComboPointsMax())
                if cp >= 0 then
                    actor:setComboPoints(cp)
                end
            elseif actor:isRageReserve() then
                actor:setRage(hero.currMp)
            end
        end
        if hero.skillCD ~= nil and hero.skillCD > 0 then
            for _, skill in pairs(actor:getManualSkills()) do
                skill:coolDown()
                local realcdt = skill:getCdTime() * hero.skillCD * 0.001
                skill:reduceCoolDownTime(realcdt)
            end
        end

        actor.ai = self._aiDirector:createBehaviorTree(actor:getAIType(), actor)
        self._aiDirector:addBehaviorTree(actor.ai)

        actor:setForceAuto(true)

        if self:isPVPMode() and self:isPVPMultipleWave() then
            table.insert(self._enemiesWave1, actor)
        end
        table.insert(self._enemies, actor)
        self._actorsByUDID[actor:getUDID()] = actor
        self._battleLog:onEnemyHeroDoDHP(actor:getActorID(), 0, actor)
        self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = actor, pos = {x = 0, y = 0}, isBoss = false})

        -- summon hunter pet
        actor:summonHunterPet()

        -- actor:dump()
    end

    -- 副将 pvp初始化
    for i, hero in ipairs(self._dungeonConfig.pvp_rivals2 or {}) do
        local actor = self:_createHero(hero, additionalInfos, not self:isPVPMultipleWave(), false, nil, self:isInTotemChallenge(), self._enemyGodArmSkillIds2, extraProp)
        actor:setType(ACTOR_TYPES.NPC)
        self._enemy_skin_infos[hero.actorId] = hero.skinId
        actor:resetStateForBattle()
        actor:setIsSupportHero(not self:isPVPMode() or not self:isPVPMultipleWave())
        if not self:isPVPMultipleWave() then
            actor:setRage(0, true)
        else
            self:_applyEnemyAttrEnterRage(actor)
        end

        if hero.currHp ~= nil and hero.currHp > 0 then
            actor:setHp(hero.currHp)
            hpFromServerIDs[hero.actorId] = hero.actorId
        end
        if hero.currMp ~= nil then
            if actor:isNeedComboPoints() then
                local cp = math.floor(hero.currMp / 1000 * actor:getComboPointsMax())
                if cp >= 0 then
                    actor:setComboPoints(cp)
                end
            elseif actor:isRageReserve() then
                actor:setRage(hero.currMp)
            end
        end
        if not self:isPVPMode() or not self:isPVPMultipleWave() then
            if hero.skillCD ~= nil and hero.skillCD > 0 then
                for _, skill in pairs(actor:getManualSkills()) do
                    skill:coolDown()
                    local realcdt = skill:getCdTime() * hero.skillCD * 0.001
                    skill:reduceCoolDownTime(realcdt)
                end
            end
        end

        actor:setForceAuto(true)

        self._actorsByUDID[actor:getUDID()] = actor
        self._battleLog:onEnemyHeroDoDHP(actor:getActorID(), 0, actor)
        if self:isPVPMode() and self:isPVPMultipleWave() then
            table.insert(self._enemiesWave2, actor)
        else
            table.insert(self._supportEnemies, actor)
            if self:isPVPMultipleWaveNew() then
                self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = actor, pos = {x = 0, y = 0}, isBoss = false, isNoneSkillSupport = i ~= self._dungeonConfig.supportSkillEnemyIndex and i ~= self._dungeonConfig.supportSkillEnemyIndex2})
            else
                self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = actor, pos = {x = 0, y = 0}, isBoss = false, isNoneSkillSupport = i ~= self._dungeonConfig.supportSkillEnemyIndex})
            end
            app.grid:setActorTo(actor, qccp(1.5 * BATTLE_AREA.width, 0.5 * BATTLE_AREA.height))
            -- summon hunter pet
            table.insert(self._enemies, actor) -- 为了能找出宝宝，先把援助英雄放入self._enemies中。然后再移除出去。
            local pet = actor:summonHunterPet(true) -- 援助英雄宝宝不使用ai
            table.remove(self._enemies, #self._enemies)
            if pet then
                app.grid:setActorTo(pet, qccp(1.5 * BATTLE_AREA.width, 0.5 * BATTLE_AREA.height))
            end
        end

        actor:dump()
    end

    -- 副将2 pvp初始化
    for i, hero in ipairs(self._dungeonConfig.pvp_rivals4 or {}) do
        local actor = self:_createHero(hero, additionalInfos, not self:isPVPMultipleWave(), false, nil, self:isInTotemChallenge(), self._enemyGodArmSkillIds3, extraProp)
        actor:setType(ACTOR_TYPES.NPC)
        self._enemy_skin_infos[hero.actorId] = hero.skinId
        actor:resetStateForBattle()
        actor:setIsSupportHero(not self:isPVPMode() or not self:isPVPMultipleWave())
        if not self:isPVPMultipleWave() then
            actor:setRage(0, true)
        else
            self:_applyEnemyAttrEnterRage(actor)
        end

        if hero.currHp ~= nil and hero.currHp > 0 then
            actor:setHp(hero.currHp)
            hpFromServerIDs[hero.actorId] = hero.actorId
        end
        if hero.currMp ~= nil then
            if actor:isNeedComboPoints() then
                local cp = math.floor(hero.currMp / 1000 * actor:getComboPointsMax())
                if cp >= 0 then
                    actor:setComboPoints(cp)
                end
            elseif actor:isRageReserve() then
                actor:setRage(hero.currMp)
            end
        end
        if not self:isPVPMode() or not self:isPVPMultipleWave() then
            if hero.skillCD ~= nil and hero.skillCD > 0 then
                for _, skill in pairs(actor:getManualSkills()) do
                    skill:coolDown()
                    local realcdt = skill:getCdTime() * hero.skillCD * 0.001
                    skill:reduceCoolDownTime(realcdt)
                end
            end
        end

        actor:setForceAuto(true)

        self._actorsByUDID[actor:getUDID()] = actor
        self._battleLog:onEnemyHeroDoDHP(actor:getActorID(), 0, actor)
        if self:isPVPMode() and self:isPVPMultipleWave() then
            table.insert(self._enemiesWave3, actor)
        else
            table.insert(self._supportEnemies2, actor)
            if self:isPVPMultipleWaveNew() then
                self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = actor, pos = {x = 0, y = 0}, isBoss = false, isNoneSkillSupport = false})
            else
                self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = actor, pos = {x = 0, y = 0}, isBoss = false, isNoneSkillSupport = i ~= self._dungeonConfig.supportSkillEnemyIndex2})
            end
            app.grid:setActorTo(actor, qccp(1.5 * BATTLE_AREA.width, 0.5 * BATTLE_AREA.height))
            -- summon hunter pet
            table.insert(self._enemies, actor) -- 为了能找出宝宝，先把援助英雄放入self._enemies中。然后再移除出去。
            local pet = actor:summonHunterPet(true) -- 援助英雄宝宝不使用ai
            table.remove(self._enemies, #self._enemies)
            if pet then
                app.grid:setActorTo(pet, qccp(1.5 * BATTLE_AREA.width, 0.5 * BATTLE_AREA.height))
            end
        end

        actor:dump()
    end

    -- 副将3 pvp初始化
    for i, hero in ipairs(self._dungeonConfig.pvp_rivals6 or {}) do
        local actor = self:_createHero(hero, additionalInfos, not self:isPVPMultipleWave(), false, nil, nil, nil, extraProp)
        actor:setType(ACTOR_TYPES.NPC)
        self._enemy_skin_infos[hero.actorId] = hero.skinId
        actor:resetStateForBattle()
        actor:setIsSupportHero(not self:isPVPMode() or not self:isPVPMultipleWave())
        if not self:isPVPMultipleWave() then
            actor:setRage(0, true)
        else
            self:_applyEnemyAttrEnterRage(actor)
        end

        if hero.currHp ~= nil and hero.currHp > 0 then
            actor:setHp(hero.currHp)
            hpFromServerIDs[hero.actorId] = hero.actorId
        end
        if hero.currMp ~= nil then
            if actor:isNeedComboPoints() then
                local cp = math.floor(hero.currMp / 1000 * actor:getComboPointsMax())
                if cp >= 0 then
                    actor:setComboPoints(cp)
                end
            elseif actor:isRageReserve() then
                actor:setRage(hero.currMp)
            end
        end
        if not self:isPVPMode() or not self:isPVPMultipleWave() then
            if hero.skillCD ~= nil and hero.skillCD > 0 then
                for _, skill in pairs(actor:getManualSkills()) do
                    skill:coolDown()
                    local realcdt = skill:getCdTime() * hero.skillCD * 0.001
                    skill:reduceCoolDownTime(realcdt)
                end
            end
        end

        actor:setForceAuto(true)

        self._actorsByUDID[actor:getUDID()] = actor
        self._battleLog:onEnemyHeroDoDHP(actor:getActorID(), 0, actor)
        if self:isPVPMode() and self:isPVPMultipleWave() then
            -- table.insert(self._enemiesWave4, actor)
        else
            table.insert(self._supportEnemies3, actor)
            if self:isPVPMultipleWaveNew() then
                self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = actor, pos = {x = 0, y = 0}, isBoss = false, isNoneSkillSupport = false})
            else
                self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = actor, pos = {x = 0, y = 0}, isBoss = false, isNoneSkillSupport = i ~= self._dungeonConfig.supportSkillEnemyIndex3})
            end
            app.grid:setActorTo(actor, qccp(1.5 * BATTLE_AREA.width, 0.5 * BATTLE_AREA.height))
            -- summon hunter pet
            table.insert(self._enemies, actor) -- 为了能找出宝宝，先把援助英雄放入self._enemies中。然后再移除出去。
            local pet = actor:summonHunterPet(true) -- 援助英雄宝宝不使用ai
            table.remove(self._enemies, #self._enemies)
            if pet then
                app.grid:setActorTo(pet, qccp(1.5 * BATTLE_AREA.width, 0.5 * BATTLE_AREA.height))
            end
        end

        actor:dump()
    end

    if self._dungeonConfig.enemyAlternateInfos ~= nil then
        for i, heroInfo in ipairs(self._dungeonConfig.enemyAlternateInfos) do
            local hero = self:_createHero(heroInfo, additionalInfos, false, true, nil, nil, self._enemyGodArmSkillIds1, extraProp)
            hero:setType(ACTOR_TYPES.NPC)
            hero:setIsSupportHero(false)
            hero:resetStateForBattle()
            hero:checkCDReduce()
            hero:setIsCandidate(true)
            -- 云顶传承不需要
            if self:isSotoTeam() and not self:isSotoTeamEquilibrium() and not self:isSotoTeamInherit() then
                hero:setRage(global.candidate_actor_initial_rage[i])
            end
            table.insert(self._candidateEnemies, hero)
            self:_applyEnemyAttrEnterRage(hero)
            self._actorsByUDID[hero:getUDID()] = hero
            self._battleLog:onEnemyHeroDoDHP(hero:getActorID(), 0, hero)
            self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = hero, pos = {x = 0, y = 0}, isBoss = false, isCandidate = true})
        end
    end

    if self:isPVPMultipleWaveNew() or self:isPVEMultipleWave() then
            -- 副将 敌对技能魂师
            if self._dungeonConfig.supportSkillEnemyIndex then
                self._supportSkillEnemy = self._supportEnemies[self._dungeonConfig.supportSkillEnemyIndex]
                self._battleLog:setSupportSkillEnemy(self._supportSkillEnemy)
            end
            -- 副将2 敌对技能魂师
            if self._dungeonConfig.supportSkillEnemyIndex2 then
                self._supportSkillEnemy2 = self._supportEnemies[self._dungeonConfig.supportSkillEnemyIndex2]
                self._battleLog:setSupportSkillEnemy2(self._supportSkillEnemy2)
            end
    elseif not self:isPVPMode() or not self:isPVPMultipleWave() then
        -- 副将 敌对技能魂师
        if self._dungeonConfig.supportSkillEnemyIndex then
            self._supportSkillEnemy = self._supportEnemies[self._dungeonConfig.supportSkillEnemyIndex]
            self._battleLog:setSupportSkillEnemy(self._supportSkillEnemy)
        end
        -- 副将2 敌对技能魂师
        if self._dungeonConfig.supportSkillEnemyIndex2 then
            self._supportSkillEnemy2 = self._supportEnemies2[self._dungeonConfig.supportSkillEnemyIndex2]
            self._battleLog:setSupportSkillEnemy2(self._supportSkillEnemy2)
        end
        -- 副将3 敌对技能魂师
        if self._dungeonConfig.supportSkillEnemyIndex3 then
            self._supportSkillEnemy3 = self._supportEnemies3[self._dungeonConfig.supportSkillEnemyIndex3]
            self._battleLog:setSupportSkillEnemy3(self._supportSkillEnemy3)
        end
    end

    self:_applyPassiveSkillPropertyForMainRival()

    if not self:isPVPMode() or not self:isPVPMultipleWave() then
        self:_applySupportEnemyAttributes(hpFromServerIDs)
    end
    if self:isMockBattle() then
        self:_applyMockBattlePropEnemy()
    end
    for _, enemy in ipairs(self._enemies) do
        self:_applySunwarHardDebuffForEnemy(enemy)
    end

    for index, hero in ipairs(self._dungeonConfig.pvp_rivals or {}) do
        if hero.currHp ~= nil and hero.currHp > 0 then
            local actor = self._enemies[index]
            actor:setHp(hero.currHp)
            hpFromServerIDs[hero.actorId] = hero.actorId
        end
    end

    -- 副本以及非海神岛首次enter_cd
    if not self:isInSunwell() and not self:isInTutorial() then
        for _, hero in ipairs(self._enemies) do
            for _, skill in pairs(hero:getSkills()) do
                if skill:get("enter_cd") ~= nil then
                    skill:coolDown()
                end
            end
        end
        if not self:isPVPMode() or not self:isPVPMultipleWave() then
            for _, hero in ipairs(self._supportEnemies) do
                for _, skill in pairs(hero:getSkills()) do
                    if skill:get("enter_cd") ~= nil then
                        skill:coolDown()
                    end
                end
            end
            for _, hero in ipairs(self._supportEnemies2) do
                for _, skill in pairs(hero:getSkills()) do
                    if skill:get("enter_cd") ~= nil then
                        skill:coolDown()
                    end
                end
            end
            for _, hero in ipairs(self._supportEnemies3) do
                for _, skill in pairs(hero:getSkills()) do
                    if skill:get("enter_cd") ~= nil then
                        skill:coolDown()
                    end
                end
            end
        end
    end
end

function QBattleManager:_prepareHeroes()
    -- collect team skills
    local skills = {}
    -- Get team skill from hero totems
    local heroInfos = self._dungeonConfig.heroInfos
    local totemInfos = (heroInfos[1] or {}).totemInfos or {}
    for _, totemInfo in ipairs(totemInfos) do
        local config = db:getDragonTotemConfigByIdAndLevel(totemInfo.dragonDesignId, totemInfo.grade)
        if config then
            local skillId = config.skill_id
            local level = totemInfo.grade
            if skillId and level then
                local skillConfig = db:getSkillByID(skillId)
                if skillConfig.type == QSkill.TEAM then
                    table.insert(skills, {id = skillId, level = level})
                end
            end
        end
    end
    -- get team skill from hero
    (
        function(visitor, ...)
            local arrs = {...}
            for _, arr in ipairs(arrs) do
                for _, obj in ipairs(arr) do
                    visitor(obj)
                end
            end
        end
    )(
        function(actor)
            for _, skill in pairs(actor:getTeamSkills()) do
                table.insert(skills, {id = skill:getId(), level = skill:getSkillLevel()})
            end
        end,
        self:getHeroes(), self:getSupportHeroes(), self:getSupportHeroes2(), self:getSupportHeroes3()
    )

    -- apply team skill property
    for _, skill in ipairs(skills) do
        local skillId, level = skill.id, skill.level
        local skillDataConfig = db:getSkillDataByIdAndLevel(skillId, level)
        if skillDataConfig then
            local skillConfig = db:getSkillByID(skillId)
            local teamSkillProperty
            if skillConfig.target_type == QSkill.ENEMY then
                teamSkillProperty = self._enemyTeamSkillProperty
            else
                teamSkillProperty = self._heroTeamSkillProperty
            end

            local count = 1
            while true do
                local key = skillDataConfig["addition_type_"..count]
                local value = skillDataConfig["addition_value_"..count]
                if key == nil then
                    break
                end
                teamSkillProperty[key] = (teamSkillProperty[key] or 0) + value
                count = count + 1
            end
        end
    end
    
    if app.battle:isInTutorial() == true then
        local w = BATTLE_AREA.width / global.screen_big_grid_width
        local h = BATTLE_AREA.height / global.screen_big_grid_height
        local heros = app.battle:getHeroes()
        local heroCount = table.nums(heros)
        for i, hero in ipairs(heros) do
            hero:setAnimationScale(app.battle:getTimeGear(), "time_gear")
            local x = self._dungeonConfig.heroInfos[i].position.x * w + BATTLE_AREA.left
            local y = self._dungeonConfig.heroInfos[i].position.y * h + BATTLE_AREA.bottom
            app.grid:addActor(hero)
            app.grid:setActorTo(hero, {x = x, y = y})
        end

    elseif app.battle:isPVPMode() == true then
        local heros = app.battle:getHeroes()
        local heroCount = table.nums(heros)
        for i, hero in ipairs(heros) do
            hero:setAnimationScale(app.battle:getTimeGear(), "time_gear")

            -- set hero hp and skill cooldown time 
            if self:isInSunwell() == true then
                local heroInfoInSunwell
                for _, heroInfo in ipairs(self._dungeonConfig.heroInfos) do
                    if heroInfo.actorId == hero:getActorID() then
                        heroInfoInSunwell = heroInfo.heroInfoInSunwell
                        break
                    end
                end
                if heroInfoInSunwell ~= nil then
                    local heroStatusView = nil
                    if not IsServerSide then
                        heroStatusView = app.scene:getHeroStatusViewByActor(hero)
                    end
                    if heroInfoInSunwell.currHp ~= nil then
                        hero:setHp(math.min(heroInfoInSunwell.currHp, hero:getMaxHp()))
                        if heroStatusView then heroStatusView:onHpChanged() end
                    end
                    if heroInfoInSunwell.currMp ~= nil and hero:isRageReserve() then
                        hero:setRage(heroInfoInSunwell.currMp)
                    end
                    if heroInfoInSunwell.skillCD ~= nil and heroInfoInSunwell.skillCD > 0 then
                        for _, skill in pairs(hero:getManualSkills()) do
                            skill:coolDown()
                            local realcdt = skill:getCdTime() * heroInfoInSunwell.skillCD * 0.001
                            skill:reduceCoolDownTime(realcdt)
                            if skill:getCDProgress() < 1.0 then
                                if heroStatusView then heroStatusView:onCdStarted() end
                                if heroStatusView then heroStatusView:updateSkillCD(1.0 - skill:getCDProgress()) end
                            end
                        end
                    end
                else
                    for _, skill in pairs(hero:getManualSkills()) do
                        skill:coolDown()
                        if heroStatusView then heroStatusView:onCdStarted() end
                        if heroStatusView then heroStatusView:updateSkillCD(0.999) end
                    end
                end
            elseif self:isInArena() == true then
                if not app.battle:isArenaAllowControl() then
                    hero:setForceAuto(true)
                end
            elseif self:isInSilverMine() == true then
                hero:setForceAuto(true)
            end
        end

        local left = BATTLE_AREA.left
        local bottom = BATTLE_AREA.bottom
        local w = BATTLE_AREA.width
        local h = BATTLE_AREA.height
        -- 魂师入场起始点
        local stopPosition = clone(ARENA_HERO_POS)
        for _, position in ipairs(stopPosition) do
            position[1] = BATTLE_AREA.left + position[1] + BATTLE_AREA.width / 2
            position[2] = BATTLE_AREA.bottom + position[2] + BATTLE_AREA.height / 2
        end
        
        for i, hero in ipairs(heros) do
            local index = heroCount - i + 1
            hero._enterStartPosition = {x = stopPosition[index][1] - BATTLE_AREA.width / 2, y = stopPosition[index][2]}
            hero._enterStopPosition = {x = stopPosition[index][1], y = stopPosition[index][2]}
            app.grid:addActor(hero) -- 注意要在view创建后加入app.grid，否则只有model，没有view的情况下，有些状态消息会miss掉
            app.grid:setActorTo(hero, hero._enterStartPosition)
            app.grid:moveActorTo(hero, hero._enterStopPosition)

            -- 宠物出场
            local pet = hero:getHunterPet()
            if pet then
                local startpos = clone(hero._enterStartPosition)
                local stoppos = clone(hero._enterStopPosition)
                startpos.x = startpos.x - 125
                stoppos.x = stoppos.x - 125
                
                app.grid:addActor(pet)
                app.grid:setActorTo(pet, startpos)
                app.grid:moveActorTo(pet, stoppos)
            end

            self:_checkBattleStartDelay(startPosition, stopPosition, hero:getMoveSpeed())
        end
    else
        local heros = app.battle:getHeroes()
        local heroCount = table.nums(heros)

        for i, hero in ipairs(heros) do
            hero:setAnimationScale(app.battle:getTimeGear(), "time_gear")
        end

        local left = BATTLE_AREA.left
        local bottom = BATTLE_AREA.bottom
        local w = BATTLE_AREA.width
        local h = BATTLE_AREA.height
        -- 魂师入场起始点
        local stopPosition = clone(HERO_POS)
        for _, position in ipairs(stopPosition) do
            position[1] = BATTLE_AREA.left + position[1] + BATTLE_AREA.width / 2
            position[2] = BATTLE_AREA.bottom + position[2] + BATTLE_AREA.height / 2
        end
        
        if self:isInUnionDragonWar() then
            for i, hero in ipairs(heros) do
                local index = heroCount - i + 1
                hero._enterStartPosition = {x = stopPosition[index][1] - BATTLE_AREA.width / 2, y = stopPosition[index][2]}
                hero._enterStopPosition = {x = stopPosition[index][1], y = stopPosition[index][2]}
                app.grid:addActor(hero) -- 注意要在view创建后加入app.grid，否则只有model，没有view的情况下，有些状态消息会miss掉
                app.grid:setActorTo(hero, hero._enterStopPosition)

                -- 宠物出场
                local pet = hero:getHunterPet()
                if pet then
                    local startpos = clone(hero._enterStartPosition)
                    local stoppos = clone(hero._enterStopPosition)
                    startpos.x = startpos.x - 125
                    stoppos.x = stoppos.x - 125
                    app.grid:addActor(pet)
                    app.grid:setActorTo(pet, stoppos)
                    pet:setDirection(QActor.DIRECTION_RIGHT)
                end
                hero:setDirection(QActor.DIRECTION_RIGHT)
            end
        else
            for i, hero in ipairs(heros) do
                local index = heroCount - i + 1
                hero._enterStartPosition = {x = stopPosition[index][1] - BATTLE_AREA.width / 2, y = stopPosition[index][2]}
                hero._enterStopPosition = {x = stopPosition[index][1], y = stopPosition[index][2]}
                app.grid:addActor(hero) -- 注意要在view创建后加入app.grid，否则只有model，没有view的情况下，有些状态消息会miss掉
                if not hero:getAppearSkillId() then
                    app.grid:setActorTo(hero, hero._enterStartPosition)
                    app.grid:moveActorTo(hero, hero._enterStopPosition)
                else
                    hero._enterStartPosition.x = hero._enterStartPosition.x - hero:getRect().size.width
                    app.grid:setActorTo(hero, hero._enterStartPosition)
                    app.grid:moveActorTo(hero, hero._enterStartPosition, true)
                    hero:setDirection(hero.DIRECTION_RIGHT)
                    hero:attack(hero:getSkillWithId(hero:getAppearSkillId()), nil, nil, true)
                end

                -- 宠物出场
                local pet = hero:getHunterPet()
                if pet then
                    local startpos = clone(hero._enterStartPosition)
                    local stoppos = clone(hero._enterStopPosition)
                    startpos.x = startpos.x - 125
                    stoppos.x = stoppos.x - 125
                    app.grid:addActor(pet)
                    if not pet:getAppearSkillId() then
                        app.grid:setActorTo(pet, startpos)
                        app.grid:moveActorTo(pet, stoppos)
                    else
                        pet:attack(pet:getSkillWithId(hero:getAppearSkillId()), nil, nil, true)
                    end
                end
            end
        end

        for i, hero in ipairs(heros) do
            local leftHp, leftMp = self:getHeroLeftHp(hero:getActorID())
            if leftHp then
                if leftHp > 0 then
                    hero:setHp(math.min(leftHp, hero:getMaxHp()))
                    if not IsServerSide then
                        local statusView = app.scene:getHeroStatusViewByActor(hero)
                        if statusView then statusView:onHpChanged() end 
                    end
                elseif leftHp == 0 then
                    hero:suicide()
                end
            end
            if leftMp and leftMp > 0 then
                hero:setRage(leftMp)
            end
        end
    end

    if not self:isPVPMultipleWave() then
        if (not self:isPVPMultipleWaveNew()) and (not self:isPVEMultipleWave()) then
            -- 副将 魂师副将actor初始化
            local sprts = app.battle:getSupportHeroes()
            for _, sprt in ipairs(sprts) do
                local x = -BATTLE_AREA.width / 2
                local y = BATTLE_AREA.height / 2

                if sprt == app.battle:getSupportSkillHero() then
                    sprt:setDirection(QActor.DIRECTION_RIGHT)
                    sprt:setAnimationScale(app.battle:getTimeGear(), "time_gear")
                    app.grid:addActor(sprt)
                    app.grid:setActorTo(sprt, qccp(x, y))
                end

                local pet = sprt:getHunterPet()
                if pet then
                    app.grid:addActor(pet)
                    app.grid:setActorTo(pet, qccp(x, y))
                end
            end

            -- 副将2 魂师副将actor初始化
            local sprts = app.battle:getSupportHeroes2()
            for _, sprt in ipairs(sprts) do
                local x = -BATTLE_AREA.width / 2
                local y = BATTLE_AREA.height / 2

                if sprt == app.battle:getSupportSkillHero2() then
                    sprt:setDirection(QActor.DIRECTION_RIGHT)
                    sprt:setAnimationScale(app.battle:getTimeGear(), "time_gear")
                    app.grid:addActor(sprt)
                    app.grid:setActorTo(sprt, qccp(x, y))
                end

                local pet = sprt:getHunterPet()
                if pet then
                    app.grid:addActor(pet)
                    app.grid:setActorTo(pet, qccp(x, y))
                end
            end

            -- 副将3 魂师副将actor初始化
            local sprts = app.battle:getSupportHeroes3()
            for _, sprt in ipairs(sprts) do
                local x = -BATTLE_AREA.width / 2
                local y = BATTLE_AREA.height / 2

                if sprt == app.battle:getSupportSkillHero3() then
                    sprt:setDirection(QActor.DIRECTION_RIGHT)
                    sprt:setAnimationScale(app.battle:getTimeGear(), "time_gear")
                    app.grid:addActor(sprt)
                    app.grid:setActorTo(sprt, qccp(x, y))
                end

                local pet = sprt:getHunterPet()
                if pet then
                    app.grid:addActor(pet)
                    app.grid:setActorTo(pet, qccp(x, y))
                end
            end
        else
            local sprts = app.battle:getSupportHeroes()
            for _, sprt in ipairs(sprts) do
                local x = -BATTLE_AREA.width / 2
                local y = BATTLE_AREA.height / 2

                if sprt == app.battle:getSupportSkillHero() then
                    sprt:setDirection(QActor.DIRECTION_RIGHT)
                    sprt:setAnimationScale(app.battle:getTimeGear(), "time_gear")
                    app.grid:addActor(sprt)
                    app.grid:setActorTo(sprt, qccp(x, y))
                elseif sprt == app.battle:getSupportSkillHero2() then
                    sprt:setDirection(QActor.DIRECTION_RIGHT)
                    sprt:setAnimationScale(app.battle:getTimeGear(), "time_gear")
                    app.grid:addActor(sprt)
                    app.grid:setActorTo(sprt, qccp(x, y))
                end

                local pet = sprt:getHunterPet()
                if pet then
                    app.grid:addActor(pet)
                    app.grid:setActorTo(pet, qccp(x, y))
                end
            end
        end
    end

    for i, hero in ipairs(self._candidateHeroes) do
        hero._enterStopPosition = global.candidate_heroes_enter_pos[i]
    end

    self:_prepareHeroSoulSpirit()
end

function QBattleManager:_checkBattleStartDelay(startPosition, stopPosition, moveSpeed)
    if startPosition == nil or stopPosition == nil or moveSpeed == nil or moveSpeed <= 0 then
        return
    end

    local deltaX = startPosition.x - stopPosition.x
    local deltaY = startPosition.y - stopPosition.y
    local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
    local timeCost = distance / moveSpeed
    if self._startDelay < timeCost then
        self._startDelay = timeCost
    end
end

function QBattleManager:_prepareEnemiesInPVPMode()
    if app.battle:isPVPMode() == false then
        return
    end

    local _enemies = app.battle:getEnemies()
    local enemies = {}
    -- 过滤掉猎人宠物
    table.mergeForArray(enemies, _enemies, function(enemy) return not enemy:getHunterMaster() and not enemy:isSupport() end)
    local heroCount = table.nums(enemies)
    local left = BATTLE_AREA.left
    local bottom = BATTLE_AREA.bottom
    local w = BATTLE_AREA.width
    local h = BATTLE_AREA.height
    -- 魂师入场起始点
    local stopPosition = clone(ARENA_HERO_POS)
    for _, position in ipairs(stopPosition) do
        position[1] = BATTLE_AREA.left + BATTLE_AREA.width - (position[1] + BATTLE_AREA.width / 2)
        position[2] = BATTLE_AREA.bottom + position[2] + BATTLE_AREA.height / 2
    end

    local i = 0
    for _, enemy in ipairs(enemies) do
        if not enemy:getHunterMaster() and not enemy:isSupport() then
            i = i + 1
            local index = heroCount - i + 1

            if self:isInSunwell() == true then
                for _, skill in pairs(enemy._manualSkills) do
                    skill:coolDown()
                end
            elseif self:isInArena() == true then
                for _, skill in pairs(enemy._manualSkills) do
                    skill:coolDown()
                end
            end

            -- nzhang: 2015-10-24，太阳井有可能会生成5个敌人，防止出错
            index = math.clamp(index, 1, 4)

            enemy._enterStartPosition = {x = stopPosition[index][1] + BATTLE_AREA.width / 2, y = stopPosition[index][2]}
            enemy._enterStopPosition = {x = stopPosition[index][1], y = stopPosition[index][2]}
            app.grid:addActor(enemy) -- 注意要在view创建后加入app.grid，否则只有model，没有view的情况下，有些状态消息会miss掉
            app.grid:setActorTo(enemy, enemy._enterStartPosition)
            app.grid:moveActorTo(enemy, enemy._enterStopPosition)
        end
    end

    for i, enemy in ipairs(enemies) do
        -- 宠物出场
        local pet = enemy:getHunterPet()
        if pet then
            local startpos = clone(enemy._enterStartPosition)
            local stoppos = clone(enemy._enterStopPosition)
            startpos.x = startpos.x + 125
            stoppos.x = stoppos.x + 125
            app.grid:addActor(pet)
            app.grid:setActorTo(pet, startpos)
            app.grid:moveActorTo(pet, stoppos)
        end
    end

    if not self:isPVPMode() or not self:isPVPMultipleWave() then
       if (not self:isPVPMultipleWaveNew()) and (not self:isPVEMultipleWave()) then
            -- 副将 魂师副将actor 初始化
            local sprts = app.battle:getSupportEnemies()
            for _, sprt in ipairs(sprts) do
                local x = BATTLE_AREA.width + BATTLE_AREA.width / 2
                local y = BATTLE_AREA.height / 2

                if sprt == app.battle:getSupportSkillEnemy() then
                    sprt:setDirection(QActor.DIRECTION_LEFT)
                    sprt:setAnimationScale(app.battle:getTimeGear(), "time_gear")
                    app.grid:addActor(sprt)
                    app.grid:setActorTo(sprt, qccp(x, y))
                end

                local pet = sprt:getHunterPet()
                if pet then
                    app.grid:addActor(pet)
                    app.grid:setActorTo(pet, qccp(x, y))
                end
            end
            -- 副将2 魂师副将actor 初始化
            local sprts = app.battle:getSupportEnemies2()
            for _, sprt in ipairs(sprts) do
                local x = BATTLE_AREA.width + BATTLE_AREA.width / 2
                local y = BATTLE_AREA.height / 2

                if sprt == app.battle:getSupportSkillEnemy2() then
                    sprt:setDirection(QActor.DIRECTION_LEFT)
                    sprt:setAnimationScale(app.battle:getTimeGear(), "time_gear")
                    app.grid:addActor(sprt)
                    app.grid:setActorTo(sprt, qccp(x, y))
                end

                local pet = sprt:getHunterPet()
                if pet then
                    app.grid:addActor(pet)
                    app.grid:setActorTo(pet, qccp(x, y))
                end
            end

            -- 副将3 魂师副将actor 初始化
            local sprts = app.battle:getSupportEnemies3()
            for _, sprt in ipairs(sprts) do
                local x = BATTLE_AREA.width + BATTLE_AREA.width / 2
                local y = BATTLE_AREA.height / 2

                if sprt == app.battle:getSupportSkillEnemy3() then
                    sprt:setDirection(QActor.DIRECTION_LEFT)
                    sprt:setAnimationScale(app.battle:getTimeGear(), "time_gear")
                    app.grid:addActor(sprt)
                    app.grid:setActorTo(sprt, qccp(x, y))
                end

                local pet = sprt:getHunterPet()
                if pet then
                    app.grid:addActor(pet)
                    app.grid:setActorTo(pet, qccp(x, y))
                end
            end
       else
            local sprts = app.battle:getSupportEnemies()
            for _, sprt in ipairs(sprts) do
                local x = BATTLE_AREA.width + BATTLE_AREA.width / 2
                local y = BATTLE_AREA.height / 2

                if sprt == app.battle:getSupportSkillEnemy() then
                    sprt:setDirection(QActor.DIRECTION_LEFT)
                    sprt:setAnimationScale(app.battle:getTimeGear(), "time_gear")
                    app.grid:addActor(sprt)
                    app.grid:setActorTo(sprt, qccp(x, y))
                elseif sprt == app.battle:getSupportSkillEnemy2() then
                    sprt:setDirection(QActor.DIRECTION_LEFT)
                    sprt:setAnimationScale(app.battle:getTimeGear(), "time_gear")
                    app.grid:addActor(sprt)
                    app.grid:setActorTo(sprt, qccp(x, y))
                end

                local pet = sprt:getHunterPet()
                if pet then
                    app.grid:addActor(pet)
                    app.grid:setActorTo(pet, qccp(x, y))
                end
            end
       end
    end

    for i, enemy in ipairs(self._candidateEnemies) do
        enemy._enterStopPosition = global.candidate_enemies_enter_pos[i]
    end

    self:_prepareEnemySoulSpirit()
end

function QBattleManager:createEnemiesInTutorial()
    if self:isInTutorial() == false then
        return
    end

    local wave = 1

    for i, item in ipairs(self._monsters) do
        if item.wave == wave then
            if item.created ~= true then
                -- create NPC
                item.created = true
                item.npc = app:createNpc(item.npc_id, item.npc_difficulty, item.npc_level, nil, nil, true)
                item.npc:setPropertyCoefficient(item.attack_coefficient, item.hp_coefficient, item.damage_coefficient, item.armor_coefficient, item.armor_coefficient)
                if item.actor_scale then
                    item.npc:setActorScale(item.npc:getActorScale() * item.actor_scale)
                end
                table.insert(self._enemies, item.npc)
                self._actorsByUDID[item.npc:getUDID()] = item.npc
                self._battleLog:onEnemyHeroDoDHP(item.npc:getActorID(), 0, item.npc)
                self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = item.npc, pos = {x = item.x, y = item.y}, isBoss = item.is_boss})
            end
        end
    end
end

-- only for cut scene
-- ignore appear skill and appear effect
function QBattleManager:createEnemyManually(id, wave, x, y, skeletonView)
    if id == nil or wave <= 0 then
        return
    end

    for i, item in ipairs(self._monsters) do
        if item.npc_id == id and item.created ~= true then
            if x == nil then
                x = item.x
            end
            if y == nil then
                y = item.y
            end
            item.created = true
            local character_id, item_config = self:getBattleRandomNpc(self._dungeonConfig.monster_id, i, item.npc_id, item)
            item.npc = app:createNpc(character_id, item_config.npc_difficulty, item_config.npc_level, {item.appear_skill, item.dead_skill}, item.dead_skill, true)
            item.npc:setPropertyCoefficient(item_config.attack_coefficient, item_config.hp_coefficient, item_config.damage_coefficient, item_config.armor_coefficient, item_config.armor_coefficient)
            if item_config.actor_scale then
                item.npc:setActorScale(item.npc:getActorScale() * item_config.actor_scale)
            end
            item.born_time = self:getTime()
            item.ai = self._aiDirector:createBehaviorTree(item.npc:getAIType(), item.npc)
            self._aiDirector:addBehaviorTree(item.ai)
            self._battleLog:onEnemyHeroDoDHP(item.npc:getActorID(), 0, item.npc, item.show_battlelog)
            self._isHaveEnemyInAppearEffectDelay = false
           
            item.npc.rewards = item.rewards
            if x == nil or y == nil then
                self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = item.npc, pos = {x = item.x, y = item.y}, isBoss = item.is_boss, isManually = true, skeletonView = skeletonView,isEliteBoss = item.is_elite_boss})
            else
                self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = item.npc, screen_pos = {x = x, y = y}, isBoss = item.is_boss, isManually = true, skeletonView = skeletonView,isEliteBoss = item.is_elite_boss})
            end
            if self._isActiveDungeon == true and self._activeDungeonType == DUNGEON_TYPE.ACTIVITY_TIME and item.rewardIndex ~= nil then 
                self._battleLog:onMonsterCreated(item.npc:getId(), item.npc:getActorID(), item.rewardIndex, q.time())
            end
        end
    end
end

--[[
check 3 things:
1. if there is npc in this wave need to be created, create it when appropriate in this function
2. all NPC in current wave have been dead
3. if there is next wave if all NPC dead
--]]
function QBattleManager:_checkWave()
    if self._ended or self._aiDirector == nil then return nil, nil end

    if self._curWave == 0 then
        return true, 1
    end

    -- check if all of npc in this wave have been dead
    local allDead = true

    local interval = self:getTime() - self._curWaveStartTime

    -- check if all enemy is dead and disapper
    for i, monster in ipairs(self._monsters) do
        if monster.created and monster.npc and monster.npc:isDead() == false then
            if not (monster.can_be_ignored or (monster.show_battlelog == false) or monster.is_neutral or (monster.dead_battle_end == true)) then
                allDead = false
                break
            end
        end
    end
    if self._isHaveEnemyInAppearEffectDelay == false and allDead == true and self._isFirstNPCCreated == true then
        local isChangeStartTime = true
        local deltaTime = 0xffff
        for i, item in ipairs(self._monsters) do
            if item.wave == self._curWave and item.created ~= true then
                if interval >= item.appear then
                    isChangeStartTime = false
                    break
                else
                    if item.appear - interval < deltaTime then
                        deltaTime = item.appear - interval
                    end
                end
            end
        end
        if deltaTime > global.npc_view_dead_blink_time then
            deltaTime = deltaTime - global.npc_view_dead_blink_time
        end
        if isChangeStartTime == true then
            self._curWaveStartTime = self._curWaveStartTime - deltaTime 
        end
    end 

    -- summoned enemy is not assigned in self._monsters, remove dead sommoned enemies
    for i, enemy in ipairs(self._enemies) do
        if not enemy:isSupport() then
            if enemy:isDead() == false then
                local can_be_ignored = nil
                for i, item in ipairs(self._monsters) do
                    if item.npc and item.npc == enemy then
                        can_be_ignored = item.can_be_ignored or (item.show_battlelog == false) or item.is_neutral or (item.dead_battle_end == true)
                        break
                    elseif item.npc_summoned and item.npc_summoned[enemy:getId()] and item.npc_summoned[enemy:getId()].npc == enemy then
                        can_be_ignored = item.can_be_ignored or (item.show_battlelog == false) or item.is_neutral or (item.dead_battle_end == true)
                        break
                    end
                end
                if not can_be_ignored then
                    allDead = false
                end
            else
                local summoned_item = nil
                local summoned = nil
                local isSummoned = false
                local isPreWave = false
                for _, item in ipairs(self._monsters) do
                    if item.npc == enmey and item.wave < self._curWave then
                        isPreWave = true
                        break
                    end
                    if item.npc_summoned then
                        summoned = item.npc_summoned[enemy:getId()]
                        if summoned and summoned.npc == enemy then
                            isSummoned = true
                            summoned_item = item
                            break
                        end
                    end
                end
                if isSummoned or isPreWave then
                    if app.grid:hasActor(enemy) == true then
                        self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = enemy,  isBoss = enemy:isBoss(), isEliteBoss = enemy:isEliteBoss()})
                        self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = enemy,  isBoss = enemy:isBoss(), isEliteBoss = enemy:isEliteBoss()})

                        self:performWithDelay(function()
                            if not enemy:isNeutral() then
                                table.insert(self._deadEnemies, enemy)
                                table.removebyvalue(self._enemies, enemy)
                            end
                        end, global.remove_npc_delay_time)

                        for _, ai in ipairs(self._aiDirector:getChildren()) do
                            if ai:getActor() == enemy then
                                self._aiDirector:removeBehaviorTree(ai)
                                break
                            end
                        end

                        app.grid:removeActor(enemy)
                        if isSummoned then
                            self._battleLog:addMonsterLifeSpan(enemy, self:getTime() - summoned.born_time)
                        end
                    end
                end
                if enemy:isDoingDeadSkill() then
                    local sb = enemy:getCurrentSBDirector()
                    if sb and sb:hasAction("QSBSummonMonsters") then
                        allDead = false
                    end
                end
            end
        end
    end

    for _, enemy in ipairs(self._candidateEnemies) do
        if not enemy:isDead() then
            allDead = false
            break
        end
    end

    -- get current time interval since the battle created
    local isCreatedNpc = false
    for i, item in ipairs(self._monsters) do
        if item.wave == self._curWave then
            local probability = item.probability
            if probability ~= nil and self:getBattleNpcProbability(self._dungeonConfig.monster_id, i) > probability * 100 then
                -- npc不生成
            elseif interval >= item.appear then
                if item.created ~= true then
                    if not isCreatedNpc then
                        allDead = false
                        -- create NPC
                        item.created = true
                        local character_id, item_config = self:getBattleRandomNpc(self._dungeonConfig.monster_id, i, item.npc_id, item)
                        local remainHp, level, fullHp = nil, nil, nil
                        if self:isInRebelFight() then
                            character_id = self._dungeonConfig.rebelID
                            -- assert(self._dungeonConfig.rebelHP, "rebelHP must have a value!!!")
                            remainHp = self._dungeonConfig.rebelHP
                            level = self._dungeonConfig.rebelLevel
                        end
                        if self:isInWorldBoss() then
                            character_id = self._dungeonConfig.worldBossID
                            remainHp = self._dungeonConfig.worldBossHP
                            level = self._dungeonConfig.worldBossLevel
                        end
                        if self:isInUnionDragonWar() then
                            -- character_id = self._dungeonConfig.unionDragonWarBossId
                            remainHp = self._dungeonConfig.unionDragonWarBossHp
                            level = self._dungeonConfig.unionDragonWarBossLevel
                            fullHp = self._dungeonConfig.unionDragonWarBossFullHp
                        end
                        if remainHp and remainHp > 0 and level then
                            -- change character id based on real_id hp segment redirecti
                            local config = db:getCharacterByID(character_id)
                            if config.real_id then
                                local data = db:getCharacterDataByID(character_id, level)
                                local maxHP = (data.hp_value or 0) + (data.hp_grow or 0) * level
                                local percent = remainHp / maxHP
                                local words = string.split(config.real_id, ";")
                                for i, word in ipairs(words) do
                                    word = string.split(word, ",")
                                    if percent <= tonumber(string.sub(word[1], 1, string.len(word[1]) - 1)) / 100 then
                                        character_id = tonumber(word[2])
                                    else
                                        break
                                    end
                                end
                            end
                        end
                        if self:isInRebelFight() then
                            -- 叛军的id和level, 剩余血量
                            item.npc = app:createNpc(character_id, "", level, {}, nil, true)
                            item.npc:setDisplayLevel(self._dungeonConfig.rebelDisplayLevel)
                            item.npc:setHp(remainHp)
                        elseif self:isInWorldBoss() then
                            -- 世界boss的id和level, 剩余血量
                            item.npc = app:createNpc(character_id, "", level, {}, nil, true)
                            item.npc:setDisplayLevel(self._dungeonConfig.worldBossDisplayLevel)
                            item.npc:setHp(remainHp)

                            local worldBossLittleMonster = {60032, 60032, 60032, 60032}
                            item.npc_summoned = #worldBossLittleMonster > 0 and {} or nil
                            for _, id in ipairs(worldBossLittleMonster) do
                                local npc = app:createNpc(id, "", level, {}, nil, true)
                                npc:setDisplayLevel(self._dungeonConfig.worldBossDisplayLevel)
                                npc:connectToHpGroup(item.npc)
                                npc:setIsEliteBoss(true)
                                npc.not_show_hp_bar = true
                                local ai = self._aiDirector:createBehaviorTree(npc:getAIType(), npc)
                                self._aiDirector:addBehaviorTree(ai)
                                if not npc:isNeutral() then
                                    table.insert(self._enemies, npc)
                                end
                                self._actorsByUDID[npc:getUDID()] = npc
                                item.npc_summoned[npc:getUDID()] = {npc = npc, born_time = self:getTime()}
                                self._battleLog:onEnemyHeroDoDHP(npc:getActorID(), 0, npc, show_battlelog)
                            end
                        elseif self:isInSocietyDungeon() then
                            -- 宗门boss buff
                            local config = db:getScoietyWave(self._dungeonConfig.societyDungeonWave, self._dungeonConfig.societyDungeonChapter)
                            -- 宗门boss的id和lebel，剩余血量
                            item.npc = app:createNpc(self._dungeonConfig.societyDungeonBossID, "", self._dungeonConfig.societyDungeonBossLevel, {}, nil, true)
                            item.npc:setDisplayLevel(self._dungeonConfig.societyDungeonBossLevel)
                            if self:isBossHpInfiniteDungeon() then
                                item.npc:setFullHp()
                            else
                                item.npc:setHp(self._dungeonConfig.societyDungeonBossHp)
                            end
                            if config then
                                self:_applyBuffForSocietyDungeonBoss(item.npc, config)
                            end
                            -- 宗门boss的小弟，共享血量
                            self._dungeonConfig.societyDungeonLittleMonster = self._dungeonConfig.societyDungeonLittleMonster or {}
                            item.npc_summoned = #self._dungeonConfig.societyDungeonLittleMonster > 0 and {} or nil
                            for _, id in ipairs(self._dungeonConfig.societyDungeonLittleMonster) do
                                local npc = app:createNpc(id, "", self._dungeonConfig.societyDungeonBossLevel, {}, nil, true)
                                npc:setDisplayLevel(self._dungeonConfig.societyDungeonBossLevel)
                                npc:connectToHpGroup(item.npc)
                                npc:setIsEliteBoss(true)
                                npc.not_show_hp_bar = true
                                local ai = self._aiDirector:createBehaviorTree(npc:getAIType(), npc)
                                self._aiDirector:addBehaviorTree(ai)
                                if not npc:isNeutral() then
                                    table.insert(self._enemies, npc)
                                end
                                self._actorsByUDID[npc:getUDID()] = npc
                                item.npc_summoned[npc:getUDID()] = {npc = npc, born_time = self:getTime()}
                                self._battleLog:onEnemyHeroDoDHP(npc:getActorID(), 0, npc, show_battlelog)
                                if config then
                                    self:_applyBuffForSocietyDungeonBoss(npc, config)
                                end
                            end
                        elseif self:isInUnionDragonWar() and item.is_boss then
                            -- 巨龙之战boss的id和level, 剩余血量
                            item.npc = app:createNpc(character_id, "", level, {}, nil, true)
                            -- 如果剩余血量为0，则进入灵魂状态
                            if fullHp then
                                item.npc:setFixMaxHp(fullHp)
                            end
                            if self:isBossHpInfiniteDungeon() then
                                item.npc:setFullHp()
                            elseif remainHp and remainHp > 0 then
                                item.npc:setHp(remainHp)
                            else
                                if fullHp then
                                    item.npc:setHp(fullHp)
                                end
                                -- item.npc:setIsWeak(true)
                            end
                            self:summonMonsters(-1, item.npc, nil, level, true)
                            self._unionDragonWarBossHp = item.npc:getHp()
                        else
                            local leftHp = self:getMonsterLeftHp(i)
                            if leftHp ~= 0 then
                                item.npc = app:createNpc(character_id, item_config.npc_difficulty, item_config.npc_level, {item.appear_skill, item.dead_skill}, item.dead_skill, true)
                                item.npc:setPropertyCoefficient(item_config.attack_coefficient, item_config.hp_coefficient, item_config.damage_coefficient, item_config.armor_coefficient)
                                self:_applyNotRecommendDebuffForMonster(item.npc)
                                if item_config.actor_scale then
                                    item.npc:setActorScale(item.npc:getActorScale() * item_config.actor_scale)
                                end
                                item.npc:setImmuneAoE(item_config.immune_aoe)
                                item.npc.monsterIndex = i
                                if leftHp then
                                    item.npc:setHp(leftHp)
                                end
                            else
                            end
                        end
                        if self._isFirstNPCCreated == false then
                            self._isFirstNPCCreated = true
                        end
                        if item.npc then -- 可能npc初始化的时候就死了
                            item.born_time = self:getTime()
                            if item.is_neutral then
                                item.npc:setIsNeutral(true)
                                app.grid:removeActor(item.npc)
                            end
                            for _, skill in pairs(item.npc:getSkills()) do
                                if skill:get("enter_cd") ~= nil then
                                    skill:coolDown()
                                end
                            end
                            if self:isInTutorial() == false then
                                local delay = 0
                                if item.appear_effect ~= nil then
                                    delay = item.appear_delay or 0.3
                                end
                                -- delay to create ai if npc have appear effect 
                                self._isHaveEnemyInAppearEffectDelay = true
                                if delay == 0 then
                                    item.ai = self._aiDirector:createBehaviorTree(item.npc:getAIType(), item.npc)
                                    self._aiDirector:addBehaviorTree(item.ai)
                                    if not item.npc:isNeutral() then
                                        table.insert(self._enemies, item.npc)
                                    end
                                    self._actorsByUDID[item.npc:getUDID()] = item.npc
                                    self._battleLog:onEnemyHeroDoDHP(item.npc:getActorID(), 0, item.npc, item.show_battlelog)
                                    self._isHaveEnemyInAppearEffectDelay = false
                                else
                                    self:performWithDelay(function()
                                        if not self._ended and self._aiDirector then
                                            item.ai = self._aiDirector:createBehaviorTree(item.npc:getAIType(), item.npc)
                                            self._aiDirector:addBehaviorTree(item.ai)
                                            if not item.npc:isNeutral() then
                                                table.insert(self._enemies, item.npc)
                                            end
                                            self._actorsByUDID[item.npc:getUDID()] = item.npc
                                            self._battleLog:onEnemyHeroDoDHP(item.npc:getActorID(), 0, item.npc, item.show_battlelog)
                                            self._isHaveEnemyInAppearEffectDelay = false
                                        end
                                    end, delay)
                                end

                                item.npc.rewards = item.rewards
                                local eventDict = {}
                                eventDict.name = QBattleManager.NPC_CREATED
                                eventDict.npc = item.npc
                                eventDict.pos = {x = item.x, y = item.y}
                                eventDict.appear_skill = item.appear_skill
                                eventDict.effectId = item.appear_effect
                                eventDict.isBoss = item.is_boss
                                eventDict.depth_tag = item.depth_tag
                                eventDict.newEnemyTipsConfig = item.monster_tips
                                eventDict.isEliteBoss = item.is_elite_boss
                                eventDict.noreposition = item.noreposition
                                self:dispatchEvent(eventDict)

                                if item.npc_summoned then
                                    for _, obj in pairs(item.npc_summoned) do
                                        local eventDict = {}
                                        eventDict.name = QBattleManager.NPC_CREATED
                                        eventDict.npc = obj.npc
                                        eventDict.pos = {x = item.x, y = item.y}
                                        eventDict.effectId = item.appear_effect
                                        eventDict.isBoss = false
                                        eventDict.noreposition = item.noreposition
                                        self:dispatchEvent(eventDict)
                                    end
                                end

                                if item.appear_skill ~= nil then
                                    item.npc:attack(item.npc:getSkillWithId(item.appear_skill), nil, nil, true)
                                end
                            else
                                if not item.npc:isNeutral() then
                                    table.insert(self._enemies, item.npc)
                                end
                                self._actorsByUDID[item.npc:getUDID()] = item.npc
                                
                                local eventDict = {}
                                eventDict.name = QBattleManager.NPC_CREATED
                                eventDict.npc = item.npc
                                eventDict.pos = {x = item.x, y = item.y}
                                eventDict.isBoss = item.is_boss
                                eventDict.isEliteBoss = item.is_elite_boss
                                eventDict.noreposition = item.noreposition
                                self:dispatchEvent(eventDict)
                            end
                            if self._isActiveDungeon == true and self._activeDungeonType == DUNGEON_TYPE.ACTIVITY_TIME and item.rewardIndex ~= nil then 
                                self._battleLog:onMonsterCreated(item.npc:getId(), item.npc:getActorID(), item.rewardIndex, q.time())
                            end
                            item.npc:summonHunterPet()
                            self:setFuncMark(item.npc, item_config.func, self._dungeonConfig.monster_id, i)
                            item.npc:setIsBoss(item.is_boss)
                            item.npc:setIsEliteBoss(item.is_elite_boss)
                            item.npc:setIsNpcBoss(item.is_npc_boss)
                            isCreatedNpc = true 
                        end
                    end

                elseif item.npc then
                    if not item.npc:isDead() then
                        if not (item.can_be_ignored or (item.show_battlelog == false) or item.is_neutral or (item.dead_battle_end == true)) then
                            allDead = false
                        end
                    elseif item.cleanup ~= true then
                        -- 张南：hard coding, 莫格莱尼的尸体在其生成的那波不消失，剧情需要
                        local isRevive = false
                        local dungeon_id = self:getDungeonConfig().id
                        if item.clean_body == false then
                            isRevive = true
                        end

                        if self:isInTutorial() == false and not isRevive and not item.npc:isDoingDeadSkill() then

                            item.cleanup = true

                            self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = item.npc, isBoss = item.is_boss, isEliteBoss = item.is_elite_boss})

                            self:performWithDelay(function()
                                table.insert(self._deadEnemies, item.npc)
                                table.removebyvalue(self._enemies, item.npc)
                            end, global.remove_npc_delay_time)
                            self._aiDirector:removeBehaviorTree(item.ai)

                            app.grid:removeActor(item.npc)
                        elseif self:isInTutorial() then
                            item.cleanup = true
                            self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = item.npc, isBoss = item.is_boss, isEliteBoss = item.is_elite_boss})
                        end

                        if item.death_logged ~= true and self:isInTutorial() == false and not isRevive then

                            item.death_logged = true

                            self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = item.npc, isBoss = item.is_boss})

                            if self._isActiveDungeon == true and self._activeDungeonType == DUNGEON_TYPE.ACTIVITY_TIME and item.rewardIndex ~= nil then 
                                self._battleLog:onMonsterDead(item.npc:getId(), item.npc:getActorID(), q.time())
                            else
                                self._battleLog:onMonsterDead(item.npc:getId(), item.npc:getActorID(), q.time())
                            end
                            self._battleLog:addMonsterLifeSpan(item.npc, self:getTime() - item.born_time)
                        elseif self:isInTutorial() then
                            self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = item.npc, isBoss = item.is_boss})
                        end
                    end
                end
            else
                allDead = false
            end
        elseif item.wave > self._curWave then
            return allDead, item.wave
        else
            -- 张南：hard coding, 莫格莱尼的尸体在下一波中消失
            if item.npc and item.npc:getActorID() == 3303 and item.npc:getReviveCount() > 0 then
                -- 被复活的怪物
                if not item.npc:isDead() then
                    allDead = false
                elseif item.cleanup ~= true then
                    if self:isInTutorial() == false then
                        item.cleanup = true
                    
                        self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = item.npc, isBoss = item.is_boss, isEliteBoss = item.is_elite_boss})

                        self:performWithDelay(function()
                            table.insert(self._deadEnemies, item.npc)
                            table.removebyvalue(self._enemies, item.npc)
                        end, global.remove_npc_delay_time)
                        if self._aiDirector then
                            self._aiDirector:removeBehaviorTree(item.ai)
                        end

                        app.grid:removeActor(item.npc)
                    end
                end
            end
        end
    end
    return allDead, nil
end

function QBattleManager:_checkHeroes()
    if self._ended then return false end

    if self:isInTutorial() == false then
        local checkHero = function(heroDict)
            for i, hero in ipairs(heroDict) do
                if hero:isDead() then
                    table.insert(self._deadHeroes, hero)
                    table.removebyvalue(heroDict, hero)
                    app.grid:removeActor(hero)
                    if hero.behaviorNode and hero.behaviorNode:getParent() then
                        if self._aiDirector then
                            self._aiDirector:removeBehaviorTree(hero.behaviorNode)
                        end
                    end
                    self._battleLog:addHeroDeath(hero)
                    self._battleLog:onHeroDead(hero:getActorID(), q.time())
                    self:dispatchEvent({name = QBattleManager.HERO_CLEANUP, hero = hero})
                    -- candidate actor入场
                    if #self._candidateHeroes > 0 and hero:isCopyHero() == false then
                        local candidate_hero = nil
                        for _, actor in ipairs(self._candidateHeroes) do
                            if actor._candidate == nil then
                                candidate_hero = actor
                                break
                            end
                        end
                        if candidate_hero then
                            candidate_hero._candidate = hero
                            local appear_skill_id = candidate_hero:getAppearSkillId()
                            if appear_skill_id then
                                candidate_hero:attack(candidate_hero:getSkillWithId(appear_skill_id))
                            else
                                local skill = QSkill.new(32002, {}, candidate_hero)
                                candidate_hero:attack(skill)
                            end
                            app.grid:addActor(candidate_hero)
                            candidate_hero:setDirection(QActor.DIRECTION_RIGHT)
                        end
                    end
                end
            end
        end
        checkHero(self._heroes)
    end

    return true
end

function QBattleManager:_checkEnemyHeroes()
    if self._ended or not self:isPVPMode() or self:isInTutorial() then
        return false
    end

    local checkEnemyHeroes = function(enemyDict)
        for i, enemy in ipairs(enemyDict) do
            if enemy:isDead() and app.grid:hasActor(enemy) == true then
                self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = enemy, isBoss = false})
                self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = enemy, isBoss = false})

                -- 因为云顶之战需要显示敌方英雄头像，延迟删除会造成顺序错误，所以这里屏蔽掉。
                -- self:performWithDelay(function()
                    table.insert(self._deadEnemies, enemy)
                    table.removebyvalue(enemyDict, enemy)
                -- end, global.remove_npc_delay_time)

                if self._aiDirector then
                    for _, ai in ipairs(self._aiDirector:getChildren()) do
                        if ai:getActor() == enemy then
                            self._aiDirector:removeBehaviorTree(ai)
                            break
                        end
                    end
                end
                app.grid:removeActor(enemy)
                -- candidate actor入场
                if #self._candidateEnemies > 0 and not enemy:isSupport() and enemy:isCopyHero() == false then
                    local candidate_enemy = nil
                    for _, actor in ipairs(self._candidateEnemies) do
                        if actor._candidate == nil then
                            candidate_enemy = actor
                            break
                        end
                    end
                    if candidate_enemy then
                        candidate_enemy._candidate = enemy
                        local appear_skill_id = candidate_enemy:getAppearSkillId()
                        if appear_skill_id then
                            candidate_enemy:attack(candidate_enemy:getSkillWithId(appear_skill_id))
                        else
                            local skill = QSkill.new(32002, {}, candidate_enemy)
                            candidate_enemy:attack(skill)
                        end
                        app.grid:addActor(candidate_enemy)
                        candidate_enemy:setDirection(QActor.DIRECTION_LEFT)
                    end
                end
            end
        end
    end
    checkEnemyHeroes(self._enemies)

    return true
end

function QBattleManager:_calculateWaveCount()
    if self:isPVPMode() == true then
        return 1
    end
    
    local wave = 0
    for i, item in ipairs(self._monsters) do
        if item.wave > wave then
            wave = item.wave
        end
    end
    return wave
end

function QBattleManager:getDungeonDuration()
    if self:isInWorldBoss() then
        return 30
    end

    if self:isPVPMode() then
        if self:isInMetalAbyss() then
            local config = db:getConfiguration()
            local duration = config.ABYSS_BATTLE_TIME and config.ABYSS_BATTLE_TIME.value or 90
            return duration or 90
        elseif self:isPVPMultipleWaveNew() then
            local config = db:getConfiguration()
            local duration = config.STORM_ARENA_BATTLE_TIME and config.STORM_ARENA_BATTLE_TIME.value or 90
            return duration or 90
        elseif self:isInArena() and not self:isPVPMultipleWaveNew() then
            local config = db:getConfiguration()
            local duration = config.ARENA_DURATION and config.ARENA_DURATION.value or 90
            if self:isSotoTeam() or self:isSotoTeamInherit() or self:isSotoTeamEquilibrium() then
                return 120
            end
            return duration or 90
        elseif self:isInSunwell() then
            local config = db:getConfiguration()
            local duration = config.SUNWELL_BATTLE_TIME and config.SUNWELL_BATTLE_TIME.value or 90
            return duration or 90
        end
    end

    if self._dungeonConfig.duration == nil then
        return 600
    else
        return self._dungeonConfig.duration
    end
end

function QBattleManager:onUseSkill(actor, skill)
    if actor == nil or skill == nil then
        return
    end

    if actor:getType() == ACTOR_TYPES.NPC then
        for _, enmey in ipairs(self._enemies) do
            if actor == enmey then
                self._battleLog:addEnemySkillCast(actor, skill)
                break
            end
        end
        if self:getSoulSpiritEnemy() == actor then
            self._battleLog:addEnemySkillCast(actor, skill)
        end
    else
        for _, hero in ipairs(self._heroes) do
            if actor == hero then
                self._battleLog:addHeroSkillCast(actor, skill)
                break
            end
        end
        if self:getSoulSpiritHero() == actor then
            self._battleLog:addHeroSkillCast(actor, skill)
        end
    end
end

function QBattleManager:onActorUseManualSkill(actor, skill, auto)
    if actor == nil or skill == nil then
        return
    end

    self:dispatchEvent({name = QBattleManager.USE_MANUAL_SKILL, actor = actor, skill = skill, auto = auto})
end

function QBattleManager:addTrapDirector(director)
    if director == nil then
        return
    end

    for _, trapDirector in ipairs(self._trapDirectors) do
        if trapDirector == director then
            return
        end
    end

    table.insert(self._trapDirectors, director)
end

function QBattleManager:getTrapDirectors()
    return self._trapDirectors
end

function QBattleManager:addBullet(bullet)
    table.insert(self._bullets, bullet)
end

function QBattleManager:addLaser(laser)
    table.insert(self._lasers, laser)
end

function QBattleManager:addUFO(ufo)
    table.insert(self._ufos, ufo)
    self:dispatchEvent({name = QBattleManager.UFO_CREATED, ufo = ufo})
    ufo:playAnimation()
end

function QBattleManager:_onBulletTimeEvent(event)
    if event.name == QBattleManager.EVENT_BULLET_TIME_TURN_ON then
        self._bulletTimeReferenceCount = self._bulletTimeReferenceCount + 1

        local heroes = self:getHeroes()
        local enemies = self:getEnemies()
        local heroGhosts = self._heroGhosts
        local enemyGhosts = self._enemyGhosts

        for _, hero in ipairs(heroes) do
            hero:inBulletTime(true)
            hero:setAnimationScale(0, "bullet_time")
        end
        for _, enemy in ipairs(enemies) do
            enemy:inBulletTime(true)
            enemy:setAnimationScale(0, "bullet_time")
        end
        for _, hero in ipairs(heroGhosts) do
            hero.actor:inBulletTime(true)
            hero.actor:setAnimationScale(0, "bullet_time")
        end
        for _, enemy in ipairs(enemyGhosts) do
            enemy.actor:inBulletTime(true)
            enemy.actor:setAnimationScale(0, "bullet_time")
        end

        -- hero will not stop animation when it is playing manual skill
        self._exceptActor = {}
        local exceptActor = {}
        if not self:isPVPMode() then
            local function _makeActorException(hero)
                if hero:isDead() == false then
                    for _, skill in ipairs(hero:getExecutingSkills()) do
                        if skill ~= nil and skill:getSkillType() == QSkill.MANUAL then
                            hero:inBulletTime(false)
                            table.insert(exceptActor, hero)
                            table.insert(self._exceptActor, hero)
                            break
                        end
                    end
                end
            end
            for _, hero in ipairs(heroes) do
                _makeActorException(hero)
            end
            for _, hero in ipairs(heroGhosts) do
                _makeActorException(hero.actor)
            end
        else
            local hero = event.actor
            hero:inBulletTime(false)
            table.insert(exceptActor, hero)
            table.insert(self._exceptActor, hero)
            for _, actor in ipairs(heroes) do
                if hero ~= actor then
                    local sbs = actor:getSkillDirectors()
                    for _, sbDirector in ipairs(sbs) do
                        if sbDirector:isInBulletTime() then
                            actor:inBulletTime(false)
                            table.insert(exceptActor, actor)
                            table.insert(self._exceptActor, actor)
                            break
                        end
                    end
                end
            end
            for _, actor in ipairs(enemies) do
                if hero ~= actor then
                    local sbs = actor:getSkillDirectors()
                    for _, sbDirector in ipairs(sbs) do
                        if sbDirector:isInBulletTime() then
                            actor:inBulletTime(false)
                            table.insert(exceptActor, actor)
                            table.insert(self._exceptActor, actor)
                            break
                        end
                    end
                end
            end
            for _, ghost in ipairs(self._heroGhosts) do
                local actor = ghost.actor
                if hero ~= actor then
                    local sbs = actor:getSkillDirectors()
                    for _, sbDirector in ipairs(sbs) do
                        if sbDirector:isInBulletTime() then
                            actor:inBulletTime(false)
                            table.insert(exceptActor, actor)
                            table.insert(self._exceptActor, actor)
                            break
                        end
                    end
                end
            end
            for _, ghost in ipairs(self._enemyGhosts) do
                local actor = ghost.actor
                if hero ~= actor then
                    local sbs = actor:getSkillDirectors()
                    for _, sbDirector in ipairs(sbs) do
                        if sbDirector:isInBulletTime() then
                            actor:inBulletTime(false)
                            table.insert(exceptActor, actor)
                            table.insert(self._exceptActor, actor)
                            break
                        end
                    end
                end
            end
        end

        for _, actor in ipairs(exceptActor) do
            if actor.setAnimationScale then
                actor:setAnimationScale(1, "bullet_time")
            end
        end

        if self._bulletTimeReferenceCount == 1 then
            self:dispatchEvent({name = QBattleManager.EVENT_BULLET_TIME_TURN_START})
        end

        self:setTimeGear(1.0)
        
    elseif event.name == QBattleManager.EVENT_BULLET_TIME_TURN_OFF then
        self._bulletTimeReferenceCount = math.max(0, self._bulletTimeReferenceCount - 1)

        if self._bulletTimeReferenceCount == 0 then

            local heroes = self:getHeroes()
            local enemies = self:getEnemies()
            local heroGhosts = self._heroGhosts
            local enemyGhosts = self._enemyGhosts

            for _, hero in ipairs(heroes) do
                hero:inBulletTime(false)
                hero:setAnimationScale(1.0, "bullet_time")
            end
            for _, enemy in ipairs(enemies) do
                enemy:inBulletTime(false)
                enemy:setAnimationScale(1.0, "bullet_time")
            end
            for _, hero in ipairs(heroGhosts) do
                hero.actor:inBulletTime(false)
                hero.actor:setAnimationScale(1.0, "bullet_time")
            end
            for _, enemy in ipairs(enemyGhosts) do
                enemy.actor:inBulletTime(false)
                enemy.actor:setAnimationScale(1.0, "bullet_time")
            end

            self._exceptActor = {}

            self:dispatchEvent({name = QBattleManager.EVENT_BULLET_TIME_TURN_FINISH})
        end
    end
end

function QBattleManager:isInBulletTime()
    if self._bulletTimeReferenceCount > 0 then
        return true
    else
        return false
    end
end

-- 如果有将会执行子弹时间，但是尚未执行完成子弹时间的技能行为，返回true, otherwise false
function QBattleManager:hasPotentialBulletTimeSkillBehavior()
    local sbDirector = nil
    for _, actor in ipairs(self._heroes) do
        sbDirector = actor:getCurrentSBDirector()
        if sbDirector and sbDirector:hasBulletTime() and not sbDirector:isBulletTimeOver() then
            return true
        end
    end
    for _, actor in ipairs(self._enemies) do
        sbDirector = actor:getCurrentSBDirector()
        if sbDirector and sbDirector:hasBulletTime() and not sbDirector:isBulletTimeOver() then
            return true
        end
    end

    return false
end

function QBattleManager:reloadActorAi(actor)
    if actor == nil or self._aiDirector == nil or actor:isSupportHero() then
        return
    end

    if actor:isDead() == true then
        return
    end

    local children = self._aiDirector:getChildren()
    for _, aiTree in ipairs(children) do
        if aiTree:getActor() == actor then
            self._aiDirector:removeBehaviorTree(aiTree)
            break
        end
    end

    local ai = self._aiDirector:createBehaviorTree(actor:getAIType(), actor)
    self._aiDirector:addBehaviorTree(ai)
    if actor:getType() == ACTOR_TYPES.HERO then
        actor.behaviorNode = ai
    else
        local isSuc = false
        for _, monster in ipairs(self._monsters) do
            if monster.created == true and monster.npc == actor then
                monster.ai = ai
                isSuc = true
                break
            end
        end
        if isSuc == false then
            for i,ghost in ipairs(self:getHeroGhosts()) do
                if ghost.actor == actor then
                    ghost.ai = ai
                    isSuc = true
                    break
                end
            end
        end
        if isSuc == false then
            for i,ghost in ipairs(self:getEnemyGhosts()) do
                if ghost.actor == actor then
                    ghost.ai = ai
                    isSuc = true
                    break
                end
            end
        end
    end
    
end

function QBattleManager:replaceActorAI(actor, aitype)
    if actor == nil or self._aiDirector == nil then
        return
    end

    if actor:isDead() == true then
        return
    end

    actor:unlockTarget()

    local children = self._aiDirector:getChildren()
    for _, aiTree in ipairs(children) do
        if aiTree:getActor() == actor then
            self._aiDirector:removeBehaviorTree(aiTree)
            break
        end
    end

    if aitype == nil then aitype = actor:getAIType() end
    local ai = self._aiDirector:createBehaviorTree(aitype, actor)
    self._aiDirector:addBehaviorTree(ai)
    if actor:getType() == ACTOR_TYPES.HERO then
        actor.behaviorNode = ai
    else
        local isSuc = false
        for _, monster in ipairs(self._monsters) do
            if monster.created == true and monster.npc == actor then
                monster.ai = ai
                isSuc = true
                break
            end
        end
        if isSuc == false then
            for i,ghost in ipairs(self:getHeroGhosts()) do
                if ghost.actor == actor then
                    ghost.ai = ai
                    isSuc = true
                    break
                end
            end
        end
        if isSuc == false then
            for i,ghost in ipairs(self:getEnemyGhosts()) do
                if ghost.actor == actor then
                    ghost.ai = ai
                    isSuc = true
                    break
                end
            end
        end
    end
end

function QBattleManager:isWaitingForStart()
    if self._curWave == 0 or self._curWaveStartTime == 0 then
        return true
    end

    if self._curWave == 1 and self._curWaveStartTime > self:getTime() then
        return true
    end

    return false
end

function QBattleManager:getCurrentWave()
    return self._curWave
end

function QBattleManager:getCurrentPVPWave()
    return self._curPVPWave
end

function QBattleManager:getNextWave()
    return self._nextWave
end

-- function QBattleManager:summonGhosts(ghost_id, summoner, life_span, screen_pos, is_normal_pet, pet_hp_per, pet_atk_per, no_ai, clean_new_wave)
--[[--
召唤ghost鬼魂，return ghost

@param ghost_id
@param summoner         召唤者
@param life_span        生存时间
@param screen_pos       场景位置
@param is_normal_pet    pet
@param pet_hp_per       生命值因子
@param pet_atk_per      攻击值因子
@param no_ai            是否需要AI
@param clean_new_wave   在新的波次开始时是否要清除
@param dead_skill       ghost的死亡技能

@return ghost
]]
function QBattleManager:summonGhosts(config)
    if config.ghost_id == nil or config.summoner == nil then
        return
    end

    local heroes = self:getHeroes()
    local enemies = self:getEnemies()

    if config.summoner:getType() == ACTOR_TYPES.HERO or config.summoner:getType() == ACTOR_TYPES.HERO_NPC then
        local ghost = app:createNpc(config.ghost_id, nil, nil, {config.dead_skill}, config.dead_skill, true, nil, config.skin_id)
        ghost:setType(ACTOR_TYPES.HERO_NPC)
        ghost:resetStateForBattle()
        local ai
        if not config.no_ai then
            ai = self._aiDirector:createBehaviorTree(ghost:getAIType(), ghost)
            self._aiDirector:addBehaviorTree(ai)
        end
        table.insert(self._heroGhosts, {actor = ghost, ai = ai, life_span = config.life_span,
            life_countdown = config.life_span, summoner = config.summoner,
            clean_new_wave = config.clean_new_wave, is_no_deadAnimation = config.is_no_deadAnimation})
        self._actorsByUDID[ghost:getUDID()] = ghost

        if config.is_normal_pet then
            ghost:setIsPet(true)
            function ghost:getTalentHatred()
                return config.summoner:getTalentHatred()
            end
            function ghost:getMaxHp()
                return config.summoner:getMaxHp() * config.pet_hp_per
            end
            function ghost:getLevel()
                return config.summoner:getLevel()
            end
            function ghost:getPhysicalArmor()
                return config.summoner:getPhysicalArmor() + QActor.getPhysicalArmor(self)
            end
            function ghost:getMagicArmor()
                return config.summoner:getMagicArmor() + QActor.getMagicArmor(self)
            end
            function ghost:getHit()
                return config.summoner:getHit() + QActor.getHit(self)
            end
            function ghost:getDodge()
                return config.summoner:getDodge() + QActor.getDodge(self)
            end
            function ghost:getCrit()
                return config.summoner:getCrit() + QActor.getCrit(self)
            end
            function ghost:getBlock()
                return config.summoner:getBlock() + QActor.getBlock(self)
            end
            function ghost:getMaxHaste()
                return config.summoner:getMaxHaste() + QActor.getMaxHaste(self)
            end

            function ghost:getPhysicalDamagePercentAttack()
                return config.summoner:getPhysicalDamagePercentAttack() + QActor.getPhysicalDamagePercentAttack(self)
            end
            function ghost:getMagicDamagePercentAttack()
                return config.summoner:getMagicDamagePercentAttack() + QActor.getMagicDamagePercentAttack(self)
            end
            function ghost:getPhysicalDamagePercentUnderAttack()
                return config.summoner:getPhysicalDamagePercentUnderAttack() + QActor.getPhysicalDamagePercentUnderAttack(self)
            end
            function ghost:getMagicDamagePercentUnderAttack()
                return config.summoner:getMagicDamagePercentUnderAttack() + QActor.getMagicDamagePercentUnderAttack(self)
            end

            if config.pet_atk_per then
                function ghost:getAttack()
                    return config.summoner:getAttack() * config.pet_atk_per
                end
            else
                function ghost:getAttack()
                    return config.summoner:getAttack() + QActor.getAttack(self)
                end
            end
            ghost:setHp(ghost:getMaxHp())
        else
            ghost:setIsGhost(true)
        end

        -- hot fix
        if app.battle:isPVPMultipleWave() then
            ghost.pvp_born_wave = app.battle:getCurrentPVPWave()
        end

        self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = ghost, screen_pos = config.screen_pos, is_hero = true})
        
        return ghost
    end

    if config.summoner:getType() == ACTOR_TYPES.NPC then
        local ghost = app:createNpc(config.ghost_id, nil, nil, {config.dead_skill}, config.dead_skill, true, nil, config.skin_id)
        local ai
        if not config.no_ai then
            ai = self._aiDirector:createBehaviorTree(ghost:getAIType(), ghost)
            self._aiDirector:addBehaviorTree(ai)
        end
        table.insert(self._enemyGhosts, {actor = ghost, ai = ai, life_span = config.life_span,
            life_countdown = config.life_span, summoner = config.summoner,
            clean_new_wave = config.clean_new_wave, is_no_deadAnimation = config.is_no_deadAnimation})
        self._actorsByUDID[ghost:getUDID()] = ghost

        if config.is_normal_pet then
            ghost:setIsPet(true)
            function ghost:getTalentHatred()
                return config.summoner:getTalentHatred()
            end
            function ghost:getMaxHp()
                return config.summoner:getMaxHp() * config.pet_hp_per
            end
            function ghost:getLevel()
                return config.summoner:getLevel()
            end
            function ghost:getPhysicalArmor()
                return config.summoner:getPhysicalArmor() + QActor.getPhysicalArmor(self)
            end
            function ghost:getMagicArmor()
                return config.summoner:getMagicArmor() + QActor.getMagicArmor(self)
            end
            function ghost:getHit()
                return config.summoner:getHit() + QActor.getHit(self)
            end
            function ghost:getDodge()
                return config.summoner:getDodge() + QActor.getDodge(self)
            end
            function ghost:getCrit()
                return config.summoner:getCrit() + QActor.getCrit(self)
            end
            function ghost:getBlock()
                return config.summoner:getBlock() + QActor.getBlock(self)
            end
            function ghost:getMaxHaste()
                return config.summoner:getMaxHaste() + QActor.getMaxHaste(self)
            end

            function ghost:getPhysicalDamagePercentAttack()
                return config.summoner:getPhysicalDamagePercentAttack() + QActor.getPhysicalDamagePercentAttack(self)
            end
            function ghost:getMagicDamagePercentAttack()
                return config.summoner:getMagicDamagePercentAttack() + QActor.getMagicDamagePercentAttack(self)
            end
            function ghost:getPhysicalDamagePercentUnderAttack()
                return config.summoner:getPhysicalDamagePercentUnderAttack() + QActor.getPhysicalDamagePercentUnderAttack(self)
            end
            function ghost:getMagicDamagePercentUnderAttack()
                return config.summoner:getMagicDamagePercentUnderAttack() + QActor.getMagicDamagePercentUnderAttack(self)
            end
            
            if config.pet_atk_per then
                function ghost:getAttack()
                    return config.summoner:getAttack() * config.pet_atk_per
                end
            else
                function ghost:getAttack()
                    return config.summoner:getAttack() + QActor.getAttack(self)
                end
            end
            ghost:setHp(ghost:getMaxHp())
        else
            ghost:setIsGhost(true)
        end

        -- hot fix
        if app.battle:isPVPMultipleWave() then
            ghost.pvp_born_wave = app.battle:getCurrentPVPWave()
        end

        self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = ghost, screen_pos = config.screen_pos})
        return ghost
    end
end

-- 是否是ghost或pet
function QBattleManager:isGhost(actor)
    if actor == nil then return nil end
    if self._is_ghost_cache[actor] then
        return self._is_ghost_cache[actor].v
    end
    for _, ghost in ipairs(self._heroGhosts) do 
        if actor == ghost.actor then
            self._is_ghost_cache[actor] = {v = ghost.summoner}
            return ghost.summoner
        end
    end
    for _, ghost in ipairs(self._enemyGhosts) do 
        if actor == ghost.actor then
            self._is_ghost_cache[actor] = {v = ghost.summoner}
            return ghost.summoner
        end
    end
    self._is_ghost_cache[actor] = {v = nil}
    return nil
end

function QBattleManager:getHeroGhosts()
    return self._heroGhosts
end

function QBattleManager:getEnemyGhosts()
    return self._enemyGhosts
end

function QBattleManager:summonMonsters(wave, summoner, skill, override_level, connectHpToSummoner)
    -- normal wave monsters can not be summoned
    if type(wave) ~= "number" and wave >= 0 then
        return 
    end

    for i, item in ipairs(self._monsters) do
        if item.wave == wave then
            self:_summonMonster(item, i, summoner, skill, override_level, connectHpToSummoner)
        end
    end
end

function QBattleManager:_summonMonster(item, index, summoner, skill, override_level, connectHpToSummoner)
    -- create NPC
    local character_id, item_config = self:getBattleRandomNpc(self._dungeonConfig.monster_id, index, item.npc_id, item)
    local npc = app:createNpc(character_id, item_config.npc_difficulty, override_level or item_config.npc_level, {item.appear_skill, item.dead_skill}, item.dead_skill, true)
    npc:setPropertyCoefficient(item_config.attack_coefficient, item_config.hp_coefficient, item_config.damage_coefficient, item_config.armor_coefficient)
    self:_applyNotRecommendDebuffForMonster(npc)
    if item_config.actor_scale then
        npc:setActorScale(npc:getActorScale() * item_config.actor_scale)
    end
    npc:setImmuneAoE(item_config.immune_aoe)
    if item.npc_summoned == nil then
        item.npc_summoned = {}
    end
    npc:setIsBoss(item.is_boss)
    npc:setIsEliteBoss(item.is_elite_boss)
    npc:setIsNpcBoss(item.is_npc_boss)
    if connectHpToSummoner then
        npc:connectToHpGroup(summoner)
        npc:setIsEliteBoss(true)
        npc.not_show_hp_bar = true
    end
    item.npc_summoned[npc:getId()] = {npc = npc, born_time = self:getTime()}
    for _, skill in pairs(npc:getSkills()) do
        if skill:get("enter_cd") ~= nil then
            skill:coolDown()
        end
    end

    if self._isFirstNPCCreated == false then
        self._isFirstNPCCreated = true
    end

    local screen_pos = {}
    if item.relative then
        local offset_x = 0
        if item.offset_x then offset_x = item.offset_x end
        local offset_y = 0
        if item.offset_y then offset_y = item.offset_y end
        screen_pos = {x = summoner:getPosition().x + offset_x, y = summoner:getPosition().y + offset_y}

        -- 检查是否出屏幕
        local area = app.grid:getRangeArea()
        screen_pos.x = math.min(screen_pos.x, area.right)
        screen_pos.x = math.max(screen_pos.x, area.left)
        screen_pos.y = math.min(screen_pos.y, area.top)
        screen_pos.y = math.max(screen_pos.y, area.bottom)
    else
        screen_pos = nil
    end 
    if self:isInTutorial() == false then
        local delay = 0
        if item.appear_effect ~= nil then
            delay = item.appear_delay or 0.3
        end
        -- delay to create ai if npc have appear effect 
        if delay > 0 then
            self:performWithDelay(function()
                if self._aiDirector and not self._ended then
                    local ai = self._aiDirector:createBehaviorTree(npc:getAIType(), npc)
                    self._aiDirector:addBehaviorTree(ai)
                    self._actorsByUDID[npc:getUDID()] = npc
                    self._battleLog:onEnemyHeroDoDHP(npc:getActorID(), 0, npc, item.show_battlelog)
                    if item.is_neutral == true then
                        npc:setIsNeutral(true)
                    else
                        table.insert(self._enemies, npc)
                    end
                end
            end, delay)
        else
            if self._aiDirector and not self._ended then
                local ai = self._aiDirector:createBehaviorTree(npc:getAIType(), npc)
                self._aiDirector:addBehaviorTree(ai)
                self._actorsByUDID[npc:getUDID()] = npc
                self._battleLog:onEnemyHeroDoDHP(npc:getActorID(), 0, npc, item.show_battlelog)
                if item.is_neutral == true then
                    npc:setIsNeutral(true)
                else
                    table.insert(self._enemies, npc)
                end
            end
        end

        self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = npc, screen_pos = screen_pos, pos = {x = item.x, y = item.y}, effectId = item.appear_effect, isBoss = item.is_boss,isEliteBoss = item.is_elite_boss, noreposition = item.noreposition })

        if item.appear_skill ~= nil then
            npc:attack(npc:getSkillWithId(item.appear_skill), nil, nil, true)
        end
    else
        table.insert(self._enemies, npc)
        self._actorsByUDID[npc:getUDID()] = npc
        self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = npc, screen_pos = screen_pos, pos = {x = item.x, y = item.y}, isBoss = item.is_boss,isEliteBoss = item.is_elite_boss, noreposition = item.noreposition})
        
        app.scene:getActorViewFromModel(npc):setVisible(false)                
        if item.appear_skill ~= nil then
            npc:attack(npc:getSkillWithId(item.appear_skill), nil, nil, true)
            app.scene:getActorViewFromModel(npc):setVisible(true)
        end
    end

    if type(item.mode) == "string" then
        local words = string.split(item.mode, ";")
        local new_monster = clone(item)
        new_monster.npc = npc
        new_monster.born_time = self:getTime()
        if nil == self._battleTutorialObjs then self._battleTutorialObjs = {} end
        table.insert(self._battleTutorialObjs, {monster = new_monster, words = words, ended = false})
    end

    self:setFuncMark(npc, item_config.func, self._dungeonConfig.monster_id, index)
end

function QBattleManager:isBoss(npc)
    if npc == nil or npc:getType() ~= ACTOR_TYPES.NPC then
        return false
    end

    for _, item in ipairs(self._monsters) do
        if item.npc == npc then
            if item.is_boss == true then
                return true
            else
                return false
            end
            break
        end
    end
    return false
end

function QBattleManager:performWithDelay(func, delay, actor, pauseBetweenWave, skipCurrentFrame, ignoreTimeGear)
    if func == nil or delay < 0 then
        -- assert(false, "invalid args to call QBattleManager:performWithDelay")
        return nil
    end

    local handlerId = self._nextSchedulerHandletId
    table.insert(self._delaySchedulers, {handlerId = handlerId, delay = delay, func = func, actor = actor, pauseBetweenWave = not pauseBetweenWave,
                                         skipCurrentFrame = skipCurrentFrame, ignoreTimeGear = ignoreTimeGear})
    self._nextSchedulerHandletId = handlerId + 1
    return handlerId
end

function QBattleManager:removePerformWithHandler(handlerId)
    if handlerId <= 0 then
        return
    end

    local index = 0
    for i, schedulerInfo in ipairs(self._delaySchedulers) do
        if schedulerInfo.handlerId == handlerId then
            index = i
            break
        end
    end

    if index > 0 then
        table.remove(self._delaySchedulers, index)
    end
end

function QBattleManager:getBattleLog()
    if self._battleLog then
        return self._battleLog:getBattleLog() or {}
    else
        return {}
    end
end

function QBattleManager:getBattleLog1()
    if self:getPVEMultipleCurWave() == 1 then
        return self:getBattleLog()
    end
    return self._dungeonConfig.battleLog1:getBattleLog() or {}
end

function QBattleManager:getBattleLogForServer()
    if self._battleLog then
        return self._battleLog:getBattleLogForServer()
    end
end

function QBattleManager:setBattleLogFromServer(log)
    if self._battleLog then
        self._battleLog:setBattleLogFromServer(log)
    end
end

--服务传递过来的战斗数据统计
function QBattleManager:getRawBattleLogFromServer()
    local data = self._dungeonConfig.fightEndResponse
    
    if data then
        local reportDataStats = data.gfEndResponse.fightReportStats
        if reportDataStats then
            local content = crypto.decodeBase64(reportDataStats)
            local battleStats = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayOutput", content)
            return battleStats.battleLog, battleStats.otherBattleLogs
        end
    end
end

function QBattleManager:isAutoNextWave()
    if self:isInReplay() or IsServerSide then
        return true
    end

    for _, hero in ipairs(self._heroes) do
        if hero:isForceAuto() then
            return true
        end
    end

    return false
end

function QBattleManager:_checkStartCountDown()
    if self._paused == false and self._ended == false and self._pauseBetweenWaves == false and self._startCountDown == true then 
        self._battleLog:setStartCountDown(q.time())
    end
end

function QBattleManager:isBattleStartCountDown()
    return self._startCountDown
end

function QBattleManager:_checkEndCountDown()
    if self._paused == true or self._ended == true or self._pauseBetweenWaves == true or self._startCountDown == false then 
        self._battleLog:setEndCountDown(q.time())
    end
end

function QBattleManager:setTimeGear(time_gear)
    -- time_gear = QUtility:float_to_half(time_gear)
    if self._timeGear_change == nil and time_gear == self._timeGear then
        return
    end
    if self._timeGear_change and time_gear == self._timeGear_change then
        return
    end
    self._timeGear_change = time_gear
end

function QBattleManager:getTimeGear()
    return self._timeGear
end

function QBattleManager:saveDisableAIChange(isDisable)
    local currentFrame = tostring(#self._record.recordTimeSlices)

    if self._dungeonConfig.disableAIChange == nil then
        self._dungeonConfig.disableAIChange = {}
    end
    self._dungeonConfig.disableAIChange[currentFrame] = isDisable

    -- 保存到current frame record
    local cfr = self._currentFrameRecord
    if cfr then
        cfr.disableAIChange = isDisable
    end
end

function QBattleManager:loadDisableAIChange()
    local currentFrame = tostring(#self._record.recordTimeSlices)

    local disableAIChange = self._dungeonConfig.disableAIChange
    if disableAIChange and disableAIChange[currentFrame] ~= nil then
        return disableAIChange[currentFrame]
    end
end

function QBattleManager:isDisableAI()
    if self:isPVPMode() and not self:isInSunwell() and not self:isInGlory() and not self:isInTotemChallenge() then
        return false
    else    
        return self._disable_ai == true
    end
end

function QBattleManager:setDisableAI(isDisable)
    self._disable_ai_change = isDisable
end

function QBattleManager:_updateDisableAIChange()
    if not self:isInReplay() then
        if self._disable_ai_change ~= nil then
            self._disable_ai = self._disable_ai_change
            self._disable_ai_change = nil
            self:saveDisableAIChange(self._disable_ai)
        end
    else
        local disableAI = self:loadDisableAIChange()
        if disableAI ~= nil then
            self._disable_ai = disableAI
            self._disable_ai_change = nil
        end
    end
end

function QBattleManager:_updateTimeGearChange()
    if not self:isInReplay() then
        if self._timeGear_change then
            self._timeGear = self._timeGear_change
            self:dispatchEvent({name = QBattleManager.ON_SET_TIME_GEAR, time_gear = self._timeGear})
            self._timeGear_change = nil
            -- 记录time gear改变事件
            self:saveTimeGearChange(self._timeGear)
        end
    else
        -- 读取time gear改变事件
        local timeGear = self:loadTimeGearChange()
        if timeGear then
            self._timeGear = timeGear
            self:dispatchEvent({name = QBattleManager.ON_SET_TIME_GEAR, time_gear = self._timeGear})
            self._timeGear_change = nil
        end
    end
end

function QBattleManager:getDamageCoefficient()
    return self._damageCoefficient
end

function QBattleManager:getBattleRandomNpc(dungeon_id, npc_index, npc_id, monster_config)
    local _ids, _id_index
    local ids = string.split(npc_id, ";")
    if #ids == 1 then
        _ids = ids
        _id_index = 1
    else
        local rand = self._dungeonConfig.battleRandomNPC and self._dungeonConfig.battleRandomNPC[npc_index] or app.random(1, 10000)
        local id_index = math.fmod(rand, #ids) + 1
        _ids = ids
        _id_index = id_index
    end

    local return_config
    if monster_config then
        local function getbyindex(src, dst, index, member_list, convert_list)
            for i, member_name in ipairs(member_list) do
                local member = src[member_name]
                local words = string.split(member, ";")
                local word
                if #words == 1 then
                    word = words[1]
                else
                    word = words[index]
                end
                dst[member_name] = convert_list[i](word)
            end
        end
        return_config = {}
        local member_list = {"npc_difficulty", "npc_level", "attack_coefficient", "hp_coefficient", "actor_scale", "damage_coefficient", "armor_coefficient", "func", "immune_aoe"}
        local convert_list = {tostring, tonumber, tonumber, tonumber, tonumber, tonumber, tonumber, tostring, function (src) return src == "true" end}
        getbyindex(monster_config, return_config, _id_index, member_list, convert_list)
    end

    return _ids[_id_index], return_config
end

function QBattleManager:getBattleNpcProbability(dungeon_id, npc_index)
    return self._dungeonConfig.battleProbability and self._dungeonConfig.battleProbability[npc_index] or app.random(1, 100)
end

function QBattleManager:saveForceAutoChange(actor_id, force)
    local recordTimeSlices = self._record.recordTimeSlices
    local currentFrame = #recordTimeSlices
    actor_id = tostring(actor_id)

    if self._dungeonConfig.forceAutoChange == nil then
        self._dungeonConfig.forceAutoChange = {}
    end
    if self._dungeonConfig.forceAutoChange[actor_id] == nil then
       self._dungeonConfig.forceAutoChange[actor_id] = {}
    end
    self._dungeonConfig.forceAutoChange[actor_id][tostring(currentFrame)] = force

    -- 保存到current frame record
    local cfr = self._currentFrameRecord
    if cfr then
        if cfr.forceAutoChange == nil then
            cfr.forceAutoChange = {}
        end
        cfr.forceAutoChange[actor_id] = force
    end
end

function QBattleManager:loadForceAutoChange(actor_id)
    local recordTimeSlices = self._record.recordTimeSlices
    local currentFrame = #recordTimeSlices
    actor_id = tostring(actor_id)

    if self._dungeonConfig.forceAutoChange and self._dungeonConfig.forceAutoChange[actor_id] then
        return self._dungeonConfig.forceAutoChange[actor_id][tostring(currentFrame)]
    end

    return nil
end

function QBattleManager:savePlayerAction(udid, category, param)
    local recordTimeSlices = self._record.recordTimeSlices
    local currentFrame = #recordTimeSlices
    local dungeonConfig = self._dungeonConfig
    udid = tostring(udid)
    currentFrame = tostring(currentFrame)

    local playerAction = dungeonConfig.playerAction
    if playerAction == nil then
        dungeonConfig.playerAction = {}
        playerAction = dungeonConfig.playerAction
    end
    local actorPlayerAction = playerAction[udid]
    if actorPlayerAction == nil then
       playerAction[udid] = {}
       actorPlayerAction = playerAction[udid]
    end
    local frameActorPlayerAction = actorPlayerAction[currentFrame]
    if frameActorPlayerAction == nil then
        actorPlayerAction[currentFrame]= {}
        frameActorPlayerAction = actorPlayerAction[currentFrame]
    end
    if param then
        table.insert(frameActorPlayerAction, {c = category, p = param})
    else
        table.insert(frameActorPlayerAction, {c = category})
    end

    -- 保存到current frame record
    local cfr = self._currentFrameRecord
    if cfr then
        if cfr.playerAction == nil then
            cfr.playerAction = {}
        end
        local pa = cfr.playerAction
        table.insert(pa, {udid, category, param})
    end
end

function QBattleManager:loadPlayerAction(udid)
    local recordTimeSlices = self._record.recordTimeSlices
    local currentFrame = #recordTimeSlices
    local dungeonConfig = self._dungeonConfig
    udid = tostring(udid)
    currentFrame = tostring(currentFrame)

    local playerAction = dungeonConfig.playerAction
    if not playerAction then
        return nil
    end

    local actorPlayerAction = playerAction[udid]
    if not actorPlayerAction then
        return nil
    end

    local frameActorPlayerAction = actorPlayerAction[currentFrame]
    if not frameActorPlayerAction then
        return nil
    end

    return frameActorPlayerAction
end

function QBattleManager:saveTimeGearChange(time_gear)
    local currentFrame = tostring(#self._record.recordTimeSlices)

    if self._dungeonConfig.timeGearChange == nil then
        self._dungeonConfig.timeGearChange = {}
    end
    self._dungeonConfig.timeGearChange[currentFrame] = time_gear

    -- 保存到current frame record
    local cfr = self._currentFrameRecord
    if cfr then
        cfr.timeGearChange = time_gear
    end
end

function QBattleManager:loadTimeGearChange()
    local currentFrame = tostring(#self._record.recordTimeSlices)

    local timeGearChange = self._dungeonConfig.timeGearChange
    if timeGearChange and timeGearChange[currentFrame] then
        local timeGear = timeGearChange[currentFrame]
        self._timeGear = math.modf(timeGear*100)/100.0 -- 经过protobuf加密后会在10位以后添加小数，这个问题需要看看protobuf
        self:dispatchEvent({name = QBattleManager.ON_SET_TIME_GEAR, time_gear = self._timeGear})
        self._timeGear_change = nil
    end
end

function QBattleManager:isCurrentFrameRecord()
    return self._currentFrameRecord ~= nil
end

function QBattleManager:_appendCurrentFrameRecord()
    if self:isInReplay() or  self._currentFrameRecord == nil then
        return
    end

    if not ENABLE_STREAM_REPLAY then
        return
    end

    if not self._repxStreamStarted then
        app:startBattleRecordStream(self._dungeonConfig, self._record.recordRandomSeed)
        self._repxStreamStarted = true
    end

    local recordTimeSlices = self._record.recordTimeSlices
    self._currentFrameRecord.dt = recordTimeSlices[#recordTimeSlices]
    app:appendBattleRecordStream(self._currentFrameRecord)
    self._currentFrameRecord = nil
end

function QBattleManager:_calculateRandomPosition(avoid_positions, avoid_size, consider_forbidden_area)
    local positions = avoid_positions
    local nx, ny = app.grid._nx, app.grid._ny
    local forbid_length = math.ceil(ny / 3)
    local dist_max = avoid_size * nx
    local weights = {}
    local index = 1
    if consider_forbidden_area then
        for i = 1, nx do
            for j = 1, ny do
                weights[index] = 0

                if (i < forbid_length and j > ny - forbid_length)
                    or (i > nx - forbid_length and j > ny - forbid_length) then
                    weights[index] = -999999
                end

                index = index + 1
            end
        end
    else
        for i = 1, nx do
            for j = 1, ny do
                weights[index] = 0

                index = index + 1
            end
        end
    end
    for _, pos in ipairs(positions) do
        local index = 1
        for i = 1, nx do
            for j = 1, ny do
                weights[index] = weights[index] + math.min(q.distOf2Points(pos, {x = i, y = j}), dist_max)
                index = index + 1
            end
        end
    end
    local weight = 0
    local candidates = {}
    local index = 1
    for i = 1, nx do
        for j = 1, ny do
            if weight > weights[index] then
            elseif weight == weights[index] then
                table.insert(candidates, {x = i, y = j})
            else
                weight = weights[index]
                candidates = {}
                table.insert(candidates, {x = i, y = j})
            end
            index = index + 1
        end
    end
    if #candidates > 0 then
        return app.grid:_toScreenPos(candidates[app.random(1, #candidates)])
    end
end

function QBattleManager:_updateBattleRune(dt)
    if not self._battleRuneInitialized then
        self._battleRuneObjs = {}
        self._battleRuneThrows = {}
        for index, monster in ipairs(self._monsters) do
            if type(monster.rune_ids) == "string" and monster.rune_ids ~= "" then
                local probability = monster.rune_probability
                if app.random(0, 100) < (probability * 100) then
                    local ids = string.split(monster.rune_ids, ";")
                    local proportions = monster.rune_proportions
                    local id
                    if proportions == nil then
                        id = ids[app.random(1, #ids)]
                    else
                        proportions = string.split(proportions, ";")
                        if #ids ~= #proportions then
                            id = ids[app.random(1, #ids)]
                        else
                            local r = app.random(0, 100)
                            local total = 0
                            for i, proportion in ipairs(proportions) do
                                proportion = tonumber(proportion)
                                if r > total and r <= total + proportion then
                                    id = ids[i]
                                    break
                                else
                                    total = total + proportion
                                end
                            end
                        end
                    end
                    if id then
                        local new_obj = {monster = monster, rune_id = id, appear = monster.rune_appear, position = monster.rune_position, kill = monster.rune_kill}
                        new_obj.appear = new_obj.appear or 0
                        table.insert(self._battleRuneObjs, new_obj)
                    end
                end
            end
        end
        self._battleRuneInitialized = true
    end

    if #self._battleRuneObjs > 0 then
        for _, obj in ipairs(self._battleRuneObjs) do
            if not obj.ended then
                local monster = obj.monster
                local spawn = false
                local need_throw = false
                if not obj.kill then
                    if monster.npc and self:getTime() - monster.born_time >= obj.appear then
                        spawn = true
                    end
                else
                    if monster.npc and monster.npc:isDead() then
                        if not IsServerSide then
                            local monster_view = app.scene:getActorViewFromModel(monster.npc)
                            if monster_view then
                                monster_view:setGlowColor(nil)
                            end
                        end
                        spawn = true
                        need_throw = RUNE_THROW
                    elseif monster.npc and not monster.npc:isDead() then
                        if not obj.glow_colored then
                            if not IsServerSide then
                                local monster_view = app.scene:getActorViewFromModel(monster.npc)
                                if monster_view then
                                    monster_view:setGlowColor(ccc4(255 * 0.625, 200 * 0.625, 0, 192))
                                end
                            end
                            obj.glow_colored = true
                        end
                    end
                end
                if spawn then
                    -- spawn rune
                    local position
                    if obj.position and obj.position ~= "" then
                        local strs = string.split(obj.position, ";")
                        if #strs == 2 then
                            position = {x = tonumber(strs[1]), y = tonumber(strs[2])}
                            local w = BATTLE_AREA.width / global.screen_big_grid_width
                            local h = BATTLE_AREA.height / global.screen_big_grid_height
                            position.x = BATTLE_AREA.left + w * position.x - w / 2
                            position.y = BATTLE_AREA.bottom + h * position.y - h / 2
                        end
                    end
                    if position == nil then
                        -- random position algorithm
                        local positions = {}
                        for _, hero in ipairs(self._heroes) do
                            local _, gridPos = app.grid:_toGridPos(hero:getPosition().x, hero:getPosition().y)
                            table.insert(positions, gridPos)
                        end
                        position = self:_calculateRandomPosition(positions, 0.15, false)
                    end
                    if need_throw and position then
                        local trapId, level = q.parseIDAndLevel(obj.rune_id)
                        local trapDirector = QTrapDirector.new(trapId, monster.npc:getPosition(), monster.npc:getType(), monster.npc, level, nil, ALLOW_RUNE_CLICK)
                        self:addTrapDirector(trapDirector)
                        table.insert(self._battleRuneThrows ,{trapDirector = trapDirector, start_pos = clone(monster.npc:getPosition()), end_pos = clone(position), ended = false})
                        trapDirector:pause()
                    else
                        local trapId, level = q.parseIDAndLevel(obj.rune_id)
                        local trapDirector = QTrapDirector.new(trapId, position or monster.npc:getPosition(), monster.npc:getType(), monster.npc, level, nil, ALLOW_RUNE_CLICK)
                        self:addTrapDirector(trapDirector)
                    end
                    obj.ended = true
                end
            end
        end
    end

    local THROW_TIME = 1.0
    local THROW_SPEED_POWER = 1.5
    local THROW_HEIGHT = 7
    local THROW_AT = 0.3
    local function _calculateThrowInfo(pos1, pos2, totalTime)
        local dy = math.abs(pos2.y - pos1.y)
        local dx = math.abs(pos2.x - pos1.x)
        if math.abs(dx) < 1 then
            dx = 1
        end
        if math.abs(dy) < 1 then
            dx = 1
        end

        local ratio1 = 1 / ((dy / dx) + 2)
        local midX = math.sampler(pos1.x, pos2.x, (pos1.y > pos2.y) and ratio1 or (1 - ratio1))

        local ratio2 = 1 / ((dy / dx) + THROW_HEIGHT)
        local peakY = math.max(pos1.y, pos2.y) + dx * ratio2

        local totalTime = totalTime
        local fhTime = totalTime * math.abs(pos1.x - midX) / dx
        local shTime = totalTime - fhTime

        local info = {pos1 = pos1, pos2 = pos2, midX = midX, peakY = peakY, totalTime = totalTime, currentTime = 0, fhTime = fhTime, shTime = shTime}
        return info
    end
    for _, obj in ipairs(self._battleRuneThrows) do
        if obj.ended == false then
            if obj.info == nil then
                obj.info = _calculateThrowInfo(obj.start_pos, obj.end_pos, THROW_TIME)
            end
            local info = obj.info
            if info.currentTime < info.totalTime then
                info.currentTime = info.currentTime + dt
                local adjustCurrentTime = math.min(info.currentTime, info.totalTime)
                adjustCurrentTime = math.pow(adjustCurrentTime / info.totalTime, THROW_SPEED_POWER) *adjustCurrentTime
                local newX, newY
                if adjustCurrentTime < info.fhTime then
                    if info.pos1.x - info.midX ~= 0 then
                        local a = (info.pos1.y - info.peakY) / (math.pow(info.pos1.x - info.midX, 2))
                        if a > 0 then a = -a end
                        newX = math.sampler(info.pos1.x, info.midX, adjustCurrentTime / info.fhTime)
                        newY = a * math.pow(newX - info.midX, 2) + info.peakY
                    end
                else
                    if info.pos2.x - info.midX ~= 0 then
                        local a = (info.pos2.y - info.peakY) / (math.pow(info.pos2.x - info.midX, 2))
                        if a > 0 then a = -a end
                        newX = math.sampler(info.midX, info.pos2.x, (adjustCurrentTime - info.fhTime) / info.shTime)
                        newY = a * math.pow(newX - info.midX, 2) + info.peakY
                    end
                end
                if newX and newY then
                    obj.trapDirector:setPosition({x = newX, y = newY})
                end
            else
                obj.trapDirector:resume()
                obj.ended = true
            end
        end
    end
end

function QBattleManager:_updateBattleTutorial()
    if IsServerSide then
        return
    end

    if remote.instance:checkIsPassByDungeonId(self._dungeonConfig.id) then
        return
    end

    if not self._battleTutorialInitialized then
        self._battleTutorialObjs = {}
        for index, monster in ipairs(self._monsters) do
            if type(monster.mode) == "string" then
                local words = string.split(monster.mode, ";")
                table.insert(self._battleTutorialObjs, {monster = monster, words = words, ended = false})
            end
        end
        self._attackHandTouchs = {}
        self._battleTutorialInitialized = true
    end

    if #self._battleTutorialObjs > 0 and not self._battleTutorialEnded then
        local all_ended = true
        for tutorialIndex, obj in ipairs(self._battleTutorialObjs) do
            if not obj.ended then
                local monster = obj.monster
                local words = obj.words
                if #words == 2 then
                    -- 怪物出场后1秒开始引导
                    if monster.npc and self:getTime() - monster.born_time >= 1 and not self._appearActors[monster.npc] then
                        local down = monster.y > 3
                        if words[1] == "guide" then
                            if app.scene ~= nil then
                                app.scene:pauseBattleAndAttackEnemy(monster.npc, words[2], nil, down, tutorialIndex)
                            end
                        elseif words[1] == "mark" then
                            if app.scene ~= nil then
                                local handTouch
                                handTouch = app.scene:attackEnemy(monster.npc, words[2], nil, down)
                                handTouch:retain()
                                handTouch.npc = monster.npc
                                handTouch.start_time = self:getTime()
                                handTouch.tutorialIndex = tutorialIndex
                                table.insert(self._attackHandTouchs, handTouch)
                            end
                        end
                        obj.ended = true
                    end
                elseif #words == 4 then
                    -- 为了保证技能能够在引导的时候释放，强制是技能处于cd阶段
                    if not obj.battleTutorialSkillInfo or obj.battleTutorialSkillInfo.hero == nil then
                        local heroes = {}
                        table.mergeForArray(heroes, self._heroGhosts, function(ghost) return ghost.actor:isControlNPC() end, function(ghost) return ghost.actor end)
                        table.mergeForArray(heroes, self:getHeroes())
                        local skill, hero
                        for _, _hero in ipairs(heroes) do
                            local skills = _hero:getManualSkills()
                            local _skill = skills[next(skills)]
                            if tostring(_skill:getId()) == words[2] then
                                skill = _skill
                                hero = _hero
                                -- 强制技能的怒气不够
                                hero:setRage(hero:getRageTotal() / 2)
                                function hero:_changeRage(dRage, support)
                                    local rage = self:getRage() + dRage
                                    if rage >= self:getRageTotal() then
                                        return
                                    end
                                    QActor._changeRage(self, dRage, support)
                                end
                                break
                            end
                        end
                        obj.battleTutorialSkillInfo = {hero = hero, skill = skill, cd_time = words[3]}
                    end
                    local hero = obj.battleTutorialSkillInfo.hero
                    local skill = obj.battleTutorialSkillInfo.skill
                    local cd_time = obj.battleTutorialSkillInfo.cd_time
                    if hero and skill then
                        if monster.wave > self._curWave then
                            -- 波次还没有到，给个最大的cd冷却
                            if skill:isReady() then
                                skill:coolDown(self:getTimeLeft())
                            end
                        elseif monster.wave == self._curWave then
                            local least_cd_time = monster.appear + words[3] + 3
                            if skill:isReady() then
                                -- 波次到，按照出场的时间冷却
                                skill:coolDown(least_cd_time)
                            else
                                local dt = skill:getLeftCoolDownTime() - least_cd_time
                                if dt > 0 then
                                    skill:reduceCoolDownTime(dt)
                                end
                            end
                        end
                        -- 怪物出场后指定秒后开始引导释放技能
                        if monster.npc and self:getTime() - monster.born_time >= tonumber(words[3]) and not self._appearActors[monster.npc] then
                            if app.scene ~= nil then
                                skill:_stopCd()
                                hero._changeRage = QActor._changeRage
                                hero:setRage(hero:getRageTotal())
                                if words[1] == "guide" then
                                    app.scene:pauseBattleAndUseSkill(hero, skill, words[4], nil, tutorialIndex)
                                elseif words[1] == "mark" then
                                    local handTouch = app.scene:useSkill(hero, skill, words[4])
                                    -- 可能status view不够用导致没有handTouch可以引导
                                    if handTouch ~= nil then
                                        handTouch:retain()
                                        handTouch.skill = skill
                                        handTouch.start_time = self:getTime()
                                        handTouch.tutorialIndex = tutorialIndex
                                        self._skillHandTouch = handTouch
                                    end
                                end
                            end
                            obj.ended = true
                        end
                    end
                end
            end
            all_ended = all_ended and obj.ended
        end
        self._battleTutorialEnded = all_ended
    end

    if self._attackHandTouchs then
        for index, handTouch in ipairs(self._attackHandTouchs) do
            if handTouch.npc:isDead() or handTouch.npc:isMarked() or self:getTime() - handTouch.start_time > 3.0 then
                handTouch:removeFromParent()
                handTouch:release()
                app:triggerBuriedPoint(QBuriedPoint:getDungeonTutorialBuriedPointID(self._dungeonConfig.id, handTouch.tutorialIndex))
                table.remove(self._attackHandTouchs, index)
                break
            else
                local position = handTouch.npc:getCenterPosition_Stage()
                handTouch:setPosition(position.x, position.y-50)
            end
        end
    end

    if self._skillHandTouch then
        local handTouch = self._skillHandTouch
        if not handTouch.skill:isReady() or self:getTime() - handTouch.start_time > 3.0 then
            handTouch:removeFromParent()
            handTouch:release()
            app:triggerBuriedPoint(QBuriedPoint:getDungeonTutorialBuriedPointID(self._dungeonConfig.id, handTouch.tutorialIndex))
            self._skillHandTouch = nil
        end
    end
end

function QBattleManager:_hideAllBattleTutorialHandtouches()
    if self._attackHandTouchs then
        for _, handTouch in ipairs(self._attackHandTouchs) do
            handTouch:setVisible(false)
        end
    end

    if self._skillHandTouch then
        local handTouch = self._skillHandTouch
        handTouch:setVisible(false)
    end
end

function QBattleManager:_showAllBattleTutorialHandtouches()
    if self._attackHandTouchs then
        for _, handTouch in ipairs(self._attackHandTouchs) do
            handTouch:setVisible(true)
        end
    end

    if self._skillHandTouch then
        local handTouch = self._skillHandTouch
        handTouch:setVisible(true   )
    end
end

function QBattleManager:removeAllBattleTutorialHandtouches()
    if self._attackHandTouchs then
        for _, handTouch in ipairs(self._attackHandTouchs) do
            handTouch:removeFromParent()
            handTouch:release()
        end
        self._attackHandTouchs = {}
    end

    if self._skillHandTouch then
        local handTouch = self._skillHandTouch
        handTouch:removeFromParent()
        handTouch:release()
        self._skillHandTouch = nil
    end
end

function QBattleManager:_updateHeroHelper()
    local dungeonConfig = self._dungeonConfig
    local heroes = self._heroes

    if #heroes == 0 then
        return
    end

    if not self._heroHelperInitialized then
        local helper = dungeonConfig.helper
        local words = string.split(helper, ";")
        if helper and self._curWave == tonumber(words[2]) then
            self:performWithDelay(function()
                if self._aiDirector == nil then
                    return
                end

                local x, y = 250, 300
                if words[6] and words[7] then
                    x = tonumber(words[6])
                    y = tonumber(words[7])
                    local w = BATTLE_AREA.width / global.screen_big_grid_width
                    local h = BATTLE_AREA.height / global.screen_big_grid_height
                    x = BATTLE_AREA.left + w * x - w / 2
                    y = BATTLE_AREA.bottom + h * y - h / 2
                end
                 
                local ghost_actor = self:summonGhosts({ghost_id = tonumber(words[1]), summoner.heroes[1], life_span = 600, screen_pos = {x = x, y = y}})
                local info = db:getCharacterByID(tonumber(words[1]))
                function ghost_actor:getTalentHatred() return info.hatred end
                function ghost_actor:hasRage() return true end
                function ghost_actor:getGradeValue() return info.grade or 0 end
                ghost_actor:setIsPet(true)
                ghost_actor:setIsGhost(false)
                self._heroHelperGhostActor = {actor = ghost_actor, delete_time = words[4] and tonumber(words[4]) or -1}

                -- 助战武将需要能够控制
                ghost_actor:setIsControlNPC(true)
                if not IsServerSide then
                    local view = app.scene:getActorViewFromModel(ghost_actor)
                    view:setCanTouchBegin(true)
                    --添加武将控制
                    app.scene:addHeroStatusView(ghost_actor)

                    app.scene:getActorViewFromModel(ghost_actor):setVisible(false)
                    if words[5] then
                        local skill = QSkill.new(tonumber(words[5]), {}, ghost_actor)
                        ghost_actor:attack(skill, nil, nil, true)
                    end
                    app.scene:getActorViewFromModel(ghost_actor):setVisible(true)
                end
                -- 助战武将满怒气
                ghost_actor:setRage(ghost_actor:getRageTotal())

            end, tonumber(words[3]))
            self._heroHelperInitialized = true
        end
    end

    local ghost_actor = self._heroHelperGhostActor
    if ghost_actor and not ghost_actor.actor:isDead() and ghost_actor.delete_time >= 0 and self._onWin_Time and self:getTime() - self._onWin_Time >= ghost_actor.delete_time then
        local actor = ghost_actor.actor
        actor:suicide()
        self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = actor})
        self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = actor})

        if not IsServerSide then
            local view = app.scene:getActorViewFromModel(actor)
            view:setVisible(false)
            -- 移除武将控制
            app.scene:removeHeroStatusView(actor)
        end
    end
end

function QBattleManager:_updateDungeonDialogs()
    if IsServerSide then
        return
    end

    if not self:isInEditor() and not self:isPVPMode() then 
        if remote.instance:checkIsPassByDungeonId(self._dungeonConfig.id) ~= false then
            return
        end
    end

    if not self._dungeonDialogs_inited then
        self._dungeonDialogs_inited = true
        self._dungeonDialogIndex = 0
        local dungeonDialogs = QStaticDatabase:sharedDatabase():getDungeonDialogs()
        local dialogDisplay = QStaticDatabase:sharedDatabase():getDialogDisplay()

        if dungeonDialogs == nil or dialogDisplay == nil then
            self._dungeon_dialogs = {}
        else
            local dialogs = dungeonDialogs[tostring(self._dungeonConfig.id)]
            if dialogs == nil then
                dialogs = {}
            elseif dialogs[1] == nil then
                -- TOFIX: SHRINK
                dialogs = {q.cloneShrinkedObject(dialogs)}
            else
                -- TOFIX: SHRINK
                local _dialogs = {}
                for _, dialog in ipairs(dialogs) do
                    table.insert(_dialogs, q.cloneShrinkedObject(dialog))
                end
                dialogs = _dialogs
            end
            self._dungeon_dialogs = dialogs
        end
    end

    local dialogs = self._dungeon_dialogs
    for _, dialog in ipairs(dialogs) do
        if not dialog.triggered then
            if self:_tryTriggerDungeonDialog(dialog) then
                dialog.triggered = true
            end
        end
    end
end

function QBattleManager:_tryTriggerDungeonDialog(dialog)
    local trigger = dialog.trigger
    local dialogs = dialog.dialogs

    local words = string.split(trigger, ";")
    if words[1] == "wave" then
        local wave = tonumber(words[2])
        -- check wave valid
        if not dialog.wave_valid_check then
            dialog.wave_valid_check = true
            if wave <= 0 then
                return true
            else
                local max_wave = 0
                for _, monster in ipairs(self._monsters) do
                    if monster.wave > max_wave then
                        max_wave = monster.wave
                    end
                end
                if max_wave < wave then
                    CCMessageBox("dungeon_dialog, id:\"" .. dialog.id .. "\", trigger: \"".. trigger .. "\", wave is larger than the largest wave in dungeon_monster", "Warning!")
                    return true
                end
            end
        end
        local time = words[3] or 0
        if math.min(wave, self:getWaveCount()) == self._curWave then
            self:performWithDelay(function()
                self:_popDungeonDialogs(dialogs, dialog)
            end, tonumber(time), nil, true)
            return true
        end
    elseif words[1] == "npcbirth" then
        local npc_indexes = {}
        local time_index = 3
        if string.find(words[2], "{") then
            table.insert(npc_indexes, tonumber(string.sub(words[2], 2, string.len(words[2]))))
            local i = 3
            while true do
                if string.find(words[i], "}") then
                    table.insert(npc_indexes, tonumber(string.sub(words[i], 1, string.len(words[i]) - 1)))
                    time_index = i + 1
                    break
                else
                    table.insert(npc_indexes, tonumber(words[i]))
                    i = i + 1
                end
            end
        else
            table.insert(npc_indexes, tonumber(words[2]))
        end
        local time = words[time_index] or 0
        for _, npc_index in ipairs(npc_indexes) do
            local monster = self._monsters[npc_index]
            -- 如果没有该monster，continue
            if monster and not monster.npc then
                return false
            end
        end
        self:performWithDelay(function()
            self:_popDungeonDialogs(dialogs, dialog)
        end, tonumber(time), nil, true)
        return true
    elseif words[1] == "npcdeath" then
        local npc_indexes = {}
        local time_index = 3
        if string.find(words[2], "{") then
            table.insert(npc_indexes, tonumber(string.sub(words[2], 2, string.len(words[2]))))
            local i = 3
            while true do
                if string.find(words[i], "}") then
                    table.insert(npc_indexes, tonumber(string.sub(words[i], 1, string.len(words[i]) - 1)))
                    time_index = i + 1
                    break
                else
                    table.insert(npc_indexes, tonumber(words[i]))
                    i = i + 1
                end
            end
        else
            table.insert(npc_indexes, tonumber(words[2]))
        end
        local time = words[time_index] or 0
        for _, npc_index in ipairs(npc_indexes) do
            local monster = self._monsters[npc_index]
            -- 如果没有该monster，continue
            if monster and (not monster.npc or not monster.npc:isDead()) then
                return false
            end
        end
        
        --应龙少要求，在NPC死亡后，有对话框弹出，则结束全场所有魂师的动作，为得是结束小舞在旋转带来的音效不能停止的问题
        local heroViews = app.scene:getHeroViews()
        for i, view in ipairs(heroViews) do
            view:getModel():cancelAllSkills()
        end
        self:performWithDelay(function()
            self:_popDungeonDialogs(dialogs, dialog)
        end, tonumber(time), nil, true)
        return true
    elseif words[1] == "npcskill" then
        local npc_index = tonumber(words[2])
        local skill_id = words[3]
        local time = words[4] or 0
        local monster = self._monsters[npc_index]
        if monster and monster.npc and monster.npc:isDead() then
            dialog.finished = true
            return true
        end
        if monster and monster.npc and monster.npc:getCurrentSkill() and tostring(monster.npc:getCurrentSkill():getId()) == skill_id then
            self:performWithDelay(function()
                self:_popDungeonDialogs(dialogs, dialog)
            end, tonumber(time), nil, true)
            return true
        end
    elseif words[1] == "npchp" then
        local npc_index = tonumber(words[2])
        local hp_percent = tonumber(words[3])
        local time = words[4] or 0
        local monster = self._monsters[npc_index]
        if monster and monster.npc and monster.npc:getHp() / monster.npc:getMaxHp() <= hp_percent then
            self:performWithDelay(function()
                self:_popDungeonDialogs(dialogs, dialog)
            end, tonumber(time), nil, true)
            return true
        end
    elseif words[1] == "victory" then
        if self._victory_dialog == nil then
            self._victory_dialog = dialog
            self._force_skip_move = words[2] == "y"
        end
        if self._onWin_Time then
            self:performWithDelay(function ()
                self:_popDungeonDialogs(dialogs, dialog)
            end, 2.8, nil, true, true, true)
            return true
        end
    elseif words[1] == "start" then
        self:_popDungeonDialogs(dialogs, dialog)
        return true
    end

    return false
end

function QBattleManager:_popDungeonDialogs(dialogs, dialog)

    if dialog.type == 2 then
        app.scene:_pauseBattleAndShowImageDialog(dialog)
        return
    end

    local strs = string.split(dialogs,";")
    if strs[1] == "speak" then
        local actorId = tonumber(strs[2])
        local duration = tonumber(strs[3])
        if actorId and duration then
            local actor = nil
            for i,hero in pairs(self:getHeroes()) do
                if tonumber(hero:getActorID()) == actorId then
                    actor = hero
                    break
                end
            end
            if actor == nil then
                for i,hero_ghosts in pairs(self:getHeroGhosts()) do
                    if tonumber(hero_ghosts.actor:getActorID()) == actorId then
                        actor = hero
                        break
                    end
                end
            end
            if actor then
                actor:speak(strs[4],duration,1)
            end
        end
        dialog.finished = true
        return
    end

    local db = QStaticDatabase:sharedDatabase()
    local dialogDisplay = db:getDialogDisplay()
    local words = string.split(dialogs, ";")
    local sentences = {}
    local imageFiles = {}
    local names = {}
    local titleNames = {}
    local leftSides = {}
    local dialogIndice = {}

    for index = 1, math.floor(#words / 3) do
        self._dungeonDialogIndex = self._dungeonDialogIndex + 1
        local display_id = words[index * 3 - 2]
        local leftSide = words[index * 3 - 1] == "left"
        local sentence = words[index * 3]

        local display = dialogDisplay[tostring(display_id)]
        local character = db:getCharacterDisplayByID(display_id)
        if display then
            table.insert(sentences, 1, sentence)
            table.insert(leftSides, 1, leftSide)
            table.insert(imageFiles, 1, display.bust)
            table.insert(names, 1, display.name)
            table.insert(dialogIndice, 1, self._dungeonDialogIndex)
        end
        if character then
            table.insert(titleNames,1,character.title or "")
        end
    end

    app.scene:pauseBattleAndDisplayDislog(sentences, imageFiles, names, titleNames, nil, function() dialog.finished = true end, leftSides, dialogIndice)
end

function QBattleManager:isDungeonDialogsAllFinished()
    local dialogs = self._dungeon_dialogs
    if dialogs == nil or #dialogs == 0 then
        return true
    end

    for _, dialog in ipairs(dialogs) do
        if not dialog.finished then
            return false
        end
    end

    return true
end

function QBattleManager:registerCharge(actor, target, allow_callback)
    local charges = self._registerdCharges
    table.insert(charges, {actor = actor, target = target, allow_callback = allow_callback})
end

function QBattleManager:_updateRegisteredCharges()
    local candidate_obj = nil
    local candidate_dist_max = 0
    local candidate_hatred = 0
    local charges = self._registerdCharges
    for _, obj in ipairs(charges) do
        local actor = obj.actor
        local target = obj.target
        if actor and target then
            local dist = q.distOf2PointsSquare(actor:getPosition(), target:getPosition())
            local hatred = actor:getTalentHatred()
            if hatred > candidate_hatred or (hatred == candidate_hatred and dist > candidate_dist_max) then
                candidate_dist_max = dist
                candidate_hatred = hatred
                candidate_obj = obj
            end
        end
    end
    for _, obj in ipairs(charges) do
        obj.allow_callback(obj == candidate_obj)
    end
    self._registerdCharges = {}
end

--[[
    怒气相关
]]
function QBattleManager:getRageCoefficients(actor)
    local coefficients_offence = self._rageCoefficientsOffence
    local coefficients_defence = self._rageCoefficientsDefence
    if coefficients_offence == nil or coefficients_defence == nil then
        local dungeon_id = self._dungeonConfig.id
        coefficients_offence = db:getDungeonRageOffenceByDungeonID(dungeon_id)
        if dungeon_id ~= "sunwell" then
            coefficients_defence = db:getDungeonRageDefenceByDungeonID(dungeon_id)
        else
            -- coefficients_defence = db:getSunWarDungeonRageConfig(remote.sunWar:getCurrentMapID(), remote.sunWar:getCurrentWaveID())
            -- if coefficients_defence == nil then
                coefficients_defence = db:getDungeonRageDefenceByDungeonID(dungeon_id)
            -- end
        end
        self._rageCoefficientsOffence = coefficients_offence
        self._rageCoefficientsDefence = coefficients_defence
    end

    local actor_type = actor:getType()
    if actor_type == ACTOR_TYPES.HERO or actor_type == ACTOR_TYPES.HERO_NPC then
        return coefficients_offence
    else
        return coefficients_defence
    end
end

function QBattleManager:getSupportSkillHero()
    return self._supportSkillHero
end

function QBattleManager:getSupportSkillHero2()
    return self._supportSkillHero2
end

function QBattleManager:getSupportSkillHero3()
    return self._supportSkillHero3
end

function QBattleManager:getSupportSkillEnemy()
    return self._supportSkillEnemy
end

function QBattleManager:getSupportSkillEnemy2()
    return self._supportSkillEnemy2
end

function QBattleManager:getSupportSkillEnemy3()
    return self._supportSkillEnemy3
end

-- for UI and AI
function QBattleManager:useSupportHeroSkill(actor, ignore_resource)
    if actor ~= self._supportSkillHero and actor ~= self._supportSkillHero2 and actor ~= self._supportSkillHero3 then
        return
    end

    if not actor or actor:isDead() then
        return
    end

    local mskills = actor:getManualSkills()
    local skill = mskills[next(mskills)]
    if not skill then
        return
    end

    actor:onUseManualSkill(skill, ignore_resource)
end

function QBattleManager:useSupportEnemySkill(actor, ignore_resource)
    if actor ~= self._supportSkillEnemy and actor ~= self._supportSkillEnemy2 and actor ~= self._supportSkillEnemy3 then
        return
    end

    if not actor or actor:isDead() then
        return
    end

    local mskills = actor:getManualSkills()
    local skill = mskills[next(mskills)]
    if not skill then
        return
    end

    actor:onUseManualSkill(skill, ignore_resource)
end

-- for QActor
function QBattleManager:doSupportSkill(actor, skill, ignore_resource)
    if actor == nil or skill == nil then
        return
    end

    if actor:getCurrentSkill() then
        return
    end
    if not ignore_resource then
        if not actor:isRageEnough() then
            return
        end
    end
    if table.indexof(self._heroes, actor) or table.indexof(self._enemies, actor) then
        return
    end

    -- 寻找一个目标，作为当前目标
    local target = self:_findSupportActorTarget(actor)

    -- 如果技能要求有目标，但是target是nil，则放弃执行，否则会有可能出错
    if target == nil then
        if skill:getRangeType() == skill.SINGALE and skill:getTargetType() == skill.TARGET or
            skill:getRangeType() == skill.MULTIPLE and skill:getZoneType() == skill.ZONE_FAN and skill:getSectorCenter() == skill.CENTER_TARGET then
            return 
        end
    end

    if target then
        actor:unlockTarget()
        actor:setTarget(target)
    end

    -- 远程魂师，以及没有目标的近战魂师出现在场地的中央
    -- 有目标的近战魂师，站在目标身边
    local center_x, center_y = (BATTLE_AREA.left + BATTLE_AREA.right) / 2, (BATTLE_AREA.top + BATTLE_AREA.bottom) / 2
    app.grid:addActor(actor)
    if actor:isRanged() or not target then
        if actor:isHealth() then
            if actor:getType() == ACTOR_TYPES.HERO then
                app.grid:setActorTo(actor, {x = center_x * 0.667, y = center_y})
            else
                app.grid:setActorTo(actor, {x = center_x * 1.333, y = center_y})
            end
        else
            app.grid:setActorTo(actor, {x = center_x, y = center_y})
        end
    else
        local distance = (actor:getRect().size.width * 0.5 + target:getRect().size.width * 0.5) * ((target:getPosition().x < center_x) and 1 or -1)
        app.grid:setActorTo(actor, {x = target:getPosition().x + distance, y = target:getPosition().y})
    end
    local pet = actor:getHunterPet()
    if pet then
        if target then
            pet:setTarget(target)
        end
        app.grid:setActorTo(pet, {x = center_x, y = center_y})
    end
    if actor == self._supportSkillHero or actor == self._supportSkillHero2 or actor == self._supportSkillHero3 then
        table.insert(self._heroes, actor)
    elseif actor == self._supportSkillEnemy or actor == self._supportSkillEnemy2 or actor == self._supportSkillEnemy3 then
        table.insert(self._enemies, actor)
    else
        assert(false, "")
    end

    actor:attack(skill, nil, nil, true)

    if actor == self._supportSkillHero or actor == self._supportSkillHero2 or actor == self._supportSkillHero3 then
        self._supportHeroSkillTime[actor:getActorID(true)] = 0
    else
        self._supportEnemySkillTime[actor:getActorID(true)] = 0
    end
    
    local otherSkills = {}
    if self:getSupportSkillHero() == actor then
        if self:getSupportSkillHero2() then
            table.insert(otherSkills,self:getSupportSkillHero2():getFirstManualSkill())
        end
        if self:getSupportSkillHero3() then
            table.insert(otherSkills,self:getSupportSkillHero3():getFirstManualSkill())
        end
    elseif self:getSupportSkillHero2() == actor then
        if self:getSupportSkillHero() then
            table.insert(otherSkills,self:getSupportSkillHero():getFirstManualSkill())
        end
        if self:getSupportSkillHero3() then
            table.insert(otherSkills,self:getSupportSkillHero3():getFirstManualSkill())
        end
    elseif self:getSupportSkillHero3() == actor then
        if self:getSupportSkillHero() then
            table.insert(otherSkills,self:getSupportSkillHero():getFirstManualSkill())
        end
        if self:getSupportSkillHero2() then
            table.insert(otherSkills,self:getSupportSkillHero2():getFirstManualSkill())
        end
    elseif self:getSupportSkillEnemy() == actor then
        if self:getSupportSkillEnemy2() then
            table.insert(otherSkills,self:getSupportSkillEnemy2():getFirstManualSkill())
        end
        if self:getSupportSkillEnemy3() then
            table.insert(otherSkills,self:getSupportSkillEnemy3():getFirstManualSkill())
        end
    elseif self:getSupportSkillEnemy2() == actor then
        if self:getSupportSkillEnemy() then
            table.insert(otherSkills,self:getSupportSkillEnemy():getFirstManualSkill())
        end
        if self:getSupportSkillEnemy3() then
            table.insert(otherSkills,self:getSupportSkillEnemy3():getFirstManualSkill())
        end
    elseif self:getSupportSkillEnemy3() == actor then
        if self:getSupportSkillEnemy() then
            table.insert(otherSkills,self:getSupportSkillEnemy():getFirstManualSkill())
        end
        if self:getSupportSkillEnemy2() then
            table.insert(otherSkills,self:getSupportSkillEnemy2():getFirstManualSkill())
        end
    end
    for k,otherSkill in ipairs(otherSkills) do
        otherSkill:resetCoolDown()
        otherSkill:coolDown(5, true)
    end
end

function QBattleManager:_findSupportActorTarget(actor)
    local target = nil
    if actor:isHealth() then
        --[[
        -- 优先主T
        local _mates = self:getMyTeammates(actor, false)
        local mates = {}
        for _, mate in ipairs(_mates) do
            if not mate:isSupport() then
                table.insert(mates, mate)
            end
        end
        for _, mate in ipairs(mates) do
            if mate:isT() then
                target = mate
                break
            end
        end
        if not target then
            -- 没有的话随便找一个自己人
            if #mates > 0 then
                target = mates[app.random(1, #mates)]
            else
                target = actor
            end
        end
        --]]
        ----[[
        --新的选择目标逻辑
        local _mates = self:getMyTeammates(actor, false, true)
        local mates = {}
        for _, mate in ipairs(_mates) do
            if not mate:isSupport() then
                table.insert(mates, mate)
            end
        end
        local function getHpPercent(actor)
            return actor:getHp()/actor:getMaxHp()
        end
        table.sort(mates, function(a,b)  
                return getHpPercent(a)<getHpPercent(b)
            end)
        if #mates > 0 then
            target = mates[1]
        else
            target = actor
        end
        --]]
    else
        -- 有集火印记的敌人
        local enemies = self:getMyEnemies(actor)
        local mark_enemy, mark_time
        for _, enemy in ipairs(enemies) do
            local isMarked, markTime = enemy:isMarked()
            if isMarked then
                if mark_enemy == nil or markTime > mark_time then
                    mark_enemy = enemy
                    mark_time = markTime
                end
            end
        end
        target = mark_enemy
        -- 优先非治疗的共同的目标
        if not target then
            local mates = self:getMyTeammates(actor, false)
            local common_target = nil
            for _, mate in ipairs(mates) do
                if not mate:isHealth() then
                    local matetarget = mate:getTarget()
                    if not matetarget or matetarget:isSupport() then
                        common_target = nil
                        break
                    elseif not common_target then
                        common_target = matetarget
                    elseif common_target ~= matetarget then
                        common_target = nil
                        break
                    end
                end
            end
            target = common_target
        end
        -- 优先主T的目标
        if not target then
            local mates = self:getMyTeammates(actor, false)
            for _, mate in ipairs(mates) do
                if mate:isT() and mate:getTarget() and (not mate:getTarget():isDead()) and (not mate:getTarget():isSupport()) then
                    target = mate:getTarget()
                    break
                end
            end
        end
        -- 没有的话随便找一个敌人
        if not target then
            local targets = {}
            for i,enemy in ipairs(enemies) do
                if not enemy:isSupport() then
                    table.insert(targets, enemy)
                end
            end

            if #targets > 0 then
                target = targets[app.random(1, #targets)]
            end
        end
    end
    return target
end

function QBattleManager:_getSupportHeroRagePerSecond()
    local rage = self:isPVPMode() and QBattleManager.SUPPORT_HERO_RAGE_PER_SECOND_IN_PVP or QBattleManager.SUPPORT_HERO_RAGE_PER_SECOND
    rage = rage * (0.95 + app.random() * 0.1)
    return rage
end

function QBattleManager:_clearTargetSupportEnemy(actors, actor)
    for _, enemy in ipairs(actors) do
        if enemy:getTarget() == actor then
            enemy:_cancelCurrentSkill()
            enemy:unlockTarget()
            enemy:setTarget(nil)
            enemy:stopMoving()
            enemy:getHitLog():clearByActor(actor)
        end
        if enemy:getLastAttackee() == actor then
            enemy:clearLastAttackee()
        end
        if enemy:getLastAttacker() == actor then
            enemy:clearLastAttacker()
        end
    end
end

function QBattleManager:_clearTargetSupportTeammate(actors, actor)
    for _, mate in ipairs(actors) do
        -- fix线上bug
        if mate and not mate:isDead() and actor and not actor:isDead() then
            if mate:getTarget() == actor and mate:getCurrentSkill() and mate:getCurrentSkill():isNeedATarget() then
                mate:_cancelCurrentSkill()
                mate:setTarget(nil)
            end
        end
    end
end

function QBattleManager:_updateSupportHeroSkill(dt)
    if self._pauseBetweenWaves then
        return
    end
    -- 魂师不在场，每秒回怒气
    if self._lastUpdateSupportHeroRage == nil then
        self._lastUpdateSupportHeroRage = 0
    else
        self._lastUpdateSupportHeroRage = self._lastUpdateSupportHeroRage + dt
    end
    local dSecond = math.floor(self._lastUpdateSupportHeroRage)
    self._lastUpdateSupportHeroRage = self._lastUpdateSupportHeroRage - dSecond
    local dRage = dSecond * self:_getSupportHeroRagePerSecond()
    local function _updateSupportHeroSkillByActor(actor, rage)
        if not actor or actor:isDead() then
            return
        end
        local mskills = actor:getManualSkills()
        local skill = mskills[next(mskills)]
        if not skill then
            return
        end
        local hero_index = table.indexof(self._heroes, actor)
        if not hero_index then
            actor:changeRage(rage, true)
            -- 检查是否自动释放手动技能
            if actor:isForceAuto() and actor:isSupportSkillReady() then
                -- 额外检查逻辑：波次开始后的2秒内不允许自动释放援助魂师的援助技能
                if self._curWave == 1 or not self._curWaveStartTime or self:getTime() - self._curWaveStartTime > 2 then
                    -- actor:onUseManualSkill(skill)
                    self:doSupportSkill(actor, skill)
                end
            end
            return
        end
        local sbDirectors = actor:getSkillDirectors()
        for _, sbDirector in ipairs(sbDirectors) do
            if sbDirector:getSkill() == skill then
                return
            end
        end

        local actorID = actor:getActorID(true)

        if self._supportHeroSkillTime[actorID] then
            self._supportHeroSkillTime[actorID] = self._supportHeroSkillTime[actorID] + dt
        end

        -- 自强型魂师要等技能给的buff结束时才能回去。
        -- 方法：检查是否有与skill关联的buff还存在
        -- 超过X秒，直接结束
        if self._supportHeroSkillTime[actorID] and self._supportHeroSkillTime[actorID] <= QBattleManager.SUPPORT_HERO_MAX_SECONDS then
            for _, buff in ipairs(actor:getBuffs()) do
                if buff:getSkill() == skill then
                    -- 检查魂师的目标是否还存在，不在的话再找一个目标
                    if actor:getTarget() == nil or actor:getTarget():isDead() then
                        actor:unlockTarget()
                        actor:setTarget(self:_findSupportActorTarget(actor))
                    end
                    local pet = actor:getHunterPet()
                    if pet and (pet:getTarget() == nil or pet:getTarget():isDead()) then
                        pet:unlockTarget()
                        pet:setTarget(actor:getTarget())
                    end
                    return
                end
            end
        end

        -- 技能结束了，副将可以回去了
        table.remove(self._heroes, hero_index)

        self:_clearTargetSupportEnemy(app.battle:getMyEnemies(actor), actor)
        self:_clearTargetSupportEnemy(self._enemySoulSpritsList, actor)
        self:_clearTargetSupportTeammate(app.battle:getMyTeammates(actor), actor)
        self:_clearTargetSupportTeammate(self._userSoulSpritsList, actor)

        actor:unlockTarget()
        actor:setTarget(nil)
        actor:stopMoving()
        actor:cancelAllSkills()
        actor:clearLastAttackee()
        actor:clearLastAttacker()
        app.grid:setActorTo(actor, {x = -0.5 * BATTLE_AREA.width, y = 0.5 * BATTLE_AREA.height})
        app.grid:removeActor(actor)
        -- if app.scene._touchController then
        --     if app.scene._touchController:getSelectActorView() == app.scene:getActorViewFromModel(actor) then
        --         app.scene._touchController:setSelectActorView(nil)
        --     end
        -- end
        local pet = actor:getHunterPet()
        if pet then
            app.grid:setActorTo(pet, {x = -0.5 * BATTLE_AREA.width, y = 0.5 * BATTLE_AREA.height})
            pet:unlockTarget()
            pet:setTarget(nil)
            pet:stopMoving()
            pet:cancelAllSkills()
            pet:clearLastAttackee()
            pet:clearLastAttacker()
        end
    end
    _updateSupportHeroSkillByActor(self._supportSkillHero, dRage)
    _updateSupportHeroSkillByActor(self._supportSkillHero2, dRage)
    _updateSupportHeroSkillByActor(self._supportSkillHero3, dRage)
end

function QBattleManager:_updateSupportEnemySkill(dt)
    -- 敌对魂师不在场，每秒回怒气
    if self._lastUpdateSupportEnemyRage == nil then
        self._lastUpdateSupportEnemyRage = 0
    else
        self._lastUpdateSupportEnemyRage = self._lastUpdateSupportEnemyRage + dt
    end
    local dSecond = math.floor(self._lastUpdateSupportEnemyRage)
    self._lastUpdateSupportEnemyRage = self._lastUpdateSupportEnemyRage - dSecond
    local dRage = dSecond * self:_getSupportHeroRagePerSecond()
    local function _updateSupportEnemySkillByActor(actor, rage)
        if not actor or actor:isDead() then
            return
        end
        local mskills = actor:getManualSkills()
        local skill = mskills[next(mskills)]
        if not skill then
            return
        end
        local hero_index = table.indexof(self._enemies, actor)
        if not hero_index then
            actor:changeRage(rage, true)
            -- 检查是否自动释放手动技能
            if actor:isSupportSkillReady() then
                self:doSupportSkill(actor, skill)
            end
            return
        end
        local sbDirectors = actor:getSkillDirectors()
        for _, sbDirector in ipairs(sbDirectors) do
            if sbDirector:getSkill() == skill then
                return
            end
        end

        local actorID = actor:getActorID(true)
        if self._supportEnemySkillTime[actorID] then
            self._supportEnemySkillTime[actorID] = self._supportEnemySkillTime[actorID] + dt
        end

        -- 自强型敌对魂师要等技能给的buff结束时才能回去。
        -- 方法：检查是否有与skill关联的buff还存在
        -- 超过X秒，直接结束
        if self._supportEnemySkillTime[actorID] and self._supportEnemySkillTime[actorID] <= QBattleManager.SUPPORT_HERO_MAX_SECONDS then
            for _, buff in ipairs(actor:getBuffs()) do
                if buff:getSkill() == skill then
                    -- 检查敌对魂师的目标是否还存在，不在的话再找一个目标
                    if actor:getTarget() == nil or actor:getTarget():isDead() then
                        actor:unlockTarget()
                        actor:setTarget(self:_findSupportActorTarget(actor))
                    end
                    return
                end
            end
        end

        -- 技能结束了，副将可以回去了
        table.remove(self._enemies, hero_index)

        self:_clearTargetSupportEnemy(app.battle:getMyEnemies(actor), actor)
        self:_clearTargetSupportEnemy(self._userSoulSpritsList, actor)
        self:_clearTargetSupportTeammate(app.battle:getMyTeammates(actor), actor)
        self:_clearTargetSupportTeammate(self._enemySoulSpritsList, actor)

        actor:unlockTarget()
        actor:setTarget(nil)
        actor:stopMoving()
        actor:cancelAllSkills()
        actor:clearLastAttackee()
        actor:clearLastAttacker()
        app.grid:setActorTo(actor, {x = 1.5 * BATTLE_AREA.width, y = 0.5 * BATTLE_AREA.height})
        app.grid:removeActor(actor)
        -- if app.scene._touchController then
        --     if app.scene._touchController:getSelectActorView() == app.scene:getActorViewFromModel(actor) then
        --         app.scene._touchController:setSelectActorView(nil)
        --     end
        -- end
        local pet = actor:getHunterPet()
        if pet then
            app.grid:setActorTo(pet, {x = 1.5 * BATTLE_AREA.width, y = 0.5 * BATTLE_AREA.height})
            pet:unlockTarget()
            pet:setTarget(nil)
            pet:stopMoving()
            pet:cancelAllSkills()
            pet:clearLastAttackee()
            pet:clearLastAttacker()
        end
    end
    _updateSupportEnemySkillByActor(self._supportSkillEnemy, dRage)
    _updateSupportEnemySkillByActor(self._supportSkillEnemy2, dRage)
    _updateSupportEnemySkillByActor(self._supportSkillEnemy3, dRage)
end

function QBattleManager:_updateHeroicMonsterIntroduction()
    if not INTRODUCE_HEROIC_MONSTER then
        return
    end

    if IsServerSide then
        return
    end

    if self._heroicMonsterIntroductionOver then
        return
    end

    if self._heroicMonster == nil then
        local heroicMonster = nil
        for i, monster in ipairs(self._monsters) do
            local info = db:getCharacterByID(self:getBattleRandomNpc(self._dungeonConfig.monster_id, i, monster.npc_id))
            -- TOFIX 填了npc_skill_list都是魂师怪
            -- if info.npc_skill_list then
            if info.is_hero_boss == true then
                local introduced = app:getUserData():getUserValueForKey(tostring(info.id) .. "_introduced")
                if ALWAYS_SHOW_BOSS_INTRODUCTION then
                    introduced = QUserData.STRING_FALSE
                end
                if introduced ~= QUserData.STRING_TRUE or self:isInEditor() then
                    heroicMonster = monster
                    break
                end
            end
        end
        if heroicMonster == nil then
            self._heroicMonsterIntroductionOver = true
            return
        end
        self._heroicMonster = heroicMonster
    end

    local heroicMonster = self._heroicMonster
    if heroicMonster then
        local actor = heroicMonster.npc
        local monster = heroicMonster
        if actor and not actor:isDead() and (not monster.appear_skill or not actor:isDoingSkillByID(monster.appear_skill)) and self:isInBulletTime() ~= true then
            app.scene:prompHeroIntroduction(actor)
            if not self:isInEditor() then
                app:getUserData():setUserValueForKey(tostring(actor:getActorID()) .. "_introduced", QUserData.STRING_TRUE)
            end
            self._heroicMonsterIntroductionOver = true
        end
    end
end

function QBattleManager:getThunderConditionTexts()
    local target_type, target_value, target_text = db:getThunderWinConditionByDungeonId(self._dungeonConfig.id)
    local failure = false
    if target_type == "hero_deaded" then
        local death_toll = 0
        for _, hero in ipairs(self._deadHeroes) do
            if not hero:isPet() and not hero:isGhost() then
                death_toll = death_toll + 1
            end
        end
        if death_toll > target_value then
            failure = true
        end
        return string.format("死亡人数不超过%d个人", target_value), "死亡人数：", tostring(death_toll), failure
    elseif target_type == "dungeon_time" then
        if (self:getDungeonDuration() - self:getTimeLeft()) > target_value then
            failure = true
        end
        local time = math.floor(math.max(0, target_value - (self:getDungeonDuration() - self:getTimeLeft())))
        return string.format("在%d秒内获胜", target_value), "剩余时间：", string.format("%d", time), failure, true
    elseif target_type == "hp_remain" then
        local hp, max_hp = 0, 0
        for _, hero in ipairs(self._heroes) do
            if not hero:isPet() and not hero:isGhost() then
                hp = hp + hero:getHp()
                max_hp = max_hp + hero:getMaxHp()
            end
        end
        for _, hero in ipairs(self._deadHeroes) do
            if not hero:isPet() and not hero:isGhost() then
                hp = hp + hero:getHp()
                max_hp = max_hp + hero:getMaxHp()
            end
        end
        if max_hp ~= 0 and (hp / max_hp) < (target_value / 100) then
            failure = true
        end 
        local percent = hp / max_hp * 100
        return string.format("我方总血量高于%d％", target_value), "剩余血量：", percent >= 10 and string.format("%02d％", percent) or string.format(" %d％", percent), failure
    end
    return "", "", "", false
end

function QBattleManager:_updateMonsterString()
    if IsServerSide then
        return
    end

    if self:isInTutorial() or self:isPVPMode() then
        return
    end

    if not self._monsterString_inited then
        self._monsterString_inited = true

        local monsters = self._monsters
        for _, monster in ipairs (monsters) do
            if monster.NPCstring then
                local stringids = string.split(tostring(monster.NPCstring), ",")
                local bullshitobjs = {}
                for _, stringid in ipairs(stringids) do
                    local monster_string = db:getMonsterStringByID(stringid)
                    if monster_string then
                        if monster_string.time then
                            table.insert(bullshitobjs, {cat = "time", value = monster_string.time, bullshit = monster_string.string, duration = monster_string.duration, type = monster_string.type, cfg = monster_string})
                        end
                        if monster_string.hp then
                            table.insert(bullshitobjs, {cat = "hp", value = monster_string.hp, bullshit = monster_string.string, duration = monster_string.duration, type = monster_string.type, cfg = monster_string})
                        end
                        if monster_string.skill then
                            table.insert(bullshitobjs, {cat = "skill", value = monster_string.skill, bullshit = monster_string.string, duration = monster_string.duration, type = monster_string.type, cfg = monster_string})
                        end
                    end
                end
                monster.bullshitobjs = bullshitobjs
            end
        end
    end

    local monsters = self._monsters
    for _, monster in ipairs (monsters) do
        local actor = monster.npc
        if monster.bullshit_id then
            actor = monster.npc_summoned[monster.bullshit_id]
        end
        if monster.bullshitobjs and actor and not actor:isDead() then
            local rmObjs = {}
            for _, bullshitobj in pairs(monster.bullshitobjs) do
                if not bullshitobj.triggered then
                    local triggered = false
                    local cat, value = bullshitobj.cat, bullshitobj.value
                    if cat == "time" then
                        if self:getTime() - monster.born_time >= value then
                            triggered = true
                        end
                    elseif cat  == "hp" then
                        if actor:getHp() / actor:getMaxHp() <= value then
                            triggered = true
                        end
                    elseif cat == "skill" then
                        if actor:getCurrentSkill() and actor:getCurrentSkill():getId() == value then
                            if bullshitobj.sbDirector ~= actor:getCurrentSBDirector() then
                                bullshitobj.sbDirector = actor:getCurrentSBDirector()
                                if tonumber(bullshitobj.type) == 3 then
                                    app.scene:showBossTips(bullshitobj.duration, bullshitobj.bullshit, bullshitobj.cfg)
                                else
                                    actor:speak(bullshitobj.bullshit, bullshitobj.duration, bullshitobj.type)
                                end
                            end
                        end
                    elseif cat == "behavior" then -- behavior 会立刻生效
                        if tonumber(bullshitobj.type) == 3 then
                            app.scene:showBossTips(bullshitobj.duration, bullshitobj.bullshit, bullshitobj.cfg)
                        else
                            actor:speak(bullshitobj.bullshit, bullshitobj.duration, bullshitobj.type)
                        end
                        table.insert(rmObjs,bullshitobj)
                    end
                    if triggered then
                        if tonumber(bullshitobj.type) == 3 then
                            app.scene:showBossTips(bullshitobj.duration, bullshitobj.bullshit, bullshitobj.cfg)
                        else
                            actor:speak(bullshitobj.bullshit, bullshitobj.duration, bullshitobj.type)
                        end
                        bullshitobj.triggered = true
                    end
                end
            end
            for k,v in ipairs(rmObjs) do
                table.removebyvalue(monster.bullshitobjs,v)
            end
        end
    end
end

function QBattleManager:setFuncMark(npc, func, monster_id, index)
    if IsServerSide then
        return
    end

    if func == nil or func == "nil" then
        return
    end

    local mark_id = monster_id .. "_fm_" ..tostring(index)
    local mark_count = app:getUserData():getUserValueForKey(mark_id)
    mark_count = mark_count and tonumber(mark_count) or 0
    if mark_count >= 3 then
        return
    end

    app:getUserData():setUserValueForKey(mark_id, tostring(mark_count + 1))
    local funcs = string.split(func, ",")
    npc:setFuncMark(funcs[1], funcs[2] and tonumber(funcs[2]))
end

function QBattleManager:isActorAppearing(actor)
    return self._appearActors[actor]
end

function QBattleManager:_applyRebelFightHeroAttackMultiplier(attack_multiplier)
    if not (self:isInRebelFight() or self:isInWorldBoss()) or not attack_multiplier then
        return
    end
    local db = QStaticDatabase:sharedDatabase()
    local aptitudeTable = 
    {
        [0] = 0,
        [10] = db:getConfigurationValue("BUFF_C") or 0,
        [12] = db:getConfigurationValue("BUFF_B") or 0,
        [15] = db:getConfigurationValue("BUFF_A") or 0,
        [18] = db:getConfigurationValue("BUFF_AA") or 0,
        [20] = db:getConfigurationValue("BUFF_S") or 0,
        [22] = db:getConfigurationValue("BUFF_SS") or 0,
        [24] = db:getConfigurationValue("BUFF_SSR") or 0,
    }
    for _, hero in ipairs(self:getHeroes()) do
        local grade = hero:getGradeValue() + 1 + aptitudeTable[db:getCharacterByID(hero:getActorID()).aptitude or 0]
        hero:insertPropertyValue("attack_percent", "rebel_fight", "+", (attack_multiplier * grade - 1))
    end
    for _, hero in ipairs(self:getSupportHeroes()) do
        local grade = hero:getGradeValue() + 1 + aptitudeTable[db:getCharacterByID(hero:getActorID()).aptitude or 0]
        hero:insertPropertyValue("attack_percent", "rebel_fight", "+", (attack_multiplier * grade - 1))
    end
end

function QBattleManager:isInRebelFight()
    return self._dungeonConfig.isInRebelFight
end

function QBattleManager:getRebelFightBossHp()
    return self._rebelFightBossHp or 0
end

function QBattleManager:getRebelFightBossHpReduce()
    local boss = self:getEnemies()[1]
    if boss == nil then
        return 0 
    else
        return self._dungeonConfig.rebelHP - self:getEnemies()[1]:getHp()
    end
end

function QBattleManager:isInWorldBoss()
    return self._dungeonConfig.isInWorldBossFight or false
end

function QBattleManager:getWorldBossFightBossHp()
    return self._worldBossFightBossHp or 0
end

function QBattleManager:getWorldBossFightBossHpReduce()
    local boss = self:getEnemies()[1]
    if boss == nil then
        return 0
    else
        return self._dungeonConfig.worldBossHP - self:getEnemies()[1]:getHp()
    end
end

function QBattleManager:getSocietyDungeonBossHpReduce()
    -- local boss = self:getEnemies()[1]
    -- if boss == nil then
    --     return 0
    -- else
    --     return self._dungeonConfig.societyDungeonBossHp - self:getEnemies()[1]:getHp()
    -- end

    return self:getInfiniteDungeonBossHpReduce()
end

function QBattleManager:getUnionDragonWarFightBossHp()
    return self._unionDragonBossHp or 0
end

function QBattleManager:getUnionDragonWarFightBossHpReduce()
    -- local boss = self:getEnemies()[1]
    -- if boss == nil or self._unionDragonWarBossHp == nil then
    --     return 0
    -- else
    --     return self._unionDragonWarBossHp - self:getEnemies()[1]:getHp()
    -- end
    return self:getInfiniteDungeonBossHpReduce()
end

function QBattleManager:getUnionDragonWarAttack(actorType)
    if self._dungeonConfig.isUnionDragonWar then
        local _unionDragonWarAttack = self._unionDragonWarAttack 
        if _unionDragonWarAttack == nil then
            _unionDragonWarAttack = {}
            local function getValue(buffs, type)
                for _, buff in ipairs(buffs) do
                    if buff.roarType == type then
                        local info = db:getDragonBufferInfo(type, buff.level) or 0
                        return info and info.value or 0
                    end
                end
                return 0
            end
            local dungeonConfig = self._dungeonConfig
            local userBuffs, enemyBuffs = dungeonConfig.unionDragonWarUserBuff or {}, dungeonConfig.unionDragonWarEnemyBuff or {}
            local defense_atk = math.max(1 + getValue(enemyBuffs, 1) - getValue(userBuffs, 2), 0)
            local offense_atk = math.max(1 + getValue(userBuffs, 3) - getValue(enemyBuffs, 4), 0)
            _unionDragonWarAttack[1] = defense_atk
            _unionDragonWarAttack[2] = offense_atk
            self._unionDragonWarAttack = _unionDragonWarAttack
        end
        if actorType == ACTOR_TYPES.NPC then
            return _unionDragonWarAttack[1]
        else
            return _unionDragonWarAttack[2]
        end
    else
        return 1
    end
end

function QBattleManager:isAllRoundFinished()
    if self:isPaused() then
        return false
    end

    if self:isInEditor() then
        local leftRound = app:getBattleRound()
        if leftRound == nil or leftRound == 0 then
            app:clearBattleLogs()
            return true
        elseif leftRound == 1 then
            for _, otherLog in ipairs(app:getBattleLogs()) do
                self._battleLog:mergeStats(otherLog)
            end
            app:setBattleRound(0)
            self:pause()
            local curModalDialog = QBattleDialogAgainstRecord.new({},{})
            return false
        elseif leftRound > 1 then
            app:pushBattleLog(self._battleLog)
            app:setBattleRound(leftRound - 1)
            return true
        end
        return true
    else
        return true
    end
end

function QBattleManager:hasWinOrLose()
    return self._onWin_Time ~= nil or self._onLose_Time ~= nil
end

function QBattleManager:_onNpcCreated(event)
    -- if self._curWave == 2 then
    --     print("QBattleManager:_onNpcCreated"..tostring(app.battleFrame))
    -- end

    local targetPos
    if app.battle:isPVPMode() == false or event.npc:isCopyHero() then
        event.npc:setAnimationScale(app.battle:getTimeGear(), "time_gear")
        local w = BATTLE_AREA.width / global.screen_big_grid_width
        local h = BATTLE_AREA.height / global.screen_big_grid_height
        local halfW = w / 2
        if event.npc:isCopyHero() then halfW = 0 end
        if event.screen_pos ~= nil then
            targetPos = clone(event.screen_pos)
        else
            targetPos = {x = BATTLE_AREA.left + w * event.pos.x - halfW, y = BATTLE_AREA.bottom + h * event.pos.y - h / 2}
        end
    else
        event.npc:setAnimationScale(app.battle:getTimeGear(), "time_gear")
        if event.screen_pos ~= nil then
            targetPos = clone(event.screen_pos)
        else
            targetPos = {x = BATTLE_AREA.left + event.pos.x, y = BATTLE_AREA.bottom + event.pos.y}
        end
    end

    if not event.isNoneSkillSupport then
        app.grid:addActor(event.npc) -- 注意要在view创建后加入app.grid，否则只有model，没有view的情况下，有些状态消息会miss掉
        -- 因为copyhero可以被攻击所以要在战斗区域内
        app.grid:setActorTo(event.npc, targetPos, event.npc:isCopyHero(), event.noreposition or event.screen_pos ~= nil)
    end
end

function QBattleManager:_onWaveEnded(event)
    if app.battle:isPVPMode() == true or app.battle:isInTutorial() == true then
        return
    end

    for _, hero in ipairs(app.battle:getHeroes()) do
        hero:stopMoving()
    end

    for _, ghost in ipairs(self._heroGhosts) do
        if not ghost.actor:isDead() and ghost.clean_new_wave then
            ghost.actor:suicide(ghost.is_no_deadAnimation)
            app.grid:removeActor(ghost.actor)
            self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = ghost.actor, is_hero = true, dead_delay = 0.8})
            self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = ghost.actor, is_hero = true})
        end
    end
    for _, ghost in ipairs(self._enemyGhosts) do
        if not ghost.actor:isDead() and ghost.clean_new_wave then
            ghost.actor:suicide(ghost.is_no_deadAnimation)
            app.grid:removeActor(ghost.actor)
            self:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = ghost.actor, dead_delay = 0.8})
            self:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = ghost.actor})
        end
    end

    if app.battle:isAutoNextWave() then
        self:_onNextWaveClicked()
    end
end

function QBattleManager:_onSetTimeGear(event)
    local time_gear = event.time_gear
    for _, actor in ipairs(self._heroes) do
        actor:setAnimationScale(time_gear, "time_gear")
    end
    for _, actor in ipairs(self._deadHeroes) do
        actor:setAnimationScale(time_gear, "time_gear")
    end
    for _, ghost in ipairs(self._heroGhosts) do
        if ghost.actor.setAnimationScale then
            ghost.actor:setAnimationScale(time_gear, "time_gear")
        end
    end
    for _, actor in ipairs(self._enemies) do
        actor:setAnimationScale(time_gear, "time_gear")
    end
    for _, ghost in ipairs(self._enemyGhosts) do
        if ghost.actor.setAnimationScale then
            ghost.actor:setAnimationScale(time_gear, "time_gear")
        end
    end
    for _, actor in pairs(self._appearActors) do
        actor:setAnimationScale(time_gear, "time_gear")
    end
end

function QBattleManager:_onNextWaveClicked()
    app.battle._executeNextWave = function()
        self:_doNextWaveClick()
    end
    
    -- 当前帧可能未被记录，所以不能直接继续
    self.__pauseRecord = false
end

function QBattleManager:_doNextWaveClick()
    local heroes = {}
    table.mergeForArray(heroes, self._heroes)
    table.mergeForArray(heroes, self._heroGhosts, nil, function(ghost) return ghost.actor end)

    for i, hero in ipairs(heroes) do
        if hero:isDead() == false and not hero:isSupport() then
            app.grid:removeActor(hero)
        end
    end

    -- nzhang: make sure this function is called before view:changToWalkAnimationAndRightDirection() is called
    app.battle:onConfirmNewWave()

    local speedCoefficient = 2.0
    local timeToLeave = 0
    for i, hero in ipairs(heroes) do
        if hero:isDead() == false and not hero:isIdleSupport() then
            hero:insertPropertyValue("movespeed_value", "nextwave", "*", speedCoefficient)
            hero:setDirection(QActor.DIRECTION_RIGHT)

            local moveSpeed = hero:getMoveSpeed()
            local position = hero:getPosition()
            local targetPosition = {x = BATTLE_SCREEN_WIDTH + hero:getRect().size.width + 249, y = position.y}
            local time = (targetPosition.x - position.x) / moveSpeed
            if time > timeToLeave then
                timeToLeave = math.min(time,3)
            end
        end
    end
    timeToLeave = timeToLeave + 0.5
    app.battle:performWithDelay(function()
        app.grid:resetWeight()
        for i, hero in ipairs(heroes) do
            if hero:isDead() == false and not hero:isIdleSupport() then
                app.grid:addActor(hero)
                if not app.battle:isGhost(hero) and not hero:isSupport() then
                    app.grid:setActorTo(hero, hero._enterStartPosition)
                    app.grid:moveActorTo(hero, hero._enterStopPosition)
                else
                    local start_pos = {x = -100, y = hero:getPosition().y}
                    local stop_pos = {x = start_pos.x + BATTLE_SCREEN_WIDTH / 2, y = start_pos.y}
                    app.grid:setActorTo(hero, start_pos)
                    app.grid:moveActorTo(hero, stop_pos)
                end
            end
        end

        app.battle:onStartNewWave()
        
    end, timeToLeave, nil, true, nil, true)

    app.battle:performWithDelay(function()
        for i, hero in ipairs(heroes) do
            if hero:isDead() == false and not hero:isIdleSupport() then
                hero:removePropertyValue("movespeed_value", "nextwave")
            end
        end

    end, timeToLeave + global.hero_enter_time / speedCoefficient - 0.3, nil, true, nil, true)
end

function QBattleManager:replaceActorViewWithCharacterId(actor, characterId)
    local positionX, positionY = actor:getPosition().x, actor:getPosition().y
    actor:willReplaceActorView()
    actor:setReplaceCharacterId(characterId)
    actor:_initRect()
    actor:didReplaceActorView()
    actor:setActorPosition(qccp(positionX, positionY))
    actor:clearLastAttackee()
    app.battle:reloadActorAi(actor)
    app.grid:setActorTo(actor, actor:getPosition(), nil, true)
end

function QBattleManager:replaceActorAIAndPosition(actor, aitype)
    local positionX, positionY = actor:getPosition().x, actor:getPosition().y
    actor:setActorPosition(qccp(positionX, positionY))
    actor:clearLastAttackee()
    app.battle:replaceActorAI(actor, aitype)
    app.grid:setActorTo(actor, actor:getPosition())
end

function QBattleManager:_applyPassiveSkillPropertyForMainHero()
    local pskills = {}
    for _, actor in ipairs(self._heroes) do
        local skills = actor:getPassiveSkills()
        for _, pskill in pairs(skills) do
            if pskill:isAdditionForMain() then
                table.insert(pskills, pskill)
            end
        end
    end
    for _, actor in ipairs(self._supportHeroes) do
        local skills = actor:getPassiveSkills()
        for _, pskill in pairs(skills) do
            if pskill:isAdditionForMain() then
                table.insert(pskills, pskill)
            end
        end
    end
    for _, actor in ipairs(self._supportHeroes2) do
        local skills = actor:getPassiveSkills()
        for _, pskill in pairs(skills) do
            if pskill:isAdditionForMain() then
                table.insert(pskills, pskill)
            end
        end
    end
    for _, actor in ipairs(self._supportHeroes3) do
        local skills = actor:getPassiveSkills()
        for _, pskill in pairs(skills) do
            if pskill:isAdditionForMain() then
                table.insert(pskills, pskill)
            end
        end
    end
    for index, pskill in ipairs(pskills) do
        local prop = pskill._additionEffects
        local name = "AwakenPassiveSkill"..index
        for _, actor in ipairs(self._heroes) do
            actor:addExtendsProp(prop, name)
        end
    end

    -- 神器援助技能
    local godArmPro = {}
    for _, idStr in ipairs(self._heroYZGodArmSkillIds) do
        local idDict = string.split(idStr, ":")
        local skillId, level = tonumber(idDict[1]), tonumber(idDict[2])
        local skillDataConfig = db:getSkillDataByIdAndLevel(skillId, level)
        local skillConfig = db:getSkillByID(skillId)
        if skillDataConfig and skillConfig.addition_for_main == true then
            local count = 1
            while true do
                local key = skillDataConfig["addition_type_"..count]
                local value = skillDataConfig["addition_value_"..count]
                if key == nil then
                    break
                end
                godArmPro[key] = (godArmPro[key] or 0) + value
                count = count + 1
            end
        end
    end
    for _, actor in ipairs(self._heroes) do
        actor:addExtendsProp(godArmPro, "AwakenPassiveSkill_godArm")
    end

    for _, actor in ipairs(self._heroes) do
        actor:_disableHpChangeByPropertyChange()
        actor:_applyStaticActorNumberProperties()
        actor:_enableHpChangeByPropertyChange()
        actor:setFullHp()
    end
end

function QBattleManager:_applyPassiveSkillPropertyForMainRival()
    local pskills = {}
    for _, actor in ipairs(self._enemies) do
        local skills = actor:getPassiveSkills()
        for _, pskill in pairs(skills) do
            if pskill:isAdditionForMain() then
                table.insert(pskills, pskill)
            end
        end
    end
    for _, actor in ipairs(self._supportEnemies) do
        local skills = actor:getPassiveSkills()
        for _, pskill in pairs(skills) do
            if pskill:isAdditionForMain() then
                table.insert(pskills, pskill)
            end
        end
    end
    for _, actor in ipairs(self._supportEnemies2) do
        local skills = actor:getPassiveSkills()
        for _, pskill in pairs(skills) do
            if pskill:isAdditionForMain() then
                table.insert(pskills, pskill)
            end
        end
    end
    for _, actor in ipairs(self._supportEnemies3) do
        local skills = actor:getPassiveSkills()
        for _, pskill in pairs(skills) do
            if pskill:isAdditionForMain() then
                table.insert(pskills, pskill)
            end
        end
    end
    for index, pskill in ipairs(pskills) do
        local prop = pskill._additionEffects
        local name = "AwakenPassiveSkill"..index
        for _, actor in ipairs(self._enemies) do
            actor:addExtendsProp(prop, name)
        end
    end

    -- 神器援助技能
    local godArmPro = {}
    for _, idStr in ipairs(self._enemyYZGodArmSkillIds) do
        local idDict = string.split(idStr, ":")
        local skillId, level = tonumber(idDict[1]), tonumber(idDict[2])
        local skillDataConfig = db:getSkillDataByIdAndLevel(skillId, level)
        local skillConfig = db:getSkillByID(skillId)
        if skillDataConfig and skillConfig.addition_for_main == true then
            local count = 1
            while true do
                local key = skillDataConfig["addition_type_"..count]
                local value = skillDataConfig["addition_value_"..count]
                if key == nil then
                    break
                end
                godArmPro[key] = (godArmPro[key] or 0) + value
                count = count + 1
            end
        end
    end
    for _, actor in ipairs(self._enemies) do
        actor:addExtendsProp(godArmPro, "AwakenPassiveSkill_godArm")
    end

    for _, actor in ipairs(self._enemies) do
        actor:_disableHpChangeByPropertyChange()
        actor:_applyStaticActorNumberProperties()
        actor:_enableHpChangeByPropertyChange()
        actor:setFullHp()
    end
end

function QBattleManager:getSunWarCurrentWaveTargetOrder()
    if not IsServerSide and not self:isInReplay() then
        local targetOrder = remote.sunWar:getCurrentWaveTargetOrder() or {}
        self._dungeonConfig.sunwarTargetOrder = targetOrder
        return self._dungeonConfig.sunwarTargetOrder
    else
        return self._dungeonConfig.sunwarTargetOrder
    end
end

function QBattleManager:getGloryCurrentFloorTargetOrder()
    if not IsServerSide and not self:isInReplay() then
        local targetOrder = remote.tower:getCurrentFloorTargetOrder() or {}
        self._dungeonConfig.gloryTargetOrder = targetOrder
        return self._dungeonConfig.gloryTargetOrder
    else
        return self._dungeonConfig.gloryTargetOrder
    end
end

function QBattleManager:isInSocietyDungeon()
    return self._dungeonConfig.isSocietyDungeon or false
end

function QBattleManager:getSocietyBossHp()
    return self._societyBossHp or 0
end

function QBattleManager:_applyBuffForSocietyDungeonBoss(actor, config)
    actor:addExtendsProp(config, "SocietyDungeonBossBuff")
    actor:_disableHpChangeByPropertyChange()
    actor:_applyStaticActorNumberProperties()
    actor:_enableHpChangeByPropertyChange()
end

function QBattleManager:visibleBackgroundLayer(visible, actor)
    if visible then
        self._showActor = actor
    else
        self._showActor = nil
    end
end

function QBattleManager:getShowActor()
    return self._showActor
end

function QBattleManager:_checkWinOrLose_PVPMultipleWave()
    if self._pauseBetweenPVPWaves then
        return false
    end

    if self._curPVPWave == 0 then
        self._curPVPWave = 1
        return false
    else
        local isOverTime = self._timeLeft < 0
        local isHeroesAllDead = true
        for _, hero in ipairs(self._heroes) do
            if not hero:isSupport() and not hero:isDead() then
                isHeroesAllDead = false
                break
            end
        end
        local isEnemiesAllDead = true
        for _, enemy in ipairs(self._enemies) do
            if not enemy:isSupport() and not enemy:isDead() then
                isEnemiesAllDead = false
                break
            end
        end
        local waveEnd = isOverTime or isHeroesAllDead or isEnemiesAllDead
        local isWin = not isOverTime and isEnemiesAllDead and not isHeroesAllDead
        if waveEnd then
            self._pvpMultipleWaveLastWaveIsWin = isWin
            if isWin then
                self._pvpMultipleWaveHeroScore = self._pvpMultipleWaveHeroScore + 1
                table.insert(self._pvpMultipleWaveHeroScoreList, true)
            else
                self._pvpMultipleWaveEnemyScore = self._pvpMultipleWaveEnemyScore + 1
                table.insert(self._pvpMultipleWaveHeroScoreList, false)
            end
            while self._aiDirector:getChildrenCount() > 0 do
                self._aiDirector:removeChild(self._aiDirector:getChildAtIndex(1))
            end
            if self._curPVPWave < self._pvpWaveCount 
                and not (self._pvpMultipleWaveHeroScore > self._pvpWaveCount / 2)
                and not (self._pvpMultipleWaveEnemyScore > self._pvpWaveCount / 2)
            then
                self._curPVPWave = self._curPVPWave + 1
                -- cancel skills, remove buffs, remove traps, remove bullets and lasers
                for _, hero in ipairs(self._heroes) do
                    hero:cancelAllSkills()
                    hero:removeAllBuff()
                    hero:removeBattleFrameListener()
                end
                for _, hero in ipairs(self._heroGhosts) do
                    hero.actor:cancelAllSkills()
                    hero.actor:removeAllBuff()
                    hero.actor:removeBattleFrameListener()
                end
                for _, enemy in ipairs(self._enemies) do
                    enemy:cancelAllSkills()
                    enemy:removeAllBuff()
                    enemy:removeBattleFrameListener()
                end
                for _, enemy in ipairs(self._enemyGhosts) do
                    enemy.actor:cancelAllSkills()
                    enemy.actor:removeAllBuff()
                    enemy.actor:removeBattleFrameListener()
                end
                for _, trapDirector in ipairs(self._trapDirectors) do
                    if trapDirector:isCompleted() == false then
                        trapDirector:cancel()
                    end
                end
                self._trapDirectors = {}
                for _, bullet in ipairs(self._bullets) do
                    if bullet:isFinished() == false then
                        bullet:cancel()
                    end
                end
                self._bullets = {}
                for _, laser in ipairs(self._lasers) do
                    if laser:isFinished() == false then
                        laser:cancel()
                    end
                end
                self._lasers = {}
                for _, ufo in ipairs(self._ufos) do
                    if ufo:isEnded() == false then
                        ufo:forceEnd()
                    end
                end
                self._ufos = {}
                local winners = isWin and self._heroes or self._enemies
                for _, actor in ipairs(winners) do
                    if not actor:isDead() then
                        actor:onVictory()
                    end
                end
                if not IsServerSide then
                    app.scene:removeAllEffectViews()
                end
                self._pauseBetweenPVPWaves = true
                self:performWithDelay(function ()
                    self:performWithDelay(function()
                        self._pauseBetweenPVPWaves = false
                        self:_preparePVPWave()
                    end, 0, nil, true, true)
                    if not self:isInReplay() or self:isInQuick() then
                        self:pause()
                        local event = {name = QBattleManager.PVP_WAVE_END, isWin = isWin , callback = function()
                            self:resume()
                        end}
                        self:dispatchEvent(event)
                    end
                end, global.victory_animation_duration, nil, true)
            else
                self._curPVPWave = self._curPVPWave + 1
                if self._pvpMultipleWaveHeroScore > self._pvpMultipleWaveEnemyScore then
                    self:_onWin()
                    return true
                else
                    self:_onLose()
                    return true
                end
            end
        end
        return false
    end
end

function QBattleManager:_preparePVPWave()
    if not IsServerSide then
        app.scene:_removeLastPVPWave()
    end

    local wave = self._curPVPWave
    assert(wave > 1 and wave <= self._pvpWaveCount)
    local left = BATTLE_AREA.left
    local bottom = BATTLE_AREA.bottom
    local width = BATTLE_AREA.width
    local height = BATTLE_AREA.height
    -- 移除老魂师
    for _, hero in ipairs(self._heroes) do
        app.grid:removeActor(hero)
    end
    for _, enemy in ipairs(self._enemies) do
        app.grid:removeActor(enemy)
    end
    -- 魂师入场起始点
    local stopPosition = clone(ARENA_HERO_POS)
    for _, position in ipairs(stopPosition) do
        position[1] = left + position[1] + width / 2
        position[2] = bottom + position[2] + height / 2
    end
    -- prepare heroes
    local heroes = {}
    local heroPets = {}
    local heroesWave = self["_heroesWave"..wave]
    for _, hero in ipairs(heroesWave) do
        table.insert(heroes, hero)
        hero._debugWave = wave
    end
    local heroCount = table.nums(heroes)
    for i, hero in ipairs(heroes) do
        local index = heroCount - i + 1
        hero._enterStartPosition = {x = stopPosition[index][1] - width / 2, y = stopPosition[index][2]}
        hero._enterStopPosition = {x = stopPosition[index][1], y = stopPosition[index][2]}
        app.grid:addActor(hero) -- 注意要在view创建后加入app.grid，否则只有model，没有view的情况下，有些状态消息会miss掉
        app.grid:setActorTo(hero, hero._enterStartPosition)
        app.grid:moveActorTo(hero, hero._enterStopPosition)
        hero.ai = self._aiDirector:createBehaviorTree(hero:getAIType(), hero)
        self._aiDirector:addBehaviorTree(hero.ai)
        -- 宠物出场
        local pet = hero:summonHunterPet()
        if pet then
            local startpos = clone(hero._enterStartPosition)
            local stoppos = clone(hero._enterStopPosition)
            startpos.x = startpos.x - 125
            stoppos.x = stoppos.x - 125
            app.grid:addActor(pet)
            app.grid:setActorTo(pet, startpos)
            app.grid:moveActorTo(pet, stoppos)
            table.insert(heroPets, pet)
            pet._debugWave = wave
        end
    end
    table.mergeForArray(heroes, heroPets)
    self._heroes = heroes
    -- all passive skills and buffs
    self:_applyPassiveSkillPropertyForMainHero()
    self:_applyDungeonBuffs()
    self:_applyRebelFightHeroAttackMultiplier(self._dungeonConfig.rebelAttackPercent)
    self:_applyRebelFightHeroAttackMultiplier(self._dungeonConfig.worldBossAttackPercent)
    self:_applyNotRecommendDebuff()
    self:_applyRecommendBuff()
    self:_applyLostCountBuff()
    self:_applyEasyBuff()
    self:_applySunwarEasyBuff()
    -- self:_applySunwarHardDebuff()
    -- 副本以及非海神岛首次enter_cd
    if not self:isInSunwell() and not self:isInTutorial() then
        for _, hero in ipairs(self._heroes) do
            for _, skill in pairs(hero:getSkills()) do
                if skill:get("enter_cd") ~= nil then
                    skill:coolDown()
                end
            end
        end
    end
    -- 敌人入场起始点
    local stopPosition = clone(ARENA_HERO_POS)
    for _, position in ipairs(stopPosition) do
        position[1] = BATTLE_AREA.left + BATTLE_AREA.width - (position[1] + BATTLE_AREA.width / 2)
        position[2] = BATTLE_AREA.bottom + position[2] + BATTLE_AREA.height / 2
    end
    -- prepare enemies
    local enemies = {}
    local enemyPets = {}
    local enemiesWave = self["_enemiesWave"..wave]
    for _, enemy in ipairs(enemiesWave) do
        table.insert(enemies, enemy)
        enemy._debugWave = wave
    end
    local heroCount = table.nums(enemies)
    for i, enemy in ipairs(enemies) do
        local index = heroCount - i + 1
        -- nzhang: 2015-10-24，太阳井有可能会生成5个敌人，防止出错
        index = math.clamp(index, 1, 4)
        enemy._enterStartPosition = {x = stopPosition[index][1] + BATTLE_AREA.width / 2, y = stopPosition[index][2]}
        enemy._enterStopPosition = {x = stopPosition[index][1], y = stopPosition[index][2]}
        app.grid:addActor(enemy) -- 注意要在view创建后加入app.grid，否则只有model，没有view的情况下，有些状态消息会miss掉
        app.grid:setActorTo(enemy, enemy._enterStartPosition)
        app.grid:moveActorTo(enemy, enemy._enterStopPosition)
        enemy.ai = self._aiDirector:createBehaviorTree(enemy:getAIType(), enemy)
        self._aiDirector:addBehaviorTree(enemy.ai)
        -- 宠物出场
        local pet = enemy:summonHunterPet()
        if pet then
            local startpos = clone(enemy._enterStartPosition)
            local stoppos = clone(enemy._enterStopPosition)
            startpos.x = startpos.x + 125
            stoppos.x = stoppos.x + 125
            app.grid:addActor(pet)
            app.grid:setActorTo(pet, startpos)
            app.grid:moveActorTo(pet, stoppos)
            table.insert(enemyPets, pet)
            pet._debugWave = wave
        end
    end
    table.mergeForArray(enemies, enemyPets)
    self._enemies = enemies
    -- all enemies passive skills and buffs
    self:_applyPassiveSkillPropertyForMainRival()
    for _, enemy in ipairs(self._enemies) do
        self:_applySunwarHardDebuffForEnemy(enemy)
    end
    -- enemy enter_cd
    if (not self:isPVPMode() or self:isInArena()) and not self:isInTutorial() then
        for _, hero in ipairs(self._enemies) do
            for _, skill in pairs(hero:getSkills()) do
                if skill:get("enter_cd") ~= nil then
                    skill:coolDown()
                end
            end
        end
    end

    -- time rewind
    self._timeLeft = self:getDungeonDuration()
    self._battleTime = 0
    self._battleTimeForEffect = 0
    self._battleTimeNoTimeGear = 0

    -- enemy views preparation
    if not IsServerSide then
        app.scene:_preparePVPWave()
    end

    self._startCountDown = false
    self._aiDirector:pause()
    local enter_time = 2.2
    self:performWithDelay(function()
        if self._aiDirector then
            self._startCountDown = true
            self._aiDirector:resume()
        end
    end, enter_time)
end

function QBattleManager:getPVPMultipleWaveScore()
    return self._pvpMultipleWaveHeroScore, self._pvpMultipleWaveEnemyScore
end

function QBattleManager:getPVPMultipleWaveScoreList()
    if self:isPVPMultipleWaveNew() then
        return self._dungeonConfig._newPvpMultipleScoreInfo and self._dungeonConfig._newPvpMultipleScoreInfo.scoreList
    end
    return self._pvpMultipleWaveHeroScoreList
end

function QBattleManager:getPVPMultipleWaveLastWaveIsWin()
    return self._pvpMultipleWaveLastWaveIsWin
end

function QBattleManager:setPVPMultipleWaveScore(heroScore, enemyScore)
    self._pvpMultipleWaveHeroScore = heroScore
    self._pvpMultipleWaveEnemyScore = enemyScore
end

function QBattleManager:setPVPMultipleWaveScoreList(scoreList)
    self._pvpMultipleWaveHeroScoreList = scoreList
end

function QBattleManager:setPVPMultipleWaveLastWaveIsWin(isWin)
    self._pvpMultipleWaveLastWaveIsWin = isWin
end

function QBattleManager:_removeBulletsAndLasers()
    -- remove bullet
    for _, bullet in ipairs(self._bullets) do
        if bullet:isFinished() == false then
            bullet:cancel()
        end
    end
    self._bullets = {}
    -- remove laser
    for _, laser in ipairs(self._lasers) do
        if laser:isFinished() == false then
            laser:cancel()
        end
    end
    self._lasers = {}
    -- remove ufo
    for _, ufo in ipairs(self._ufos) do
        if ufo:isEnded() == false then
            ufo:forceEnd()
        end
    end
end

function QBattleManager:getHeroesHpLeft(isWin)
    local selfHeros = {}
    local liveHeroes = self:getHeroes()
    local deadHeroes = self:getDeadHeroes()
    local heroes = {}
    table.mergeForArray(heroes, liveHeroes, function(actor) return actor ~= self:getSupportSkillHero() and actor ~= self:getSupportSkillHero2() and actor ~= self:getSupportSkillHero3() end)
    table.mergeForArray(heroes, deadHeroes, function(actor) return actor ~= self:getSupportSkillHero() and actor ~= self:getSupportSkillHero2() and actor ~= self:getSupportSkillHero3() end)
    for _, hero in ipairs(heroes) do
        if hero:isDead() or (not isWin and not hero:isSupportHero()) then
            table.insert(selfHeros, {actorId = hero:getActorID(), currHp = -1, currMp = -1})
        else
            table.insert(selfHeros, {actorId = hero:getActorID(), currHp = hero:getMaxHp(), currMp = math.max(hero:getRageTotal()/2, 1)})
        end
    end
    return selfHeros
end

function QBattleManager:getHeroLeftHp(actorId)
    local heroesHp = self._dungeonConfig.heroesHp
    if heroesHp then
        for _, obj in ipairs(heroesHp) do
            if obj.actorId == actorId then
                if obj.currHp == -1 then -- dead
                    return 0, 0
                else -- left hp
                    return obj.currHp, obj.currMp
                end
            end
        end
    end
end

function QBattleManager:getMonstersHpLeft()
    local result = {}
    for i, monster in ipairs(self._monsters) do
        if monster.wave > 0 then
            local obj = {}
            obj.actorId = i
            if not monster.created then
                obj.currHp = -2
            elseif monster.npc == nil or monster.npc:isDead() then
                obj.currHp = -1
            else
                obj.currHp = math.max(monster.npc:getHp(), 1)
            end
            result[#result + 1] = obj
        end
    end
    return result
end

function QBattleManager:getMonsterLeftHp(i)
    local monstersHp = self._dungeonConfig.monstersHp
    if monstersHp then
        for _, obj in ipairs(monstersHp) do
            if obj.actorId == i then
                if obj.currHp == -2 then -- not created yet
                    return
                elseif obj.currHp == -1 then -- dead
                    return 0
                else -- left hp
                    return obj.currHp
                end
            end
        end
    end
end

function QBattleManager:isAllowControl()
    local allow = true
    local warning = nil
    if self:isInReplay() and not self:isInQuick() then
        warning = global.replay_warning
        allow = false
    elseif self:isPVPMode() then
        if self:isInArena() then
            if not self:isArenaAllowControl() then
                if self:isInGlory() then
                    warning = global.glory_warning
                    allow = false
                elseif self:isInGloryArena() then
                    warning = global.gloryarena_warning
                    allow = false
                elseif self:isInStormArena() then
                    warning = global.stormarena_warning
                    allow = false
                elseif self:isInMaritime() then
                    warning = global.maritime_warning
                    allow = false
                else
                    warning = global.arena_warning
                    allow = false
                end
            end
        elseif self:isInSunwell() then
            if not self:isSunwellAllowControl() then
                warning = global.sunwell_warning
                allow = false
            end
        elseif self:isInPlunder() then
            warning = global.plunder_warning
            allow = false
        elseif self:isInSilverMine() then
            warning = global.silvermine_warning
            allow = false
        end
    end
    return allow, warning
end

function QBattleManager:getTeamSkillProperty(actor, property_name)
    local teamSkillProperty
    if actor:getType() == ACTOR_TYPES.NPC then
        teamSkillProperty = self._enemyTeamSkillProperty
    else
        teamSkillProperty = self._heroTeamSkillProperty
    end
    return teamSkillProperty[property_name] or 0
end

-- 模块相关伤害系数
function QBattleManager:addDamage(damage, attacker)
    if self:isInUnionDragonWar() then
        if damage > 0 and attacker and attacker:getType() ~= ACTOR_TYPES.NPC then
            local unionDragonWarDamageCoefficient = self._unionDragonWarDamageCoefficient
            if unionDragonWarDamageCoefficient == nil then
                unionDragonWarDamageCoefficient = 1
                if self._dungeonConfig.unionDragonWarHolyBuffer then
                    unionDragonWarDamageCoefficient = unionDragonWarDamageCoefficient * db:getConfigurationValue("sociaty_dragon_holy_bonous") or 1
                end
                local bufferId = self._dungeonConfig.unionDragonWarWinStreakNum
                if bufferId and bufferId > 1 then
                    local configuration = db:getConfiguration()
                    local index = 2
                    while configuration["union_dragon_war_victory_time_"..index] do
                        if bufferId == index then
                            index = index + 1 
                            break
                        end
                        index = index + 1 
                    end
                    index = index - 1 
                    unionDragonWarDamageCoefficient = unionDragonWarDamageCoefficient * configuration["union_dragon_war_victory_time_"..index].value
                end
                self._unionDragonWarDamageCoefficient = unionDragonWarDamageCoefficient
            end
            damage = damage * unionDragonWarDamageCoefficient
        end
    end
    return damage
end

--战斗结束，让符合条件的npc狗带
function QBattleManager:_npcGoDie()
    if not self._monsters then return end
    for k,v in pairs(self._monsters) do
        if v.dead_battle_end then
            local actor = v.npc
            if actor and (not actor:isDead()) then
                actor:suicide()
            end
            if v.npc_summoned then --召唤出来的怪物也要自杀
                for id,actor in pairs(v.npc_summoned) do
                    if not actor.npc:isDead() then
                        actor.npc:suicide()
                    end
                end
            end
        end
    end
end

function QBattleManager:setKillEnemyCount(count)
    if not self._dungeonConfig.killEnemyCount then
        self._dungeonConfig.killEnemyCount = 0
    end
    self._dungeonConfig.killEnemyCount = self._dungeonConfig.killEnemyCount + count
end

function QBattleManager:getKillEnemyCount()
    return self._dungeonConfig.killEnemyCount
end

function QBattleManager:setMinimumHp(hp)
    if not self._dungeonConfig.bossMinimumHp or self._dungeonConfig.bossMinimumHp == -1000 then
        self._dungeonConfig.bossMinimumHp = hp
    else
        if self._dungeonConfig.bossMinimumHp > hp then
            self._dungeonConfig.bossMinimumHp = hp
        end
    end
end

function QBattleManager:getMinimumHp()
    return self._dungeonConfig.bossMinimumHp or -1000
end

function QBattleManager:_resetDailyBossAwards()
    if self._dungeonConfig.dailyAwards then
        for _, v in ipairs(self._dungeonConfig.dailyAwards) do
            for k, award in ipairs(v) do
                award.droped = false
            end
        end
    end
end

function QBattleManager:setTimePauseInStoryLine(isInStoryLine)
    self._isTimePauseInStoryLine = isInStoryLine
end

function QBattleManager:getMyEnemiesSupportHero(actor)
    local result = {}
    local actorType = actor:getType()
    local enemies = nil
    local ghosts = nil
    if not actor:isNeutral() then
        if actorType == ACTOR_TYPES.HERO or actorType == ACTOR_TYPES.HERO_NPC then
            table.mergeForArray(result,self:getSupportEnemies())
            table.mergeForArray(result,self:getSupportEnemies2())
            table.mergeForArray(result,self:getSupportEnemies3())
        else
            table.mergeForArray(result,self:getSupportHeroes())
            table.mergeForArray(result,self:getSupportHeroes2())
            table.mergeForArray(result,self:getSupportHeroes3())
        end
    else
        table.mergeForArray(result,self:getSupportHeroes())
        table.mergeForArray(result,self:getSupportHeroes2())
        table.mergeForArray(result,self:getSupportHeroes3())
    end

    return result
end

function QBattleManager:_createHero(heroInfo, additionalInfos, isSupport, isHero, isInStory, isInTotemChallenge, additional_skills, extraProp)
    local hero = app:createHeroWithoutCache(heroInfo, nil, additionalInfos, true, isSupport, isInStory, isInTotemChallenge, additional_skills, extraProp)
    if isHero then
        self:_applySunWarBuffs(hero)
        self:_applySparfieldLengendaryBuff(hero)
    end
    return hero
end

function QBattleManager:isPVEMultipleWave()
    return self._dungeonConfig.isPveMultiple or false
end

function QBattleManager:getPVEMultipleCurWave()
    return self._pveMultipleWave
end

function QBattleManager:isPVPMultipleWaveNew()
    return self._dungeonConfig.isPvpMultipleNew or false
end

function QBattleManager:isPVP2TeamBattle()
    return self._dungeonConfig.isPVP2TeamBattle or false
end

function QBattleManager:getPVPMultipleNewCurWave()
    return self._pvpMultipleWave
end

function QBattleManager:getPVPMultipleWaveNewScoreInfo()
    return self._dungeonConfig._newPvpMultipleScoreInfo
end

function QBattleManager:_checkWinOrLoseDragon()
    local isHeroesAllDead = true
    for _, hero in ipairs(self._heroes) do
        if not hero:isSupport() and not hero:isDead() then
            isHeroesAllDead = false
            break
        end
    end
    if isHeroesAllDead then
        self:_onLose()
        return true
    end
    if self._timeLeft <= 0 then
        self:_onWin({isAllEnemyDead = true})
        return true
    end
    return false
end

function QBattleManager:getHeroSkinById(heroId)
    return self._hero_skin_infos[heroId]
end

function QBattleManager:getEnemySkinById(heroId)
    return self._enemy_skin_infos[heroId]
end

function QBattleManager:getUnionDragonWarWeatherId()
    return self._dungeonConfig.unionDragonWarWeatherId
end

function QBattleManager:getUnionDragonWarBossId()
    return self._dungeonConfig.unionDragonWarBossId
end

function QBattleManager:isSociatyWar()
    return self._dungeonConfig.is_sociaty_war
end

function QBattleManager:_checkWinOrLoseSociatyWar()
    local isHeroesAllDead = true
    for _, hero in ipairs(self._heroes) do
        if not hero:isSupport() and not hero:isDead() then
            isHeroesAllDead = false
            break
        end
    end
    local isEnemiesAllDead = true
    for _, enemy in ipairs(self._enemies) do
        if not enemy:isSupport() and not enemy:isDead() then
            isEnemiesAllDead = false
            break
        end
    end

    if isHeroesAllDead and isEnemiesAllDead then --同归于尽判断战斗力
        if self._dungeonConfig.pvpMultipleTeams[self:getPVPMultipleNewCurWave()].hero.force < self._dungeonConfig.pvpMultipleTeams[self:getPVPMultipleNewCurWave()].enemy.force then
            self:_onLose()
        else
            self:_onWin()
        end
        return true
    end

    if isHeroesAllDead then
        self:_onLose()
        return true
    end

    if isEnemiesAllDead then
        self:_onWin{isAllEnemyDead = true}
        return true
    end

    if self:getTimeLeft() < 0.00001 then

        local hp, max_hp = 0, 0
        for _, hero in ipairs(self._heroes) do
            if not hero:isPet() and not hero:isGhost() then
                hp = hp + hero:getHp()
                max_hp = max_hp + hero:getMaxHp()
            end
        end
        for _, hero in ipairs(self._deadHeroes) do
            if not hero:isPet() and not hero:isGhost() then
                hp = hp + hero:getHp()
                max_hp = max_hp + hero:getMaxHp()
            end
        end

        local heroHpPercent = hp/max_hp
        for _, hero in ipairs(self._enemies) do
            if not hero:isPet() and not hero:isGhost() then
                hp = hp + hero:getHp()
                max_hp = max_hp + hero:getMaxHp()
            end
        end
        for _, hero in ipairs(self._deadEnemies) do
            if not hero:isPet() and not hero:isGhost() then
                hp = hp + hero:getHp()
                max_hp = max_hp + hero:getMaxHp()
            end
        end
        local enemyHpPercent = hp/max_hp

        if heroHpPercent > enemyHpPercent then
            self:_onWin()
        elseif heroHpPercent < enemyHpPercent then
            self:_onLose()
        else
            if self._dungeonConfig.pvpMultipleTeams[self:getPVPMultipleNewCurWave()].hero.force < self._dungeonConfig.pvpMultipleTeams[self:getPVPMultipleNewCurWave()].enemy.force then
                self:_onLose()
            else
                self:_onWin()
            end
        end

        return true
    end
    return false
end

function QBattleManager:isInConsortiaWar()
    return self._dungeonConfig.isConsortiaWar or false
end

function QBattleManager:isInSotoTeam()
    return self._dungeonConfig.isSotoTeam or false
end

function QBattleManager:_prepareHeroSoulSpirit()
    if self:isPVPMultipleWave() or self:isInDragon() or
        not self._dungeonConfig.userSoulSpirits then
        return
    end

    self._userSoulSpritsList = {}

    if self._dungeonConfig.userSoulSpirits then
        for i = #self._dungeonConfig.userSoulSpirits, 1, -1 do
            local soulSpiritInfo = self._dungeonConfig.userSoulSpirits[i]
            if soulSpiritInfo ~= nil and soulSpiritInfo.id and tonumber(soulSpiritInfo.id) > 0 then
                local soulSpirit = QSoulSpiritModel.new(soulSpiritInfo, ACTOR_TYPES.HERO_NPC, true)
                soulSpirit._npc_skill = soulSpirit:getNPCSkillId()
                soulSpirit:setIsGhost(true)
                soulSpirit:resetStateForBattle()
                self._actorsByUDID[soulSpirit:getUDID()] = soulSpirit

                if not self:isInSunwell() and not self:isInTutorial() then
                    for _, skill in pairs(soulSpirit:getActiveSkills()) do
                        if skill:get("enter_cd") ~= nil then
                            skill:coolDown()
                        end
                    end
                end

                local appearSkill = soulSpirit:getAppearSkillId()

                local stoppos, startpos
                if #self._dungeonConfig.userSoulSpirits > 1 then
                    local yIndex = i == 1 and 3 or 2 --默认只有两个魂灵的情况，如果有多于两个魂灵则代码需要修改
                    stoppos = {x = BATTLE_AREA.left + BATTLE_AREA.width / 2 + HERO_POS[4][1] - 50,
                        y = BATTLE_AREA.bottom + BATTLE_AREA.height / 2 + HERO_POS[yIndex][2]}
                    startpos = {x = stoppos.x - BATTLE_AREA.width / 2 - 50, y = stoppos.y}
                    self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = soulSpirit, screen_pos = startpos, is_hero = true,
                        appear_skill = appearSkill})
                else
                    stoppos = {x = BATTLE_AREA.left + BATTLE_AREA.width / 2 + (HERO_POS[1][1] + HERO_POS[4][1]) / 2,
                        y = BATTLE_AREA.bottom + BATTLE_AREA.height / 2 + HERO_POS[1][2]}
                    startpos = {x = stoppos.x - BATTLE_AREA.width / 2 - 50, y = stoppos.y}
                    self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = soulSpirit, screen_pos = startpos, is_hero = true,
                        appear_skill = appearSkill})
                end

                if appearSkill ~= nil then
                    soulSpirit:setDirection(QActor.DIRECTION_RIGHT)
                    soulSpirit:attack(soulSpirit:getSkillWithId(appearSkill), nil, nil, true)
                end

                soulSpirit._enterStartPosition = startpos
                soulSpirit._enterStopPosition = stoppos
                app.grid:addActor(soulSpirit)
                app.grid:setActorTo(soulSpirit, soulSpirit._enterStartPosition)
                app.grid:moveActorTo(soulSpirit, soulSpirit._enterStopPosition)
                soulSpirit.ai = self._aiDirector:createBehaviorTree(soulSpirit:getAIType() or "dps", soulSpirit)
                self._aiDirector:addBehaviorTree(soulSpirit.ai)
                table.insert(self._heroGhosts, {actor = soulSpirit, ai = soulSpirit.ai, life_span = 600, life_countdown = 600, summoner = soulSpirit})
                table.insert(self._userSoulSpritsList, soulSpirit)
                -- 添加精灵属性
                -- to do
                -- self:_applyAttributesForHero(soulSpirit, self._heroes)
                soulSpirit:getFirstManualSkill():coolDown(nil, true)
                soulSpirit:reportDoDHP(0, soulSpirit)

                if self:isInSunwell() and soulSpiritInfo.currMp and soulSpiritInfo.currMp ~= -1 then
                    soulSpirit:setRage(soulSpiritInfo.currMp or 0)
                end
            end
        end
    end
end

function QBattleManager:_prepareEnemySoulSpirit()
    if self:isPVPMultipleWave() or self:isInDragon() or
        not self._dungeonConfig.enemySoulSpirits then
        return
    end

    self._enemySoulSpritsList = {}

    if self._dungeonConfig.enemySoulSpirits then
        for i = #self._dungeonConfig.enemySoulSpirits, 1, -1 do
            local soulSpiritInfo = self._dungeonConfig.enemySoulSpirits[i]
            if soulSpiritInfo ~= nil and soulSpiritInfo.id and tonumber(soulSpiritInfo.id) > 0 then
                local soulSpirit = QSoulSpiritModel.new(soulSpiritInfo, ACTOR_TYPES.NPC, true)
                soulSpirit._npc_skill = soulSpirit:getNPCSkillId()
                soulSpirit:setIsGhost(true)
                soulSpirit:resetStateForBattle()
                self._actorsByUDID[soulSpirit:getUDID()] = soulSpirit

                if not self:isInSunwell() and not self:isInTutorial() then
                    for _, skill in pairs(soulSpirit:getActiveSkills()) do
                        if skill:get("enter_cd") ~= nil then
                            skill:coolDown()
                        end
                    end
                end
                
                local appearSkill = soulSpirit:getAppearSkillId()

                local stoppos, startpos
                if #self._dungeonConfig.enemySoulSpirits > 1 then
                    local yIndex = i == 1 and 3 or 2
                    stoppos = {x = BATTLE_AREA.left + BATTLE_AREA.width / 2 - HERO_POS[4][1] + 50,
                        y = BATTLE_AREA.bottom + BATTLE_AREA.height / 2 + HERO_POS[yIndex][2]}
                    startpos = {x = stoppos.x + BATTLE_AREA.width / 2 + 50, y = stoppos.y}
                    self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = soulSpirit, screen_pos = startpos,
                        is_hero = false, appear_skill = appearSkill})
                else
                    stoppos = {x = BATTLE_AREA.left + BATTLE_AREA.width / 2 - (HERO_POS[1][1] + HERO_POS[4][1]) / 2,
                        y = BATTLE_AREA.bottom + BATTLE_AREA.height / 2 + HERO_POS[1][2]}
                    startpos = {x = stoppos.x + BATTLE_AREA.width / 2 + 50, y = stoppos.y}
                    self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = soulSpirit, screen_pos = startpos,
                        is_hero = false, appear_skill = appearSkill})
                end

                if appearSkill ~= nil then
                    soulSpirit:setDirection(QActor.DIRECTION_LEFT)
                    soulSpirit:attack(soulSpirit:getSkillWithId(appearSkill), nil, nil, true)
                end

                soulSpirit._enterStartPosition = startpos
                soulSpirit._enterStopPosition = stoppos
                app.grid:addActor(soulSpirit)
                app.grid:setActorTo(soulSpirit, soulSpirit._enterStartPosition)
                app.grid:moveActorTo(soulSpirit, soulSpirit._enterStopPosition)
                soulSpirit.ai = self._aiDirector:createBehaviorTree(soulSpirit:getAIType() or "dps", soulSpirit)
                self._aiDirector:addBehaviorTree(soulSpirit.ai)
                table.insert(self._enemyGhosts, {actor = soulSpirit, ai = soulSpirit.ai, life_span = 600, life_countdown = 600, summoner = soulSpirit})
                table.insert(self._enemySoulSpritsList, soulSpirit)
                -- 添加精灵属性
                -- to do
                -- self:_applyAttributesForHero(soulSpirit, self._enemies)
                if self:isPVPMode() then
                    soulSpirit:setForceAuto(true)
                end
                soulSpirit:getFirstManualSkill():coolDown(nil, true)
                soulSpirit:reportDoDHP(0, soulSpirit)

                if self:isInSunwell() and soulSpiritInfo.currMp and soulSpiritInfo.currMp ~= -1 then
                    soulSpirit:setRage(soulSpiritInfo.currMp or 0)
                end
            end
        end
    end
end

function QBattleManager:getTeamSoulSpirit(actor)
    if actor == nil then return end
    local actorType = actor:getType()
    if actorType == ACTOR_TYPES.HERO or actorType == ACTOR_TYPES.HERO_NPC then
        return self:getSoulSpiritHero()
    else
        return self:getSoulSpiritEnemy()
    end
end

function QBattleManager:getSoulSpiritHero()
    return self._userSoulSpritsList
end

function QBattleManager:getSoulSpiritEnemy()
    return self._enemySoulSpritsList
end

function QBattleManager:isEnemyCanBeIgnore(enemy)
    for _, item in ipairs(self._monsters) do
        if item.created and item.npc and item.npc == enemy then
            if item.can_be_ignored or item.show_battlelog or item.is_neutral or item.dead_battle_end then
                return true
            end
        end
    end
end

function QBattleManager:isSotoTeam()
    return self._dungeonConfig.isSotoTeam
end

-- 云顶之战传承
function QBattleManager:isSotoTeamInherit()
    return self._dungeonConfig.isSotoTeamInherit
end

-- 云顶之战均衡
function QBattleManager:isSotoTeamEquilibrium()
    return self._dungeonConfig.isSotoTeamEquilibrium
end

-- 训练关卡
function QBattleManager:isCollegeTrain()
    return self._dungeonConfig.isCollegeTrain
end

-- 大师赛
function QBattleManager:isMockBattle()
    return self._dungeonConfig.isMockBattle
end

-- 圣柱挑战
function QBattleManager:isTotemChallenge()
    return self._dungeonConfig.isTotemChallenge
end

-- 升灵台
function QBattleManager:isSoulTower()
    return self._dungeonConfig.isSoulTower
end

-- 破碎位面
function QBattleManager:isMazeExplore()
    return self._dungeonConfig.isMazeExplore
end

function QBattleManager:getCandidateHeroes()
    return self._candidateHeroes
end

function QBattleManager:getCandidateEnemies()
    return self._candidateEnemies
end

function QBattleManager:isBossHpInfiniteDungeon()
    return self._dungeonConfig.boss_hp_infinite
end


function QBattleManager:getInfiniteDungeonBossHpReduce()
    local currentHurt = 0

    local log = self:getBattleLog()
    for _, hero in pairs(log.heroStats) do
        currentHurt = currentHurt + (hero.damage or 0)
    end

    return currentHurt
end

function QBattleManager:onCandidateHeroEnter(hero)
    if self._ended == true or self._paused == true or self._aiDirector == nil then return end
    assert(not hero:isDead(), "canditate hero error, hero is Dead: " .. hero:getDisplayName())
    local heroTab, tempheroesTab, orders
    if hero:getType() ~= ACTOR_TYPES.NPC then
        heroTab = self._candidateHeroes
        tempheroesTab = self._heroes
        orders = self._dungeonConfig.userAlternateTargetOrder
    else
        heroTab = self._candidateEnemies
        tempheroesTab = self._enemies
        orders = self._dungeonConfig.enemyAlternateTargetOrder
    end
    table.removebyvalue(heroTab, hero)
    local tempOderTab = {}

    table.insert(tempheroesTab, hero)
    for _, actorId in ipairs(orders) do
        for i, actor in ipairs(tempheroesTab) do
            if actor:getActorID(true) == actorId then
                table.insert(tempOderTab, actor)
                table.remove(tempheroesTab, i)
                break
            end
        end
    end

    if hero:getType() ~= ACTOR_TYPES.NPC then
        self._heroes = tempOderTab
    else
        self._enemies = tempOderTab
    end

    for _, actor in ipairs(app.battle:getMyEnemies(hero)) do
        actor:setAIReloadTargets(true)
    end

    local ai = self._aiDirector:createBehaviorTree(hero:getAIType(), hero)
    hero.behaviorNode = ai
    self._aiDirector:addBehaviorTree(ai)

    local event = {
        name = QBattleManager.CANDIDATE_ACTOR_ENTER,
        isHero = hero:getType() ~= ACTOR_TYPES.NPC,
        candidate_actor = hero,
        dead_actor = hero._candidate
    }
    self:dispatchEvent(event)
end

function QBattleManager:getHeroAdditionInfos()
    if self._heroAdditionInfos == nil then
        local attrListProp = {}
        local userAttrList = self._dungeonConfig.userAttrList
        if userAttrList then
            local soulGuidProp = db:calculateSoulGuideLevelProp(userAttrList.soulGuideLevel or 0)
            QActorProp:getPropByConfig(soulGuidProp, attrListProp)

            for i, mountInfo in pairs(userAttrList.reformInfo or {}) do
                local mountConfig = db:getCharacterByID(mountInfo.zuoqiId)
                local refromProp = db:getReformConfigByAptitudeAndLevel(mountConfig.aptitude, mountInfo.reformLevel) or {}
                QActorProp:getPropByConfig(refromProp, attrListProp)
            end
        end
        -- 计算羁绊技能，以及组合属性
        local additionalInfos = {
            superSkillInfos = db:calculateSuperSkillIDArray(self._dungeonConfig.heroRecords or {}),
            -- 羁绊属性
            combinationProps = db:calculateCombinationPropByIDArray(self._dungeonConfig.heroRecords or {}),
            -- 宗门技能
            unionSkillProp = db:calculateUnionSkillProp(self._dungeonConfig.userConsortiaSkill),
            -- 头像框
            avatarProp = db:calculateAvatarProp(self._dungeonConfig.userAvatar, self._dungeonConfig.userTitle, self._dungeonConfig.userTitles),
            -- 考古
            archaeologyProp = db:calculateArchaeologyProp(self._dungeonConfig.userLastEnableFragmentId),
            -- 雕文
            teamGlyphInfo = self._dungeonConfig.userHeroTeamGlyphs or {},
            -- 纹章
            badgeProp = db:getBadgeByCount(self._dungeonConfig.userNightmareDungeonPassCount or 0),
            -- 坐骑图鉴
            mountCombinationProp = db:calculateMountCombinationProp(self._dungeonConfig.mountRecords or {}),
            -- 魂灵图鉴
            soulSpiritCombinationProp = db:calculateSoulSpiritCombinationProp(self._dungeonConfig.userSoulSpiritCollectInfo or {}),
            -- 魂力试炼
            soulTrialProp = db:calculateSoulTrialProp( self._dungeonConfig.userSoulTrial),
            attrListProp = attrListProp,

            godarmReformProp = db:getGodArmPropByList(self._dungeonConfig.userGodArmList),
        }
        self._heroAdditionInfos = additionalInfos
    end

    return self._heroAdditionInfos
end

function QBattleManager:getEnemyAdditionInfos()
    if self._enemyAdditionInfos == nil then
        local attrListProp = {}
        local enemyAttrList = self._dungeonConfig.enemyAttrList
        if enemyAttrList then
            local soulGuidProp = db:calculateSoulGuideLevelProp(enemyAttrList.soulGuideLevel or 0)
            QActorProp:getPropByConfig(soulGuidProp, attrListProp)

            for i, mountInfo in pairs(enemyAttrList.reformInfo or {}) do
                local mountConfig = db:getCharacterByID(mountInfo.zuoqiId)
                local refromProp = db:getReformConfigByAptitudeAndLevel(mountConfig.aptitude, mountInfo.reformLevel) or {}
                QActorProp:getPropByConfig(refromProp, attrListProp)
            end
        end

        -- 计算羁绊技能，以及组合属性，宗门技能属性，头像属性，考古属性
        local additionalInfos = {
            superSkillInfos = db:calculateSuperSkillIDArray(self._dungeonConfig.pvpRivalHeroRecords or {}),
            combinationProps = db:calculateCombinationPropByIDArray(self._dungeonConfig.pvpRivalHeroRecords or {}),
            unionSkillProp = db:calculateUnionSkillProp(self._dungeonConfig.enemyConsortiaSkill),
            avatarProp = db:calculateAvatarProp(self._dungeonConfig.enemyAvatar, self._dungeonConfig.enemyTitle, self._dungeonConfig.enemyTitles),
            archaeologyProp = db:calculateArchaeologyProp(self._dungeonConfig.enemyLastEnableFragmentId),
            teamGlyphInfo = self._dungeonConfig.enemyHeroTeamGlyphs or {},
            badgeProp = db:getBadgeByCount(self._dungeonConfig.enemyNightmareDungeonPassCount or 0),
            mountCombinationProp = db:calculateMountCombinationProp(self._dungeonConfig.pvpRivalMountRecords or {}),
            soulSpiritCombinationProp = db:calculateSoulSpiritCombinationProp(self._dungeonConfig.enemySoulSpiritCollectInfo or {}),
            soulTrialProp = db:calculateSoulTrialProp( self._dungeonConfig.enemySoulTrial),
            attrListProp = attrListProp,
            godarmReformProp = db:getGodArmPropByList(self._dungeonConfig.enemyGodArmList),
            }
        self._enemyAdditionInfos = additionalInfos
    end

    return self._enemyAdditionInfos
end

--[[--
@param summoner         召唤者
@param copySlots        需要拷贝的技能插槽
@param heroId           需要召唤的hero ID
@param screen_pos       场景位置 
@param aiType           召唤物的AI 
@param hasEnchatSkill   是否有附魔技能
@param hasGodSkill      是否有神技
@param pos              格子坐标
@param clean_new_wave   在新的波次开始时是否要清除
--]]
function QBattleManager:summonCopyHero(param)
    if param.heroId == nil then return end 
    local heroInfo = nil
    local getCopyHeroInfo = function(infos)
        if infos then
            for _, info in ipairs(infos) do
                if info.actorId == param.heroId then
                    heroInfo = info
                    break
                end
            end
        end
    end
    local isHero = not (param.summoner:getType() == ACTOR_TYPES.NPC)
    local additionalInfos = nil
    local extraProp = nil
    if isHero then
        if heroInfo == nil then getCopyHeroInfo(self._dungeonConfig.heroInfos) end
        if heroInfo == nil then getCopyHeroInfo(self._dungeonConfig.supportHeroInfos) end
        if heroInfo == nil then getCopyHeroInfo(self._dungeonConfig.supportHeroInfos2) end
        if heroInfo == nil then getCopyHeroInfo(self._dungeonConfig.supportHeroInfos3) end
        if heroInfo == nil then getCopyHeroInfo(self._dungeonConfig.userAlternateInfos) end
        if heroInfo == nil then return end
        additionalInfos = self:getHeroAdditionInfos()
        extraProp = self._dungeonConfig.extraProp or {}
    else
        if heroInfo == nil then getCopyHeroInfo(self._dungeonConfig.pvp_rivals) end
        if heroInfo == nil then getCopyHeroInfo(self._dungeonConfig.pvp_rivals2) end
        if heroInfo == nil then getCopyHeroInfo(self._dungeonConfig.pvp_rivals4) end
        if heroInfo == nil then getCopyHeroInfo(self._dungeonConfig.pvp_rivals6) end
        if heroInfo == nil then getCopyHeroInfo(self._dungeonConfig.enemyAlternateInfos) end
        if heroInfo == nil then return end
        additionalInfos = self:getEnemyAdditionInfos()
        extraProp = self._dungeonConfig.enemyExtraProp or {}
    end

    local copyHero = QCopyHeroModel.new(heroInfo, nil, nil, additionalInfos, param.copySlots, param.hasEnchatSkill, param.hasGodSkill, true, false, false, extraProp)
    -- copyHero:setIsControlNPC(true)
    copyHero:setGhostCanBeAttacked(true)
    if isHero then
        copyHero:setType(ACTOR_TYPES.HERO_NPC)
    else
        copyHero:setType(ACTOR_TYPES.NPC)
        if param.pos then
            param.pos.x = 6 - param.pos.x
        end
    end
    copyHero:setIsGhost(true)

    local ai_name
    if copyHero:isHealth() then
        ai_name = param.aiTypeHealth
    else
        ai_name = param.aiType
    end
    if ai_name == nil then ai_name = copyHero:getAIType() end
    local ai = self._aiDirector:createBehaviorTree(ai_name, copyHero)
    self._aiDirector:addBehaviorTree(ai)

    copyHero:setIsSupportHero(false)
    copyHero:resetStateForBattle()
    self._actorsByUDID[copyHero:getUDID()] = copyHero
    if isHero then
        table.insert(self._heroGhosts, {actor = copyHero, ai = ai, life_span = 1000, life_countdown = 1000,
            summoner = param.summoner, clean_new_wave = param.clean_new_wave})
    else
        table.insert(self._enemyGhosts, {actor = copyHero, ai = ai, life_span = 1000, life_countdown = 1000,
            summoner = param.summoner, clean_new_wave = param.clean_new_wave})
    end
    -- 下面的两行代码在修改伤害统计信息的时候需要修改
    self._battleLog:onHeroDoDHP(copyHero:getActorID(), 0, copyHero)
    self._battleLog:addHeroOnStage(copyHero, copyHero:getBattleForce())

    self:dispatchEvent({name = QBattleManager.NPC_CREATED, npc = copyHero, screen_pos = param.screen_pos, is_hero = isHero,
        pos = param.pos})

    return copyHero
end

function QBattleManager:setFromMap(p1,p2,p3)
    if p3 ~= nil then
        self._map_cache:setObject(p1,p2,p3)
    else
        self._map_cache:set(p1,p2)
    end
end

function QBattleManager:getFromMap(p1,p2)
    if p2 ~= nil then
        return self._map_cache:getObject(p1,p2)
    else
        return self._map_cache:get(p1)
    end
end

function QBattleManager:applyPropertiesForEquilibrium(propertyDict, heroes, candidates)
    local hpTotal, attackTotal, magicArmorTotal, physicalArmorTotal, magicPenetrationTotal, physicalPenetrationTotal = 0, 0, 0, 0, 0, 0
    for _, actor in ipairs(heroes) do
        hpTotal = actor:getMaxHp(nil, true) + hpTotal
        attackTotal = actor:getMaxAttack() + attackTotal
        magicArmorTotal = actor:getMaxMagicArmor() + magicArmorTotal
        physicalArmorTotal = actor:getMaxPhysicalArmor() + physicalArmorTotal
        physicalPenetrationTotal = actor:getMaxPhysicalPenetration() + physicalPenetrationTotal 
        magicPenetrationTotal = actor:getMaxMagicPenetration() + magicPenetrationTotal
    end
    for _, actor in ipairs(candidates) do
        hpTotal = actor:getMaxHp(nil, true) + hpTotal
        attackTotal = actor:getMaxAttack() + attackTotal
        magicArmorTotal = actor:getMaxMagicArmor() + magicArmorTotal
        physicalArmorTotal = actor:getMaxPhysicalArmor() + physicalArmorTotal
        physicalPenetrationTotal = actor:getMaxPhysicalPenetration() + physicalPenetrationTotal 
        magicPenetrationTotal = actor:getMaxMagicPenetration() + magicPenetrationTotal
    end
    local count = 7

    for _, actor in ipairs(heroes) do
        actor:removePropertyValue("hp_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("hp_equilibrium", "sotoTeamEquilibrium", "+", hpTotal/count - actor:getMaxHp(nil, true))
        actor:removePropertyValue("attack_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("attack_equilibrium", "sotoTeamEquilibrium", "+", attackTotal/count - actor:getMaxAttack())
        actor:removePropertyValue("magic_armor_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("magic_armor_equilibrium", "sotoTeamEquilibrium", "+", magicArmorTotal/count - actor:getMaxMagicArmor())
        actor:removePropertyValue("physical_armor_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("physical_armor_equilibrium", "sotoTeamEquilibrium", "+", physicalArmorTotal/count - actor:getMaxPhysicalArmor())
        actor:removePropertyValue("magic_penetration_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("magic_penetration_equilibrium", "sotoTeamEquilibrium", "+", magicPenetrationTotal/count - actor:getMaxPhysicalPenetration())
        actor:removePropertyValue("physical_penetration_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("physical_penetration_equilibrium", "sotoTeamEquilibrium", "+", physicalPenetrationTotal/count - actor:getMaxPhysicalPenetration())
        actor:setFullHp()
    end
    for _, actor in ipairs(candidates) do
        actor:removePropertyValue("hp_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("hp_equilibrium", "sotoTeamEquilibrium", "+", hpTotal/count - actor:getMaxHp(nil, true))
        actor:removePropertyValue("attack_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("attack_equilibrium", "sotoTeamEquilibrium", "+", attackTotal/count - actor:getMaxAttack())
        actor:removePropertyValue("magic_armor_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("magic_armor_equilibrium", "sotoTeamEquilibrium", "+", magicArmorTotal/count - actor:getMaxMagicArmor())
        actor:removePropertyValue("physical_armor_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("physical_armor_equilibrium", "sotoTeamEquilibrium", "+", physicalArmorTotal/count - actor:getMaxPhysicalArmor())
        actor:removePropertyValue("magic_penetration_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("magic_penetration_equilibrium", "sotoTeamEquilibrium", "+", magicPenetrationTotal/count - actor:getMaxPhysicalPenetration())
        actor:removePropertyValue("physical_penetration_equilibrium", "sotoTeamEquilibrium")
        actor:insertPropertyValue("physical_penetration_equilibrium", "sotoTeamEquilibrium", "+", physicalPenetrationTotal/count - actor:getMaxPhysicalPenetration())
        actor:setFullHp()
    end

    for _, propertyObj in ipairs(propertyDict) do 
        if not propertyObj.isNotFinal then
            local valueTotal = 0
            for _, actor in ipairs(heroes) do
                valueTotal = valueTotal + actor[propertyObj.name]
            end
            for _, actor in ipairs(candidates) do
                valueTotal = valueTotal + actor[propertyObj.name]
            end
            local value = valueTotal / count
            local calc = false
            for _, actor in ipairs(heroes) do
                actor:_disableHpChangeByPropertyChange()
                actor:clearNumberPropery(propertyObj.name)
                actor:_enableHpChangeByPropertyChange()
                actor:insertPropertyValue(propertyObj.name, actor, propertyObj.operator, value)
            end
            for _, actor in ipairs(candidates) do
                actor:_disableHpChangeByPropertyChange()
                actor:clearNumberPropery(propertyObj.name)
                actor:_enableHpChangeByPropertyChange()
                actor:insertPropertyValue(propertyObj.name, actor, propertyObj.operator, value)
            end
        end
    end
end

local function applyMockBattleProp(cards, actorDict)
    for _, card in pairs(cards) do
        for _, hero in ipairs(actorDict) do
            if hero:getActorID() == tonumber(card.character_id) then
                hero:insertPropertyValue("pvp_physical_damage_percent_attack", "mockBattle", "+", tonumber(card.pvp_damage_percent_attack or 0))
                hero:insertPropertyValue("pvp_magic_damage_percent_attack", "mockBattle", "+", tonumber(card.pvp_damage_percent_attack or 0))
                hero:insertPropertyValue("pvp_physical_damage_percent_beattack_reduce", "mockBattle", "+", tonumber(card.pvp_damage_percent_beattack_reduce or 0))
                hero:insertPropertyValue("pvp_magic_damage_percent_beattack_reduce", "mockBattle", "+", tonumber(card.pvp_damage_percent_beattack_reduce or 0))
            end
        end
    end
end

function QBattleManager:_applyMockBattlePropHero()
    local mockBattleCards = QStaticDatabase:sharedDatabase():getMockBattleCardConfig()
    applyMockBattleProp(mockBattleCards, self._heroes)
    applyMockBattleProp(mockBattleCards, self._supportHeroes)
    applyMockBattleProp(mockBattleCards, self._supportHeroes2)
    applyMockBattleProp(mockBattleCards, self._supportHeroes3)
end

function QBattleManager:_applyMockBattlePropEnemy()
    local mockBattleCards = QStaticDatabase:sharedDatabase():getMockBattleCardConfig()
    applyMockBattleProp(mockBattleCards, self._enemies)
    applyMockBattleProp(mockBattleCards, self._supportEnemies)
    applyMockBattleProp(mockBattleCards, self._supportEnemies2)
    applyMockBattleProp(mockBattleCards, self._supportEnemies3)
end

function QBattleManager:isInTotemChallenge()
    return self._dungeonConfig.isTotemChallenge
end

function QBattleManager:initTotemChallengeAffix()
    local config
    if totem_challenge_affx_config.force_id then
        config = clone(totem_challenge_affx_config[totem_challenge_affx_config.force_id])
    else
        local affix_cfg = db:getTotemAffixsConfigByBuffId(self._dungeonConfig.totemChallengeBuffId)
        config = clone(totem_challenge_affx_config[affix_cfg["affix_" .. tostring(self._pvpMultipleWave)]])
    end
    self._totem_challenge_affix_hero = {}
    self._totem_challenge_affix_enemy = {}
    if config then
        local is_second = false
        if config.is_hero then
            self._totem_challenge_affix_hero = config
            is_second = true
        end
        if config.is_enemy then
            self._totem_challenge_affix_enemy = is_second and clone(config) or config
            self._totem_challenge_affix_enemy.is_second = is_second
        end
    end

    local property_cfg = db:getTotemChallengeForceYieldProperty(self._dungeonConfig.forceYield)
    for k, v in pairs(property_cfg) do
        if QActorProp._field[k] then
            self._enemyTeamSkillProperty[k] = (self._enemyTeamSkillProperty[k] or 0) + v
        end
    end
end

function QBattleManager:_totemChallengeFindTarget()
    if not self:isInTotemChallenge() then return end
    local function findTarget(affix, teammates, enemies)
        if affix.kind == 19 then
            local target = enemies[1]
            for k, hero in pairs(enemies) do
                if hero:getBattleForce() > target:getBattleForce() then
                    target = hero
                end
            end
            affix.target = target
            return
        else
            local pos = totem_challenge_affx_config.force_pos or self._dungeonConfig.totemChallengePos or 1
            for i = pos, 1, -1 do
                if teammates[i] then
                    affix.target = teammates[i]
                    return
                end
            end
        end
    end
    findTarget(self._totem_challenge_affix_hero, self._heroes, self._enemies)
    findTarget(self._totem_challenge_affix_enemy, self._enemies, self._heroes)
end

function QBattleManager:getTotemChallengeAffix(hero)
    return hero:getType() == ACTOR_TYPES.NPC and self._totem_challenge_affix_enemy or self._totem_challenge_affix_hero
end

function QBattleManager:_updateTotemChallengeAffix(dt)
    if (not self:isInTotemChallenge()) or self._startCountDown ~= true then return end
    local _last_time = nil
    local function _getTime()
        _last_time = _last_time or (self:getDungeonDuration() - self:getTimeLeft())
        return _last_time
    end
    local function updateTotemChallengeAffix(dt, affix, isHero)
        if affix.triggered == true then return end
        if affix.string and (not IsServerSide) and affix.is_second ~= true then
            if type(affix.string) == "string" then
                affix.string = {{string = affix.string, string_begin_time = affix.string_begin_time, string_interval = affix.string_interval, string_duration = affix.string_duration}}
            end
            for i, str_cfg in ipairs(affix.string) do
                local cur_time = _getTime()
                local is_show = true
                if string.find(str_cfg.string, "#HERO_NAME#") then
                    if affix.target then
                        str_cfg.string = string.gsub(str_cfg.string, "#HERO_NAME#", affix.target:getDisplayName())
                    else
                        is_show = false
                    end
                end
                if is_show then
                    if str_cfg.string_last_trigger_time == nil then
                        if cur_time >= (str_cfg.string_begin_time or 0) then
                            app.scene:showBossTips(str_cfg.string_duration or 2.5, str_cfg.string, {bg_scale_x = str_cfg.bg_scale_x or 1.5})
                            str_cfg.string_last_trigger_time = cur_time
                        end
                    elseif str_cfg.string_interval and (cur_time - str_cfg.string_last_trigger_time) > str_cfg.string_interval then
                        app.scene:showBossTips(str_cfg.string_duration or 2.5, str_cfg.string, {bg_scale_x = str_cfg.bg_scale_x or 1.5})
                        str_cfg.string_last_trigger_time = cur_time
                    end
                end
            end
        end

        if affix.kind == 9 and affix.target then
            for i,v in ipairs(affix.value) do
                affix.target:removePropertyValue(v[1], "affix")
                affix.target:insertPropertyValue(v[1], "affix", "+", v[2])
            end
            affix.triggered = true
        end

        if affix.effect_buff_id and affix.target and affix.effect_inited ~= true and (affix.kind == 10 or affix.kind == 11 or affix.kind == 12) then
            local check = true
            if affix.kind == 10 or affix.kind == 11 or affix.kind == 12 then
                check = #(self:getMyTeammates(affix.target, false, true)) > 0
            end
            if check then
                affix.target:applyBuff(affix.effect_buff_id)
                affix.effect_inited = true
            end
        end

        if affix.kind == 6 then
            local tab = isHero and self._heroTeamSkillProperty or self._enemyTeamSkillProperty
            for i,v in ipairs(affix.value) do
                local effect = v[1]
                local value = v[2]
                tab[effect] = (tab[effect] or 0) + value
            end
            affix.triggered = true
        end

        if affix.kind == 20 and affix.inited ~= true then
            local tab = isHero and self._heroTeamSkillProperty or self._enemyTeamSkillProperty
            local arr = (isHero and self._heroes) or self._enemies or {}
            tab["critical_chance"] = (tab["critical_chance"] or 0) + affix.value.base * (#arr)
            affix.inited = true
        end

        if affix.kind == 13 then
            local cur_time = _getTime()
            local function _dotrigger()
                local actors = {}
                table.mergeForArray(actors,isHero and self:getHeroes() or self:getEnemies(), function(actor) 
                    return actor:isHero() and not actor:isDead()
                end)
                if #actors > 0 then
                    if affix.value.random_target then
                        local actor = actors[app.random(1, #actors)]
                        actor:applyBuff(affix.value.buff_id, actor, actor:getTalentSkill())
                    else
                        for i, actor in ipairs(actors) do
                            actor:applyBuff(affix.value.buff_id, actor, actor:getTalentSkill())
                        end
                    end
                end
                affix.lastTriggerTime = cur_time
            end
            if affix.lastTriggerTime == nil then
                if cur_time > (affix.value.first_time or 0) then
                    _dotrigger()
                end
            else
                if cur_time - affix.lastTriggerTime > affix.value.interval then
                    _dotrigger()
                end
            end
        end

        if affix.kind == 14 then
            local cur_time = _getTime()

            if affix.lastTriggerTime and affix.markedHeroes and (cur_time - affix.lastTriggerTime) >= affix.value.duration then
                --一段时间之后集火会重置,把目标设置为空,让ai选择下一个对手
                for i,actor in ipairs(affix.markedHeroes) do
                    if actor:isHero() and (not actor:isDead()) and (not actor:isHealth()) then
                        actor:setTarget(nil)
                    end
                end
                if affix.current_target and affix.effect_buff_id then
                    affix.current_target:removeBuffByID(affix.effect_buff_id)
                end
                affix.markedHeroes = nil
                affix.lastTriggerTime = cur_time
                affix.current_target = nil
            end
            local function _dotrigger()
                local actors = isHero and self:getHeroes() or self:getEnemies()
                local enemys = isHero and self:getEnemies() or self:getHeroes()
                local hp_lastest = enemys[1]
                for i, actor in ipairs(enemys) do
                    if actor:isHero() and not actor:isDead() then
                        if hp_lastest:getHp() > actor:getHp() then
                            hp_lastest = actor
                        end
                    end
                end
                if hp_lastest then
                    for i,actor in ipairs(actors) do
                        if actor:isHero() and (not actor:isDead()) and (not actor:isHealth()) then
                            actor:setTarget(hp_lastest)
                        end
                    end
                    affix.markedHeroes = actors
                    affix.lastTriggerTime = cur_time
                    if affix.effect_buff_id then
                        hp_lastest:applyBuff(affix.effect_buff_id)
                    end
                    affix.current_target = hp_lastest
                end
            end
            if affix.lastTriggerTime == nil then
                if cur_time > (affix.value.first_time or 0) then
                    _dotrigger()
                end
            elseif cur_time - affix.lastTriggerTime > affix.value.interval then
                _dotrigger()
            end
        end

        if affix.kind == 15 then
            local cur_time = _getTime()
            if affix.lastTriggerTime and affix.inDedicationTime and (cur_time - affix.lastTriggerTime) >= affix.value.duration then
                affix.inDedicationTime = false
                affix.lastTriggerTime = cur_time
            end
            if affix.lastTriggerTime == nil then
                if cur_time > (affix.value.first_time or 0) then
                    affix.inDedicationTime = true
                    affix.lastTriggerTime = cur_time
                end
            elseif cur_time - affix.lastTriggerTime > affix.value.interval then
                affix.inDedicationTime = true
                affix.lastTriggerTime = cur_time
            end
        end

        if affix.kind == 17 and affix.target then
            local actor = affix.target
            if actor._skills[affix.value] == nil then
                actor._skills[affix.value] = QSkill.new(affix.value, {}, actor, 1)
            end
            local skill = actor._skills[affix.value]
            local sbDirector = actor:triggerAttack(actor._skills[affix.value])
            if sbDirector ~= nil then
                affix.triggered = true
            end
        end

        if affix.kind == 19 and affix.target and _getTime() > 0 then
            local cur_time = _getTime()
            local actor = affix.target
            local arr = actor:getType() == ACTOR_TYPES.NPC and self._enemies or self._heroes
            if affix.lockTime then
                if cur_time - affix.lockTime >= affix.value then
                    table.insert(arr, actor)
                    self:replaceActorAI(actor)
                    actor:allowMove()
                    actor:allowNormalAttack()
                    actor:exileActor(false)
                    if not IsServerSide then
                        local view = app.scene:getActorViewFromModel(actor)
                        if view then
                            view:setEnableTouchEvent(true)
                            view._skeletonActor:setOpacity(255)
                        end
                    end
                    if affix.effect_buff_id then
                        actor:removeBuffByID(affix.effect_buff_id)
                    end
                    affix.triggered = true
                end
            else
                for i,actor in ipairs(self._heroes) do
                    if actor:getTarget() == actor then
                        actor:setTarget(nil)
                    end
                end
                for i,ghost in ipairs(self._heroGhosts) do
                    if ghost.actor and ghost.actor:getTarget() == actor then
                        ghost.actor:setTarget(nil)
                    end
                end
                for i,actor in ipairs(self._enemies) do
                    if actor:getTarget() == actor then
                        actor:setTarget(nil)
                    end
                end
                for i,ghost in ipairs(self._enemyGhosts) do
                    if ghost.actor and ghost.actor:getTarget() == actor then
                        ghost.actor:setTarget(nil)
                    end
                end

                --移除ai
                local children = self._aiDirector:getChildren()
                for _, aiTree in ipairs(children) do
                    if aiTree:getActor() == actor then
                        self._aiDirector:removeBehaviorTree(aiTree)
                        break
                    end
                end
                if affix.effect_buff_id then
                    actor:applyBuff(affix.effect_buff_id)
                end
                actor:cancelAllSkills()
                actor:forbidMove()
                actor:forbidNormalAttack()
                actor:exileActor(true)
                if not IsServerSide then
                    local view = app.scene:getActorViewFromModel(actor)
                    if view then
                        if view == app.scene._touchController:getSelectActorView() then
                            app.scene._touchController:setSelectActorView(nil)
                        end
                        view._skeletonActor:setOpacity(255 * 0.4)
                        view:setEnableTouchEvent(false)
                        view:hideHpView()
                    end
                end
                affix.lockTime = cur_time
            end
        end

        if affix.kind == 23 then
            local cur_time = _getTime()
            local function _dotrigger()
                local actors = {}
                local heroes = isHero and self._enemies or self._heroes
                local ghosts = isHero and self._enemyGhosts or self._heroGhosts
                table.mergeForArray(actors, heroes, func_dead_filter)
                table.mergeForArray(actors, ghosts, func_nonghost_filter, func_actor_get)
                affix.isLeft = not affix.isLeft 
                local isLeft = affix.isLeft
                for i, hero in ipairs(actors) do
                    if hero:isDead() ~= true then
                        local pos = hero:getPosition()
                        if isLeft then
                            if pos.x < (BATTLE_AREA.left + BATTLE_AREA.width / 2) then
                                hero:applyBuff(affix.value.buff_id, hero)
                            end
                        else
                            if pos.x > (BATTLE_AREA.left + BATTLE_AREA.width / 2) then
                                hero:applyBuff(affix.value.buff_id, hero)
                            end
                        end
                    end
                end
                if affix.scene_effect then
                    local cfgs = affix.scene_effect
                    if cfgs[1] == nil then
                        cfgs = {cfgs}
                    end
                    for i, cfg in ipairs(cfgs) do
                        local pos = isLeft and cfg.pos1 or cfg.pos2
                        app.scene:playSceneEffect(cfg.id, pos or cfg.pos, cfg.is_lay_on_the_ground)
                    end
                end
                affix.lastTriggerTime = cur_time
                affix.effect_triggered = false
            end

            local function effect_trigger()
                if not IsServerSide then
                    local isLeft = not affix.isLeft
                    if isLeft then
                        app.scene:playSceneEffect("yangwudi_attack11_3_3", {x = -420 , y = 340}, true)
                    else
                        app.scene:playSceneEffect("yangwudi_attack11_3_2", {x = 1780 , y = 340}, true)
                    end
                end
                affix.effect_triggered = true
            end

            if affix.effect_triggered ~= true then
                if affix.lastTriggerTime == nil then
                    if (affix.value.first_time - cur_time) > 0 and (affix.value.first_time - cur_time) <= 1 then
                        effect_trigger()
                    end
                elseif (affix.lastTriggerTime + affix.value.interval - cur_time) > 0 and (affix.lastTriggerTime + affix.value.interval - cur_time) <= 1 then
                    effect_trigger()
                end
            end

            if affix.lastTriggerTime == nil then
                if cur_time > (affix.value.first_time or 0) then
                    _dotrigger()
                end
            elseif cur_time - affix.lastTriggerTime > affix.value.interval then
                _dotrigger()
            end
        end

        if affix.kind == 24 then
            local cur_time = _getTime()
            local function _dotrigger()
                local actors = {}
                table.mergeForArray(actors, isHero and self._heroes or self._enemies)
                for i, hero in ipairs(actors) do
                    if hero:isDead() ~= true and hero:getHp() / hero:getMaxHp() <= affix.value.execute then
                        local _, damage, absorb = hero:decreaseHp(hero:getHp(), hero, nil, true, nil, nil, true, true)
                        hero:dispatchEvent({name = hero.UNDER_ATTACK_EVENT, isTreat = false, 
                        isCritical = false, tip = "", rawTip = {
                            isHero = hero:getType() == ACTOR_TYPES.HERO, 
                            isCritical = false, 
                            isTreat = false,
                            isExecute = true,
                            number = damage,
                        }})
                    end
                end
                if affix.scene_effect then
                    local cfgs = affix.scene_effect
                    if cfgs[1] == nil then
                        cfgs = {cfgs}
                    end
                    for i, cfg in ipairs(cfgs) do
                        app.scene:playSceneEffect(cfg.id, cfg.pos, cfg.is_lay_on_the_ground)
                    end
                end
                affix.lastTriggerTime = cur_time
            end
            if affix.lastTriggerTime == nil then
                if cur_time > (affix.value.first_time or 0) then
                    _dotrigger()
                end
            elseif cur_time - affix.lastTriggerTime > affix.value.interval then
                _dotrigger()
            end
        end

        if affix.kind == 25 then
            local cur_time = _getTime()
            local function _dotrigger()
                local actors = {}
                table.mergeForArray(actors, isHero and self._heroes or self._enemies)
                for i, hero in ipairs(actors) do
                    if hero:isDead() ~= true then
                        hero:setRecoverHpLimit(hero:getMaxHp() * affix.value.value, hero:getMaxHp())
                    end
                end
                affix.lastTriggerTime = cur_time
            end
            if affix.lastTriggerTime == nil then
                if cur_time > (affix.value.first_time or 0) then
                    _dotrigger()
                end
            elseif cur_time - affix.lastTriggerTime > affix.value.interval then
                _dotrigger()
            end
        end

    end
    updateTotemChallengeAffix(dt, self._totem_challenge_affix_hero, true)
    updateTotemChallengeAffix(dt, self._totem_challenge_affix_enemy, false)
end

function QBattleManager:getTotemChallengeForceYield()
    return self._dungeonConfig.forceYield or 1
end

function QBattleManager:_initYZGodArmIdList(curHeroGodArmList, curEnemyGodArmList)
    -- 上阵的神器技能不会作为援助神器技能
    local parseIds = function(godArmIdList, godArmSkillIds, allGodArmList, dataBase)
        for _, idStr in ipairs(godArmIdList) do
            local level
            local lis = string.split(idStr, ";")
            for i, godArmIdStr in ipairs(allGodArmList) do
                local lisEx = string.split(godArmIdStr, ";")
                if lisEx[1] == lis[1] then
                    level = tonumber(lisEx[2])
                    table.remove(allGodArmList, i) break
                end
            end
            if level == nil then
                level = tonumber(lis[2])
            end
            if level then
                local config = dataBase:getGradeByHeroActorLevel(lis[1], level)
                table.insert(godArmSkillIds, config.god_arm_skill_sz)
            end
        end
    end
    local tempIdList = clone(self._dungeonConfig.allHeroGodArmIdList)
    local dataBase = QStaticDatabase:sharedDatabase()
    parseIds(curHeroGodArmList, self._heroGodArmSkillIds1, tempIdList, dataBase)

    for _, idStr in ipairs(tempIdList) do
        local lis = string.split(idStr, ";")
        local config = dataBase:getGradeByHeroActorLevel(lis[1], tonumber(lis[2]))
        table.insert(self._heroYZGodArmSkillIds, config.god_arm_skill_yz)
    end

    local tempIdList = clone(self._dungeonConfig.allEnemyGodArmIdList)
    parseIds(curEnemyGodArmList, self._enemyGodArmSkillIds1, tempIdList, dataBase)

    for _, idStr in ipairs(tempIdList) do
        local lis = string.split(idStr, ";")
        local config = dataBase:getGradeByHeroActorLevel(lis[1], tonumber(lis[2]))
        table.insert(self._enemyYZGodArmSkillIds, config.god_arm_skill_yz)
    end
    self._curHeroGodArmList = curHeroGodArmList
    self._curEnemyGodArmList = curEnemyGodArmList
end

function QBattleManager:getHeroGodArmIdList()
    return self._curHeroGodArmList
end

function QBattleManager:getEnemyGodArmIdList()
    return self._curEnemyGodArmList
end

function QBattleManager:isTotemChallengeQuick()
    return self._dungeonConfig.isTotemChallengeQuick
end

function QBattleManager:saveMockBattle2Resulte(isWin)
    local resultNum = isWin and "1" or "0"
    if self._dungeonConfig.mockBattle2Resulte == nil then
        self._dungeonConfig.mockBattle2Resulte = ""
    end
    self._dungeonConfig.mockBattle2Resulte = self._dungeonConfig.mockBattle2Resulte .. resultNum
    if self:getPVPMultipleNewCurWave() == 1 then
        self._dungeonConfig.mockBattle2Resulte = self._dungeonConfig.mockBattle2Resulte .. "-"
    end
end

function QBattleManager:getMockBattle2Resulte()
    return self._dungeonConfig.mockBattle2Resulte
end

function QBattleManager:_getEnterRageConfig(userAttrList)
    local result = {}
    local configs = db:getStaticByName("skins_combination_skills")
    if userAttrList then
        for _, id in ipairs(userAttrList.skinPictureIds or {}) do
            for _, config in pairs(configs) do
                if config.id == id then
                    table.insert(result, config)
                end
            end
        end
    end

    return result
end

function QBattleManager:_applyHeroAttrEnterRage(hero)
    if self._heroEnterRageConfigs == nil then
        self._heroEnterRageConfigs = self:_getEnterRageConfig(self._dungeonConfig.userAttrList)
    end
    for _, config in ipairs(self._heroEnterRageConfigs) do
        local idsList = string.split(config.character_skins, ";")
        for _, idStr in ipairs(idsList) do
            local skinConfig = db:getHeroSkinConfigByID(idStr)
            if skinConfig.character_id == hero:getActorID(true) and config.type == 3 then
                hero:changeRage(config.enter_rage)
            end
        end
    end
end

function QBattleManager:_applyEnemyAttrEnterRage(hero)
    if self._enemyEnterRageConfigs == nil then
        self._enemyEnterRageConfigs = self:_getEnterRageConfig(self._dungeonConfig.enemyAttrList)
    end
    for _, config in ipairs(self._enemyEnterRageConfigs) do
        local idsList = string.split(config.character_skins, ";")
        for _, idStr in ipairs(idsList) do
            local skinConfig = db:getHeroSkinConfigByID(idStr)
            if skinConfig.character_id == hero:getActorID(true) and config.type == 3 then
                hero:changeRage(config.enter_rage)
            end
        end
    end
end


function QBattleManager:isInMetalAbyss()
    return self._dungeonConfig.isMetalAbyss
end

function QBattleManager:hasRecoverDeath()
    return self._hasRecoverDeath
end

function QBattleManager:setRecoverDeath()
    self._hasRecoverDeath = true 
end

return QBattleManager

