

local QActor
if IsServerSide then
    local EventProtocol = import("EventProtocol")
    QActor = class("QActor", EventProtocol)
else
    local QModelBase = import("..models.QModelBase")
    QActor = class("QActor", QModelBase)
end
local QActorProp = import(".QActorProp")
local StateMachine
if IsServerSide then
    StateMachine = import("StateMachine")
end
local QFileCache = import("..utils.QFileCache")
local QHitLog = import("..utils.QHitLog")
local QBattleManager = import("..controllers.QBattleManager")
local QSkill = import(".QSkill")
local QSBDirector = import("..skill.QSBDirector")
local QSBDeadDirector = import("..skill.QSBDeadDirector")
local QBuff = import(".QBuff")
local QTrapDirector = import("..trap.QTrapDirector")
local QSoundEffect
if not IsServerSide then
    QSoundEffect = import("..utils.QSoundEffect")
end

-- brewmaster movement              
local translate = {
    { time = 0, x = 0, y = 0, curve = "stepped" },
    { time = 0.4333, x = 0, y = 0, curve = "stepped" },
    { time = 0.5, x = 0, y = 0, curve = "stepped" },
    { time = 0.6, x = 0, y = 0, curve = "stepped" },
    { time = 0.8666, x = 0, y = 0, curve = "stepped" },
    { time = 1.1666, x = 0, y = 0, curve = "stepped" },
    { time = 1.2333, x = 0, y = 0 },
    { time = 1.3, x = -12, y = 0, curve = "stepped" },
    { time = 1.3333, x = -12, y = 0, curve = "stepped" },
    { time = 1.3666, x = -12, y = 0, curve = "stepped" },
    { time = 1.4, x = -12, y = 0 },
    { time = 1.5, x = 28.48, y = -1.57 },
    { time = 1.5333, x = 40.57, y = 2.62 },
    { time = 1.6, x = 36.89, y = 0, curve = "stepped" },
    { time = 1.6333, x = 36.89, y = 0 },
    { time = 1.6666, x = -7.92, y = 2.71 },
    { time = 1.7, x = 36.89, y = 0 },
    { time = 1.7333, x = -5.55, y = 0.71 },
    { time = 1.8333, x = -18.23, y = 3.06 },
    { time = 2, x = -50.6, y = 2.86 },
    { time = 2.0666, x = -16.74, y = 33.83 },
    { time = 2.1666, x = -40.06, y = 69.88 },
    { time = 2.3, x = -54.63, y = 104.53 },
    { time = 2.4333, x = -83.08, y = 126.65 },
    { time = 2.7333, x = -106.54, y = 146.34 },
    { time = 2.8, x = -134.25, y = 148.65 },
    { time = 2.8333, x = -86.88, y = 164.53 },
    { time = 2.8666, x = -124.22, y = 66.88 },
    { time = 2.9333, x = -130.67, y = 66.88 },
    { time = 3.0666, x = -131.39, y = 67.6 },
    { time = 3.1, x = -288.27, y = 15.21 },
    { time = 3.1333, x = -221.83, y = 1.43 },
    { time = 3.2, x = -224.34, y = 2.31 },
    { time = 3.3, x = -222.91, y = 3.03 },
    { time = 3.5333, x = -221.48, y = 0.88 },
    { time = 3.5666, x = -192.55, y = -0.33 }
}

local function calcFinalCrit(attacker, attackee)
    local attackerCrit = attacker:getCrit() -- 暴击率
    local attackerCritLevel = attacker:getCritLevel()  -- 暴击等级
    local attackerCritReduceDecrease = attacker:getCritReduceDecrease()  -- 降低目标抗暴率
    local attackerCritReduceLevelDecrease = attacker:getCritReduceLevelDecrease()  -- 降低目标抗暴等级
    local attackeeCritReduce = attackee:getCritReduce()  -- 抗暴率
    local attackeeCritReduceLevel = attackee:getCritReduceLevel()  -- 抗暴等级
    local attackeeCritDecrease = attackee:getCritDecrease() -- 降低（作为）目标（时）暴击率
    local attackeeCritLevelDecrease = attackee:getCritLevelDecrease() -- 降低（作为）目标（时）暴击等级
    local critK = attackee:getLevelCoefficient().crit
    local critKTreat = attackee:getLevelCoefficient().crit_treat
    local critReduceK = attacker:getLevelCoefficient().cri_reduce

    local finalCrit
    if not attacker:isHealth() then
        local critLevel = math.max(0, attackerCritLevel - attackeeCritLevelDecrease)
        local crit = (critLevel / (critLevel + critK)) * 100 + attackerCrit - attackeeCritDecrease
        crit = math.clamp(crit, 0, 99.9999)
        local critReduceLevel = math.max(0, attackeeCritReduceLevel - attackerCritReduceLevelDecrease)
        local critReduce = (critReduceLevel / (critReduceLevel + critReduceK)) * 100 + attackeeCritReduce - attackerCritReduceDecrease
        critReduce = math.clamp(critReduce, 0, 99.9999)
        finalCrit = math.max(0, crit - critReduce)
    else
        local critLevel = math.max(0, attackerCritLevel - attackeeCritLevelDecrease)
        local crit = 5 + 0.2 * (critLevel / (critLevel + critKTreat)) * 100 + attackerCrit - attackeeCritDecrease
        crit = math.clamp(crit, 0, 99.9999)
        finalCrit = math.max(0, crit)
    end
    return finalCrit
end

local function calcFinalDodge(attacker, attackee)
    local attackerHit = attacker:getHit()
    local attackerHitLevel = attacker:getHitLevel()
    local attackerDodgeDecrease = attacker:getDodgeDecrease()
    local attackerDodgeLevelDecrease = attacker:getDodgeLevelDecrease()
    local attackeeDodge = attackee:getDodge()
    local attackeeDodgeLevel = attackee:getDodgeLevel()
    local attackeeHitDecrease = attackee:getHitDecrease()
    local attackeeHitLevelDecrease = attackee:getHitLevelDecrease()
    local dodgeK = attacker:getLevelCoefficient().dodge
    local hitK = attackee:getLevelCoefficient().hit
    local hitRate = math.max(0, attackerHitLevel - attackeeHitLevelDecrease)
    local hit = math.clamp(hitRate / (hitRate + hitK) * 100 + attackerHit - attackeeHitDecrease, 0, 99.9999)
    local dodgeRate = math.max(0, attackeeDodgeLevel - attackerDodgeLevelDecrease)
    local dodge = math.clamp(dodgeRate / (dodgeRate + dodgeK) * 100 + attackeeDodge - attackerDodgeDecrease, 0, 99.9999)
    local finalDodge = math.max(0, dodge - hit)
    return finalDodge
end

local function calcFinalBlock(attacker, attackee)
    local attackeeBlock = attackee:getBlock()
    local attackeeBlockLevel = attackee:getBlockLevel()
    local attackeeWreckDecrease = attackee:getWreckDecrease()
    local attackeeWreckLevelDecrease = attackee:getWreckLevelDecrease()
    local attackerWreck = attacker:getWreck()
    local attackerWreckLevel = attacker:getWreckLevel()
    local attackerBlockDecrease = attacker:getBlockDecrease()
    local attackerBlockLevelDecrease = attacker:getBlockLevelDecrease()
    local blockK = attacker:getLevelCoefficient().block
    local wreckK = attackee:getLevelCoefficient().wreck
    local wreckRate = math.max(0, attackerWreckLevel - attackeeWreckLevelDecrease)
    local wreck = math.clamp(wreckRate / (wreckRate + wreckK) * 100 + attackerWreck - attackeeWreckDecrease, 0, 99.9999)
    local blockRate = math.max(0, attackeeBlockLevel - attackerBlockLevelDecrease)
    local block = math.clamp(blockRate / (blockRate + blockK) * 100 + attackeeBlock - attackerBlockDecrease, 0, 99.9999)
    local finalBlock = math.max(0, block - wreck)
    return finalBlock
end

-- 配置表或者其他脚本取属性最终值的函数对照表
QActor.funcTable = {
    max_attack = "getMaxAttack",
    max_hp = "getMaxHp",
    max_physical_armor = "getPhysicalArmor",
    max_magic_armor = "getMagicArmor",
    max_crit = "getCrit",
    max_crit_reduce = "getCritReduce",
}

-- 常量
QActor.ATTACK_COOLDOWN = 0.2 -- 开火冷却时间

-- 定义事件
QActor.CHANGE_STATE_EVENT       = "CHANGE_STATE_EVENT"
QActor.START_EVENT              = "START_EVENT"
QActor.READY_EVENT              = "READY_EVENT"
QActor.ATTACK_EVENT             = "ATTACK_EVENT"
QActor.MOVE_EVENT               = "MOVE_EVENT"
QActor.FREEZE_EVENT             = "FREEZE_EVENT"
QActor.THAW_EVENT               = "THAW_EVENT"
QActor.KILL_EVENT               = "KILL_EVENT"
QActor.RELIVE_EVENT             = "RELIVE_EVENT"
QActor.HP_CHANGED_EVENT         = "HP_CHANGED_EVENT"
QActor.MAX_HP_CHANGED_EVENT     = "MAX_HP_CHANGED_EVENT"
QActor.ABSORB_CHANGE_EVENT      = "ABSORB_CHANGE_EVENT"
QActor.HP_CHANGED_EVENT_INFINITE= "HP_CHANGED_EVENT_INFINITE"
QActor.CP_CHANGED_EVENT         = "CP_CHANGED_EVENT"
QActor.RP_CHANGED_EVENT         = "RP_CHANGED_EVENT"
QActor.UNDER_ATTACK_EVENT       = "UNDER_ATTACK_EVENT"
QActor.SET_POSITION_EVENT       = "SET_POSITION_EVENT"
QActor.SET_HEIGHT_EVENT         = "SET_HEIGHT_EVENT"
QActor.VICTORY_EVENT            = "VICTORY_EVENT"
QActor.USE_MANUAL_SKILL_EVENT   = "USE_MANUAL_SKILL_EVENT"
QActor.ONE_TRACK_START_EVENT    = "ONE_TRACK_START_EVENT"
QActor.ONE_TRACK_END_EVENT      = "ONE_TRACK_END_EVENT"
QActor.FORCE_AUTO_CHANGED_EVENT = "FORCE_AUTO_CHANGED_EVENT"
QActor.SPEAK_EVENT              = "SPEAK_EVENT"
QActor.SHOW_CCB                 = "SHOW_CCB"
QActor.TRIGGER_PASSIVE_SKILL    = "TRIGGER_PASSIVE_SKILL"
QActor.DECREASEHP_EVENT         = "DECREASEHP_EVENT"
QActor.HP_LIMIT_CHANGE_EVENT    = "HP_LIMIT_CHANGE_EVENT"
QActor.END                      = "BATTLE_END"

QActor.ACTION_DRAG_ATTACK   = 1
QActor.ACTION_DRAG_MOVE     = 2
QActor.ACTION_MANUAL_SKILL  = 3
QActor.ACTION_ONMARK        = 4
QActor.ACTION_ONUNMARK      = 5

QActor.BUFF_STARTED        = "BUFF_STARTED"
QActor.BUFF_ENDED          = "BUFF_ENDED"
QActor.BUFF_MUTED          = "BUFF_MUTED"

QActor.MARK_STARTED        = "MARK_STARTED"
QActor.MARK_ENDED          = "MARK_ENDED"

QActor.PLAY_SKILL_ANIMATION = "PLAY_SKILL_ANIMATION"
QActor.ANIMATION_ENDED     = "ANIMATION_ENDED"
QActor.ANIMATION_ATTACK     = "ANIMATION_ATTACK"
QActor.PLAY_SKILL_EFFECT = "PLAY_SKILL_EFFECT"
QActor.STOP_SKILL_EFFECT = "STOP_SKILL_EFFECT"
QActor.CANCEL_SKILL = "CALCEL_SKILL"
QActor.SKILL_END = "SKILL_END"

QActor.CUSTOM_EVENT_HP_CHANGE = "hp_change"
QActor.CUSTOM_EVENT_BUFF_REMOVE = "buff_remove"
QActor.CUSTOM_EVENT_BUFF_REMOVE_WHEN_DEATH = "buff_remove_when_death"
QActor.CUSTOM_EVENT_HIT = "hit"
QActor.CUSTOM_EVENT_IMMUNE_DEATH = "immune_death"

-- 手动模式枚举
QActor.AUTO = "AUTO"       -- 自动模式
QActor.STAY = "STAY"       -- 手动模式：呆在某地
QActor.ATTACK = "ATTACK"   -- 手动模式：攻击敌人

QActor.DIRECTION_LEFT  = "left"
QActor.DIRECTION_RIGHT  = "right"

function QActor:get(key)
    return self._getInfo[key]
end

function QActor:set(key, value)
    self._getInfo[key] = value
end

function QActor:getId()
    return self._udid
end

local _QActor_pvpCoefficients = {}
local _pvpCoefficientsInitialized = false
local function InitializePVPCoefficients()
    if _pvpCoefficientsInitialized == false then
        local globalConfig = db:getConfiguration()
        local function getValue(k, dv)
            local v = dv
            if globalConfig[k] ~= nil and globalConfig[k].value ~= nil then
                v = globalConfig[k].value
            end
            if type(v) == "string" then
                local words = string.split(v, ";")
                local objs = {}
                for _, word in ipairs(words) do
                    local words2 = string.split(word, ",")
                    if #words2 == 2 then
                        local obj = {}
                        obj[1] = tonumber(words2[1]) 
                        obj[2] = tonumber(words2[2])
                        objs[#objs + 1] = obj
                        obj[3] = #objs
                    end
                end
                table.sort(objs, function (obj1, obj2)
                    if obj1[2] < obj2[2] then
                        return true
                    elseif obj1[2] > obj2[2] then
                        return false
                    else
                        return obj1[3] < obj2[3]
                    end
                end)
                v = objs
            else
                v = {{v, 1, 1}}
            end
            _QActor_pvpCoefficients[k] = v
        end
        getValue("ARENA_MAX_HEALTH_COEFFICIENT", 1)
        getValue("SUNWELL_MAX_HEALTH_COEFFICIENT", 1)
        getValue("SILVERMINE_MAX_HEALTH_COEFFICIENT", 1)
        getValue("ARENA_FINAL_DAMAGE_COEFFICIENT", 1)
        getValue("SUNWELL_FINAL_DAMAGE_COEFFICIENT", 1)
        getValue("SILVERMINE_FINAL_DAMAGE_COEFFICIENT", 1)
        getValue("ARENA_TREAT_COEFFICIENT", 1)
        getValue("SUNWELL_TREAT_COEFFICIENT", 1)
        getValue("SILVERMINE_TREAT_COEFFICIENT", 1)
        getValue("ARENA_BEATTACKED_CD_REDUCE", 0)

        getValue("STORM_ARENA_FINAL_DAMAGE_COEFFICIENT", 2)
        getValue("STORM_ARENA_TREAT_COEFFICIENT", 1)
        getValue("STORM_ARENA_MAX_HEALTH_COEFFICIENT", 1)

        getValue("ABYSS_FINAL_DAMAGE_COEFFICIENT", 2)
        getValue("ABYSS_TREAT_COEFFICIENT", 1)
        getValue("ABYSS_MAX_HEALTH_COEFFICIENT", 1)

        getValue("SOTO_TEAM_FINAL_DAMAGE_COEFFICIENT", 2)
        getValue("SOTO_TEAM_TREAT_COEFFICIENT", 1)
        getValue("SOTO_TEAM_MAX_HEALTH_COEFFICIENT", 1)
        getValue("SOTO_TEAM_EQUILIBRIUM_TREAT_COEFFICIENT", 1)

        getValue("TOTEM_CHALLENGE_FINAL_DAMAGE_COEFFICIENT", 2)
        getValue("TOTEM_CHALLENGE_TREAT_COEFFICIENT", 1)
        getValue("TOTEM_CHALLENGE_MAX_HEALTH_COEFFICIENT", 1)
        getValue("TOTEM_CHALLENGE_EQUILIBRIUM_TREAT_COEFFICIENT", 1)
        _pvpCoefficientsInitialized = true
    end
end

function QActor.setPVPCoefficientByLevel(level)
    InitializePVPCoefficients()
    for k, v in pairs(_QActor_pvpCoefficients) do
        local levelobj = v[#v]
        for _, obj in ipairs(v) do
            if level <= obj[2] then
                levelobj = obj
                break
            end
        end
        QActor[k] = levelobj[1]
    end
end

function QActor:ctor(actorInfo, events, callbacks, extraProp)
    self._getInfo = actorInfo.properties

    QActor.super.ctor(self, actorInfo.properties)

    -- fsm
    if IsServerSide then
        self.fsm__ = StateMachine.new()
    else
        -- 因为角色存在不同状态，所以这里为 QActor 绑定了状态机组件
        self:addComponent("components.behavior.StateMachine")
        -- 由于状态机仅供内部使用，所以不应该调用组件的 exportMethods() 方法，改为用内部属性保存状态机组件对象
        self.fsm__ = self:getComponent("components.behavior.StateMachine")
    end
    -- 设定状态机的默认事件
    local defaultEvents = {
        -- 初始化后，角色处于 idle 状态
        {name = "start",        from = {"none", "dead"},                                                                to = "idle"},
        -- 攻击               
        {name = "attack",       from = {"idle", "walking"},                                                             to = "attacking"},
        -- 特殊技能             
        {name = "skill",        from = {"idle", "attacking", "walking"},                                                to = "attacking"},
        -- 移动               
        {name = "move",         from = {"idle", "walking", "attacking"},                                                to = "walking"},
        -- 开火冷却结束
        {name = "ready",        from = {"attacking", "walking", "victorious", "idle", "beatbacking", "blowingup"},      to = "idle"},
        -- 角色被冰冻
        {name = "freeze",       from = {"idle", "attacking", "walking"},                                                to = "frozen"},
        -- 从冰冻状态恢复              
        {name = "thaw",         form = "frozen",                                                                        to = "idle"},
        -- 角色在正常状态和冰冻状态下都可能被杀死              
        {name = "kill",         from = {"attacking", "idle", "frozen", "walking", "beatbacking", "blowingup"},          to = "dead"},
        -- 复活               
        {name = "relive",       from = "dead",                                                                          to = "idle"},
        -- 胜利               
        {name = "victory",      from = {"idle", "walking", "attacking", "frozen"},                                      to = "victorious"},
        -- 击退               
        {name = "beatback",     from = {"idle", "walking", "attacking"},                                                to = "beatbacking"},
        -- 吹起               
        {name = "blowup",       from = {"idle", "walking", "attacking", "beatbacking"},                                 to = "blowingup"},
    }
    -- 如果继承类提供了其他事件，则合并
    table.insertto(defaultEvents, checktable(events))

    -- 设定状态机的默认回调
    local defaultCallbacks = {
        onchangestate = handler(self, self._onChangeState),
        onstart       = handler(self, self._onStart),
        onattack      = handler(self, self._onAttack),
        onskill       = handler(self, self._onSkill),
        onmove        = handler(self, self._onMove),
        onready       = handler(self, self._onReady),
        onfreeze      = handler(self, self._onFreeze),
        onthaw        = handler(self, self._onThaw),
        onkill        = handler(self, self._onKill),
        onrelive      = handler(self, self._onRelive),
        onvictory     = handler(self, self._onVictory),
        onbeforeready = handler(self, self._onBeforeReady),
    }
    -- 如果继承类提供了其他回调，则合并
    table.merge(defaultCallbacks, checktable(callbacks))

    self.fsm__:setupState({
        events = defaultEvents,
        callbacks = defaultCallbacks
    })

    -- view related
    self._opacity = 255
    self._isKeepAnimation = false
    self._sizeScales = {}
    self._animationScale = 1.0
    self._animationScales = {}
    self._propertyCoefficient = {}
    self._direction = QActor.DIRECTION_LEFT
    self._skin_id = actorInfo.skinId

    self._skin_info = q.cloneShrinkedObject(db:getHeroSkinConfigByID(actorInfo.skinId))
    assert(self._skin_info.character_id == nil or self._skin_info.character_id == actorInfo.actorId, "error skin id")
    local skin_skills = db:getSkinSkillsBySkinID(actorInfo.skinId)
    self._skin_info.replace_skills = {}
    for i,info in ipairs(skin_skills) do
        self._skin_info.replace_skills[info.old_skill] = info.new_skill
    end
    if self._skin_info.victory_skill then
        self:set("victory_skill", self._skin_info.victory_skill)
    end
    if self._skin_info.dead_skill then
        self:set("dead_skill", self._skin_info.dead_skill)
    end

    self._actor_id = tonumber(self:get("actor_id") or 0)
    self._udid = self:get("udid") or ""
    self._uuid = self:get("uuid")
    self._display_id = self:get("display_id")
    self._level = actorInfo.level or self:get("level") or 1
    self._speed = self:get("speed") or 120
    self._combo_points_auto = self:get("combo_points_auto" or 1)
    self._victory_skill = self:get("victory_skill") or -1
    self._dead_skill = self:get("dead_skill") or -1
    self._npc_ai = self:get("npc_ai") or ""
    self._npc_skill = self:get("npc_skill") or -1
    self._npc_skill2 = self:get("npc_skill2") or -1
    self._pet_id = self:get("pet_id") or -1
    self._attack_type = self:get("attack_type") or -1
    self._hit_dummy = self:get("hit_dummy")
    self._rage_decide_attack = self:get("rage_decide_attack")
    self._jingling_func = self:get("jingling_func")

    self._actorProp = QActorProp.new()
    if ACTOR_PRINT_ID == actorInfo.actorId then
        self._actorProp:setPrint(true)
    end
    self._actorProp:setHeroInfo(actorInfo, extraProp)
    self._breakthrough_value = actorInfo.breakthrough or 0
    self._grade_value = actorInfo.grade or 0
    self._skills = {}
    self._custom_event_list = setmetatable({}, {__mode = "k"}) --设置k为弱表，不能设置v 因为v一定是没其他引用的
    self._artifact_breakthrough = actorInfo.artifact and actorInfo.artifact.artifactBreakthrough
    self._is_SS = self:get("aptitude") == APTITUDE.SS
    self._actorInfo = actorInfo

    self._status_list = {}
    self._group_absorbs = {}

    if actorInfo.skillIds ~= nil then
        for _, skillId in ipairs(actorInfo.skillIds) do
            local id, level = self:_parseSkillID(skillId)
            if id and level then
                local skill = QSkill.new(id, {}, self, level)
                self._skills[id] = skill
            end
        end
        -- 暗器星级技能
        if actorInfo.zuoqi ~= nil then
            local zuoqiInfo = actorInfo.zuoqi
            local zuoqiId = zuoqiInfo.zuoqiId
            local zuoqiGrade = zuoqiInfo.grade or 0
            local isSupport = actorInfo.isSupport
            local gradeConfig = db:getGradeByHeroActorLevel(zuoqiId, zuoqiGrade)
            self._mount_id = zuoqiId
            if gradeConfig then
                local skill_term = isSupport and gradeConfig.zuoqi_skill_yz or gradeConfig.zuoqi_skill1_sz
                local skillIds = {}
                if type(skill_term) == "string" then
                    skillIds = string.split(skill_term, ";")
                else
                    skillIds[#skillIds + 1] = skill_term
                end
                for _, skillId in ipairs(skillIds) do
                    local id, level = self:_parseSkillID(skillId)
                    if id and level then
                        local skill = QSkill.new(id, {}, self, level)
                        skill:setMountId(zuoqiId)
                        self._skills[id] = skill
                    end
                end
                --配件技能
                if zuoqiInfo.wearZuoqiInfo and zuoqiInfo.wearZuoqiInfo.grade and not isSupport then
                    local gradeConfig = db:getGradeByHeroActorLevel(zuoqiId, zuoqiInfo.wearZuoqiInfo.grade)
                    local skill_term = gradeConfig.zuoqi_skill_pj
                    local skillIds = {}
                    if type(skill_term) == "string" then
                        skillIds = string.split(skill_term, ";")
                    else
                        skillIds[#skillIds + 1] = skill_term
                    end
                    for _, skillId in ipairs(skillIds) do
                        local id, level = self:_parseSkillID(skillId)
                        if id and level then
                            local skill = QSkill.new(id, {}, self, level)
                            skill:setMountId(zuoqiId)
                            self._skills[id] = skill
                        end
                    end
                end
            end
        end

        if actorInfo.godSkillGrade ~= nil and actorInfo.godSkillGrade > 0 then
            local id_string = db:getGodSkillByIdAndGrade(self._actor_id, actorInfo.godSkillGrade).skill_id
            local skillIds = string.split(id_string, ";")
            for _, skillId in ipairs(skillIds) do
                local id, level = self:_parseSkillID(skillId)
                if id and level then
                    local skill = QSkill.new(id, {}, self, level)
                    skill:setIsGodSkill()
                    self._skills[id] = skill
                end
            end
        end

        -- 晶石星级套装技能
        if actorInfo.spar ~= nil and #actorInfo.spar == 2 then
            local sparInfo = actorInfo.spar
            local itemId1 = sparInfo[1].itemId
            local itemId2 = sparInfo[2].itemId
            local index1 = db:getSparsIndexByItemId(sparInfo[1].itemId)
            local realItemId1 = index1 == 1 and itemId1 or itemId2
            local realItemId2 = index1 == 1 and itemId2 or itemId1
            local minGrade = math.min(sparInfo[1].grade or 0, sparInfo[2].grade or 0)
            local isSupport = actorInfo.isSupport
            local activeSuit = db:getActiveSparSuitInfoBySparId(realItemId1, realItemId2, minGrade+1)
            if activeSuit and next(activeSuit) ~= nil then
                local idStr = isSupport and activeSuit.skill_yz or activeSuit.skill_sz
                local idList = string.split(idStr, ";")
                local level = activeSuit.skill_level
                for _, ids in ipairs(idList) do
                    local id = tonumber(ids)
                    if id and level then
                        local skill = QSkill.new(id, {}, self, level)
                        self._skills[id] = skill
                    end
                end
            end
        end
        -- 有些被动技能能够修改其他技能的字段
        local t = {}
        for _, skill in pairs(self._skills) do
            local modify_skill_id = skill:getModifySkillID()
            local modify_skill_property = skill:getModifySkillProperty()
            if modify_skill_id and modify_skill_property then
                modify_skill_property = string.split(modify_skill_property, ";")
                local subt = t[modify_skill_id] or {}
                t[modify_skill_id] = subt
                for _, propertyName in ipairs(modify_skill_property) do
                    subt[propertyName] = skill:getOriginal(propertyName)
                end
            end
        end
        self._modifySkillTable = t
        for id, subt in pairs(t) do
            local skill = self._skills[id]
            if skill then
                local mountId = skill:getMountId()
                local modifiedSkill = QSkill.new(id, subt, self, skill:getSkillLevel())
                modifiedSkill:setMountId(mountId)
                self._skills[id] = modifiedSkill
            end
        end
        -- 有些被动技能能够提升其他技能的最终效果（伤害、治疗，甚至其他技能加的buff的效果）
        local t = {}
        for _, skill in pairs(self._skills) do
            local enhance_skill_id = skill:getEnhanceSkillID()
            local enhance_skill_value = skill:getEnhanceSkillValue()
            if enhance_skill_id  and enhance_skill_value then
                t[enhance_skill_id] = (t[enhance_skill_id] or 0) + enhance_skill_value
            end
        end
        self._enhanceSkillTable = t
        for id, value in pairs(t) do
            local skill = self._skills[id]
            if skill then
                skill:setEnhanceValue(value)
            end
        end
        -- 有些被动技能能够修改其他buff的字段
        local t = {}
        for _, skill in pairs(self._skills) do
            local modify_buff_id = skill:getModifyBuffID()
            local modify_buff_property = skill:getModifyBuffProperty()
            if modify_buff_id and modify_buff_property then
                modify_buff_property = string.split(modify_buff_property, ";")
                local subt = {}
                for _, property_value in ipairs(modify_buff_property) do
                     local kv = string.split(property_value, ",")
                     subt[kv[1]] = tonumber(kv[2])
                end
                modify_buff_id = string.split(modify_buff_id, ";")
                for _, buff_id in ipairs(modify_buff_id) do
                    t[buff_id] = subt
                end
            end
            
            local modify_buff_id = skill:getModifyBuffID2()
            local modify_buff_property = skill:getModifyBuffProperty2()
            if modify_buff_id and modify_buff_property then
                modify_buff_property = string.split(modify_buff_property, ";")
                local subt = {}
                for _, property_value in ipairs(modify_buff_property) do
                     local kv = string.split(property_value, ",")
                     subt[kv[1]] = tonumber(kv[2])
                end
                modify_buff_id = string.split(modify_buff_id, ";")
                for _, buff_id in ipairs(modify_buff_id) do
                    t[buff_id] = subt
                end
            end
        end
        self._modifyBuffTable = t
    end
    self:_initGlyphs(actorInfo.glyphs or {})
    self._displayInfo = q.cloneShrinkedObject(db:getCharacterDisplayByID(self:getDisplayID()))

    if self._skin_info then
        -- 皮肤会替换display的一些字段
        -- 这些字段本来寻思在get的时候再获取，可是actor_scale没办法这么做 就干脆都在这里写好了
        self._displayInfo.actor_scale = self._skin_info.skins_scale or self._displayInfo.actor_scale
        self._displayInfo.selected_rect_width = self._skin_info.selected_rect_width or self._displayInfo.selected_rect_width
        self._displayInfo.selected_rect_height = self._skin_info.selected_rect_height or self._displayInfo.selected_rect_height
        self._displayInfo.icon = self._skin_info.skins_head_icon or self._displayInfo.icon
        self._displayInfo.aid_bust = self._skin_info.skin_aid_bust or self._displayInfo.aid_bust
        self._displayInfo.actor_file = self._skin_info.skins_fca or self._displayInfo.actor_file
        self._displayInfo.victory_effect = self._skin_info.victory_effect or self._displayInfo.victory_effect
        self._displayInfo.additional_effects = self._skin_info.skins_additional_effects or self._displayInfo.additional_effects
    end

    self._manualSkills = {}
    self._activeSkills = {}
    self._passiveSkills = {}
    self._teamSkills = {}
    self._activeSkillsByPriority = {}
    self:_classifySkillByType()
    self._sbDirectors = {}
    self._sbDirectorsWaitingList = {} -- self._sbDirectorsWaitingList[i] = {sbDirector, minimum_interval, processed_time --[[nil, if not processed]]}
    self._currentSkill = nil
    self._currentSBDirector = nil
    self._nextAttackSkill = nil
    self._revive_count = 0
    self._immune_physical_damage = 0
    self._immune_magic_damage = 0
    self._hitlog = QHitLog.new()
    self._manual = QActor.AUTO
    self._position = {x = 0, y = 0}
    self._height = 0
    self._buffs = {}
    self._buffEventListeners = {}
    self._buffAttacker = {}
    self._passiveBuffApplied = false
    self._animationControlMove = false
    self._combo_points = 0
    self._combo_points_max = 5
    self._combo_points_total = 5
    self._rage = 0
    self._rage_total = 1000
    self._rage_attack = 0
    if not IsServerSide then
        self._hpValidate = q.createValidation()
    else
        self._hpValidate = {set = function()end, validate = function()end}
    end
    self._hpValidate:set(0)
    self._hp = 0
    self._supportSkillUsageCount = 0
    self._isLockTarget = 0
    self._isInBulletTime = false
    self._isInTimeStop = 0
    self._isLockHp = 0
    self._replaceCharacterId = nil
    self._actionEvents = {}
    self:_handleBattleEvents()
    self._replace_character_skill_lists = {}
    self:_initPropertyDict()
    self:_initActorNumberProperties()
    self:_applyStaticActorNumberProperties()
    self._additionalManualSkillDamageMultiplier = 1
    self._drainBloodPhysical = 0
    self._drainBloodMagic = 0
    self:_initRect()
    self._use_absorb_damage_value = 0

    self._neutralizeDamage = 0 -- 抵消的固定值伤害

    -- 风墙后面的目标列表
    self._ignoreHurtTargetsList = {}
    -- 开启风墙的参数
    self._ignoreHurtArgs = nil
    -- 契约缔结者，用于分担自己承受的伤害
    self._strikeAgreementers = {}

    self._buff_effect_reduce = 0 --增益buff降低的系数
    self._buff_effect_reduce_from_other = 0 --增益buff降低的系数
    self._adaptivityHelmetValue = 0 --适应性头盔系数
    self._functionCallBack = {}
    self._custom_status_list = {}
    self._absorbRenderValue = 0 -- 自身护盾反伤属性已反伤的value
    self._absorbRenderLimit = 0 -- 自身护盾反伤属性上限
    if app.battle then
        self:_initRageCoefficients()
    end
    self.fsm__:doEvent("start")

end

-- @property scale
-- @client
function QActor:setScale(scale)
    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(self)
        if view then
            view:setScale(scale)
        end
    end
end

function QActor:setSizeScale(scale, reason)
    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(self)
        if view then
            view:setSizeScale(scale, reason)
        end
    end
end

function QActor:getSizeScale(reason)
    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(self)
        if view then
            return view:getSizeScale(reason)
        end
    end
    return 1
end

-- @property animation scale
-- @client
function QActor:setAnimationScale(scale, reason)
    local finalScale = scale
    if not reason then
        finalScale = scale
    else
        if scale == 1 then
            scale = nil
        end
        self._animationScales[reason] = scale
        local result_scale = 1
        for _, sub_scale in pairs(self._animationScales) do
            result_scale = result_scale * sub_scale
        end
        finalScale = result_scale
    end
    self._animationScale = finalScale
    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(self)
        if view then
            view:setAnimationScale(finalScale)
        end
    end
end

-- animation functions
local empty = {}
function QActor:playSkillAnimation(animations, loop)
    if animations == nil then
        return
    end

    if not loop then
        if self._animationQueue then
            for _, oldAnimation in ipairs(self._animationQueue) do
                self:dispatchEvent({name = QActor.ANIMATION_ENDED, animationName = oldAnimation})
            end
        end
        self._animationQueue = animations
        local animationQueueTime = {}
        local animationQueueSpeed = {}
        local animationQueueLoop = {}
        local time
        for _, animation in ipairs(animations) do
            time = db:getCharacterAnimationDuration(self:getActorID(), animation, self:getReplaceCharacterId() and 0 or self._skin_id)
            animationQueueTime[#animationQueueTime + 1] = {time[1],  unpack(time[2] or empty)}
            animationQueueSpeed[#animationQueueSpeed + 1] = {unpack(time[3] or empty)}
            animationQueueLoop[#animationQueueLoop + 1] = {unpack(time[4] or empty)}
        end
        self._animationTimeQueue = animationQueueTime
        self._animationSpeedQueue = animationQueueSpeed
        self._animationLoopQueue = animationQueueLoop
        self._animationCurrentTime = 0
    end

    if not IsServerSide then
        self:dispatchEvent({name = QActor.PLAY_SKILL_ANIMATION, animations = animations, isLoop = loop}) 
    end
end

function QActor:jumpAnimationTime(totime)
    local time = db:getCharacterAnimationDuration(self:getActorID(), self._animationQueue[1], self:getReplaceCharacterId() and 0 or self._skin_id)
    local animationTime = {time[1], unpack(time[2] or empty)}
    local idx = 0
    while animationTime[2 + idx * 3] do
        if animationTime[2 + idx * 3] < totime then
            table.remove(animationTime, 2 + idx * 3)
            table.remove(animationTime, 2 + idx * 3)
            table.remove(animationTime, 2 + idx * 3)
        else
            idx = idx + 1
        end
    end
    local animationSpeed = {unpack(time[3] or empty)}
    local idx = 0
    while animationSpeed[1+ idx * 2] do
        if animationSpeed[1 + idx * 2] < totime then
            table.remove(animationSpeed, 1 + idx * 2)
            table.remove(animationSpeed, 1 + idx * 2)
        else
            idx = idx + 1
        end
    end
    self._animationTimeQueue[1] = animationTime
    self._animationSpeedQueue[1] = animationSpeed
    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(self)
        if view then
            view:jumpAnimationTime(totime)
        end
    end
end

function QActor:updateAnimation(dt)
    local animationQueue = self._animationQueue
    if animationQueue and #animationQueue > 0 then
        local animationQueueTime = self._animationTimeQueue
        local animationQueueSpeed = self._animationSpeedQueue
        local animationQueueLoop = self._animationLoopQueue
        local animationCurrentTime = self._animationCurrentTime
        animationCurrentTime = animationCurrentTime + dt * self._animationScale
        -- update attack event
        local curAnimationTime = animationQueueTime[1]
        local idx = 2
        while true do
            local atk_time = curAnimationTime[idx]
            if atk_time and atk_time <= animationCurrentTime then
                local atk_x = curAnimationTime[idx + 1] or 0
                local atk_y = curAnimationTime[idx + 2] or 0
                table.remove(curAnimationTime, idx)
                table.remove(curAnimationTime, idx)
                table.remove(curAnimationTime, idx)
                local animation = animationQueue[1]
                self:dispatchEvent({name = QActor.ANIMATION_ATTACK, animationName = animation, atk_x = atk_x, atk_y = -atk_y})
            else
                break
            end
        end
        if self._isNpcBoss then
            -- update speed event
            local curAnimationSpeed = animationQueueSpeed[1]
            local idx = 1
            while true do
                local spd_time = curAnimationSpeed[idx]
                if spd_time and spd_time <= animationCurrentTime then
                    local speed = curAnimationSpeed[idx + 1]
                    table.remove(curAnimationSpeed, idx)
                    table.remove(curAnimationSpeed, idx)
                    self:setAnimationScale(speed, "label-mark")
                else
                    break
                end
            end
            -- update loop event
            local curAnimationLoop = animationQueueLoop[1]
            local loopStart, loopCount, loopEnd = curAnimationLoop[1], curAnimationLoop[2], curAnimationLoop[3]
            if loopStart and loopCount and loopEnd then
                if animationCurrentTime > loopEnd then
                    if loopCount <= 0 then
                        table.remove(curAnimationLoop, 1)
                        table.remove(curAnimationLoop, 1)
                        table.remove(curAnimationLoop, 1)
                    else
                        loopCount = loopCount - 1
                        curAnimationLoop[2] = loopCount
                        animationCurrentTime = loopStart
                        self:jumpAnimationTime(animationCurrentTime)
                    end
                end
            end
        end
        -- animation end
        if animationCurrentTime >= animationQueueTime[1][1] then
            animationCurrentTime = 0 -- animationCurrentTime - animationQueueTime[1]
            local animation = animationQueue[1]
            table.remove(animationQueue, 1)
            table.remove(animationQueueTime, 1)
            table.remove(animationQueueSpeed, 1)
            table.remove(animationQueueLoop, 1)
            self:setAnimationScale(1.0, "label-mark")
            self:dispatchEvent({name = QActor.ANIMATION_ENDED, animationName = animation})
        end
        self._animationCurrentTime = animationCurrentTime

        if self._animationControlMove and animationQueue[1] then
            local translate = translate
            local time = self._animationCurrentTime
            local obj1, obj2
            for _, obj in ipairs(translate) do
                if obj.time <= time then
                    obj1 = obj
                elseif obj.time > time then
                    obj2 = obj
                    break
                end
            end
            if obj1 and obj2 then
                local offsetx = math.sampler2(obj1.x, obj2.x, obj1.time, obj2.time, time)
                local pos = self._animationControlMoveStartPosition
                local isFlip = self:isFlipX()
                local pos = {x = pos.x + (isFlip and -offsetx or offsetx), y = pos.y}
                app.grid:moveActorTo(self, pos, true, true, true)
                local rangeArea = app.grid:getRangeArea()
                pos.x = math.clamp(pos.x, rangeArea.left, rangeArea.right)
                self:setActorPosition(pos)
            end
        end
    end
end

local hp_related_property = {
    hp_value = true,
    hp_percent = true,
    hp_value_support = true,
}

local max_hp_related_property = {
    hp_final_additional = true,
    max_hp_stealed = true,
}

function QActor:_initPropertyDict()
    self._propertyDict = {}
    --enter_rage
    -- self:insertPropertyValue("enter_rage",self,"+",self._actorProp:getEnterRage())
    table.insert(self._propertyDict, {name = "enter_rage", operator = "+", getValue = function() return self._actorProp:getEnterRage() end, isNotFinal = true})
    -- hp 
    -- local hp_value, hp_percent = self._actorProp:getHpDetail()
    -- self:insertPropertyValue("recover_hp_limit", self, "+", 0)
    table.insert(self._propertyDict, {name = "recover_hp_limit", operator = "+", getValue = 0})
    -- self:insertPropertyValue("hp_value", self, "+", hp_value)
    table.insert(self._propertyDict, {name = "hp_value", operator = "+", getValue = function()
        local hp_value, hp_percent = self._actorProp:getHpDetail()
        return hp_value
    end, isNotFinal = true})

    table.insert(self._propertyDict, {name = "hp_value_support", operator = "+", getValue = 0, isNotFinal = true, isNotApply = true})
    table.insert(self._propertyDict, {name = "max_hp_stealed", operator = "+", getValue = 0})
    -- self:insertPropertyValue("hp_percent", self, "+", hp_percent)
    table.insert(self._propertyDict, {name = "hp_percent", operator = "+", getValue = function()
        local hp_value, hp_percent = self._actorProp:getHpDetail()
        return hp_percent
    end, isNotFinal = true})
    table.insert(self._propertyDict, {name = "hp_final_additional", operator = "+", getValue = 0})
    -- attack
    -- local attack_value, attack_percent = self._actorProp:getAttackDetail()
    -- self:insertPropertyValue("attack_value", self, "+", attack_value)
    table.insert(self._propertyDict, {name = "attack_value", operator = "+", getValue = function()
        local attack_value, attack_percent = self._actorProp:getAttackDetail()
        return attack_value
    end, isNotFinal = true})
    -- self:insertPropertyValue("attack_percent", self, "+", attack_percent)
    table.insert(self._propertyDict, {name = "attack_percent", operator = "+", getValue = function()
        local attack_value, attack_percent = self._actorProp:getAttackDetail()
        return attack_percent
    end, isNotFinal = true})
    table.insert(self._propertyDict, {name = "attack_value_support", operator = "+", getValue = 0, isNotFinal = true, isNotApply = true})
    table.insert(self._propertyDict, {name = "attack_value_stealed", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "attack_value_final_additional", operator = "+", getValue = 0})
    -- armor physical
    -- self:insertPropertyValue("armor_physical", self, "+", self._actorProp:getMaxArmorPhysical())
    table.insert(self._propertyDict, {name = "armor_physical", operator = "+",
        getValue = function() return self._actorProp:getMaxArmorPhysical() end, isNotFinal = true})
    table.insert(self._propertyDict, {name = "armor_physical_percent", operator = "+",
        getValue = 0, isNotFinal = true})
    table.insert(self._propertyDict, {name = "armor_physical_stealed", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "armor_physical_final_additional", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "armor_magic_final_additional", operator = "+", getValue = 0})

    -- armor magic
    -- self:insertPropertyValue("armor_magic", self, "+", self._actorProp:getMaxArmorMagic())
    table.insert(self._propertyDict, {name = "armor_magic", operator = "+",
        getValue = function() return self._actorProp:getMaxArmorMagic() end, isNotFinal = true})
    table.insert(self._propertyDict, {name = "armor_magic_percent", operator = "+",
        getValue = 0, isNotFinal = true})
    table.insert(self._propertyDict, {name = "armor_magic_stealed", operator = "+", getValue = 0})
    -- physical penetration
    -- local physical_penetration_value, physical_penetration_percent = self._actorProp:getPhysicalPenetrationDetail()
    -- self:insertPropertyValue("physical_penetration_value", self, "+", physical_penetration_value)
    table.insert(self._propertyDict, {name = "physical_penetration_value", operator = "+", getValue = function()
        local physical_penetration_value, physical_penetration_percent = self._actorProp:getPhysicalPenetrationDetail()
        return physical_penetration_value
    end, isNotFinal = true})
    -- self:insertPropertyValue("physical_penetration_percent", self, "+", physical_penetration_percent)
    table.insert(self._propertyDict, {name = "physical_penetration_percent", operator = "+", getValue = function()
        local physical_penetration_value, physical_penetration_percent = self._actorProp:getPhysicalPenetrationDetail()
        return physical_penetration_percent
    end, isNotFinal = true})
    -- magic penetration
    local magic_penetration_value, magic_penetration_percent = self._actorProp:getMagicPenetrationDetail()
    -- self:insertPropertyValue("magic_penetration_value", self, "+", magic_penetration_value)
    table.insert(self._propertyDict, {name = "magic_penetration_value", operator = "+", getValue = function()
        local magic_penetration_value, magic_penetration_percent = self._actorProp:getMagicPenetrationDetail()
        return magic_penetration_value
    end, isNotFinal = true})
    -- self:insertPropertyValue("magic_penetration_percent", self, "+", magic_penetration_percent)
    table.insert(self._propertyDict, {name = "magic_penetration_percent", operator = "+", getValue = function()
        local magic_penetration_value, magic_penetration_percent = self._actorProp:getMagicPenetrationDetail()
        return magic_penetration_percent
    end, isNotFinal = true})
    -- move speed
    -- self:insertPropertyValue("movespeed_value", self, "+", self._speed)
    table.insert(self._propertyDict, {name = "movespeed_value", operator = "+", getValue = function() return self._speed end, isNotFinal = true})
    table.insert(self._propertyDict, {name = "movespeed_replace", operator = "+", getValue = 0, isNotFinal = true})
    table.insert(self._propertyDict, {name = "movespeed_percent", operator = "+", getValue = 0, isNotFinal = true})
    -- hit rating
    -- self:insertPropertyValue("hit_rating", self, "+", self._actorProp:getMaxHit())
    table.insert(self._propertyDict, {name = "hit_rating", operator = "+", getValue = function() return self._actorProp:getMaxHit() end})
    -- hit chance
    -- self:insertPropertyValue("hit_chance", self, "+", self._actorProp:getHitChance())
    table.insert(self._propertyDict, {name = "hit_chance", operator = "+", getValue = function() return self._actorProp:getHitChance() end})
    table.insert(self._propertyDict, {name = "hit_chance_decrease", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "hit_rating_decrease", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "precise", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "deflection", operator = "+", getValue = 0})
    -- dodge rating
    -- self:insertPropertyValue("dodge_rating", self, "+", self._actorProp:getMaxDodge())
    table.insert(self._propertyDict, {name = "dodge_rating", operator = "+", getValue = function() return self._actorProp:getMaxDodge() end})
    -- dodge chance
    -- self:insertPropertyValue("dodge_chance", self, "+", self._actorProp:getDodgeChance())
    table.insert(self._propertyDict, {name = "dodge_chance", operator = "+", getValue = function() return self._actorProp:getDodgeChance() end})
    table.insert(self._propertyDict, {name = "dodge_chance_decrease", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "dodge_rating_decrease", operator = "+", getValue = 0})
    -- block
    -- self:insertPropertyValue("block_rating", self, "+", self._actorProp:getMaxBlock())
    table.insert(self._propertyDict, {name = "block_rating", operator = "+", getValue = function() return self._actorProp:getMaxBlock() end})
    -- self:insertPropertyValue("block_chance", self, "+", self._actorProp:getBlockChance())
    table.insert(self._propertyDict, {name = "block_chance", operator = "+", getValue = function() return self._actorProp:getBlockChance() end})
    table.insert(self._propertyDict, {name = "block_chance_decrease", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "block_rating_decrease", operator = "+", getValue = 0})
    -- self:insertPropertyValue("wreck_rating", self, "+", self._actorProp:getMaxWreck())
    table.insert(self._propertyDict, {name = "wreck_rating", operator = "+", getValue = function() return self._actorProp:getMaxWreck() end})
    -- self:insertPropertyValue("wreck_chance", self, "+", self._actorProp:getWreckChance())
    table.insert(self._propertyDict, {name = "wreck_chance", operator = "+", getValue = function() return self._actorProp:getWreckChance() end})
    table.insert(self._propertyDict, {name = "wreck_chance_decrease", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "wreck_rating_decrease", operator = "+", getValue = 0})
    -- critical rating
    -- self:insertPropertyValue("critical_rating", self, "+", self._actorProp:getMaxCrit())
    table.insert(self._propertyDict, {name = "critical_rating", operator = "+", getValue = function() return self._actorProp:getMaxCrit() end})
    -- critical chance
    -- self:insertPropertyValue("critical_chance", self, "+", self._actorProp:getMaxCriticalChance())
    table.insert(self._propertyDict, {name = "critical_chance", operator = "+",getValue = function() return self._actorProp:getMaxCriticalChance() end})
    -- critical reduce rating
    -- self:insertPropertyValue("crit_reduce_rating", self, "+", self._actorProp:getMaxCriReduce())
    table.insert(self._propertyDict, {name = "crit_reduce_rating", operator = "+", getValue = function() return self._actorProp:getMaxCriReduce() end})
    table.insert(self._propertyDict, {name = "crit_reduce_rating_stealed", operator = "+", getValue = 0})
    -- critical reduce chance
    -- self:insertPropertyValue("crit_reduce_chance", self, "+", self._actorProp:getMaxCriReduceChance())
    table.insert(self._propertyDict, {name = "crit_reduce_chance", operator = "+", getValue = function() return self._actorProp:getMaxCriReduceChance() end})
    table.insert(self._propertyDict, {name = "crit_reduce_chance_decrease", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "critical_chance_decrease", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "critical_rating_decrease", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "crit_reduce_rating_decrease", operator = "+", getValue = 0})
    -- haste
    -- self:insertPropertyValue("haste_rating", self, "+", self._actorProp:getMaxHaste())
    table.insert(self._propertyDict, {name = "haste_rating", operator = "+", getValue = function() return self._actorProp:getMaxHaste() end})
    table.insert(self._propertyDict, {name = "attackspeed_stealed", operator = "+", getValue = 0})
    -- self:insertPropertyValue("attackspeed_chance", self, "+", self._actorProp:getAttackSpeedChance())
    table.insert(self._propertyDict, {name = "attackspeed_chance", operator = "+", getValue = function() return self._actorProp:getAttackSpeedChance() end})
    -- critical damage
    -- self:insertPropertyValue("critical_damage", self, "+", self:get("critdamage_p"))
    table.insert(self._propertyDict, {name = "critical_damage", operator = "+", getValue = function() return self:get("critdamage_p") end})
    table.insert(self._propertyDict, {name = "critical_damage_resist", operator = "+", getValue = 0})
    -- misc
    -- self:insertPropertyValue("physical_damage_percent_attack", self, "+", self._actorProp:getPhysicalDamagePercentAttack())
    table.insert(self._propertyDict, {name = "physical_damage_percent_attack", operator = "+", getValue = function()
        return self._actorProp:getPhysicalDamagePercentAttack() + self._actorProp:getOnlyBattleProp("physical_damage_percent_attack") end})
    -- self:insertPropertyValue("magic_damage_percent_attack", self, "+", self._actorProp:getMagicDamagePercentAttack())
    table.insert(self._propertyDict, {name = "magic_damage_percent_attack", operator = "+", getValue = function()
        return self._actorProp:getMagicDamagePercentAttack() + self._actorProp:getOnlyBattleProp("magic_damage_percent_attack") end})
    -- self:insertPropertyValue("magic_treat_percent_attack", self, "+", self._actorProp:getMagicTreatPercentAttack())
    table.insert(self._propertyDict, {name = "magic_treat_percent_attack", operator = "+", getValue = function() return self._actorProp:getMagicTreatPercentAttack() end})
    -- self:insertPropertyValue("physical_damage_percent_beattack", self, "+", self._actorProp:getPhysicalDamagePercentBeattackTotal())
    table.insert(self._propertyDict, {name = "physical_damage_percent_beattack", operator = "+", getValue = function() return self._actorProp:getPhysicalDamagePercentBeattackTotal() end})
    -- self:insertPropertyValue("physical_damage_percent_beattack_reduce", self, "+", self._actorProp:getPhysicalDamagePercentBeattackReduceTotal())
    table.insert(self._propertyDict, {name = "physical_damage_percent_beattack_reduce", operator = "+", getValue = function()
        return self._actorProp:getPhysicalDamagePercentBeattackReduceTotal() + self._actorProp:getOnlyBattleProp("physical_damage_percent_beattack_reduce") end})
    -- self:insertPropertyValue("magic_damage_percent_beattack", self, "+", self._actorProp:getMagicDamagePercentBeattackTotal())
    table.insert(self._propertyDict, {name = "magic_damage_percent_beattack", operator = "+", getValue = function() return self._actorProp:getMagicDamagePercentBeattackTotal() end})
    -- self:insertPropertyValue("magic_damage_percent_beattack_reduce", self, "+", self._actorProp:getMagicDamagePercentBeattackReduceTotal())
    table.insert(self._propertyDict, {name = "magic_damage_percent_beattack_reduce", operator = "+", getValue = function()
        return self._actorProp:getMagicDamagePercentBeattackReduceTotal() + self._actorProp:getOnlyBattleProp("magic_damage_percent_beattack_reduce") end})
    -- self:insertPropertyValue("magic_treat_percent_beattack", self, "+", self._actorProp:getMagicTreatPercentBeattackTotal())
    table.insert(self._propertyDict, {name = "magic_treat_percent_beattack", operator = "+", getValue = function() return self._actorProp:getMagicTreatPercentBeattackTotal() end})
    -- pvp property
    -- self:insertPropertyValue("pvp_physical_damage_percent_beattack_reduce", self, "+", self._actorProp:getPVPPhysicalReducePercent())
    table.insert(self._propertyDict, {name = "pvp_physical_damage_percent_beattack_reduce", operator = "+", getValue = function() return self._actorProp:getPVPPhysicalReducePercent() end})
    -- self:insertPropertyValue("pvp_magic_damage_percent_beattack_reduce", self, "+", self._actorProp:getPVPMagicReducePercent())
    table.insert(self._propertyDict, {name = "pvp_magic_damage_percent_beattack_reduce", operator = "+", getValue = function() return self._actorProp:getPVPMagicReducePercent() end})
    -- self:insertPropertyValue("pvp_physical_damage_percent_attack", self, "+", self._actorProp:getPVPPhysicalAttackPercent())
    table.insert(self._propertyDict, {name = "pvp_physical_damage_percent_attack", operator = "+", getValue = function() return self._actorProp:getPVPPhysicalAttackPercent() end})
    -- self:insertPropertyValue("pvp_magic_damage_percent_attack", self, "+", self._actorProp:getPVPMagicAttackPercent())
    table.insert(self._propertyDict, {name = "pvp_magic_damage_percent_attack", operator = "+", getValue = function() return self._actorProp:getPVPMagicAttackPercent() end})
    -- aoe property
    -- self:insertPropertyValue("aoe_attack_percent", self, "+", 0)
    table.insert(self._propertyDict, {name = "aoe_attack_percent", operator = "+", getValue = 0})
    -- self:insertPropertyValue("aoe_beattack_percent", self, "+", 0)
    table.insert(self._propertyDict, {name = "aoe_beattack_percent", operator = "+", getValue = 0})
    -- self:insertPropertyValue("limit_rage_upper", self, "+", self._actorProp:getRageLimitUpper())
    table.insert(self._propertyDict, {name = "limit_rage_upper", operator = "+", getValue = function() return self._actorProp:getRageLimitUpper() end, isNotFinal = true})

    -- self:insertPropertyValue("extra_physical_penetration_value", self, "+", 0)
    table.insert(self._propertyDict, {name = "extra_physical_penetration_value", operator = "+", getValue = 0})
    -- self:insertPropertyValue("extra_magic_penetration_value", self, "+", 0)
    table.insert(self._propertyDict, {name = "extra_magic_penetration_value", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "magic_penetration_support", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "physical_penetration_support", operator = "+", getValue = 0})
    -- self:insertPropertyValue("ignore_magic_armor_percent", self, "+", 0)
    table.insert(self._propertyDict, {name = "ignore_magic_armor_percent", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "ignore_magic_armor_resist_percent", operator = "+", getValue = 0})
    -- self:insertPropertyValue("ignore_physical_armor_percent", self, "+", 0)
    table.insert(self._propertyDict, {name = "ignore_physical_armor_percent", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "ignore_physical_armor_resist_percent", operator = "+", getValue = 0})


    -- self:insertPropertyValue("rage_increase_coefficient", self, "+", 0)
    table.insert(self._propertyDict, {name = "rage_increase_coefficient", operator = "+", getValue = 0, isNotFinal = true})
    -- self:insertPropertyValue("pve_damage_percent_attack", self, "+", 0)
    table.insert(self._propertyDict, {name = "pve_damage_percent_attack", operator = "+",
        getValue = function() return self._actorProp:getPVEDamagePercentAttack() end})
    -- self:insertPropertyValue("pve_damage_percent_beattack", self, "+", 0)
    table.insert(self._propertyDict, {name = "pve_damage_percent_beattack", operator = "+",
        getValue = function() return self._actorProp:getPVEDamagePercentBeattack() end})
    -- self:insertPropertyValue("rage_skill_gain_percent", self, "+", 0)
    table.insert(self._propertyDict, {name = "rage_skill_gain_percent", operator = "+", getValue = 0, isNotFinal = true})
    -- self:insertPropertyValue("rage_beattack_gain_percent", self, "+", 0)
    table.insert(self._propertyDict, {name = "rage_beattack_gain_percent", operator = "+", getValue = 0, isNotFinal = true})
    table.insert(self._propertyDict, {name = "absorb_render_damage_cofficient", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "absorb_render_heal_cofficient", operator = "+", getValue = 0})
    table.insert(self._propertyDict, {name = "soul_damage_percent_beattack_reduce", operator = "+",
        getValue = function() return self._actorProp:getSoulDamagePercentBeattackReduce() end})
    table.insert(self._propertyDict, {name = "soul_damage_percent_attack", operator = "+",
        getValue = function() return self._actorProp:getSoulDamagePercentAttack() end})

    -- self:insertPropertyValue("attack_target_rage_percent", self, "+", 0)
    table.insert(self._propertyDict, {name = "attack_target_rage_percent", operator = "+", getValue = 0, isNotFinal = true})
    if app.battle and app.battle:isSotoTeamEquilibrium() then
        table.insert(self._propertyDict, {name = "hp_equilibrium", operator = "+", getValue = 0
            ,isNotFinal = true, isNotApply = true})
        table.insert(self._propertyDict, {name = "attack_equilibrium", operator = "+", getValue = 0
            ,isNotFinal = true, isNotApply = true})
        table.insert(self._propertyDict, {name = "magic_armor_equilibrium", operator = "+", getValue = 0
            ,isNotFinal = true, isNotApply = true})
        table.insert(self._propertyDict, {name = "physical_armor_equilibrium", operator = "+", getValue = 0
            ,isNotFinal = true, isNotApply = true})
        table.insert(self._propertyDict, {name = "magic_penetration_equilibrium", operator = "+", getValue = 0
            ,isNotFinal = true, isNotApply = true})
        table.insert(self._propertyDict, {name = "physical_penetration_equilibrium", operator = "+", getValue = 0
            ,isNotFinal = true, isNotApply = true})
    end
end

function QActor:getPropertyDict()
    return self._propertyDict
end

function QActor:_initActorNumberProperties()
    -- 创建属性堆栈 property stack
    self._number_properties = {}
    self._number_properties_final_value = {}

    for _, propertyObj in ipairs(self._propertyDict) do
        self:_createActorNumberProperty(propertyObj.name)
    end
end

function QActor:_applyStaticActorNumberProperties()
    for _, propertyObj in ipairs(self._propertyDict) do
        if not propertyObj.isNotApply then
            self:removePropertyValue(propertyObj.name, self)
            local value
            if type(propertyObj.getValue) == "function" then
                value = propertyObj.getValue()
            else
                value = propertyObj.getValue
            end
            self:insertPropertyValue(propertyObj.name, self, propertyObj.operator, value)
        end
    end
end

function QActor:_createActorNumberProperty(property_name)
    local property = createActorNumberProperty()
    self[property_name] = 0
    local setter = function(value)
        self[property_name] = value
    end
    property:setFinalValueSetter(setter)
    self._number_properties[property_name] = property
end

function QActor:_getActorNumberPropertyValue(property_name)
    local battle = app.battle
    if battle then
        return self[property_name] + battle:getTeamSkillProperty(self, property_name)
    else
        if self._extralPorp then
            return self[property_name] + (self._extralPorp[property_name] or 0)
        else
            return self[property_name]
        end
    end
    -- return self._number_properties[property_name]:getFinalValue()
end

function QActor:_getActorNumberPropertyValueCount(property_name)
    return self._number_properties[property_name]:getCount()
end

function QActor:_debugPrintPropertyValue(property_name)
    print(property_name)
    local array = self._number_properties[property_name]:getCalculationArray()
    for _, obj in ipairs(array) do
        if type(obj.stub) == "table" then
            print(obj.operator, obj.value, obj.stub:getId(), obj.stub.__cname)
        else
            print(obj.operator, obj.value, obj.stub)
        end
    end
end

function QActor:_getPropertyValueSourceStr(property_name, isPrint)
    local str = ""
    local array = self._number_properties[property_name]:getCalculationArray()

    for _, obj in ipairs(array) do
        local operator = obj.operator
        local value = obj.value
        local stub = obj.stub
        if type(stub) == "table" then
            if iskindof(stub, "QActor") then
                if stub == self then
                    stub = "self"
                else
                    stub = string.format("support(%s)", stub:getId())
                end
            elseif stub.getId then
                stub = string.format("%s(%s)", stub:getId(), tostring(stub.__cname))
            end
        end
        str = str .. string.format("%s:\t%s\t%s\n", stub, operator, value)
    end

    str = str .. string.format("%s:\t%s\t%s\n", "team property", "+", app.battle:getTeamSkillProperty(self, property_name))

    str = str .. "~~~~~~~value from actor prop:~~~~~~~\n"

    local function getStr(prop, name)
        return string.format("%s:\t%s\t%s\n", name, "+", prop and prop[property_name] or 0)
    end

    local prop = self:getActorPropInfo()
    str = str .. getStr(prop._actorProp, "character")
    str = str .. getStr(prop._equipmentProp, "equipment")
    str = str .. getStr(prop._breakProp, "breakthrough")
    str = str .. getStr(prop._gradeProp, "grade")
    str = str .. getStr(prop._trainingProp, "training")
    str = str .. getStr(prop._skillProp, "skill")
    str = str .. getStr(prop._masterProp, "master")
    str = str .. getStr(prop._archaeologyProp, "archaeology")
    str = str .. getStr(prop._soulTrialProp, "soulTrial")
    str = str .. getStr(prop._unionSkillProp, "unionSkill")
    str = str .. getStr(prop._avatarProp, "avatar")
    str = str .. getStr(prop._gemstoneProp, "gemstone")
    str = str .. getStr(prop._glyphTeamProp, "glyphTeam")
    str = str .. getStr(prop._badgeProp, "badge")
    str = str .. getStr(prop._mountCombinationProp, "mountCombinationProp")
    str = str .. getStr(prop._soulSpiritCombinationProp, "soulSpiritCombinationProp")
    str = str .. getStr(prop._godarmReformProp, "godarmReformProp")    
    str = str .. getStr(prop._mountProp, "mountProp")
    str = str .. getStr(prop._refineProp, "refineProp")
    str = str .. getStr(prop._artifactProp, "artifactProp")
    str = str .. getStr(prop._dragonTotemProp, "dragonTotemProp")    
    str = str .. getStr(prop._sparsProp, "sparsProp")  
    str = str .. getStr(prop._headProp, "headProp")
    str = str .. getStr(prop._heroSkinTeamProp, "heroSkinsTeamProp")
    str = str .. getStr(prop._magicHerbsProp, "magicHerbsProp")
    str = str .. getStr(prop._soulSpiritProp, "soulSpiritProp")
    str = str .. getStr(prop._godSkillProp, "godSkillProp")
    str = str .. getStr(prop._gemstoneAdvancedSkillProp, "gemstoneSkillProp")
    str = str .. getStr(prop._gemstoneGodSkillProp, "gemstoneGodSkillProp")
    str = str .. getStr(prop._attrListProp, "attrListProp")
    str = str .. getStr(prop._extraProp, "extraProp")

    str = str .. getStr(prop._glyphProp, "glyph")
    str = str .. getStr(prop._combinationProp, "combination")

    for key,props in pairs(prop._extendsProp) do
        str = str .. getStr(props, key)
    end

    if isPrint then
        print("\n" .. str)
    end

    return str
end

function QActor:_clearActorNumberPropertyValue()
    for _, property_stack in pairs(self._number_properties) do
        property_stack:clear()
    end
end

function QActor:clearNumberPropery(property_name)
    self._number_properties[property_name]:clear()
end

function QActor:_disableHpChangeByPropertyChange()
    self._hpPropertyLocked = true
end

function QActor:_enableHpChangeByPropertyChange()
    self._hpPropertyLocked = false
end

function QActor:insertPropertyValue(property_name, stub, operator, value)
    local hp_related = hp_related_property[property_name]
    local maxHprelated = max_hp_related_property[property_name]
    local hp_max_before
    if hp_related or maxHprelated then
        hp_max_before = self:getMaxHp()
    end

    local property_stack = self._number_properties[property_name]
    if property_stack then
        property_stack:insertValue(stub, operator, value)
    end

    local hp_max_after
    if hp_related and self:isDead() == false and not self._hpPropertyLocked then
        hp_max_after = self:getMaxHp()

        if hp_max_after > hp_max_before then
            self:increaseHp(hp_max_after - hp_max_before)
        elseif hp_max_after < hp_max_before then
            if self._hp > hp_max_after then
                self:decreaseHp(self._hp - hp_max_after)
            end
        end
    end
    if maxHprelated and self:isDead() == false and not self._hpPropertyLocked then
        self:dispatchEvent({name = QActor.MAX_HP_CHANGED_EVENT, hpMaxBefore = hp_max_before})
    end
end

function QActor:getPropertyValue(property_name, stub)
    local property_stack = self._number_properties[property_name]
    if property_stack then
        return property_stack:getValue(stub)
    end
end

function QActor:modifyPropertyValue(property_name, stub, operator, value)
    local hp_related = hp_related_property[property_name]
    local maxHprelated = max_hp_related_property[property_name]
    local hp_max_before
    if hp_related or maxHprelated then
        hp_max_before = self:getMaxHp()
    end

    local property_stack = self._number_properties[property_name]
    if property_stack then
        property_stack:modifyValue(stub, operator, value)
    end

    local hp_max_after
    if hp_related and self:isDead() == false and not self._hpPropertyLocked then
        hp_max_after = self:getMaxHp()
        if hp_max_after > hp_max_before then
            self:increaseHp(hp_max_after - hp_max_before)
        elseif hp_max_after < hp_max_before then
            if self._hp > hp_max_after then
                self:decreaseHp(self._hp - hp_max_after)
            end
        end
    end
    if maxHprelated and self:isDead() == false and not self._hpPropertyLocked then
        self:dispatchEvent({name = QActor.MAX_HP_CHANGED_EVENT, hpMaxBefore = hp_max_before})
    end
end

function QActor:removePropertyValue(property_name, stub)
    local hp_related = hp_related_property[property_name]
    local maxHprelated = max_hp_related_property[property_name]
    local hp_max_before
    if hp_related or maxHprelated then
        hp_max_before = self:getMaxHp()
    end 

    local property_stack = self._number_properties[property_name]
    if property_stack then
        property_stack:removeValue(stub)
    end

    local hp_max_after
    if hp_related and self:isDead() == false and not self._hpPropertyLocked then
        hp_max_after = self:getMaxHp()
        if hp_max_after > hp_max_before then
            -- self:increaseHp(hp_max_after - hp_max_before)  -- 血量上限还原后 不回血
        elseif hp_max_after < hp_max_before then
            if self._hp > hp_max_after then
                self:decreaseHp(self._hp - hp_max_after)
            end
        end
    end
    if maxHprelated and self:isDead() == false and not self._hpPropertyLocked then
        self:dispatchEvent({name = QActor.MAX_HP_CHANGED_EVENT, hpMaxBefore = hp_max_before})
    end
end

function QActor:_handleBattleEvents()
    if app.battle ~= nil then
        if  self._battleEventListener ~= nil then
            self._battleEventListener:removeAllEventListeners()
            self._battleEventListener = nil
        end
        self._battleEventListener = cc.EventProxy.new(app.battle)
        self._battleEventListener:addEventListener(QBattleManager.START, handler(self, self._onBattleStart))
        self._battleEventListener:addEventListener(QBattleManager.ONFRAME, handler(self, self._onBattleFrame))
        self._battleEventListener:addEventListener(QBattleManager.END, handler(self, self._onBattleEnded))
        self._battleEventListener:addEventListener(QBattleManager.STOP, handler(self, self._onBattleStop))
        self._battleEventListener:addEventListener(QBattleManager.PAUSE, handler(self, self._onBattlePause))
        self._battleEventListener:addEventListener(QBattleManager.RESUME, handler(self, self._onBattleResume))
        self._battleEventListener:addEventListener(QBattleManager.WAVE_ENDED_FOR_ACTOR, handler(self, self._onWaveEnded))
        self._battleEventListener:addEventListener(QBattleManager.WAVE_CONFIRMED, handler(self, self._onWaveConfirmed))
    end
end

function QActor:_onBattleStart(event)
    self:didReplaceActorView()
    if not IsServerSide then
        self:_showMountIconWithBattleStart()
    end
end

function QActor:_showMountIconWithBattleStart()
    for _,skill in pairs(self._skills) do
        if skill:getMountId() and skill:showMountIconWithBattleStart() then
            app.scene:playMountSkillAnimation(self, skill)
        end
    end
end

function QActor:removeBattleFrameListener()
    self._battleEventListener:removeEventListener(QBattleManager.ONFRAME)
end

function QActor:resetStateForBattle(revive)
    self._manual = QActor.AUTO
    self._position = {x = 0.0, y = 0.0}

    self:setTarget(nil)
    self._lastAttacker = nil
    self._lastAttackee = nil

    if revive == true then
        if self._revive_count == nil then
            self._revive_count = 0
        end
        self._revive_count = self._revive_count + 1
    else
        self._revive_count = 0
    end

    -- reset property stack
    self:_clearActorNumberPropertyValue()
    self:_applyStaticActorNumberProperties()

    self:setFullHp()

    -- pvp special skills
    self:checkCDReduce()

    -- reset skill
    for _, skill in pairs(self._skills) do
        skill:resetState()
    end

    -- reset rage
    self._rage = 0
    self._rageInfo = nil
    self:_initRageCoefficients()

    -- rage attack
    self._rage_attack = 0
    for _, skill in pairs(self._passiveSkills) do
        self._rage_attack = self._rage_attack + skill:getRageAttack()
    end

    -- support skill usage count reset
    self._supportSkillUsageCount = 0

    self:_handleBattleEvents()

    self._isInBulletTime = false
    self._grid_walking_attack_count = 0
    self._waveended = false
    self._battlepause = false
    self._isInTimeStop = 0
    self._deadBehavior = nil

    if self.fsm__:isState("dead") == true then
        self.fsm__:doEvent("start") -- 启动状态机
    elseif self.fsm__:isState("idle") == false then
        self.fsm__:doEvent("ready") 
    end
end

function QActor:checkCDReduce()
    -- pvp special skills
    local skillId = 300001
    if app.battle:isPVPMode() and not self._skills[skillId] then
        local reduce_cd_skill = QSkill.new(skillId, {}, self)
        self._skills[skillId] = reduce_cd_skill
        self:_addSkillToArray(reduce_cd_skill, self._passiveSkills)
    elseif not app.battle:isPVPMode() and self._skills[skillId] then
        local reduce_cd_skill = self._skills[skillId]
        self._skills[skillId] = nil
        self._passiveSkills[skillId] = nil
    end
end

function QActor:getUDID()
    return self._udid
end

function QActor:getUUID()
    return self._uuid
end

function QActor:dump()
    if not IsServerSide and DEBUG > 0 then
        printInfo("=============== ACTOR ==============")
        printInfo("Id: " .. self:getId())
        printInfo("Name: " .. self:getDisplayName())
        printInfo("=======HP=======")
        printInfo("Max HP: %d", self:getMaxHp(true))
        printInfo("=====ATTACK=====")
        printInfo("Attack: %d", self:getAttack(true))
        printInfo("================")
        printInfo("Magic Armor: %d%%", self:getMagicArmor() * 100)
        printInfo("Physical Armor: %d%%", self:getPhysicalArmor() * 100)
        printInfo("Hit: %.1f%%", self:getHit())
        printInfo("Dodge: %.1f%%", self:getDodge())
        printInfo("Block: %.1f%%", self:getBlock())
        printInfo("Crit: %.1f%%", self:getCrit())
    end
end

function QActor:_classifySkillByType()
    for _, skill in pairs(self._skills) do
        local skillType = skill:getSkillType()
        if skillType == QSkill.MANUAL then
            self:_addSkillToArray(skill, self._manualSkills)
        elseif skillType == QSkill.ACTIVE then
            if not skill:isTriggeredSkill() then
                self:_addSkillToArray(skill, self._activeSkills)
            end
        elseif skillType == QSkill.PASSIVE then
            self:_addSkillToArray(skill, self._passiveSkills)
        elseif skillType == QSkill.TEAM then
            self:_addSkillToArray(skill, self._teamSkills)
        end
    end
    self._activeSkillsByPriority = {}
    for _, skill in pairs(self._activeSkills) do
        table.insert(self._activeSkillsByPriority, skill)
    end
    table.sort( self._activeSkillsByPriority, function(skill1, skill2)
        local p1 = skill1:getSkillPriority()
        local p2 = skill2:getSkillPriority()
        if p1 > p2 then 
            return true 
        elseif p1 < p2 then
            return false
        else
            return skill1:getId() < skill2:getId() 
        end
    end )

    -- 根据技能是否产生连击点数或者消耗连击点数决定是否是一个有无连击点数的魂师
    local need_combo = false
    for _, skill in pairs(self._skills) do
        if skill:isNeedComboPoints() then
            need_combo = true
            break
        end
    end
    self._is_need_combo = need_combo
end

function QActor:_addSkillToArray(skill, array)
    if skill == nil or array == nil then
        return
    end

    local skillId = skill:getId()
    if array[skillId] == nil then
        array[skillId] = skill
    elseif array[skillId]:getSkillLevel() < skill:getSkillLevel() then
        array[skillId] = skill
    end
end

function QActor:_applyPassiveSkillBuffs()
    if not self:isSupport() then
        for _, skill in pairs(self._passiveSkills) do
            if skill:getBuffId1() ~= "" and skill:getBuffTargetType1() == QSkill.BUFF_SELF then
                self:applyBuff(skill:getBuffId1(), self, skill)
            end
            if skill:getBuffId2() ~= "" and skill:getBuffTargetType2() == QSkill.BUFF_SELF then
                self:applyBuff(skill:getBuffId2(), self, skill)
            end
            if skill:getBuffId3() ~= "" and skill:getBuffTargetType3() == QSkill.BUFF_SELF then
                self:applyBuff(skill:getBuffId3(), self, skill)
            end
        end
    end
end

function QActor:getActorInfo()
    return self._actorInfo
end

function QActor:getActorID(is_real_id)
    if self._replaceCharacterId and (not is_real_id) then
        return self._replaceCharacterId
    end
    return self._actor_id
end

function QActor:getDisplayID()
    return self._display_id
end

function QActor:getDisplayName()
    if self:isWeak() then
        return self._displayInfo.name .. "【灵魂】"
    else
        return self._displayInfo.name
    end
end

function QActor:getDisplayTitleName()
    if self:isWeak() then
        return (self._displayInfo.title and self._displayInfo.title.."·" or "")..self._displayInfo.name .. "【灵魂】"
    else
        return (self._displayInfo.title and self._displayInfo.title.."·" or "")..self._displayInfo.name
    end
end

function QActor:getIcon()
    return self._displayInfo.icon
end

function QActor:getAidBust()
    return self._displayInfo.aid_bust or "" -- "icon/aid_hero/aid_thrall.png"
end

function QActor:getVictoryEffect()
    return self._displayInfo.victory_effect
end

function QActor:getDeadEffect()
    return self._displayInfo.dead_effect
end

function QActor:getDeadSkillID()
    return self._deadSkill or self._dead_skill
end

function QActor:getTalent()
    return nil
end

function QActor:getTalentFunc()
    local talent = self:getTalent()
    if talent == nil then
        return nil
    end
    return talent.func
end

function QActor:getTalentHatred()
    local talent = self:getTalent()
    if talent == nil then
        return 0
    end
    return talent.hatred
end

function QActor:getActorScale()
    local actor_scale
    if self._replaceCharacterDisplayId ~= nil then
        actor_scale = self._replaceDisplayInfo.actor_scale
    else
        actor_scale = self._displayInfo.actor_scale
    end
    if actor_scale then
        if actor_scale > 0 then
            return actor_scale, 1
        else
            return -actor_scale, -1
        end
    end
end

function QActor:setActorScale(scale)
    local original_actor_scale = self._displayInfo.actor_scale
    self._displayInfo.actor_scale = math.abs(scale) * original_actor_scale / math.abs(original_actor_scale)
    self:_initRect()
end

-- actor skeleton file 
-- is a json file
function QActor:getActorFile()
    if self._replaceCharacterDisplayId ~= nil then
        return self._replaceDisplayInfo.actor_file
    end
    return self._displayInfo.actor_file
end

function QActor:getActorWeaponFile()
    if self._replaceCharacterDisplayId ~= nil then
        return self._replaceDisplayInfo.weapon_file
    end
    return self._displayInfo.weapon_file
end

function QActor:getActorReplaceBone()
    if self._replaceCharacterDisplayId ~= nil then
        return self._replaceDisplayInfo.replace_bone
    end
    return self._displayInfo.replace_bone
end

function QActor:getActorReplaceFile()
    if self._replaceCharacterDisplayId ~= nil then
        return self._replaceDisplayInfo.replace_file
    end
    return self._displayInfo.replace_file
end

function QActor:getAdditionalEffects()
    if self._replaceCharacterDisplayId ~= nil then
        return self._replaceDisplayInfo.additional_effects or ""
    end
    return self._displayInfo.additional_effects or ""
end

function QActor:getSelectRectWidth()
    if self._replaceCharacterDisplayId ~= nil then
        return self._replaceDisplayInfo.selected_rect_width
    end
    return self._displayInfo.selected_rect_width
end

function QActor:getSelectRectHeight()
    if self._replaceCharacterDisplayId ~= nil then
        return self._replaceDisplayInfo.selected_rect_height
    end
    return self._displayInfo.selected_rect_height
end

function QActor:_initRect()
    local actorScale = self:getActorScale()
    local width = self:getSelectRectWidth()
    local height = self:getSelectRectHeight()
    local rect = QRectMake(-width*0.5, 0, width, height)
    if actorScale ~= 1.0 then
        rect.origin.x = rect.origin.x * actorScale
        rect.size.width = rect.size.width * actorScale
        rect.size.height = rect.size.height * actorScale
    end
    self:setRect(rect)

    local coreScale = 0.8
    local coreRect = QRectMake(rect.origin.x * coreScale, 0, rect.size.width * coreScale, rect.size.height * coreScale)
    self:setCoreRect(coreRect)

    local touchScale = 0.4
    local touchRect = QRectMake(rect.origin.x * touchScale, 0, rect.size.width * touchScale, rect.size.height * touchScale)
    self:setTouchRect(touchRect)
end

function QActor:isMovable()
    return self._speed ~= 0
end

function QActor:getMoveSpeed()
    if self:CanControlMove() == false then
        return 0
    end

    if not self:isMovable() then
        return 0
    end

    local speed_replace = self:_getActorNumberPropertyValue("movespeed_replace")
    local speed = self:_getActorNumberPropertyValue("movespeed_value") *
                    (1 + self:_getActorNumberPropertyValue("movespeed_percent"))

    if speed_replace > 0 then
        speed = speed_replace
    end

    if speed < global.movement_speed_min then return global.movement_speed_min end
    return speed
end

function QActor:getType()
    return self._type
end

function QActor:setType(actorType)
    self._type = actorType
end

function QActor:getSkills()
    return self._skills
end

function QActor:getActiveSkills()
    return self._activeSkills
end

function QActor:getManualSkills()
    return self._manualSkills
end

function QActor:getFirstManualSkill()
    local skills = self._manualSkills
    return skills[next(skills)]
end

function QActor:setFirstManualSkill(skill)
    local skills = self._manualSkills
    local key = next(skills)
    if key then
        skills[key] = skill
    end
end

function QActor:getPassiveSkills()
    return self._passiveSkills
end

function QActor:getTeamSkills()
    return self._teamSkills
end

function QActor:getSkillWithId(id)
    return self._skills[id]
end

-- 人物等级
function QActor:getLevel()
    return self._level
end

-- 叛军的等级
function QActor:getDisplayLevel()
    return self._displayLevel or self._level
end

function QActor:setDisplayLevel(level)
    self._displayLevel = level
end

function QActor:getLevelCoefficient()
    local coefficient = self._levelCoefficient
    if not coefficient then
        coefficient = db:getLevelCoefficientByLevel(tostring(self:getLevel()))
        self._levelCoefficient = coefficient
    end
    return coefficient
end

function QActor:getLevelFullExp()
    return db:getExperienceByLevel(self:getLevel())
end

function QActor:getHp()
    local hpGroup = self._hpGroup
    if hpGroup then
        return hpGroup.main._hp
    else
        return self._hp
    end
end

function QActor:getHpBeforeLastChange()
    return self._hpBeforeLastChange
end

--[[
    QActor:_calculateByBuffAndTrapAndAura only take traps into calculation, since buff and aura is calculated via property stack
]]
function QActor:_calculateByBuffAndTrapAndAura(originValue, key, operator, includeAura)
    local newValue = originValue

    if operator == "+" then
        if app.battle ~= nil then
            for _, trapDirector in ipairs(app.battle:getTrapDirectors()) do
                if trapDirector:isExecute() == true and trapDirector:isTragInfluenceActor(self) then
                    local trap = trapDirector:getTrap()
                    if trap.effects[key] ~= nil then
                        newValue = newValue + trap.effects[key]
                    end
                end
            end
        end
    elseif operator == "*" then
        local coefficient = 0
        if app.battle ~= nil then
            for _, trapDirector in ipairs(app.battle:getTrapDirectors()) do
                if trapDirector:isExecute() == true and trapDirector:isTragInfluenceActor(self) then
                    local trap = trapDirector:getTrap()
                    if trap.effects[key] ~= nil then
                        coefficient = coefficient + trap.effects[key]
                    end
                end
            end
        end
        newValue = originValue * (1.0 + coefficient)
    elseif operator == "&" then
        if app.battle ~= nil then
            for _, trapDirector in ipairs(app.battle:getTrapDirectors()) do
                if trapDirector:isExecute() == true and trapDirector:isTragInfluenceActor(self) then
                    local trap = trapDirector:getTrap()
                    if trap.effects[key] ~= nil then
                        newValue = trap.effects[key]
                    end
                end
            end
        end
    end

    return newValue
end

--最大生命值
function QActor:getMaxHp(isPrintInfo, isIgnoreHpCoefficient)
    if self._cachingProperties and self._cachingProperties["max_hp"] then
        return self._cachingProperties["max_hp"]
    end
    local maxhp = self:getMaxHpWithoutStealed(isPrintInfo, isIgnoreHpCoefficient)
    maxhp = maxhp + self:_getActorNumberPropertyValue("max_hp_stealed")
    maxhp = math.max(maxhp, 0)
    if self._cachingProperties then
        self._cachingProperties["max_hp"] = maxhp
    end
    return maxhp
end

function QActor:getMaxHpWithoutStealed(isPrintInfo, isIgnoreHpCoefficient)
    if self._fixMaxHp then
        return self._fixMaxHp
    end

    local hpGroup = self._hpGroup
    if hpGroup and self ~= hpGroup.main then
        return hpGroup.main:getMaxHp(isPrintInfo, isIgnoreHpCoefficient)
    end

    local hp_base_total = self._actorProp:getHpDetail() 
    local hp = self:_getActorNumberPropertyValue("hp_value") *
                (1 + self:_getActorNumberPropertyValue("hp_percent")) +
                self:_getActorNumberPropertyValue("hp_value_support")
    if app.battle and app.battle:isSotoTeamEquilibrium() then
        hp = hp + self:_getActorNumberPropertyValue("hp_equilibrium")
    end

    -- PVP系数影响
    if not isIgnoreHpCoefficient then
        if app.battle ~= nil and app.battle:isPVPMode() then
            if app.battle:isInArena() and not app.battle:isPVPMultipleWaveNew() and not app.battle:isSotoTeam() then
                hp = hp * QActor.ARENA_MAX_HEALTH_COEFFICIENT
            elseif app.battle:isInSunwell() then
                hp = hp * QActor.SUNWELL_MAX_HEALTH_COEFFICIENT
            elseif app.battle:isInSilverMine() then
                hp = hp * QActor.SILVERMINE_MAX_HEALTH_COEFFICIENT
            elseif app.battle:isInMetalAbyss() then
                hp = hp * QActor.ABYSS_MAX_HEALTH_COEFFICIENT
            elseif app.battle:isPVPMultipleWaveNew() then
                hp = hp * QActor.STORM_ARENA_MAX_HEALTH_COEFFICIENT
            elseif app.battle:isSotoTeam() then
                hp = hp * QActor.SOTO_TEAM_MAX_HEALTH_COEFFICIENT
            elseif app.battle:isInTotemChallenge() then
                hp = hp * QActor.TOTEM_CHALLENGE_MAX_HEALTH_COEFFICIENT
            else
                hp = hp * QActor.ARENA_MAX_HEALTH_COEFFICIENT
            end
        end
    end

    hp = hp + self:_getActorNumberPropertyValue("hp_final_additional")

    -- 副本系数影响等等
    local hp_co = self._propertyCoefficient.hp
    if hp_co then
        hp = hp * (1 + hp_co)
    end

    return hp
end

function QActor:getLostHp()
    return self:getMaxHp() - self:getHp()
end

function QActor:getMaxHpIgnoreHpCoefficient()
    return self:getMaxHp(false, true)
end

-- 设置固定最大生命值
function QActor:setFixMaxHp(fixMaxHp)
    self._fixMaxHp = fixMaxHp
end

function QActor:getHpGrow()
    return self._actorProp:getHpGrow()
end

--获取最大攻击
function QActor:getMaxAttack(isPrintInfo)
    if self._cachingProperties then
        local value = self._cachingProperties["max_attack"]
        if value then
            return value
        end
    end

    local attack = self:getAttackWithoutSteal()

    -- 攻击力窃取
    attack = math.min(math.max(attack + self:_getActorNumberPropertyValue("attack_value_stealed"), 1), attack * 1.2)
    attack = math.max(attack, 0) -- 修复可能出现攻击力为负数的情况

    -- 怒气增强攻击力
    attack = attack * (1 + self._rage_attack * self:getRage() / self:getRageTotal())

    -- 巨龙战攻击力
    if app.battle then
        attack = attack * app.battle:getUnionDragonWarAttack(self:getType())
    end

    if self._cachingProperties then
        self._cachingProperties["max_attack"] = attack
    end

    return attack
end

function QActor:getAttackWithoutSteal()
    local attack_base_total = self._actorProp:getAttackDetail()
    local attack = self:_getActorNumberPropertyValue("attack_value") *
                    (1 + self:_getActorNumberPropertyValue("attack_percent")) + 
                    self:_getActorNumberPropertyValue("attack_value_support")
    if app.battle and app.battle:isSotoTeamEquilibrium() then
        attack = attack + self:_getActorNumberPropertyValue("attack_equilibrium")
    end

    attack = attack + self:_getActorNumberPropertyValue("attack_value_final_additional")

    -- 副本系数影响等等
    local atk_co = self._propertyCoefficient.attack
    if atk_co then
        attack = attack * (1 + atk_co)
    end
    return attack
end

function QActor:getAttackGrow()
    return self._actorProp:getAttackGrow()
end

-- 最大法术防御
function QActor:getMaxMagicArmor()
    if self._cachingProperties then
        local value = self._cachingProperties["max_magic_armor"]
        if value then
            return value
        end
    end

    local magicArmor = self:getMagicArmorWithoutSteal()
    magicArmor = magicArmor + self:_getActorNumberPropertyValue("armor_magic_stealed")

    if self._cachingProperties then
        self._cachingProperties["max_magic_armor"] = magicArmor
    end

    return math.max(0, magicArmor)
end

function QActor:getMagicArmorWithoutSteal(isPrintInfo)
    local armor_magic = self:_getActorNumberPropertyValue("armor_magic") * (1 + self:_getActorNumberPropertyValue("armor_magic_percent"))
    if app.battle and app.battle:isSotoTeamEquilibrium() then
        armor_magic = armor_magic + self:_getActorNumberPropertyValue("magic_armor_equilibrium")
    end
    armor_magic = armor_magic + self:_getActorNumberPropertyValue("armor_magic_final_additional")
    -- 副本系数影响等等
    local arm_co = self._propertyCoefficient.armor
    if arm_co then
        armor_magic = armor_magic * (1 + arm_co)
    end

    return armor_magic
end

function QActor:getMagicArmorGrow()
    return self._actorProp:getArmorMagicGrow()
end

-- 最大物理防御
function QActor:getMaxPhysicalArmor(isPrintInfo) 
    if self._cachingProperties then
        local value = self._cachingProperties["max_physical_armor"]
        if value then
            return value
        end
    end

   local physicalAromr = self:getPhysicalArmorWithoutSteal()
    physicalAromr = physicalAromr + self:_getActorNumberPropertyValue("armor_physical_stealed")  

    if self._cachingProperties then
        self._cachingProperties["max_physical_armor"] = physicalAromr
    end

    return math.max(0, physicalAromr)
end

function QActor:getPhysicalArmorWithoutSteal(isPrintInfo) 
    local armor_physical = self:_getActorNumberPropertyValue("armor_physical") * (1 + self:_getActorNumberPropertyValue("armor_physical_percent"))
    if app.battle and app.battle:isSotoTeamEquilibrium() then
        armor_physical = armor_physical + self:_getActorNumberPropertyValue("physical_armor_equilibrium")
    end
    armor_physical = armor_physical + self:_getActorNumberPropertyValue("armor_physical_final_additional")

    -- 副本系数影响等等
    local arm_co = self._propertyCoefficient.armor
    if arm_co then
        armor_physical = armor_physical * (1 + arm_co)
    end
    
    return armor_physical
end


-- 无视物理防御
function QActor:getIgnorePhysicalArmorPercent() 
    return self:_getActorNumberPropertyValue("ignore_physical_armor_percent")
end

-- 抵抗无视物理防御
function QActor:getIgnorePhysicalArmorResistPercent()
    return self:_getActorNumberPropertyValue("ignore_physical_armor_resist_percent")
end

function QActor:getIgnorePhysicalArmorPercentFinal(attackee)
    local ignorePhysicalArmor = self:getIgnorePhysicalArmorPercent() - attackee:getIgnorePhysicalArmorResistPercent()
    return math.clamp(ignorePhysicalArmor, 0, 1)
end

-- 无视魔法防御
function QActor:getIgnoreMagicArmorPercent() 
    return self:_getActorNumberPropertyValue("ignore_magic_armor_percent")
end

-- 抵抗无视魔法防御
function QActor:getIgnoreMagicArmorResistPercent()
    return self:_getActorNumberPropertyValue("ignore_magic_armor_resist_percent")
end

function QActor:getIgnoreMagicArmorPercentFinal(attackee)
    local ignoreMagicArmor = self:getIgnoreMagicArmorPercent() - attackee:getIgnoreMagicArmorResistPercent()
    return math.clamp(ignoreMagicArmor, 0, 1)
end

function QActor:getPhysicalArmorGrow()
    return self._actorProp:getArmorPhysicalGrow()
end

-- 最大法术穿透
function QActor:getMaxMagicPenetration(isPrintInfo)
    local magic_penetration = self:_getActorNumberPropertyValue("magic_penetration_value") * (1 + self:_getActorNumberPropertyValue("magic_penetration_percent"))
    + self:_getActorNumberPropertyValue("extra_magic_penetration_value") + self:_getActorNumberPropertyValue("magic_penetration_support")
    if app.battle and app.battle:isSotoTeamEquilibrium() then
        magic_penetration = magic_penetration + self:_getActorNumberPropertyValue("magic_penetration_equilibrium")
    end
    return math.max(0, magic_penetration)
end

-- 最大物理穿透
function QActor:getMaxPhysicalPenetration(isPrintInfo)
    local physical_penetration = self:_getActorNumberPropertyValue("physical_penetration_value") * (1 + self:_getActorNumberPropertyValue("physical_penetration_percent"))
    + self:_getActorNumberPropertyValue("extra_physical_penetration_value") + self:_getActorNumberPropertyValue("physical_penetration_support")
    if app.battle and app.battle:isSotoTeamEquilibrium() then
        physical_penetration = physical_penetration + self:_getActorNumberPropertyValue("physical_penetration_equilibrium")
    end
    return math.max(0, physical_penetration)
end

--根据最大命中率计算命中等级
function QActor:getMaxHitLevel(isPrintInfo)
    local hit_level = self:_getActorNumberPropertyValue("hit_rating")

    return hit_level
end

--最大命中率
function QActor:getMaxHit()
    if self._cachingProperties then
        local value = self._cachingProperties["max_hit"]
        if value then
            return value
        end
    end

    local hit = self:_getActorNumberPropertyValue("hit_chance") * 100

    return hit
end

function QActor:getHitGrow()
    return self._actorProp:getHitGrow()
end

--根据最大闪避率计算闪避等级
function QActor:getMaxDodgeLevel(isPrintInfo)
    local dodge_rate = self:_getActorNumberPropertyValue("dodge_rating")
    return dodge_rate
end

-- 最大闪避概率（%）
function QActor:getMaxDodge()
    if self._cachingProperties then
        local value = self._cachingProperties["max_dodge"]
        if value then
            return value
        end
    end

    local dodge = self:_getActorNumberPropertyValue("dodge_chance") * 100

    if self._cachingProperties then
        self._cachingProperties["max_dodge"] = dodge
    end

    return dodge
end

function QActor:getDodgeGrow()
    return self._actorProp:getDodgeGrow()
end

function QActor:getBlockGrow()
    return self._actorProp:getBlockGrow()
end

--根据最大暴击率计算暴击等级
function QActor:getMaxCritLevel(isPrintInfo)
    local crit_rate = self:_getActorNumberPropertyValue("critical_rating")

    return math.max(crit_rate, 0)
end

-- 最大暴击概率（%）
function QActor:getMaxCrit()
    if self._cachingProperties then
        local value = self._cachingProperties["max_crit"]
        if value then
            return value
        end
    end

    local crit = self:_getActorNumberPropertyValue("critical_chance") * 100

    if self._cachingProperties then
        self._cachingProperties["max_crit"] = crit
    end

    return crit
end

function QActor:getCritReduceWithoutStealed()
    return self:_getActorNumberPropertyValue("crit_reduce_rating")
end

function QActor:getMaxCritReduceLevel()
    local crit_reduce_rate = self:getCritReduceWithoutStealed() + self:_getActorNumberPropertyValue("crit_reduce_rating_stealed")
    return crit_reduce_rate
end

function QActor:getMaxCritReduce()
    if self._cachingProperties then
        local value = self._cachingProperties["max_crit_reduce"]
        if value then
            return value
        end
    end

    local crit_reduce = self:_getActorNumberPropertyValue("crit_reduce_chance") * 100

    if self._cachingProperties then
        self._cachingProperties["max_crit_reduce"] = crit_reduce
    end

    return crit_reduce
end

function QActor:getMaxCritDecrease()
    local critDecrease = self:_getActorNumberPropertyValue("critical_chance_decrease") * 100
    return critDecrease
end

function QActor:getMaxCritLevelDecrease()
    local critLevelDecrease = self:_getActorNumberPropertyValue("critical_rating_decrease")
    return critLevelDecrease
end

function QActor:getMaxCritReduceDecrease()
    local critReduceDecrease = self:_getActorNumberPropertyValue("crit_reduce_chance_decrease") * 100
    return critReduceDecrease
end

function QActor:getMaxCritReduceLevelDecrease()
    local critReduceLevelReduce = self:_getActorNumberPropertyValue("crit_reduce_rating_decrease")
    return critReduceLevelReduce
end

function QActor:getCritGrow()
    return self._actorProp:getCritGrow()
end

--根据最大攻速率计算攻速等级
function QActor:getMaxHasteLevel(isPrintInfo)
    return self._actorProp:getMaxHaste()
end

--添加附加属性
function QActor:addExtendsProp(prop, extendName)
    return self._actorProp:addExtendsProp(prop, extendName)
end

--移除附加属性
function QActor:removeExtendsProp(extendName)
    return self._actorProp:removeExtendsProp(extendName)
end

--获取是否添加了特殊属性
function QActor:getIsHasExtendsProp()
    return self._actorProp:getIsHasExtendsProp()
end

--添加洗炼属性
function QActor:addRefineProp()
    return self._actorProp:addRefineProp()
end

--移除洗炼属性
function QActor:removeRefineProp()
    return self._actorProp:removeRefineProp()
end

--添加预备洗炼属性
function QActor:addWillRefineProp( prop )
    return self._actorProp:addWillRefineProp( prop )
end

-- 最大攻速率
function QActor:getMaxHaste()
    if self._cachingProperties then
        local value = self._cachingProperties["max_haste"]
        if value then
            return value
        end
    end

    local haste = self:getHasteWithoutSteal() + self:_getActorNumberPropertyValue("attackspeed_stealed")
    haste = math.min(haste, 150)
    if self._cachingProperties then
        self._cachingProperties["max_haste"] = haste
    end

    return haste
end

function QActor:getHasteWithoutSteal()
    local co = self:getLevelCoefficient().haste
    local haste_rating = self:_getActorNumberPropertyValue("haste_rating")
    local attackspeed_chance = self:_getActorNumberPropertyValue("attackspeed_chance")
    local haste = (haste_rating / co) + attackspeed_chance * 100
    return haste
end

-- 最大攻速率，影响的速度系数
function QActor:getMaxHasteCoefficient()
    local haste = self:getMaxHaste()
    local coefficient = 1
    if haste > 0 then
        coefficient = 1 + haste / 100
    elseif haste < 0 then
        coefficient = 0.5 + 0.5 / (-haste / 100 + 1)
    end
    return coefficient
end

function QActor:getHasteGrow()
    return self._actorProp:getHasteGrow()
end

-- 计算战斗力
function QActor:getBattleForce(islocal, isPVP)
    return self._actorProp:getBattleForce(islocal, isPVP)
end

-- 攻击
function QActor:getAttack(isPrintInfo)
    if self._cachingProperties then
        local value = self._cachingProperties["attack"]
        if value then
            return value
        end
    end

    local attack = self:getMaxAttack()

    if self._cachingProperties then
        self._cachingProperties["attack"] = attack
    end

    return attack
end

-- 目標法術防禦影響系數
function QActor:getTargetMagicArmorCoefficient()
    local target = self:getTarget()
    local magic_armor = target and target:getMagicArmor() or 0
    local attack = self:getAttack()
    local coefficient = attack / (attack + 1 * magic_armor)

    return coefficient
end

-- 目標物理防禦影響系數
function QActor:getTargetPhysicalArmorCoefficient()
    local target = self:getTarget()
    local physical_armor = target and target:getPhysicalArmor() or 0
    local attack = self:getAttack()
    local coefficient = attack / (attack + 1 * physical_armor)

    return coefficient
end

-- 法术防御
function QActor:getMagicArmor(isPrintInfo)
    return self:getMaxMagicArmor(isPrintInfo)
end

-- 物理防御
function QActor:getPhysicalArmor(isPrintInfo)
    return self:getMaxPhysicalArmor(isPrintInfo)
end

-- 法术穿透
function QActor:getMagicPenetration(isPrintInfo)
    return self:getMaxMagicPenetration(isPrintInfo)
end

-- 物理穿透
function QActor:getPhysicalPenetration(isPrintInfo)
    return self:getMaxPhysicalPenetration(isPrintInfo)
end

-- 精准
function QActor:getPrecise()
    return self:_getActorNumberPropertyValue("precise") * 100
end

function QActor:getDeflection()
    return self:_getActorNumberPropertyValue("deflection") * 100
end

-- 命中率（%）
function QActor:getHit()
    return self:getMaxHit()
end

-- 命中等级
function QActor:getHitLevel()
    return self:getMaxHitLevel()
end

-- 闪避概率（%）
function QActor:getDodge()
    return self:getMaxDodge()
end

-- 闪避等级
function QActor:getDodgeLevel()
    return self:getMaxDodgeLevel()
end

function QActor:getDodgeDecrease()
    return self:_getActorNumberPropertyValue("dodge_chance_decrease") * 100
end

function QActor:getDodgeLevelDecrease()
    return self:_getActorNumberPropertyValue("dodge_rating_decrease")
end

function QActor:getHitDecrease()
    return self:_getActorNumberPropertyValue("hit_chance_decrease") * 100
end

function QActor:getHitLevelDecrease()
    return self:_getActorNumberPropertyValue("hit_rating_decrease")
end

-- 闪避概率（目标对我）字符串
function QActor:getDodgeDetailString()
    local attacker, attackee = self, self:getTarget() or self
    return string.format("%0.2f%%",calcFinalDodge(attacker, attackee))
end

-- 格挡概率（%）
function QActor:getBlock()
    return self:_getActorNumberPropertyValue("block_chance") * 100
end

function QActor:getBlockLevel()
    return self:_getActorNumberPropertyValue("block_rating")
end

-- 破击率
function QActor:getWreck()
    return self:_getActorNumberPropertyValue("wreck_chance") * 100
end

-- 破击等级
function QActor:getWreckLevel()
    return self:_getActorNumberPropertyValue("wreck_rating")
end

function QActor:getHitChance()
    return self:_getActorNumberPropertyValue("hit_chance")
end

-- 攻击者降低被攻击者的格挡率
function QActor:getBlockDecrease()
    return self:_getActorNumberPropertyValue("block_chance_decrease") * 100
end

function QActor:getBlockLevelDecrease()
    return self:_getActorNumberPropertyValue("block_rating_decrease")
end

-- 被攻击者降低攻击者的破防率
function QActor:getWreckDecrease()
    return self:_getActorNumberPropertyValue("wreck_chance_decrease") * 100
end

function QActor:getWreckLevelDecrease()
    return self:_getActorNumberPropertyValue("wreck_rating_decrease")
end

function QActor:getBlockDetailString()
    local attacker, attackee = self, self:getTarget() or self
    return string.format("%0.2f%%",calcFinalBlock(attacker, attackee))
end

-- 暴击概率（%）
function QActor:getCrit()
    return self:getMaxCrit()
end

-- 暴击等级
function QActor:getCritLevel()
    return self:getMaxCritLevel()
end

-- 降低（作为）目标（时）暴击率
function QActor:getCritDecrease()
    return self:getMaxCritDecrease()
end

-- 降低（作为）目标（时）暴击等级
function QActor:getCritLevelDecrease()
    return self:getMaxCritLevelDecrease()
end

-- 抗暴率 (%)
function QActor:getCritReduce()
    return self:getMaxCritReduce()
end

-- 抗暴等级
function QActor:getCritReduceLevel()
    return self:getMaxCritReduceLevel()
end

-- 降低抗暴率（%）
function QActor:getCritReduceDecrease()
    return self:getMaxCritReduceDecrease()
end

-- 降低抗暴等级
function QActor:getCritReduceLevelDecrease()
    return self:getMaxCritReduceLevelDecrease()
end

-- 暴击概率字符串
function QActor:getCritDetailString()
    local attacker, attackee = self, self:getTarget() or self
    return string.format("%0.2f%%",calcFinalCrit(attacker, attackee))
end

-- 基础暴击伤害
function QActor:getBaseCritDamage()
    return self:_getActorNumberPropertyValue("critical_damage")
end

-- 基础暴击伤害抵抗
function QActor:getBaseCritDamageResist()
    return self:_getActorNumberPropertyValue("critical_damage_resist")
end

-- 暴击伤害倍数
function QActor:getCritDamage(attackee)
    local critDamage = 1 + self:_getActorNumberPropertyValue("critical_damage")
        - attackee:_getActorNumberPropertyValue("critical_damage_resist")
    
    return (critDamage < 1 and 1) or critDamage
end

-- 物理伤害
function QActor:getPhysicalDamagePercentAttack()
    local percent = self:_getActorNumberPropertyValue("physical_damage_percent_attack")

    return (percent < -1 and -1) or percent
end

function QActor:getOriginPhysicalDamagePercentAttack()
    return self:_getActorNumberPropertyValue("physical_damage_percent_attack")
end

-- 魔法伤害
function QActor:getMagicDamagePercentAttack()
    local percent = self:_getActorNumberPropertyValue("magic_damage_percent_attack")

    return (percent < -1 and -1) or percent
end

function QActor:getOriginMagicDamagePercentAttack()
    return self:_getActorNumberPropertyValue("magic_damage_percent_attack")
end

-- 治疗效果
function QActor:getMagicTreatPercentAttack()
    return self:_getActorNumberPropertyValue("magic_treat_percent_attack")
end

function QActor:getOriginMagicTreatPercentAttack()
    return self:_getActorNumberPropertyValue("magic_treat_percent_attack")
end

-- 物理易伤 + 物理伤害减免
function QActor:getPhysicalDamagePercentUnderAttack()
    local percent = self:_getActorNumberPropertyValue("physical_damage_percent_beattack") - self:_getActorNumberPropertyValue("physical_damage_percent_beattack_reduce")

    return percent
end

function QActor:getPhysicalDamagePercentBeattack( ... )
    return self:_getActorNumberPropertyValue("physical_damage_percent_beattack")
end

-- 物理伤害减免
function QActor:getPhysicalDamagePercentAttackReduce()
    local percent = self:_getActorNumberPropertyValue("physical_damage_percent_beattack_reduce")

    return (percent < -1 and -1) or percent
end

function QActor:getPhysicalDamagePercentBeattackReduce( ... )
    return self:_getActorNumberPropertyValue("physical_damage_percent_beattack_reduce")
end

-- 法术易伤 + 魔法伤害减免
function QActor:getMagicDamagePercentUnderAttack()
    local percent = self:_getActorNumberPropertyValue("magic_damage_percent_beattack") - self:_getActorNumberPropertyValue("magic_damage_percent_beattack_reduce")

    return percent
end

function QActor:getMagicDamagePercentBeattack( ... )
    return self:_getActorNumberPropertyValue("magic_damage_percent_beattack")
end

-- 魔法伤害减免
function QActor:getMagicDamagePercentAttackReduce()
    local percent = self:_getActorNumberPropertyValue("magic_damage_percent_beattack_reduce")

    return (percent < -1 and -1) or percent
end

function QActor:getMagicDamagePercentBeattackReduce( ... )
    return self:_getActorNumberPropertyValue("magic_damage_percent_beattack_reduce")
end

-- 被治疗效果
function QActor:getMagicTreatPercentUnderAttack()
    return self:_getActorNumberPropertyValue("magic_treat_percent_beattack")
end

function QActor:getOriginMagicTreatPercentUnderAttack()
    return self:_getActorNumberPropertyValue("magic_treat_percent_beattack")
end

--PVP物理伤害加成
function QActor:getPVPPhysicalAttackPercent()
    return self:_getActorNumberPropertyValue("pvp_physical_damage_percent_attack")
end

--PVP魔法伤害加成
function QActor:getPVPMagicAttackPercent()
    return self:_getActorNumberPropertyValue("pvp_magic_damage_percent_attack")
end

--PVP物理伤害减免
function QActor:getPVPPhysicalReducePercent()
    local value = self:_getActorNumberPropertyValue("pvp_physical_damage_percent_beattack_reduce")
    return value
end

function QActor:getOriginPVPPhysicalReducePercent()
    return self:_getActorNumberPropertyValue("pvp_physical_damage_percent_beattack_reduce")
end

--PVP魔法伤害减免
function QActor:getPVPMagicReducePercent()
    local value = self:_getActorNumberPropertyValue("pvp_magic_damage_percent_beattack_reduce")
    return value
end

function QActor:getOriginPVPMagicReducePercent()
    return self:_getActorNumberPropertyValue("pvp_magic_damage_percent_beattack_reduce")
end

--pve加伤
function QActor:getPVEDamagePercentAttack()
    return self:_getActorNumberPropertyValue("pve_damage_percent_attack")
end
--pve减伤
function QActor:getPVEDamagePercentBeattack()
    return self:_getActorNumberPropertyValue("pve_damage_percent_beattack")
end

--aoe伤害减免
function QActor:getAOEBeattackPercent()
    return math.clamp(self:_getActorNumberPropertyValue("aoe_beattack_percent"), -1, 1)
end

--aoe伤害加成
function QActor:getAOEAttackPercent()
    return math.clamp(self:_getActorNumberPropertyValue("aoe_attack_percent"), -1, 1)
end

--附加怒气上限
function QActor:getRageLimitUpper()
    return self:_getActorNumberPropertyValue("limit_rage_upper")
end

--可回复生命上限
function QActor:getRecoverHpLimit()
    return math.clamp(self:_getActorNumberPropertyValue("recover_hp_limit"), 0, self:getMaxHp())
end

--魂灵伤害减免
function QActor:getSoulDamagePercentBeattackReduce()
    return self:_getActorNumberPropertyValue("soul_damage_percent_beattack_reduce")
end

--魂灵伤害增加
function QActor:getSoulDamagePercentAttack()
    return self:_getActorNumberPropertyValue("soul_damage_percent_attack")
end

function QActor:setRecoverHpLimit(value, limit)
    value = math.clamp(value + self:_getActorNumberPropertyValue("recover_hp_limit"), 0, limit)
    self:modifyPropertyValue("recover_hp_limit", self, "+", value)
    self:dispatchEvent({name = QActor.HP_LIMIT_CHANGE_EVENT, value = value})
end

-- AI类型
function QActor:getAIType()
    if not self:getTalentFunc() and self._replaceCharacterId ~= nil then
        local npc_ai = db:getCharacterByID(self._replaceCharacterId).npc_ai
        if npc_ai then
            return npc_ai
        end 
    end

    local aiType = self._npc_ai
    if string.len(aiType) == 0 then
        aiType = self:getTalentFunc()

        if app.battle:isPVPMode() then
            if aiType == "t" or aiType == "dps" then
                aiType = "dps_arena"
            end
        end
    end

    return aiType
end

-- 寻找最近的actor
function QActor:getClosestActor(others, in_battle_range)
    if others == nil then return nil end

    local target = nil
    local dist = 10e20 -- the value that should be large enough

    local area = app.grid:getRangeArea()
    for i, other in ipairs(others) do
        if not other:isDead() then
            if other:getPosition().x > BATTLE_AREA.left - 50 and other:getPosition().x < BATTLE_AREA.right + 50 then
                local qualified = true
                if in_battle_range then
                    local pos = other:getPosition()
                    if pos.x < area.left or pos.x > area.right or pos.y < area.bottom - 15 or pos.y > area.top + 15 then
                        qualified = false
                    end
                end
                if qualified then
                    local x = other:getPosition().x - self:getPosition().x
                    local y = other:getPosition().y - self:getPosition().y
                    local d = x * x + y * y
                    if d < dist then
                        target = other
                        dist = d
                    end
                end
            end
        end
    end

    return target
end

-- 返回最近的actor列表，并按照距离近-远排序
function QActor:getClosestActors(others)
    if others == nil then return nil end

    local target = nil
    local dist = 10e20 -- the value that should be large enough
    local list = {}

    for i, other in ipairs(others) do
        if not other:isDead() then
            if other:getPosition().x > BATTLE_AREA.left - 50 and other:getPosition().x < BATTLE_AREA.right + 50 then
                local x = other:getPosition().x - self:getPosition().x
                local y = other:getPosition().y - self:getPosition().y
                local d = x * x + y * y
                list[#list + 1] = {other = other, dist = d}
            end
        end
    end
    local result = {}
    for i = 1, #list do
        for j = i + 1, #list do
            if list[i].dist > list[j].dist then
                local tmp = list[i]
                list[i] = list[j]
                list[j] = tmp
            end
        end
        result[i] = list[i].other
    end

    return result
end

function QActor:getState()
    return self.fsm__:getState()
end

function QActor:setRect(rect)
    rect.size.width = math.round(rect.size.width)
    rect.size.height = math.round(rect.size.height)
    self._rect = rect
end

function QActor:getRect()
    return self._rect
end

function QActor:setCoreRect(rect)
    rect.size.width = math.round(rect.size.width)
    rect.size.height = math.round(rect.size.height)
    self._coreRect = rect
end

function QActor:setTouchRect(rect)
    rect.size.width = math.round(rect.size.width)
    rect.size.height = math.round(rect.size.height)
    self._touchRect = rect
end

function QActor:getCoreRect()
    return self._coreRect
end

function QActor:getTouchRect()
    return self._touchRect
end

if not IsServerSide then
function QActor:getBoundingBox()
    return CCRectMake(  self._rect.origin.x + self._position.x, 
                        self._rect.origin.y + self._position.y, 
                        self._rect.size.width, self._rect.size.height)
end

function QActor:getCoreBoundingBox()
    return CCRectMake(  self._coreRect.origin.x + self._position.x, 
                        self._coreRect.origin.y + self._position.y, 
                        self._coreRect.size.width, self._coreRect.size.height)
end

function QActor:getTouchBoundingBox()
    return CCRectMake(  self._touchRect.origin.x + self._position.x, 
                        self._touchRect.origin.y + self._position.y, 
                        self._touchRect.size.width, self._touchRect.size.height)
end
end

function QActor:getCenterPosition()
    return {x = self._rect.origin.x + self._position.x + self._rect.size.width * 0.5,
            y = self._rect.origin.y + self._position.y + self._rect.size.height * 0.5}
end

if not IsServerSide then
function QActor:getBoundingBox_Stage()
    local actorView = app.scene:getActorViewFromModel(self)
    local adjust = actorView:convertToWorldSpace(ccp(0, 0))
    adjust.x = adjust.x - self._position.x
    adjust.y = adjust.y - self._position.y

    return CCRectMake(  self._rect.origin.x + self._position.x + adjust.x, 
                        self._rect.origin.y + self._position.y + adjust.y, 
                        self._rect.size.width, self._rect.size.height)
end

function QActor:getCoreBoundingBox_Stage()
    local actorView = app.scene:getActorViewFromModel(self)
    local adjust = actorView:convertToWorldSpace(ccp(0, 0))
    adjust.x = adjust.x - self._position.x
    adjust.y = adjust.y - self._position.y

    return CCRectMake(  self._coreRect.origin.x + self._position.x + adjust.x, 
                        self._coreRect.origin.y + self._position.y + adjust.y, 
                        self._coreRect.size.width, self._coreRect.size.height)
end

function QActor:getCenterPosition_Stage()
    local actorView = app.scene:getActorViewFromModel(self)
    local adjust = actorView:convertToWorldSpace(ccp(0, 0))
    adjust.x = adjust.x - self._position.x
    adjust.y = adjust.y - self._position.y

    local pos = self:getCenterPosition()
    pos.x = pos.x + adjust.x
    pos.y = pos.y + adjust.y
    return pos
end
end

function QActor:getPosition()
    -- printInfo(self:getId() .. " getPosition: " .. self._position.x .. "," .. self._position.y)
    return self._position
end

if not IsServerSide then
function QActor:getPosition_Stage()
    local actorView = app.scene:getActorViewFromModel(self)
    local adjust = actorView:convertToWorldSpace(ccp(0, 0))
    adjust.x = adjust.x - self._position.x
    adjust.y = adjust.y - self._position.y

    local pos = clone(self:getPosition())
    pos.x = pos.x + adjust.x
    pos.y = pos.y + adjust.y
    return pos
end
end

-- 注意：这个函数应该只从QPositionDirector中调用
function QActor:setActorPosition(pos)
    local lastPositionX, lastPositionY = self._position.x, self._position.y
    self._position = pos
    self:dispatchEvent({name = QActor.SET_POSITION_EVENT, position = self._position})

    if DEBUG_ENABLE_REPLAY_LOG then
        local line1 = string.format("move time:%0.6f, frameCount: %d, randomCount:%d, actor:%s %s, from:%0.6f %0.6f, to:%0.6f %0.6f", app.battleTime, app.battleFrame, app.randomCount(),
            self:getDisplayName()..self:getUDID(), tostring(self.monsterIndex), lastPositionX, lastPositionY, pos.x, pos.y)
        print(line1)
        table.insert(app.battle.actorHitAndAttackLogs, line1)
    end

    -- use blink when character have it on Enter to scene
    if not app.battle:isPVPMode() and self:getType() == ACTOR_TYPES.HERO and app.battle ~= nil and app.battle:isWaitingForStart() == true then
        -- check if enter scene
        if lastPositionX < BATTLE_AREA.left + 50 and pos.x >= BATTLE_AREA.left + 50 then
            -- check if have blink skill
            local blinkSkill = nil
            for _, skill in pairs(self._skills) do
                if skill:getName() == "blink" then
                    blinkSkill = skill
                    break
                end
            end
            if blinkSkill == nil or not self:canAttack(blinkSkill) or self:canAttackWithBuff(blinkSkill) then
                return
            end

            local screenPos = app.grid:_toScreenPos(self.gridPos)
            self._dragPosition = {x = screenPos.x + 20, y = screenPos.y}
            self._targetPosition = {x = screenPos.x + 20, y = screenPos.y}
            self:attack(blinkSkill)
        end
    end
end

function QActor:getTargetPosition()
    return self._targetPosition
end

function QActor:getDragPosition()
    return self._dragPosition
end

function QActor:clearTargetPosition()
    self._targetPosition = nil
end

function QActor:stopDoing()
    self.fsm__:doEvent("ready")
end

function QActor:startMoving(pos)
    if pos == nil or self:CanControlMove() == false then
        return
    end

    if self._currentSkill ~= nil and self._currentSkill:isCancelWhileMove() == true then
        self:_cancelCurrentSkill()
    end

    self._targetPosition = pos

    -- 如果已经和当前位置非常接近，则忽略
    if q.is2PointsClose(self._targetPosition, self._position) then
        return
    end

    self.fsm__:doEvent("move")
end

function QActor:stopMoving()
    self.fsm__:doEvent("ready")
end

function QActor:startBeatback()
    if self._currentSkill ~= nil then
        self:_cancelCurrentSkillByOther()
    end

    self.fsm__:doEvent("beatback")
end

function QActor:stopBeatback()
    self.fsm__:doEvent("ready")
end

function QActor:startBlowup()
    if self._currentSkill ~= nil then
        self:_cancelCurrentSkillByOther()
    end

    self.fsm__:doEvent("blowup")
end

function QActor:stopBlowup()
    self.fsm__:doEvent("ready")
end

function QActor:forceStopBlowup()
    if self:isBlowingup() then
        self.blowupParam = nil
        self:stopBlowup()
        self:setActorHeight(0)
    end
end

function QActor:forceStopBeatback()
    if self:isBeatbacking() then
        self.beatbackGridPos = nil
        self:stopBeatback()
        self.beatbackGridPos = nil
        self.beatbackHeight = nil
    end
end

function QActor:isBeatbacking()
    return self.fsm__:isState("beatbacking")
end

function QActor:isBlowingup()
    return self.fsm__:isState("blowingup")
end

function QActor:isDead()
    return self._isDead
end

function QActor:isFrozen()
    return self.fsm__:getState() == "frozen"
end

function QActor:setFullHp()
    local v = self:getMaxHp()
    self:setHp(v)
    -- self._hpValidate:set(v)
    -- self._hp = v
    -- self._hpBeforeLastChange = self._hp

    -- self:onHpChangeForPassiveSkills(v, v)
end

function QActor:setHp(hp)
    if hp == nil then
        return 
    end

    if hp < 0 then
        hp = 0
    end

    self._hpValidate:set(hp)
    self._hp = hp
    self._hpBeforeLastChange = self._hp

    self:dispatchHpChangeEvent(0, self._hpBeforeLastChange, self._hp)

    self:onHpChangeForPassiveSkills(hp, hp)
    self:onHpChangeForEvents(hp, hp)
end

function QActor:reportDoDHP(dHP, attacker, skill, ignoreDhp)
    if not attacker then
        return
    end

    if app.battle:isInUnionDragonWar() and attacker:hasHpGroup() then
        attacker = attacker._hpGroup.main
    end

    local real_attacker = app.battle:isGhost(attacker)
    real_attacker = real_attacker or attacker
    local _type = real_attacker:getType()
    if _type == ACTOR_TYPES.HERO or _type == ACTOR_TYPES.HERO_NPC then
        app.battle._battleLog:onHeroDoDHP(real_attacker:getActorID(), dHP, real_attacker, nil, skill, ignoreDhp)
    else
        app.battle._battleLog:onEnemyHeroDoDHP(real_attacker:getActorID(), dHP, real_attacker, nil, skill, ignoreDhp)
    end
end

function QActor:setIsNeutral(isNeutral)
    self._isNeutral = isNeutral

    local actorType = self:getType()
    if actorType == ACTOR_TYPES.HERO or actorType == ACTOR_TYPES.HERO_NPC then
        if self._isNeutral then
            table.insert(app.battle:getNeutralHeroes(), self)
        else
            table.removebyvalue(app.battle:getNeutralHeroes(), self)
        end
    else
        if self._isNeutral then
            table.insert(app.battle:getNeutralEnemies(), self)
        else
            table.removebyvalue(app.battle:getNeutralEnemies(), self)
        end
    end
end

function QActor:isNeutral()
    return self._isNeutral
end

function QActor:increaseHp(hp, attacker, skill, not_add_to_log, ignoreSyncTreat, source)
    if self:isExile() then
        return self, 0
    end
    attacker = (skill and skill:getDamager()) or attacker
    local is_lock = self:isLockHp()
    if is_lock then
        return self, 0
    end

    local logHp = hp
    local real_treat = logHp

    if (self:getHp() + hp ) >= self:getMaxHp() then
        if skill then
            local over_treat_to_absorb = skill:getOverTreatToAbsorb()
            if over_treat_to_absorb then
                local over_treat = self:getHp() + hp - self:getMaxHp()
                local buff_field = {absorb_damage_value = over_treat * over_treat_to_absorb.percent}
                self:applyBuff(over_treat_to_absorb.buff_id, attacker, skill, nil, buff_field)  --这个buff必须配置override_group，已经跟策划强调
            end
        end

        real_treat = self:getMaxHp() - self:getHp()
        logHp = real_treat
    end

    if SHOW_OVERDOSE_TREAT then
        logHp = hp
    end

    local realAttackee = nil
    local hpGroup = self._hpGroup
    if hpGroup then
        realAttackee = hpGroup.main
    else
        realAttackee = self
    end

    if not ignoreSyncTreat then
        for i,buff in ipairs(self._buffs) do
            local coefficient = buff:getSyncTreatCoefficient()
            local buff_attacker = buff:getAttacker()
            if coefficient > 0 and self ~= buff_attacker then
                local treat_value = hp * coefficient
                local _, dHp = buff_attacker:increaseHp(treat_value, buff_attacker, buff:getSkill(), nil, true)
                if dHp > 0 then
                    buff_attacker:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = true, 
                        isCritical = false, tip = "", rawTip = {
                            isHero = buff_attacker:getType() == ACTOR_TYPES.HERO, 
                            isCritical = false, 
                            isTreat = true,
                            number = dHp,
                        }})
                end
            end
        end
    end

    realAttackee._hpBeforeLastChange = realAttackee._hp

    local newhp = realAttackee._hp + hp
    local dHp = hp
    --[[if newhp > realAttackee:getMaxHp() then
        newhp = realAttackee:getMaxHp()
    end]]
    local hpLimit = realAttackee:getMaxHp() - realAttackee:getRecoverHpLimit()
    if newhp > hpLimit then
        newhp = hpLimit
    end
    if newhp <= 0 then
        app.battle:setRecoverDeath()
    end

    realAttackee._hpValidate:set(newhp)
    realAttackee._hp = newhp

    if attacker then
        attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_TREATING, self, hp) -- 治疗的瞬间

        if skill == nil or skill:ignoreSaveTreat() == false then
            local over_treat = hp - real_treat
            for i,buff in pairs(attacker:getBuffs()) do
                if buff:isSaveTreat() and buff:getSaveTreatTarget() == "attacker" and (buff:getSaveTreatSourceFlag() == nil or buff:getSaveTreatSourceFlag() == source) then
                    local treat_type = buff:getSaveTreatType()
                    if treat_type == "treat" then
                        buff:saveTreat(real_treat)
                    elseif treat_type == "over_treat" then
                        buff:saveTreat(over_treat)
                    elseif treat_type == "all" then
                        buff:saveTreat(hp)
                    end
                end
            end
            for i,buff in pairs(self:getBuffs()) do
                if buff:isSaveTreat() and buff:getSaveTreatTarget() == "attackee" and (buff:getSaveTreatSourceFlag() == nil or buff:getSaveTreatSourceFlag() == source) then
                    local treat_type = buff:getSaveTreatType()
                    if treat_type == "treat" then
                        buff:saveTreat(real_treat)
                    elseif treat_type == "over_treat" then
                        buff:saveTreat(over_treat)
                    elseif treat_type == "all" then
                        buff:saveTreat(hp)
                    end
                end
            end
        end
    end
    -- if self:isInfiniteHpBoss() then
    --     self:dispatchEvent({name = QActor.HP_CHANGED_EVENT_INFINITE,dHP = math.abs(hp), hpBeforeLastChange = realAttackee._hpBeforeLastChange, hp = realAttackee._hp})
    -- end

    self:dispatchHpChangeEvent(hp, realAttackee._hpBeforeLastChange, realAttackee._hp)

    self:onHpChangeForPassiveSkills(realAttackee._hpBeforeLastChange, realAttackee._hp)
    self:onHpChangeForEvents(realAttackee._hpBeforeLastChange, realAttackee._hp)

    local ignoreDhp
    if not_add_to_log then
        ignoreDhp = logHp
        logHp = 0
    end
    self:reportDoDHP(logHp, attacker, skill, ignoreDhp)

    return self, dHp
end

function QActor:onDecreasHp(event)
    local _, damage, absorb, overKill = self:decreaseHp(event.hp, event.attacker, event.skill, event.on_render, event.isAOE, event.ignoreAbsorb, event.not_add_to_log)
    local rawTip = event.rawTip
    local tip = tip

    if absorb > 0 then
        local absorb_tip = "吸收 "
        self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
            isHero = self:getType() ~= ACTOR_TYPES.NPC, 
            isDodge = false, 
            isBlock = false, 
            isCritical = false, 
            isTreat = false,
            isAbsorb = true, 
            number = absorb
        }})
    end

    if damage > 0 then
        self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = tostring(math.floor(damage)),
            rawTip = {
                isHero = self:getType() ~= ACTOR_TYPES.NPC, 
                isDodge = false, 
                isBlock = false, 
                isCritical = false, 
                isTreat = false, 
                number = damage
            }})
    end
end

function QActor:decreaseHp(hp, attacker, skill, no_render, isAOE, ignoreAbsorb, not_add_to_log, isExecute, isBullet, ignoreDamgeLimit, ignoreAbsorbPercent)
    attacker = (skill and skill:getDamager()) or attacker
    local realAttackee = nil
    local hpGroup = self._hpGroup
    if hpGroup then
        realAttackee = hpGroup.main
    else
        realAttackee = self
    end
    ignoreAbsorbPercent = ignoreAbsorbPercent or 0

    if self:isDead() then
        return self, 0, 0, 0
    end

    -- 援助魂师以及宝宝不受到伤害
    if self:isSupportHero() or self:isSoulSpirit() or self:isPet() or (self:isGhost() and (not self:isAttackedGhost())) or self:isExile() then
        return self, 0, 0, 0
    end

    local is_lock = self:isLockHp()
    if is_lock then
        return self, 0, 0, 0
    end

    -- 固定伤害减免, 最少伤害为1
    hp = hp - realAttackee:getNeutralizeDamage()
    if hp <= 0 then hp = 1 end
    
    -- aoe伤害减免
    if isAOE then
        local aoe_beattack_percent = self:getAOEBeattackPercent()
        hp = hp * (1 + aoe_beattack_percent)
    end

    local saveDamageBuffs = {}
    local damageReductionBuffs = {}
    local damageLimitBuffs = {}
    local absoluteCostAbsorb = false    --绕开无视护盾，护盾百分比穿透等的逻辑
    for _, buff in ipairs(self._buffs) do
        if not buff:isImmuned() and buff:isSaveDamage()
            and ( attacker == buff:getAttacker() or  app.battle:isGhost(attacker) == buff:getAttacker()
                or buff:isSaveDamageIgnoreAttacker()) then
            table.insert(saveDamageBuffs, buff)
        end
        if not buff:isImmuned() and buff:hasDamageLimit() and not isExecute and not ignoreDamgeLimit then
            table.insert(damageLimitBuffs, buff)
        end
        if not buff:isImmuned() and buff:isDamageReductionBuff() and self ~= attacker then
            table.insert(damageReductionBuffs, buff)
        end
        if buff:isAbsoluteCostAbsorb() then
            absoluteCostAbsorb = true
        end
    end

    local render_damage = 0
    local reflectDamage = 0
    -- 因为反伤是统一计算的，所以反伤的统计合并到一个技能中统计
    local render_damage_skill, render_heal_skill
    for _, buff in ipairs(damageReductionBuffs) do
        local value = buff:getDamageReductionValue()
        if buff:getDamageReductionDataSource() == "damage" then
            value = value + buff:getDamageReductionPercent() * hp
        else
            value = value + buff:getDamageReductionPercent() * self[buff:getDamageReductionDataSource()](self)
        end
        
        reflectDamage = math.min(value, hp)
        hp = hp - reflectDamage
        if not buff:getDamageReductionNoRender() then
            if reflectDamage > 0 and render_damage_skill == nil then
                render_damage_skill = buff:getSkill()
            end
            render_damage = render_damage + reflectDamage
        end
    end

    local total_damage = hp

    if attacker and realAttackee ~= attacker and not not_add_to_log then
        attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_DAMAGE, self, QBuff.TRIGGER_TARGET_SELF, total_damage)
        local teamSoulSpirits = app.battle:getTeamSoulSpirit(attacker)
        for _, soulSpirit in ipairs(teamSoulSpirits) do
            soulSpirit:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_DAMAGE, self, QBuff.TRIGGER_TARGET_TEAMMATE_OF_SOULSPIRIT, total_damage)
        end
    end

    --群体护盾吸收伤害
    local group_absorb_value = 0
    for i, absorb_info in ipairs(self._group_absorbs) do
        if hp > 0 and absorb_info.absorb > 0 then
            local real_absorb = math.min(hp, absorb_info.absorb)
            absorb_info.absorb = absorb_info.absorb - real_absorb
            group_absorb_value = group_absorb_value + real_absorb
            hp = hp - real_absorb
        end
    end

    -- 計算吸收的傷害
    local absorbReduce, ignore_rage_absorb_reduce_percent
    local damageAbsorbScale
    if skill then
        absorbReduce = skill:getReduceAbsorbPercent()
        damageAbsorbScale = skill:getDamgeAbsorbScale()
    end
    if absorbReduce or damageAbsorbScale then
        local totalAbsorb = self:getAbsorbDamageValue()
        if absorbReduce then
            local absorb_damage_value = totalAbsorb * absorbReduce
            hp = hp + absorb_damage_value
            ignore_rage_absorb_reduce_percent = skill:isIgnoreRageAbsorbReducePercent() and absorb_damage_value or 0
        end
        if damageAbsorbScale and hp * (damageAbsorbScale + 1.0) < totalAbsorb then
            hp = hp * damageAbsorbScale
        end
    end
    --受护盾影响的剩余伤害值
    local absorbValueBeforeCost = 0
    --只有ignoreAbsorb == false 且填了正确的ignoreAbsorbPercent走护盾穿透百分比逻辑, 且不走绝对消耗护盾
    if not ignoreAbsorb and ignoreAbsorbPercent and 0 <= ignoreAbsorbPercent and ignoreAbsorbPercent <= 1 and not absoluteCostAbsorb then
        absorbValueBeforeCost = hp * (1 - ignoreAbsorbPercent)
    else
        absorbValueBeforeCost = hp
    end
    local absorbValueAfterCost = absorbValueBeforeCost
    local render_heal = 0
    local absorb_damage_by_ratio = 0

    if absoluteCostAbsorb or not ignoreAbsorb or absorbReduce then
        for _, buff in ipairs(self._buffs) do
            if buff:isAbsorbDamage() then
                --单次消耗护盾量
                local damage = math.min(buff:getAbsorbDamageValue(), absorbValueAfterCost)
                local rage_ratio = buff:getAbsorbDamageRageRatio()
                local ignore_rage = 0
                local rage_damage = damage
                if ignore_rage_absorb_reduce_percent and ignore_rage_absorb_reduce_percent > 0 then
                    ignore_rage = math.min(rage_damage, ignore_rage_absorb_reduce_percent)
                    ignore_rage_absorb_reduce_percent = ignore_rage_absorb_reduce_percent - ignore_rage
                end
                absorb_damage_by_ratio = absorb_damage_by_ratio + (rage_damage - ignore_rage) * rage_ratio
                local rd, rh = buff:absorbDamageValue(damage)
                if rd > 0 and render_damage_skill == nil then
                    render_damage_skill = buff:getSkill()
                end

                if rh > 0 and render_heal_skill == nil then
                    render_heal_skill = buff:getSkill()
                end
                render_damage = render_damage + rd
                render_heal = render_heal + rh
                absorbValueAfterCost = absorbValueAfterCost - damage

                if damage > 0 then
                    local buff_attacker = buff:getAttacker()
                    if buff:isCountAbosrbToOwner() then
                        buff_attacker = self
                    end
                    self:reportDoDHP(damage, buff_attacker)
                end
                --受护盾影响的剩余伤害消耗完跳出
                if absorbValueAfterCost <= 0 then
                    break
                end
            end
        end
    end
    absorbValueAfterCost = math.max(absorbValueAfterCost, 0)    
    --护盾消耗总量
    local absorbTotal = absorbValueBeforeCost - absorbValueAfterCost
    self._use_absorb_damage_value = self._use_absorb_damage_value + absorbTotal
    --获取扣除护盾后剩余伤害
    --只有ignoreAbsorb == false 且填了正确的ignoreAbsorbPercent走护盾穿透百分比逻辑, 且不走绝对消耗护盾
    if not ignoreAbsorb and ignoreAbsorbPercent and 0 <= ignoreAbsorbPercent and ignoreAbsorbPercent <= 1 and not absoluteCostAbsorb then
        hp = hp * ignoreAbsorbPercent + absorbValueAfterCost
    else
        hp = absorbValueAfterCost
    end
     -- 减少护盾值
    if absorbTotal > 0 then
        self:dispatchAbsorbChangeEvent(-absorbTotal)
    end

    for _, buff in ipairs(saveDamageBuffs) do
        -- if not buff:isImmuned() and buff:isSaveDamage() and ( attacker == buff:getAttacker() or  app.battle:isGhost(attacker) == buff:getAttacker() ) then
            buff:saveDamage(total_damage + reflectDamage)
        -- end
    end
    for _, buff in ipairs(damageLimitBuffs) do
        -- if not buff:isImmuned() and buff:hasDamageLimit() and not isExecute and not ignoreDamgeLimit then
            hp = buff:countDamage(hp)
        -- end
    end

    if isBullet then
        local _real_attacker = app.battle:isGhost(attacker) or attacker
        if _real_attacker then
            _real_attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_BULLET_DAMAGE, self, total_damage)
        end
    end


    -- 怒气计算，吸收的伤害部分需要使用乘以buff:getAbsorbDamageRageRatio()
    if self:hasRage() and (not attacker or not attacker:isCopyHero()) then
        if skill == nil or skill:ignoreRage() ~= true then
            local hp_by_ratio = hp + absorb_damage_by_ratio
            local rageBeattackGainPercent = math.clamp(1, self:_getActorNumberPropertyValue("rage_beattack_gain_percent"), -1)
            self:changeRage(self._rageInfo.beattack_coefficient * (hp_by_ratio / self:getMaxHp()) * (1 + rageBeattackGainPercent)  * math.max((1 + self:getActorPropValue("attack_target_rage_percent")), 0))
            -- glyphs: beattack_coefficient
            self:changeRage(self:getActorPropValue("beattack_coefficient") * (1 + rageBeattackGainPercent) * (hp_by_ratio / self:getMaxHp())  * math.max((1 + self:getActorPropValue("attack_target_rage_percent")), 0))
        end
    end

    realAttackee._hpBeforeLastChange = realAttackee._hp

    local overKill = 0
    local newhp = realAttackee._hp - hp

    local recoverLimit = realAttackee:getRecoverHpLimit()
    if recoverLimit > 0 then
        local decHpValue = recoverLimit - (realAttackee:getMaxHp() - newhp)
        if decHpValue > 0 then
            newhp = newhp - decHpValue
        end
    end

    -- 此代码之后不能对newhp进行运算和赋值
    if newhp <= 0 then
        overKill = -newhp
        newhp = 0
    end

    if isExecute then
        newhp = 0
    end

    local canPlayEffect = false 
    if not self._last_infinite_effect_time or app.battle:getBattleDuration() - 
        self._last_infinite_effect_time >= 1 then
        canPlayEffect = true
    end
    if realAttackee:isInfiniteHpBoss() and newhp <= 0 then 
        self._last_infinite_effect_time = app.battle:getBattleDuration()
        realAttackee:setFullHp()
        newhp = realAttackee._hp
        if canPlayEffect then
            self:playSkillEffect(global.infinite_boss_effect, nil, {attacker = attacker, attackee = realAttackee})
        end
    end

    if newhp == 0 then
        local is_immune_death, buff = self:isImmuneDeath()
        if is_immune_death then
            newhp = 1
            self._last_trigger_immune_death_attacker = attacker
            if buff and not buff:immuneDeathNoTrigger() then
                buff:doTrigger(self)
            end
            for _,listener in ipairs(self._custom_event_list) do
                if buff and buff == listener.obj then
                    if listener.name == QActor.CUSTOM_EVENT_IMMUNE_DEATH then
                        listener.callback()
                    end
                end
            end
        end
    end

    -- if newhp <= 0 then
    --     newhp = realAttackee._hpBeforeLastChange
    -- end

    if DEBUG_ENABLE_REPLAY_LOG then

        if skill then
            local line1 = string.format("hit time:%0.6f, frameCount: %d, randomCount:%d, skill:%s, attacker:%s %s, attackee:%s %s, dHP:%s, from:%s, to:%s", app.battleTime, app.battleFrame, app.randomCount(), skill:getId(),
                attacker:getDisplayName()..attacker:getUDID(), tostring(attacker.monsterIndex), self:getDisplayName()..self:getUDID(), tostring(self.monsterIndex), tostring(hp), tostring(self._hp), tostring(newhp))
            local line2 = string.format("        attacker:%s %s, attackee:%s %s", tostring(attacker:getPosition().x), tostring(attacker:getPosition().y), tostring(self:getPosition().x), tostring(self:getPosition().y))
            print(line1)
            print(line2)
            table.insert(app.battle.actorHitAndAttackLogs, line1)
            table.insert(app.battle.actorHitAndAttackLogs, line2)
        end
        
    end

    if newhp < realAttackee._hp then
        realAttackee._hpValidate:set(newhp)
        realAttackee._hp = newhp
        -- 屏蔽此代码，防止血量更新延迟
        -- app.battle:performWithDelay(function()
            self:dispatchHpChangeEvent(hp, realAttackee._hpBeforeLastChange, realAttackee._hp)
        -- end, 0.17, self)
    end
    
    if newhp == 0 then
        if skill and attacker and not realAttackee:isPet() and not realAttackee:isGhost() and not realAttackee:isSoulSpirit() then
            if skill:getDamageType() == QSkill.PHYSICAL then
                attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_PHYSICAL_KILL, self)
            else
                attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_MAGIC_KILL, self)
            end
        end
        realAttackee:cancelAllSkills()
        realAttackee:removeAllBuff()
        for _, skill in pairs(realAttackee._activeSkills) do
            skill:resetCoolDown()
        end
        for _, skill in pairs(realAttackee._manualSkills) do
            skill:resetCoolDown()
        end

        local deadBehaviorFile = nil
        if nil ~= skill then
            deadBehaviorFile = skill:getTargetDeadBehavior()
        end
        realAttackee:setDeadBehaviorFile(deadBehaviorFile)

        -- 魂灵击杀后给队友回复怒气
        if attacker and attacker:isSoulSpirit() and not realAttackee:isCopyHero() then
            attacker:onSoulSpiritSkillTarget(self._rageInfo.bekill_rage)
        end

        realAttackee.fsm__:doEvent("kill")
        if hpGroup then
            for sub in pairs(hpGroup.subs) do
                sub:cancelAllSkills()
                sub:removeAllBuff()
                for _, skill in pairs(sub._activeSkills) do
                    skill:resetCoolDown()
                end
                for _, skill in pairs(sub._manualSkills) do
                    skill:resetCoolDown()
                end
                sub:setDeadBehaviorFile(deadBehaviorFile)
                sub.fsm__:doEvent("kill")
            end
        end

        -- attacker从击杀中获得怒气
        if attacker and attacker:hasRage() and not self:isCopyHero() then
            attacker:changeRage(self._rageInfo.bekill_rage * attacker._rageInfo.kill_coefficient, nil, true)
            -- glyphs: pvp_kill_rage
            if app.battle:isPVPMode() then
                attacker:changeRage(attacker:getActorPropValue("pvp_kill_rage"))
            end
        end
        -- glyphs: pvp_rage_on_enemy_killed, pvp_rage_on_enemy_killed_for_team, pvp_kill_combo_points
        if attacker and app.battle:isPVPMode() and not self:isCopyHero() then
            local enemies = app.battle:getMyEnemies(self)
            for _, enemy in ipairs(enemies) do
                enemy:changeRage(enemy:getActorPropValue("pvp_rage_on_enemy_killed"))
                for _, enemy2 in ipairs(enemies) do
                    enemy2:changeRage(enemy:getActorPropValue("pvp_rage_on_enemy_killed_for_team"))
                end
            end
        end
        if attacker and attacker:isNeedComboPoints() then
            if app.battle:isPVPMode() then
                local cp = attacker:getActorPropValue("pvp_kill_combo_points")
                -- sample: cp = 0501. cp is FULL_CP_PERCENT * 100 + FIX_CP
                local full_cp_percent = math.floor(cp / 100)
                local fix_cp = math.fmod(cp, 100)
                if full_cp_percent >= (app.random(1, 10000) / 100) then
                    attacker:gainComboPoints(attacker:getComboPointsTotal())
                else
                    attacker:gainComboPoints(fix_cp)
                end
            end
        end
    end

    if realAttackee:isBoss() then
        app.battle:setMinimumHp(newhp/self:getMaxHp())
    end
    self:onHpChangeForPassiveSkills(realAttackee._hpBeforeLastChange, realAttackee._hp)
    self:onHpChangeForEvents(realAttackee._hpBeforeLastChange, realAttackee._hp)
    local dhp = -hp - absorbTotal
    local ignoreDhp
    if not_add_to_log then
        ignoreDhp = dhp
        dhp = 0
    end
    self:reportDoDHP(dhp, attacker, skill, ignoreDhp)

    -- 反弹吸收的伤害
    if not no_render and render_damage > 0 and attacker and not attacker:isDead() then
        local _, damage, absorb = attacker:decreaseHp(render_damage, self, render_damage_skill, true)
        if absorb > 0 then
            local absorb_tip = "吸收 "
            attacker:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
                isHero = attacker:getType() ~= ACTOR_TYPES.NPC, 
                isDodge = false, 
                isBlock = false, 
                isCritical = false, 
                isTreat = false,
                isAbsorb = true, 
                number = math.ceil(absorb),
            }})
        end
        attacker:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip_modifiers = {"反伤"},
            isCritical = false, tip = "", rawTip = {
                isHero = attacker:getType() ~= ACTOR_TYPES.NPC,
                isDodge = false,
                isBlock = false,
                isCritical = false,
                isTreat = false,
                isAbsorb = false,
                number = math.ceil(damage),
            }})
    end
    -- 治疗吸收的伤害
    if not no_render and render_heal > 0 then
        local _, dHp = self:increaseHp(render_heal, self, render_heal_skill, false)
        if dHp > 0 then
            self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, 
                isCritical = false, tip = "", rawTip = {
                    isHero = self:getType() ~= ACTOR_TYPES.NPC,
                    isDodge = false,
                    isBlock = false,
                    isCritical = false,
                    isTreat = true,
                    isAbsorb = false,
                    number = math.ceil(dHp),
                }})
        end
    end

    return self, hp, absorbTotal + group_absorb_value, overKill
end

function QActor:addHpChangeListener(obj, func, value, callback)
    table.insert(self._custom_event_list, {name = QActor.CUSTOM_EVENT_HP_CHANGE, func = func, value = value, callback = callback, obj = obj})
end

function QActor:addCustomEventListener(obj, name, params, callback)
    if name == QActor.CUSTOM_EVENT_HP_CHANGE then
        local cfgs = string.split(params, ";")
        self:addHpChangeListener(obj,cfgs[1], tonumber(cfgs[2]), callback)
    elseif name == QActor.CUSTOM_EVENT_BUFF_REMOVE then
        table.insert(self._custom_event_list, {name = QActor.CUSTOM_EVENT_BUFF_REMOVE, buff_id = params, callback = callback, obj = obj})
    else
        table.insert(self._custom_event_list, {name = name, params = params, callback = callback, obj = obj})
    end
end

function QActor:removeCustomEventListener(obj)
    local len = #self._custom_event_list
    for i = len, 1, -1 do
        if self._custom_event_list[i] and self._custom_event_list[i].obj == obj then
            table.remove(self._custom_event_list, i)
        end
    end
end

function QActor:suicide(no_dead_skill_or_animation)
    self:cancelAllSkills()
    self:removeAllBuff()
    self._no_dead_skill_or_animation = no_dead_skill_or_animation
    self.fsm__:doEvent("kill")
    self._isSuicided = true
end

function QActor:isNoDeadSkillOrAnimation()
    return self._no_dead_skill_or_animation
end

function QActor:isSuicided()
    return self._isSuicided
end

-- self._isLockDrag为真时，不允许拖动，防止冲锋时乱跑
function QActor:isLockDrag()
    return self._isLockDrag
end

function QActor:lockDrag()
    self._isLockDrag = true
end

function QActor:unlockDrag()
    self._isLockDrag = false
end

function QActor:isLockTarget()
    return self._isLockTarget > 0
end

function QActor:lockTarget()
    self._isLockTarget = self._isLockTarget + 1
end

function QActor:unlockTarget()
    self._isLockTarget = self._isLockTarget - 1
end

function QActor:alwaysLockTarget()
    self._alwaysLockTarget = true
end

function QActor:unAlwaysLockTarget()
    self._alwaysLockTarget = false
end

function QActor:setTarget(target)
    if self._alwaysLockTarget == true and (self._target and not self._target:isDead()) then
        return
    else
        self._alwaysLockTarget = false
    end
    
    if self._isLockTarget > 0 and self._target ~= nil and self._target:isDead() == false then
        return
    end

    --Netural目标无法被选择
    if target and target:isNeutral() then
        return
    end

    if not self:isHealth() then
        if target == self then
            return
        end
    end

    if target == self:getTarget() then
        return
    end

    -- target should alive
    if target ~= nil and target:isDead() == true then
        return
    end

    if self._target ~= nil then
        if self._targetSkillHandle ~= nil then
            self._target:removeEventListener(self._targetSkillHandle)
            self._targetSkillHandle = nil
        end
    end

    if target ~= nil then 
        self._targetSkillHandle = target:addEventListener(QActor.KILL_EVENT, handler(self, self._onTargetKill))
    end

    self._target = target
end

function QActor:isHealth()
    return (self:getTalent() ~= nil and self:getTalentFunc() == "health")
end

function QActor:isT()
    return (self:getTalent() ~= nil and self:getTalentFunc() == "t")
end

function QActor:isDps()
    return (self:getTalent() ~= nil and self:getTalentFunc() == "dps")
end

-- 是否是远程攻击的角色
function QActor:isRanged()
    if not self:getTalentSkill() then
        return false
    end
    
    -- if self:isSoulSpirit() then
    --     return self:getTalentSkill():getAttackDistance() >= global.soulSpirit_ranged_attack_distance * global.pixel_per_unit
    -- else
        return self:getTalentSkill():getAttackDistance() >= global.ranged_attack_distance * global.pixel_per_unit
    -- end
end

function QActor:getTarget()
    return self._target
end

function QActor:isInBattleArea()
    if self._position.x >= BATTLE_AREA.left 
        and self._position.x <= BATTLE_AREA.right
        and self._position.y >= BATTLE_AREA.bottom
        and self._position.y <= BATTLE_AREA.top then
       return true
    end
    return false
end

function QActor:canMove()
    return self.fsm__:canDoEvent("move")
end

function QActor:canAttack(skill, ignore_cd_and_cancel, isDrag)
    if app.battle:isBattleEnded() == true then
        return
    end

    if skill == nil or self:isDead() == true then
        return false
    end

    if skill == self._currentSkill then
        return false
    end

    -- check use condition - cd
    if skill:isReadyAndConditionMet(ignore_cd_and_cancel) == false then
        return false
    end

    if self:isExile() then
        return false
    end

    -- get change state 
    local changeEvent = nil
    if skill == self:getTalentSkill() or skill == self:getTalentSkill2() then
        changeEvent = "attack"
    else
        changeEvent = "skill"
    end

    -- other conditions
    if self.fsm__:canDoEvent(changeEvent) == false then
        return false
    end

    -- check target
    if skill:isNeedATarget() == true then
        if self._target == nil or self._target:isDead() == true or self._target:isInBattleArea() == false then 
            return false 
        end

        -- check distance
        if skill:get("auto_target") and self:getTarget() then
            if skill:isInSkillRange(self:getPosition(), self:getTarget():getPosition(), self, self:getTarget()) == false then
                return false
            end
        end
    end

    if not ignore_cd_and_cancel then
        -- check if current skill can cancel
        if self._currentSkill ~= nil then
            local currentSkillType = self._currentSkill:getSkillType()
            local skillType = skill:getSkillType()
            if currentSkillType == QSkill.ACTIVE then
                if not isDrag and (self._currentSkill ~= self:getTalentSkill() and self._currentSkill ~= self:getTalentSkill2()) and skillType ~= QSkill.MANUAL then
                    return false
                end
            elseif currentSkillType == QSkill.MANUAL then
                return false
            end
        end
    end

    if skill:getSkillType() == skill.ACTIVE and
        (skill:getTriggerCondition() == skill.TRIGGER_CONDITION_DRAG or 
            skill:getTriggerCondition() == skill.TRIGGER_CONDITION_DRAG_OR_DRAG_ATTACK)
        and self:CanChargeOrBlink() == false then
        return false
    end

    if skill:isChargeSkill() and self._target and self._target._immune_charge then
        return false
    end

    if app.battle:isInArena() and not app.battle:isInGlory() then
        local skillType = skill:getSkillType()
        if skillType == QSkill.MANUAL then
            if app.battle:isInBulletTime() then
                return false
            elseif app.battle:hasPotentialBulletTimeSkillBehavior() then
                return false
            end
        end
    end

    -- 检查召唤鬼魂是否数量达到上限
    local ghostLimit = skill:getGhostLimit()
    if ghostLimit then
        if ghostLimit <= skill:getLivingSummonedGhostCount() then
            return false
        end
    end

    return true
end

function QActor:getTalentSkill()
    if self._replaceCharacterTalentSkill and self._replaceCharacterTalentSkill.talentSkill1 then
        return self._replaceCharacterTalentSkill.talentSkill1
    end

    if self._talentSkill == nil then
        local id = self._npc_skill
        if id == -1 and self:getTalent() then
            id = self:getTalent().skill_1
        end
        for _, skill in pairs(self._skills) do
            if skill:getId() == id then
                self._talentSkill = skill
                break
            end
        end
    end
    return self._talentSkill
end

function QActor:getTalentSkill2()   
    if self._replaceCharacterTalentSkill then
        return self._replaceCharacterTalentSkill.talentSkill2
    end
 
    if self._talentSkill2 == nil then
        local id = self._npc_skill2
        if id == -1 and self:getTalent() then
            id = self:getTalent().skill_2
        end
        for _, skill in pairs(self._skills) do
            if skill:getId() == id then
                self._talentSkill2 = skill
                break
            end
        end
    end
    return self._talentSkill2
end

function QActor:getNextAttackSkill()
    if self._rage_decide_attack then
        if self:isRageEnough() then
            return self:getTalentSkill2()
        else
            return self:getTalentSkill()
        end
    end

    if self._nextAttackSkill == nil then
        self:resetNextAttackSkill()
    end

    return self._nextAttackSkill
end

function QActor:resetNextAttackSkill()
    local talentSkill = self:getTalentSkill()
    local talentSkill2 = self:getTalentSkill2()
    if talentSkill2 == nil then
        self._nextAttackSkill = talentSkill
    else
        self._nextAttackSkill = (app.random(1, 10000) <= 7500 and talentSkill) or talentSkill2  
    end
end

function QActor:switchNextAttackSkill()
    local talentSkill = self:getTalentSkill()
    local talentSkill2 = self:getTalentSkill2()
    self._nextAttackSkill = (self._nextAttackSkill == talentSkill) and talentSkill2 or talentSkill
end

function QActor:getVaildActiveSkillForAutoLaunch()
    if self._currentSkill ~= nil then
        return nil
    end

    local validSkills = {}
    local validSkillPriority = nil
    for _, skill in ipairs(self._activeSkillsByPriority) do
        if validSkillPriority ~= nil and skill:getSkillPriority() < validSkillPriority then
            break
        end

        if skill:getTriggerCondition() == nil 
            and ((skill ~= self:getTalentSkill() and skill ~= self:getTalentSkill2()) or skill == self:getNextAttackSkill())
            and self:canAttack(skill)
            and self:canAttackWithBuff(skill) then
                -- 如果是aoe技能的话检查技能是否能够命中至少一个目标
                local aoe_ok = true
                if skill:getRangeType() == skill.MULTIPLE then
                    if not(skill:getZoneType() == skill.ZONE_FAN and skill:getSectorCenter() == skill.CENTER_TARGET and (not self:getTarget() or self:getTarget():isDead())) then
                        local targets = self:getMultipleTargetWithSkill(skill, self:getTarget(), nil)
                        if #targets == 0 then
                            -- aoe区域范围可以生成，但是aoe区域范围内没有合适的目标，所以失败。
                            aoe_ok = false
                        end
                    else
                        -- aoe区域无法生成，需要一个target作为中心，但是没有target，所以失败。
                        aoe_ok = false
                    end
                end

                if aoe_ok then
                    table.insert(validSkills, skill)
                    validSkillPriority = skill:getSkillPriority()
                elseif skill == self:getNextAttackSkill() then
                    self:switchNextAttackSkill()
                end
        end
    end

    if #validSkills == 0 then
        return nil
    elseif #validSkills == 1 then
        return validSkills[1]
    else
        return validSkills[app.random(1, #validSkills)]
    end
end

-- 触发型攻击
function QActor:triggerAttack(skill, counterattack_target, instantly, triggeredBySkill, triggeredByBuff)
    if skill == nil then
        return
    end

    -- 触发型攻击不会受到控制型buff影响，也不会移除控制型buff
    -- if skill:getDamager() == nil or skill:getDamager() == skill:getActor() then
    --     local remove_buffs = {}
    --     for _, buff in ipairs(self._buffs) do
    --         if buff.effects.can_use_skill == false and not buff:isImmuned() then
    --             if buff.effects.can_be_removed_with_skill == false or skill:canRemoveBuff() == false then
    --                 -- 检查技能是否可以通过remove status移除buff
    --                 if skill:isRemoveStatus(buff:getStatus()) then
    --                     table.insert(remove_buffs, buff)
    --                 else
    --                     return
    --                 end
    --             end
    --         end
    --     end
    --     for _, buff in ipairs(remove_buffs) do
    --         self:removeBuffByID(buff:getId())
    --     end
    -- end

    -- 单体：检查技能的status是否会被target的任意一个buff的immune status给免疫掉，免疫的话直接返回
    local skillImmuned = false
    if skill:getRangeType() == QSkill.SINGLE then
        local target = nil
        local target_type = skill:getTargetType()
        if target_type == QSkill.COUNTERATTACK_TARGET then
            target = counterattack_target
        end

        if target_type == QSkill.SELF then
            target = self
        elseif target == nil then
            target = self:getTarget()
        end
        
        if target == nil and skill:isAllowNoTarget() ~= true then
            return
        end

        if target then
            skillImmuned = target:isImmuneSkill(skill)
        end

        counterattack_target = target
    end
    if skillImmuned then
        return
    end

    -- 检查召唤鬼魂是否数量达到上限
    local ghostLimit = skill:getGhostLimit()
    if ghostLimit then
        if ghostLimit <= skill:getLivingSummonedGhostCount() then
            return
        end
    end

    local sbDirector = QSBDirector.new(self, counterattack_target or self._target, skill)
    sbDirector._is_triggered = true
    sbDirector._triggeredBySkill = triggeredBySkill
    sbDirector._triggeredByBuff = triggeredByBuff

    local minimum_interval = skill:getMinimumInterval()
    if minimum_interval > 0 then
        table.insert(self._sbDirectorsWaitingList, {sbDirector, minimum_interval})
    else
        table.insert(self._sbDirectors, sbDirector)
    end
    if self:isDead() then self._isDoingDeadSkill = true end

    if skill:isTriggerDisplayName() and skill:getSkillType() == QSkill.PASSIVE then
        self:dispatchEvent({name = QActor.TRIGGER_PASSIVE_SKILL, sprite_frame = skill:getTriggerSpriteFrame(), skill = skill})
    end

    skill:coolDown()

    if skill:canRemoveBuff() == true then
        local index = -1
        while index ~= 0 do
            index = 0
            for i, buff in ipairs(self._buffs) do
                if buff.effects.can_be_removed_with_skill == true then
                    index = i
                    break
                end
            end
            if index ~= 0 then
                self:removeBuffByIndex(index)
            end
        end
    end

    if instantly then
        sbDirector:visit(0)
    end

    return sbDirector
end

function QActor:canAttackWithBuff(skill)
    for _, buff in ipairs(self._buffs) do
        if not buff:isImmuned() then
            if buff.effects.can_use_skill == false then
                -- 检查技能是否可以通过remove status移除buff
                if not skill:isRemoveStatus(buff:getStatus()) then
                    return false
                end
            elseif buff.effects.can_cast_spell == false and not skill:isTalentSkill() and skill:getDamageType() == skill.MAGIC then
                -- 检查技能是否可以通过remove status移除buff
                if not skill:isRemoveStatus(buff:getStatus()) then
                    return false
                end
            end
        end
    end

    -- 单体：检查技能的status是否会被target的任意一个buff的immune status给免疫掉，免疫的话直接返回
    local skillImmuned = false
    if skill:getRangeType() == QSkill.SINGLE and skill:isNeedATarget() then
        local target = nil
        if counterattack_target then
            target = counterattack_target
        elseif skill:getTargetType() == QSkill.SELF then
            target = self
        else
            target = self:getTarget()
        end

        skillImmuned = target and target:isImmuneSkill(skill)
    end
    if skillImmuned then
        return false
    end

    return true
end

-- 攻击
function QActor:attack(skill, auto, counterattack_target, instantly)
    if skill == nil then
        return
    end
    
    if DEBUG_ENABLE_REPLAY_LOG then
        local line1 = string.format("attack time:%0.6f, frameCount:%d, randomCount:%d, skill:%s, attacker:%s %s", app.battleTime, app.battleFrame, app.randomCount(), skill:getId(),
        self:getDisplayName()..self:getUDID(), tostring(self.monsterIndex))
        local line2 = string.format("        attacker:%s %s", tostring(self:getPosition().x), tostring(self:getPosition().y))
        print(line1)
        print(line2)
        table.insert(app.battle.actorHitAndAttackLogs, line1)
        table.insert(app.battle.actorHitAndAttackLogs, line2)
    end

    -- 防止援助魂师在释放主技能时释放别的技能
    if self:isSupportHero() then
        local sbDirectors = self:getSkillDirectors()
        local mainSkill = self:getFirstManualSkill()
        for _, sbDirector in ipairs(sbDirectors) do
            if sbDirector:getSkill() == mainSkill then
                return
            end
        end
    end

    local remove_buffs = {}
    for _, buff in ipairs(self._buffs) do
        if (buff.effects.can_use_skill == false and not buff:isImmuned())
            or (buff.effects.can_cast_spell == false and not skill:isTalentSkill() and skill:getDamageType() == skill.MAGIC) then
            if buff.effects.can_be_removed_with_skill == false or skill:canRemoveBuff() == false then
                -- 检查技能是否可以通过remove status移除buff
                if skill:isRemoveStatus(buff:getStatus()) then
                    table.insert(remove_buffs, buff)
                else
                    return
                end
            end
        end
    end
    for _, buff in ipairs(remove_buffs) do
        self:removeBuffByID(buff:getId())
    end

    -- 单体：检查技能的status是否会被target的任意一个buff的immune status给免疫掉，免疫的话直接返回
    local skillImmuned = false
    if skill:getRangeType() == QSkill.SINGLE and skill:isNeedATarget() then
        local target = nil
        local target_type = skill:getTargetType()
        if skill:getTargetType() == QSkill.SELF then
            target = self
        else
            target = self:getTarget()
        end
        skillImmuned = target and target:isImmuneSkill(skill)
    end
    if skillImmuned then
        return
    end

    -- local format = "attacker:%s[%d] attackee:%s[%d] skill:%d random:%d"
    -- local attackee = counterattack_target or self._target
    -- print(string.format(format,self:getDisplayName(),self:getActorID(),attackee and attackee:getDisplayName() or 'nil',attackee and attackee:getActorID() or -1,skill:getId(),app.randomCount()))

    self:_cancelCurrentSkill()

    if not self:isDead() and skill:isStopMoving() then
        self:stopMoving() -- 停止移动，站位机制里面需要对这个情况做特殊处理
    end

    if not self:isDead() then
        if skill ~= self:getTalentSkill() and skill ~= self:getTalentSkill2() then
            self.fsm__:doEvent("skill", {skill = skill})
        else
            self.fsm__:doEvent("attack", {skill = skill})
        end
    end

    self._currentSkill = skill
    self._currentSBDirector = QSBDirector.new(self, counterattack_target or self._target, skill)
    table.insert(self._sbDirectors, self._currentSBDirector)

    skill:coolDown(nil, self:isSoulSpirit())

    if skill == self:getNextAttackSkill() then
        self:resetNextAttackSkill()
    end

    if skill:canRemoveBuff() == true then
        local index = -1
        while index ~= 0 do
            index = 0
            for i, buff in ipairs(self._buffs) do
                if buff.effects.can_be_removed_with_skill == true then
                    index = i
                    break
                end
            end
            if index ~= 0 then
                self:removeBuffByIndex(index)
            end
        end
    end
    
    if skill:getSkillType() == QSkill.MANUAL then
        self:dispatchEvent({name = QActor.USE_MANUAL_SKILL_EVENT, skill = skill, actor = self})
        if self:getType() == ACTOR_TYPES.HERO then
            local cast_sound = self._displayInfo.cast
            if not IsServerSide and cast_sound then
               app.sound:playSound(cast_sound)
            end

            app.battle:onActorUseManualSkill(self, skill, auto)
        end
        if self:isSupportHero() then
            self._supportSkillUsageCount = self._supportSkillUsageCount + 1
        end
        if skill ~= self._victorySkill and skill:getId() ~= self:getDeadSkillID() then
            if not IsServerSide then
                app.scene:onUseSuperSkill(self, skill)
            end
        end
    end

    local combo_points = skill:getComboPointsGain()
    if combo_points > 0 then
        self:gainComboPoints(combo_points)
    end

    -- if skill:isNeedComboPoints() then
    --     self:consumeComboPoints()
    -- end

    -- if skill:isNeedRage() or self:isSupportHero() then
    --     self:consumeRage()
    -- end

    
    -- 如果是storyline的actor就不要把它加到战斗统计里了
    if not self:isStoryActor() then
        app.battle:onUseSkill(self, skill)
    end

    if instantly then
        self._currentSBDirector:visit(0)
    end

    -- aoe技能释放触发敌方被动技能
    if not self:isPet() and not self:isSoulSpirit() then
        if skill:getAttackType() == skill.ATTACK and skill:getRangeType() == skill.MULTIPLE and not skill:isTalentSkill() then
            local enemies = app.battle:getMyEnemies(self)
            for _, enemy in ipairs(enemies) do
                enemy:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_ENEMY_CAST_AOE, self) -- aoe
                if skill:getSkillType() ~= skill.MANUAL then
                    enemy:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_ENEMY_CAST_AOE_SMALL, self) -- aoe小招
                end
            end
        end

        if skill:getSkillType() == QSkill.ACTIVE then
            if skill:isTalentSkill() then

            else
                self:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_USE_ACTIVE_NOT_MANUAL, self)
            end
        end
    end

    return self._currentSBDirector
end

--[[
    set actor flipX.
--]]
function QActor:isFlipX()
    return (self._direction == QActor.DIRECTION_RIGHT)
end

function QActor:_setFlipX()
    if self._victory == true and self._direction == QActor.DIRECTION_RIGHT then
        if self._currentSkill == nil or self._currentSkill ~= self._victorySkill then
            return
        end
    end

    if app.battle and app.battle:isInUnionDragonWar() and (self:isBoss() or self:hasHpGroup()) then --龙战boss写死不能转向
        return
    end

    if self._direction == QActor.DIRECTION_LEFT then
        self._direction = QActor.DIRECTION_RIGHT
    else
        self._direction = QActor.DIRECTION_LEFT
    end

    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(self)
        if view then
            view:flipActor()
        end
    end
end

function QActor:_verifyFlip()
    if not self:isMovable() or self:isBeatbacking() then
        return
    end
    if self:getTarget() == nil then
        return
    end
    if self:getTarget() == self then
        return
    end

    local dx = self:getPosition().x - self:getTarget():getPosition().x
    if dx < EPSILON then
        if self._direction == QActor.DIRECTION_LEFT then
            self:_setFlipX()
        end
    elseif dx > EPSILON then
        if self._direction == QActor.DIRECTION_RIGHT then
            self:_setFlipX()
        end
    end
end

function QActor:_verifyBeatbackFlip()
    if math.xor(self.beatbackStartPosition.x > self.beatbackTargetPosition.x, self._direction == QActor.DIRECTION_RIGHT) then
        self:_setFlipX()
    end
end

function QActor:setDirection(direction)
    if direction ~= QActor.DIRECTION_LEFT and direction ~= QActor.DIRECTION_RIGHT then
        return
    end

    if self._direction == direction then
        return
    else
        self:_setFlipX()
    end

end

function QActor:getDirection()
    return self._direction
end

-- nzhang: 技能AoE的对象选取函数
function QActor:getMultipleTargetWithSkill(skill, target, center, range_percent, filter_actors, area_index, getAll, traps)
    area_index = area_index or 1
    local targets = {}
    local trap_inited = traps ~= nil
    if skill == nil then
        return targets
    end

    -- 扇形区域
    if skill:getZoneType(area_index) == QSkill.ZONE_FAN then
        -- get center position
        if skill:getSectorCenter() == QSkill.CENTER_SELF then
            -- 以自己为攻击圆的中心
            center = self:getPosition()
        elseif skill:getSectorCenter() == QSkill.CENTER_TARGET then
            if center == nil and target ~= nil then
                -- 在延迟的0.2秒内攻击对象有可能已经被打死
                center = target:getPosition()
            end
        elseif skill:getSectorCenter() == QSkill.CENTER_RANDOM_TEAMMATE_AND_SELF then
            if center == nil then
                local teammates = app.battle:getMyTeammates(self, true, true)
                local selectIndex = app.random(1, #teammates)
                if teammates[selectIndex] and not teammates[selectIndex]:isDead() then
                    center = teammates[selectIndex]:getPosition()
                else
                    return targets{}
                end
            end
        elseif skill:getSectorCenter() == QSkill.CENTER_RANDOM_ENEMY then
            if center == nil then
                local teammates = app.battle:getMyEnemies(self, true)
                local selectIndex = app.random(1, #teammates)
                if teammates[selectIndex] and not teammates[selectIndex]:isDead() then
                    center = teammates[selectIndex]:getPosition()
                else
                    return targets{}
                end
            end
        elseif skill:getSectorCenter() == QSkill.CENTER_COORDINATE then
            if center == nil then
                center = {x = skill:getSectorX(), y = skill:getSectorY()}
            end
        elseif skill:getSectorCenter() == QSkill.CENTER_TRAP then
            if traps == nil then
                traps = {}
                local trap_directors = app.battle:getTrapDirectors()
                local status = skill:getSectorCenterTrapStatus()
                local attacker = skill:getActor()
                for i, trap_director in ipairs(trap_directors) do
                    if trap_director:isExecute() then
                        local trap = trap_director:getTrap()
                        if trap:getTrapOwner() == attacker and trap:getStatus() == status then
                            table.insert(traps, trap)
                        end
                    end
                end
                if traps[1] then
                    center = {x = traps[1]:getPosition().x, y = traps[1]:getPosition().y}
                else
                    return targets
                end
            end
        end

        -- it's a sector
        local directionActor = nil
        if skill:getSectorCenter() == QSkill.CENTER_SELF then
            directionActor = self
        else
            directionActor = target
        end

        -- center offset
        if skill:getSectorCenterOffset() ~= "" then
            center = clone(center)
            local offset = skill:getSectorCenterOffset()
            local words = string.split(offset, ",")
            center.x = center.x + (directionActor:isFlipX() and tonumber(words[1]) or -tonumber(words[1])) * global.pixel_per_unit
            center.y = center.y + tonumber(words[2]) * global.pixel_per_unit
        end

        -- get radius in pixel
        local radius = skill:getSectorRadius() * global.pixel_per_unit
        if range_percent then
            radius = radius * range_percent
        end
        radius = radius * radius

        -- get target in circle
        if center ~= nil then
            local actors = {}
            if getAll then
                actors = app.battle:getMyTeammates(self, true)
                table.mergeForArray(actors, app.battle:getMyEnemies(self))
            elseif skill:getTargetType() == QSkill.TEAMMATE then
                actors = app.battle:getMyTeammates(self)
            elseif skill:getTargetType() == QSkill.TEAMMATE_AND_SELF then
                actors = app.battle:getMyTeammates(self, true)
            elseif skill:getTargetType() == QSkill.ENEMY then
                actors = app.battle:getMyEnemies(self)
            end

            local sectorDegree = skill:getSectorDegree()

            if sectorDegree >= 360 then
                local function _circleFilter(actor)
                    local function _inCircle(pos)
                        local deltaX = pos.x - center.x
                        local deltaY = (pos.y - center.y) * skill:getYRatio()
                        local distance = deltaX * deltaX + deltaY * deltaY
                        return distance < radius
                    end
                    local pos = actor:getPosition()
                    local hwidth = actor:getSelectRectWidth() * actor:getActorScale() / 2
                    local pos1 = {x = pos.x + hwidth, y = pos.y}
                    local pos2 = {x = pos.x - hwidth, y = pos.y}
                    return _inCircle(pos) or _inCircle(pos1) or _inCircle(pos2)
                end
                -- it's a circle
                for _, actor in ipairs(actors) do
                    if _circleFilter(actor) then
                        table.insert(targets, actor)
                    end
                end
            else
                -- is on right side
                local isRightDirection = (directionActor:isFlipX() == true)

                sectorDegree = sectorDegree * 0.5

                local function _sectorFilter(actor)
                    local function _inSector(pos)
                        local deltaX = pos.x - center.x
                        local deltaY = (pos.y - center.y) * skill:getYRatio()
                        local distance = deltaX * deltaX + deltaY * deltaY
                        if distance < radius then
                            --[[
                                For any real number (e.g., floating point) arguments x and y not both equal to zero, 
                                atan2(y, x) is the angle in radians between the positive x-axis of a plane and the point given by the coordinates (x, y) on it. 
                                The angle is positive for counter-clockwise angles (upper half-plane, y > 0), and negative for clockwise angles (lower half-plane, y < 0).
                                This produces results in the range (−π, π], which can be mapped to [0, 2π) by adding 2π to negative results.
                            --]]

                            if deltaX == 0 then
                                if sectorDegree >= 90 then
                                    return true
                                end
                                
                            elseif deltaY == 0 then
                                if isRightDirection == true and deltaX > 0 then
                                    return true
                                elseif isRightDirection == false and deltaX < 0 then
                                    return true
                                end

                            else
                                if isRightDirection == false then
                                    deltaX = -deltaX
                                end

                                local radian = math.atan2(deltaY, deltaX)
                                local degree = 180 / math.pi * radian
                                if degree < 0 then
                                    degree = -degree
                                end

                                if degree < sectorDegree then
                                    return true
                                end
                            end
                            return false
                        end
                    end
                    local pos = actor:getPosition()
                    local hwidth = actor:getSelectRectWidth() * actor:getActorScale() / 2
                    local pos1 = {x = pos.x + hwidth, y = pos.y}
                    local pos2 = {x = pos.x - hwidth, y = pos.y}
                    return _inSector(pos) or _inSector(pos1) or _inSector(pos2)
                end
                for _, actor in ipairs(actors) do
                    if _sectorFilter(actor) then
                        table.insert(targets, actor)
                    end
                end
            end

            -- -- display range
            if not IsServerSide and DISPLAY_SKILL_RANGE == true then
                if sectorDegree >= 360 then
                    radius = math.sqrt(radius)
                    local bottomLeft = ccp(center.x - radius, center.y - radius * 1 / skill:getYRatio())
                    local topRight = ccp(center.x + radius, center.y + radius * 1 / skill:getYRatio())
                    app.scene:displayRect(bottomLeft, topRight)
                elseif sectorDegree < 90 then
                    local isRightDirection = (self:isFlipX() == true)
                    radius = math.sqrt(radius)
                    local radian = sectorDegree * math.pi / 180
                    local lenth = radius * math.tan(radian)
                    lenth = lenth * 0.5
                    if isRightDirection == false then
                        local pos1 = center
                        local pos2 = ccp(center.x - radius, center.y + lenth)
                        local pos3 = ccp(center.x - radius, center.y - lenth)
                        app.scene:displayTriangle(pos1, pos2, pos3)
                    else
                        local pos1 = center
                        local pos2 = ccp(center.x + radius, center.y - lenth)
                        local pos3 = ccp(center.x + radius, center.y + lenth)
                        app.scene:displayTriangle(pos1, pos2, pos3)
                    end
                    
                end
            end
        end
    -- 矩形区域
    else
        -- get target in rect
        local actors = {}
        if getAll then
            actors = app.battle:getMyTeammates(self, true)
            table.mergeForArray(actors, app.battle:getMyEnemies(self))
        elseif skill:getTargetType() == QSkill.TEAMMATE then
            actors = app.battle:getMyTeammates(self)
        elseif skill:getTargetType() == QSkill.TEAMMATE_AND_SELF then
            actors = app.battle:getMyTeammates(self, true)
        elseif skill:getTargetType() == QSkill.ENEMY then
            actors = app.battle:getMyEnemies(self)
        end

        local rectwidth = skill:getRectWidth(area_index) * global.pixel_per_unit
        local rectheight = skill:getRectHeight(area_index) * global.pixel_per_unit

        if rectwidth > 0 and rectheight > 0 then
            local directionActor = self
            local isRightDirection = (directionActor:isFlipX() == true)
            local center = self:getPosition()
            -- center offset
            if skill:getRectCenterOffset(area_index) ~= "" then
                center = clone(center)
                local offset = skill:getRectCenterOffset(area_index)
                local words = string.split(offset, ",")
                center.x = center.x + (directionActor:isFlipX() and tonumber(words[1]) or -tonumber(words[1])) * global.pixel_per_unit
                center.y = center.y + tonumber(words[2]) * global.pixel_per_unit
            end

            local left = (isRightDirection and center.x) or (center.x - rectwidth)
            local right = (not isRightDirection and center.x) or (center.x + rectwidth)
            local bottom = center.y - rectheight / 2
            local top = center.y + rectheight / 2

            if range_percent then
                if isRightDirection then
                    right = math.sampler(left, right, range_percent)
                else
                    left = math.sampler(right, left, range_percent)
                end
            end

            local function _rectFilter(actor)
                local angle = skill:getRectAngle(area_index)
                local _inRect
                if angle ~= 0 then
                    _inRect = function(pos)
                        local rect = QRectMake(left, bottom, right - left, top - bottom)
                        return QRotateRectContainPoint(rect, -math.pi/180*angle, qccp(pos.x, pos.y))
                    end
                else     
                    _inRect = function(pos)
                        return pos.x >= left and pos.x <= right and pos.y >= bottom and pos.y <= top
                    end
                end

                local pos = actor:getPosition()
                local hwidth = actor:getSelectRectWidth() * actor:getActorScale() / 2
                local pos1 = {x = pos.x + hwidth, y = pos.y}
                local pos2 = {x = pos.x - hwidth, y = pos.y}
                return _inRect(pos) or _inRect(pos1) or _inRect(pos2)
            end
            for _, actor in ipairs(actors) do
                if _rectFilter(actor) then
                    table.insert(targets, actor)
                end
            end
            -- display range
            if not IsServerSide and DISPLAY_SKILL_RANGE == true then
                local angle = skill:getRectAngle(area_index)
                if angle == 0 then
                    app.scene:displayRect({x = left, y = bottom}, {x = right, y = top})
                else
                    local rect = QRectMake(left, bottom, right - left, top - bottom)
                    local lb, lt, rt, rb = QGetRotateRect(rect, math.pi/180*angle)
                    app.scene:displayTriangle(lb, lt, rt)
                    app.scene:displayTriangle(lb, rb, rt)
                end
            end
        end
    end

    local skill_target_id = skill:getTargetID()
    if skill_target_id ~= nil and skill_target_id ~= "" then
        local filtered_targets = {}
        for _, target in ipairs(targets) do
            if target:getActorID() == skill_target_id then
                table.insert(filtered_targets, target)
            end
        end
        targets = filtered_targets
    end

    if filter_actors then
        local filtered_targets = {}
        for _, target in ipairs(targets) do
            if filter_actors[target] then

            else
                filter_actors[target] = target
                table.insert(filtered_targets, target)
            end
        end
        targets = filtered_targets
    end

    -- AoE Immune check
    local filtered_targets = {}
    for _, target in ipairs(targets) do
        if not target:isImmuneAoE() then
            filtered_targets[#filtered_targets + 1] = target
        end
    end
    targets = filtered_targets

    area_index = area_index + 1
    if skill:getZoneType(area_index) and skill:getZoneType(area_index) ~= "" then
        local targets2 = self:getMultipleTargetWithSkill(skill, target, center, range_percent, filter_actors, area_index, getAll, traps)
        table.mergeForArray(targets,targets2)
        targets = table.unique(targets)
    end

    if traps and not trap_inited then
        for i = 2, #traps, 1 do
            local trap = traps[i]
            local targets2 = self:getMultipleTargetWithSkill(skill, target, {x = trap:getPosition().x, y = trap:getPosition().y}, range_percent, filter_actors, area_index - 1, getAll, traps)
            table.mergeForArray(targets, targets2)
            targets = table.unique(targets)
        end
    end

    skill:setMuiltipleTargets(targets)

    return targets
end

function QActor:onHit( skill, target, center, delay, range_percent, filter_actors, delay_all, damage_scale, ignoreAbsorbPercent)
    if skill == nil then
        return
    end

    if skill:isNeedATarget() == true then
        if target == nil or target:isDead() == true then
            -- 对于已经死亡的目标应该也触发地毯
            if target and target:isDead() then
                self:triggerTrap(skill, target)
            end
            return
        end
    end

    local total_damage = 0

    if skill:getRangeType() == QSkill.SINGLE then
        if skill:getTargetType() == QSkill.SELF then
            target = self
        end
        -- 单体攻击模式，直接打击目标
        if target ~= nil then
            -- 在延迟的时间内攻击对象有可能已经被打死
            local _, damage = self:hit(skill, target, nil, nil, nil, nil, nil, damage_scale, ignoreAbsorbPercent)
            total_damage = total_damage + (damage or 0)
            -- 可以额外击中一个目标
            local additional_target = skill:isAdditionalTarget()
            if additional_target then
                local teammates = app.battle:getMyTeammates(target, false)
                if #teammates > 0 then
                    if additional_target == true then
                        table.sort(teammates, function(t1, t2)
                            local d1 = q.distOf2Points(target:getPosition(), t1:getPosition())
                            local d2 = q.distOf2Points(target:getPosition(), t2:getPosition())
                            if d1 ~= d2 then
                                return d1 < d2
                            else
                                return t1:getUUID() < t2:getUUID()
                            end
                        end)
                    else -- other mean hp lowest
                        table.sort(teammates, function(t1, t2)
                            local h1 = t1:getHp() / t1:getMaxHp()
                            local h2 = t2:getHp() / t2:getMaxHp()
                            if h1 ~= h2 then
                                return h1 < h2 
                            else
                                return t1:getUUID() < t2:getUUID()
                            end
                        end)
                    end
                    local _, damage = self:hit(skill, teammates[1], nil, nil, nil, nil, nil, damage_scale, ignoreAbsorbPercent)
                    total_damage = total_damage + (damage or 0)
                end
            end
        end

        -- trap 
        self:triggerTrap(skill, target)
    else

        -- 开始属性cache,节省aoe计算量
        self._cachingProperties = {}
        -- 群体攻击模式
        local targets = self:getMultipleTargetWithSkill(skill, target, center, range_percent, filter_actors)
        -- 群体攻击伤害在PVE模式下的加速
        local aoe_damage_cache = not app.battle:isPVPMode()
        local aoe_damage_original = nil
        local aoe_damage = nil
        local aoe_damage_original_id = nil
        -- 平分伤害
        local split = skill:getDamageSplit()
        local split_number = split and #targets or 0
        local delayTime = 0
        delay = delay or 0
        if delay > 0 and #targets > 1 then
            q.shuffleArray(targets, app.random)
            if delay_all then
                delay = math.min(delay, delay_all / #targets)
            end
        end
        for _, actor in ipairs(targets) do
            if not actor:isImmuneSkill(skill) then
                if delay > 0 then
                    app.battle:performWithDelay(function()
                        if actor:isDead() == false or actor:isDoingDeadSkill() then
                            self:hit(skill, actor, split_number, nil, nil, true, nil, damage_scale, ignoreAbsorbPercent)
                        end
                    end, delayTime)
                    delayTime = delayTime + delay
                else
                    if aoe_damage_cache then
                        if aoe_damage_original_id == actor:getActorID() then
                            local _, damage = self:hit(skill, actor, split_number, nil, aoe_damage_original, true, nil, damage_scale, ignoreAbsorbPercent)
                            total_damage = total_damage + (damage or 0)
                        else
                            aoe_damage_original, aoe_damage = self:hit(skill, actor, split_number, nil, nil, true, nil, damage_scale, ignoreAbsorbPercent)
                            if aoe_damage_original ~= nil then
                                aoe_damage_original_id = actor:getActorID()
                            end
                            total_damage = total_damage + (aoe_damage or 0)
                        end
                    else
                        self:hit(skill, actor, split_number, nil, nil, true, nil, damage_scale, ignoreAbsorbPercent)
                    end
                end
            end       
        end
        -- 结束属性cache
        self._cachingProperties = nil

        if skill:getZoneType() == QSkill.ZONE_RECT or (skill:getZoneType() == QSkill.ZONE_FAN and skill:getSectorCenter() == QSkill.CENTER_SELF) then
            self:triggerTrap(skill, self)
        else
            self:triggerTrap(skill, target)
        end
    end

    if total_damage > 0 and skill:getDrainBloodPercent() > 0 then
        local percent = skill:getDrainBloodPercent()
        local for_teammate = skill:getDrainBloodForTeammate()
        local split = skill:getDrainBloodSplit()
        local total_drain_ammount = total_damage * percent
        if for_teammate then
            local teammates = app.battle:getMyTeammates(self, true)
            local each_drain_ammount = split and (total_drain_ammount / math.max(#teammates, 1)) or total_drain_ammount
            for _, teammate in ipairs(teammates) do
                local _ dHp = teammate:increaseHp(each_drain_ammount, self, skill, nil, nil, QBuff.SAVE_TREAT_FROM_DRAIN_BLOOD)
                if dHp > 0 then
                    teammate:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = true, 
                        isCritical = false, tip = "", rawTip = {
                            isHero = teammate:getType() == ACTOR_TYPES.HERO, 
                            isCritical = false, 
                            isTreat = true,
                            number = dHp,
                        }})
                end
            end
        else
            local _, dHp = self:increaseHp(total_drain_ammount, self, skill, nil, nil, QBuff.SAVE_TREAT_FROM_DRAIN_BLOOD)
            if dHp > 0 then
                self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = true, 
                    isCritical = false, tip = "", rawTip = {
                        isHero = self:getType() == ACTOR_TYPES.HERO, 
                        isCritical = false, 
                        isTreat = true,
                        number = dHp,
                    }})
            end
        end
    end
end

function QActor:triggerBuff(skill, target)
    local buffId = skill:getBuffId1()
    if buffId ~= "" and skill:isBuffConditionMet1() then
        local buffTargetType = skill:getBuffTargetType1()
        self:_doTriggerBuff(buffId, buffTargetType, target, skill)
    end

    local buffId = skill:getBuffId2()
    if buffId ~= "" and skill:isBuffConditionMet2() then
        local buffTargetType = skill:getBuffTargetType2()
        self:_doTriggerBuff(buffId, buffTargetType, target, skill)
    end

    local buffId = skill:getBuffId3()
    if buffId ~= "" and skill:isBuffConditionMet3() then
        local buffTargetType = skill:getBuffTargetType3()
        self:_doTriggerBuff(buffId, buffTargetType, target, skill)
    end
end

function QActor:_doTriggerBuff(buffId, buffTargetType, target, skill, buff)
    if buffId ~= nil and string.len(buffId) > 0 then
        if buffTargetType == QSkill.BUFF_SELF then
            return self:applyBuff(buffId, self, skill, buff)
        elseif buffTargetType == QSkill.BUFF_TARGET then
            if target then
                return target:applyBuff(buffId, self, skill, buff)
            end
        elseif buffTargetType == QSkill.BUFF_MAIN_TARGET then
            if target and target == self:getTarget() then
                return target:applyBuff(buffId, self, skill, buff)
            end
        elseif buffTargetType == QSkill.BUFF_OTHER_TARGET then
            if target and target ~= self:getTarget() then
                return target:applyBuff(buffId, self, skill, buff)
            end
        elseif buffTargetType == QSkill.BUFF_TEAMMATE_AND_SELF then
            for _, actor in ipairs(app.battle:getMyTeammates(self, true)) do
                actor:applyBuff(buffId, self, skill, buff)
            end
        elseif buffTargetType == QSkill.BUFF_ENEMY then
            for _,actor in ipairs(app.battle:getMyEnemies(self)) do
                actor:applyBuff(buffId, self, skill, buff)
            end
        elseif buffTargetType == QSkill.BUFF_TEAMMATE then
            for _,actor in ipairs(app.battle:getMyTeammates(self)) do
                actor:applyBuff(buffId, self, skill, buff)
            end
        elseif buffTargetType == QSkill.BUFF_ENEMY_TARGET then
            local targets = app.battle:getMyEnemies(self)
            if table.indexof(targets, target) then
                target:applyBuff(buffId, self, skill, buff)
            elseif #targets > 0 then
                targets[app.random(1, #targets)]:applyBuff(buffId, self, skill, buff)
            end
        end
    end
end

function QActor:triggerTrap(skill, target)
    local trapId = skill:getTrapId()
    if trapId ~= nil then
        local trapId, level = q.parseIDAndLevel(trapId)
        local trapDirector = QTrapDirector.new(trapId, target:getPosition(), self:getType(), self, level, skill)
        app.battle:addTrapDirector(trapDirector)
    end
    
end

function QActor:triggerRage(skill, target)
    local rage1 = skill:getRage1()
    if rage1 > 0 then
        local rageTargetType = skill:getRageTargetType1()
        if rageTargetType == QSkill.RAGE_SELF then
            self:changeRage(rage1)
        elseif rageTargetType == QSkill.RAGE_TARGET then
            if target then
                target:changeRage(rage1)
            end
        elseif rageTargetType == QSkill.RAGE_MAIN_TARGET then
            if  target and target == self:getTarget() then
                target:changeRage(rage1)
            end
        elseif rageTargetType == QSkill.RAGE_OTHER_TARGET then
            if target and targe ~= self:getTarget() then
                target:changeRage(rage1)
            end
        end
    end
end

function QActor:triggerPassiveSkillByEvent(event)
    self:_triggerPassiveSkillExcat(event.skill, string.lower(event.name), event.actor, 
        event.damage, event.sbThatCauseCondition, event.buff, event.trap, event.passiveSkill, true)
end

function QActor:_triggerPassiveSkillExcat(skill, condition, actor, damage, sbThatCauseCondition, buff, trap, passiveSkill)
    if skill:isReady() == true and skill:checkCondition(condition) then
        repeat
            if skill:isLockSkill() then
                if skill:getSurplusTrigger() <= 0 then
                    break
                else
                    skill:addLockNum()
                end
            end
            local status = skill:get("trigger_condition_status")
            if status then
                local cfg = string.split(status, ":")
                local target = nil
                if cfg[1] == "target" then
                    target = actor
                elseif cfg[1] == "self" then
                    target = self
                end
                if not target:isUnderStatus(cfg[2]) then
                    break;
                end
            end
            -- 检测QSkill.TRIGGER_CONDITION_HIT的条件细则
            if condition == QSkill.TRIGGER_CONDITION_HIT or condition == QSkill.TRIGGER_CONDITION_HIT_PHYSICAL or condition == QSkill.TRIGGER_CONDITION_HIT_MAGIC then
                local conditionDetail = skill:getTriggerConditionDetail()
                if conditionDetail then
                    local range = nil
                    conditionDetail = string.split(conditionDetail, ";")
                    for _, v in ipairs(conditionDetail) do
                        if #v > 5 and string.sub(v, 1, 5) == "range" then
                            range = tonumber(string.sub(v, 6, #v - 5))
                        end
                        conditionDetail[v] = v
                    end
                    local realCondition
                    if sbThatCauseCondition then
                        local skill = sbThatCauseCondition:getSkill()
                        if skill:isTalentSkill() then
                            realCondition = "normal"
                        elseif skill:getSkillType() == QSkill.ACTIVE then
                            realCondition = "active"
                        elseif skill:getSkillType() == QSkill.MANUAL then
                            realCondition = "manual"
                        end
                    elseif buff then
                        realCondition = "buff"
                    elseif trap then
                        realCondition = "trap"
                    end
                    if realCondition == nil or conditionDetail[realCondition] == nil then
                        break
                    end
                    -- 范围条件判断
                    if range then
                        range = range * global.pixel_per_unit
                        local distance = q.distOf2Points(self:getPosition(), actor:getPosition())
                        if distance > radius then
                            break
                        end
                    end
                end
            end
            -- 在一次技能周期（sbdirector的生存周期）中，同一个attackee不能导致第二次触发
            if skill:isEachTargetTriggerOnce() and actor and sbThatCauseCondition then
                if sbThatCauseCondition:getTriggerTargetHistory(skill, actor) then
                    break
                end
            end
            if condition == QSkill.TRIGGER_CONDITION_SKILL and skill:getTriggerConditionSkillID() then
                if sbThatCauseCondition == nil or sbThatCauseCondition:getSkill():getId() ~= skill:getTriggerConditionSkillID() then
                    break
                end
            end
            if condition == QSkill.TRIGGER_CONDITION_COUNT_FULL and skill:getTriggerConditionSkillID() then
                if passiveSkill == nil or passiveSkill:getId() ~= skill:getTriggerConditionSkillID() then
                    break
                end
            end
            local probability = skill:getTriggerProbability()
            if probability >= app.random(1, 100) then
                if skill:isEachTargetTriggerOnce() and actor and sbThatCauseCondition then
                    sbThatCauseCondition:setTriggerTargetHistory(skill, actor)
                end
                -- apply buff
                local failure = false
                if skill:getTriggerType() == QSkill.TRIGGER_TYPE_BUFF then
                    local buffId = skill:getTriggerBuffId()
                    if skill:isTriggerBuffOnce() then
                        local real_id = q.parseIDAndLevel(buffId, 1, skill)
                        local hasSameId = self:hasSameIDBuff(real_id)
                        if hasSameId then
                            failure = true
                        else
                            local buffTargetType = skill:getTriggerBuffTargetType()
                            self:_doTriggerBuff(buffId, buffTargetType, actor, skill)
                        end
                    else
                        local buffTargetType = skill:getTriggerBuffTargetType()
                        self:_doTriggerBuff(buffId, buffTargetType, actor, skill)
                    end
                    
                elseif skill:getTriggerType() == QSkill.TRIGGER_TYPE_ATTACK then
                    if sbThatCauseCondition and sbThatCauseCondition._triggeredBySkill == skill then
                        failure = true
                    else
                        local skillId, level = skill:getTriggerSkillId()
                        if level == "y" then level = skill:getSkillLevel() end
                        local triggerSkill = self._skills[skillId]
                        if triggerSkill == nil then
                            triggerSkill = QSkill.new(skillId, {}, self, level)
                            triggerSkill:setIsTriggeredSkill(true)
                            self._skills[skillId] = triggerSkill
                        end
                        local inherit_percent = skill:getTriggerSkillInheritPercent()
                        local isTriggerAttack = true
                        if inherit_percent > 0 then
                            if damage > 0 then
                                triggerSkill:setInheritedDamage(damage * inherit_percent)
                            else
                                isTriggerAttack = false
                            end
                        end
                        local sbDirector = nil
                        if isTriggerAttack then
                            if triggerSkill:isReadyAndConditionMet() then
                                if (condition == QSkill.TRIGGER_CONDITION_HIT or condition == QSkill.TRIGGER_CONDITION_HIT_PHYSICAL or condition == QSkill.TRIGGER_CONDITION_HIT_MAGIC) and triggerSkill:isNeedATarget() then
                                    sbDirector = self:triggerAttack(triggerSkill, actor, skill:isTriggerSkillImmediately(), skill, nil)
                                    if sbDirector then
                                        sbDirector._target = actor
                                    end
                                else
                                    sbDirector = self:triggerAttack(triggerSkill, actor, skill:isTriggerSkillImmediately(), skill, nil)
                                end
                            end
                        end
                        if sbDirector == nil then
                            failure = true
                        end
                    end
                elseif skill:getTriggerType() == QSkill.TRIGGER_TYPE_COMBO then
                    local combo_points = skill:getTriggerComboPoints()
                    self:gainComboPoints(combo_points)
                elseif skill:getTriggerType() == QSkill.TRIGGER_TYPE_CD_REDUCE then
                    local manual_skills = self:getManualSkills()
                    local id = next(manual_skills)
                    if id then
                        manual_skills[id]:reduceCoolDownTime(QActor.ARENA_BEATTACKED_CD_REDUCE)
                    end
                elseif skill:getTriggerType() == QSkill.TRIGGER_TYPE_RAGE then
                    self:changeRage(skill:getTriggerRage())
                elseif skill:getTriggerType() == QSkill.TRIGGER_TYPE_DEPRESS_RECOVER_HP then
                    if actor and damage then
                        --有些技能会造成伤害 其实伤害来源并不是自己所以不能计算伤势
                        if sbThatCauseCondition and sbThatCauseCondition._skill and sbThatCauseCondition._skill:getDamager() and sbThatCauseCondition._skill:getDamager() ~= self then
                            failure = true
                        else
                            local inherit_percent = skill:getTriggerSkillInheritPercent()
                            local limit = skill:getDepressRecoverHpLimit() * actor:getMaxHp()
                            actor:setRecoverHpLimit(inherit_percent * damage, limit)
                        end
                    end
                    -- local decHpValue = actor:getRecoverHpLimit() - (actor:getMaxHp() - actor:getHp())
                    -- if decHpValue > 0 then
                    --     actor:decreaseHp(decHpValue, self, skill, nil, false, true)
                    -- end
                elseif skill:getTriggerType() == QSkill.TRIGGER_TYPE_COUNT_DAMAGE then
                    local result, attackee, count_damage = skill:countDamage(actor, damage)
                    if result then
                        self:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_COUNT_FULL, attackee, count_damage, nil, nil, nil, skill)
                    else
                        failure = true
                    end 
                end
                if not failure then
                    skill:coolDown()
                    self:dispatchEvent({name = QActor.TRIGGER_PASSIVE_SKILL, sprite_frame = skill:getTriggerSpriteFrame(), skill = skill})
                    if not IsServerSide then
                        if skill:getMountId() and not skill:showMountIconWithBattleStart() then
                            app.scene:playMountSkillAnimation(self, skill)
                        end
                        if skill:isGodSkill() then
                            app.scene:playGodSkillAnimation(self, skill)
                        end
                    end
                end
            end
        until true
    end
end

--我是攻击者，actor为攻击目标
--我是攻击目标，actor为攻击者
function QActor:triggerPassiveSkill(condition, actor, damage, sbThatCauseCondition, buff, trap, passiveSkill)
    if condition == nil or actor == nil then
        return
    end

    for _, skill in pairs(self._passiveSkills) do
        self:_triggerPassiveSkillExcat(skill, condition, actor, damage, sbThatCauseCondition, buff, trap, passiveSkill)
    end
end

--[[
    @param attackee, is attackee
    @return a function to revoke property modifier and return trigger tip modifiers
]]
function QActor:triggerPassiveSkillAsPropertyModifier(condition, attackee, attackSkill)
    local revokeCallbacks = {}
    local tip_modifiers = {}
    for _, skill in pairs(self._passiveSkills) do
        if skill:getTriggerType() == QSkill.TRIGGER_TYPE_PROPERTY_MODIFIER and skill:isReady() == true then
            local condition_met = true
            local isConditionTargetHpSegmentStatus = skill:getTriggerCondition() == QSkill.TRIGGER_CONDITION_TARGET_HP_SEGMENT_STATUS
            local isConditionHpSegmentStatus = skill:getTriggerCondition() == QSkill.TRIGGER_CONDITION_HP_SEGMENT_STATUS
            if isConditionTargetHpSegmentStatus or isConditionHpSegmentStatus then
                condition_met = false
                local segments = skill:getHPSegment()
                for index, segment in ipairs(segments) do
                    local hpMax = (isConditionTargetHpSegmentStatus and attackee or self):getMaxHp()
                    local hpPercentAfter = (isConditionTargetHpSegmentStatus and attackee or self):getHp() / hpMax
                    if hpPercentAfter <= segment then
                        condition_met = true
                        break
                    end
                end
            elseif skill:getTriggerCondition() == QSkill.TRIGGER_CONDITION_MANUAL_SKILL and condition ~= QSkill.TRIGGER_CONDITION_MANUAL_SKILL then
                condition_met = false
            end
            if skill:getTriggerCondition() == QSkill.TRIGGER_CONDITION_PHYSICAL_SKILL and attackSkill:getDamageType() ~= QSkill.PHYSICAL then
                condition_met = false
            elseif skill:getTriggerCondition() == QSkill.TRIGGER_CONDITION_MAGIC_SKILL and attackSkill:getDamageType() ~= QSkill.MAGIC then
                condition_met = false
            end
            local status = skill:get("trigger_condition_status")
            local status_count
            if status then
                local cfg = string.split(status, ":")
                local actor = nil
                if cfg[1] == "target" then
                    actor = attackee
                elseif cfg[1] == "self" then
                    actor = self
                end
                if actor then
                    condition_met, status_count = actor:isUnderStatus(cfg[2], true)
                else
                    condition_met = false
                end
            end
            local probability = skill:getTriggerProbability()
            if condition_met and probability >= app.random(1, 100) then
                -- modifier poperties
                -- example: "attackee;armor_physical,&,0;armor_magic,&,0", that's to say to reduce attacee's armor to zero
                local propertyModifier = skill:getTriggerPropertyModifier()
                local words = string.split(propertyModifier, ";")
                local actor = nil
                if words[1] == "attacker" then
                    actor = self
                elseif words[1] == "attackee" then
                    actor = attackee
                end
                if actor then
                    for i = 2, #words do
                        local properties = string.split(words[i], ",")
                        local revokeFunction = nil
                        -- use revokeFunction as a unique property stub
                        revokeFunction = function()
                            actor:removePropertyValue(properties[1], revokeFunction)
                        end
                        local value = tonumber(properties[3])
                        if value == nil and properties[3] and status_count then
                            local values = string.split(properties[3], ":")
                            value = tonumber(values[status_count])
                        end
                        if value then
                            actor:insertPropertyValue(properties[1], revokeFunction, properties[2], value)
                            revokeCallbacks[#revokeCallbacks + 1] = revokeFunction
                        end
                    end
                end
                -- add tip modifier
                tip_modifiers[#tip_modifiers + 1] = skill:getTriggerTipModifier()
                -- passive skill cool down
                skill:coolDown()
                self:dispatchEvent({name = QActor.TRIGGER_PASSIVE_SKILL, sprite_frame = skill:getTriggerSpriteFrame(), skill = skill})
                if not IsServerSide then
                    if skill:getMountId() and not skill:showMountIconWithBattleStart() then
                        app.scene:playMountSkillAnimation(self, skill)
                    end
                    if skill:isGodSkill() then
                        app.scene:playGodSkillAnimation(self, skill)
                    end
                end
            end
        end
    end

    return function()
        for _, cb in ipairs(revokeCallbacks) do
            cb()
        end
        revokeCallbacks = nil
    end, tip_modifiers
end

--[[
    @return damage modifier
]]
function QActor:triggerPassiveSkillAsDamageModifier(condition, attackee)
    local damageModifier = 1
    local tip_modifiers = {}
    for _, skill in pairs(self._passiveSkills) do
        if skill:getTriggerType() == QSkill.TRIGGER_TYPE_DAMAGE_MODIFIER and skill:isReadyAndConditionMet(nil, attackee) == true then
            local condition_met = true
            local isConditionTargetHpSegmentStatus = skill:getTriggerCondition() == QSkill.TRIGGER_CONDITION_TARGET_HP_SEGMENT_STATUS
            local isConditionHpSegmentStatus = skill:getTriggerCondition() == QSkill.TRIGGER_CONDITION_HP_SEGMENT_STATUS
            if isConditionTargetHpSegmentStatus or isConditionHpSegmentStatus then
                condition_met = false
                local segments = skill:getHPSegment()
                for index, segment in ipairs(segments) do
                    local hpMax = (isConditionTargetHpSegmentStatus and attackee or self):getMaxHp()
                    local hpPercentAfter = (isConditionTargetHpSegmentStatus and attackee or self):getHp() / hpMax
                    if hpPercentAfter <= segment then
                        condition_met = true
                        break
                    end
                end
            elseif skill:getTriggerCondition() == QSkill.TRIGGER_CONDITION_MANUAL_SKILL and condition ~= QSkill.TRIGGER_CONDITION_MANUAL_SKILL then
                condition_met = false
            end
            local probability = skill:getTriggerProbability()
            if condition_met and probability >= app.random(1, 100) then
                damageModifier = damageModifier * skill:getTriggerDamageModifier()
                -- add tip modifier
                tip_modifiers[#tip_modifiers + 1] = skill:getTriggerTipModifier()
                -- passive skill cool down
                skill:coolDown()
                self:dispatchEvent({name = QActor.TRIGGER_PASSIVE_SKILL, sprite_frame = skill:getTriggerSpriteFrame(), skill = skill})
                if not IsServerSide then
                    if skill:getMountId() and not skill:showMountIconWithBattleStart() then
                        app.scene:playMountSkillAnimation(self, skill)
                    end
                    if skill:isGodSkill() then
                        app.scene:playGodSkillAnimation(self, skill)
                    end
                end
            end
        end
    end
    return damageModifier, tip_modifiers
end

-- actor is attacker if isHit equal to true
-- actor is target if isHit equal to false
function QActor:triggerAlreadyAppliedBuff(condition, actor, trigger_target, damage, sbThatCauseCondition)
    if condition == nil or actor == nil then
        return
    end

    for _, buff in ipairs(self._buffs) do
        if buff:checkCondition(condition) then
            -- trigger target check
            local trigger_target_check = false
            local buff_trigger_target = buff:getTriggerTarget()
            if buff_trigger_target ~= QBuff.TRIGGER_TARGET_TEAMMATE_AND_SELF then
                trigger_target_check = buff_trigger_target == trigger_target
            else
                trigger_target_check = buff_trigger_target == QBuff.TRIGGER_TARGET_TEAMMATE or buff_trigger_target == QBuff.TRIGGER_TARGET_SELF
            end

            if trigger_target_check and buff:isReady() and buff:isImmuned() == false then
                self:_triggerAlreadyAppliedBuff(buff, condition, actor, damage, sbThatCauseCondition)
            end
        end
    end
end

function QActor:_triggerAlreadyAppliedBuff(buff, condition, actor, damage, sbThatCauseCondition)
    local probability = buff:getTriggerProbability()
    if probability >= app.random(1, 100) and not buff:triggeredMaxCount() then
        if buff:triggerPeriodCountdown() then
            buff:addTriggerCount()
            local ok = true
            -- apply buff
            local triggerType = buff:getTriggerType()
            if triggerType == QBuff.TRIGGER_TYPE_BUFF then
                local buffId = buff:getTriggerBuffId()
                local buffTargetType = buff:getTriggerBuffTargetType()
                self:_doTriggerBuff(buffId, buffTargetType, actor, buff:getSkill(), buff)
                
            elseif triggerType == QBuff.TRIGGER_TYPE_ATTACK then
                if sbThatCauseCondition and sbThatCauseCondition._triggeredByBuff == buff then
                    ok = false
                else
                    local skillId, level = buff:getTriggerSkillId()
                    if level == "y" then level = buff:getSkill():getSkillLevel() end
                    local triggerSkill = self._skills[skillId]
                    if triggerSkill == nil then
                        triggerSkill = QSkill.new(skillId, {}, self, level)
                        triggerSkill:setIsTriggeredSkill(true)
                        triggerSkill:setEnhanceValue(buff:getEnhanceValue())
                        self._skills[skillId] = triggerSkill
                    end
                    if buff:isTriggerSkillUseBuffAttackerProp() then
                        triggerSkill:setDamager(buff:getAttacker())
                    end
                    if triggerSkill:isReadyAndConditionMet() then
                        local inherit_percent = buff:getTriggerSkillInheritPercent()
                        local isTriggerAttack = true
                        if inherit_percent > 0 then
                            if damage > 0 then
                                triggerSkill:setInheritedDamage(damage * inherit_percent)
                            else
                                isTriggerAttack = false
                            end
                        end

                        if isTriggerAttack == true then
                            if (condition == QBuff.TRIGGER_CONDITION_HIT or 
                                condition == QBuff.TRIGGER_CONDITION_HIT_PHYSICAL or 
                                condition == QBuff.TRIGGER_CONDITION_HIT_MAGIC or 
                                condition == QBuff.TRIGGER_CONDITION_NORMAL_SKILL_HIT or 
                                condition == QBuff.TRIGGER_CONDITION_IMMUNE_MAGIC_DAMAGE or 
                                condition == QBuff.TRIGGER_CONDITION_IMMUNE_PHYSICAL_DAMAGE)and triggerSkill:isNeedATarget() then
                                local sbDirector = nil
                                if buff:getTriggerSkillAsCurrent() then
                                    sbDirector = self:attack(triggerSkill, false, actor, buff:triggerImmediately())
                                else
                                    sbDirector = self:triggerAttack(triggerSkill, actor, buff:triggerImmediately(), nil, buff)
                                end
                                if sbDirector then
                                    sbDirector._target = actor
                                end
                            else
                                local sbDirector = nil
                                if buff:getTriggerSkillAsCurrent() then
                                    sbDirector = self:attack(triggerSkill, nil, nil, buff:triggerImmediately())
                                else
                                    sbDirector = self:triggerAttack(triggerSkill, nil, buff:triggerImmediately(), nil, buff)
                                end
                            end
                        end
                    end
                end
            elseif triggerType == QBuff.TRIGGER_TYPE_COMBO then
                local combo_points = buff:getTriggerComboPoints()
                self:gainComboPoints(combo_points)
            elseif triggerType == QBuff.TRIGGER_TYPE_CD_REDUCE then
                local manual_skills = self:getManualSkills()
                manual_skills[next(manual_skills)]:reduceCoolDownTime(QActor.ARENA_BEATTACKED_CD_REDUCE)
            elseif triggerType == QBuff.TRIGGER_TYPE_RAGE then
                self:changeRage(buff:getTriggerRage())
            elseif triggerType == QBuff.TRIGGER_TYPE_ADDITION_TIME then
                local addition_time, max_time = buff:getAdditionTimeConfig()
                local id_list = string.split(buff:getTriggerBuffId(), ";")
                local id_cache = {}
                local target = self
                local targetType = buff:getTriggerBuffTargetType()
                if targetType == QBuff.BUFF_TARGET then
                    target = self:getTarget()
                end
                for k,v in ipairs(id_list) do
                    id_cache[v] = true
                end
                if target then
                    for k,v in ipairs(target._buffs) do
                        if id_cache[v:getId()] then
                            local cur_duration = v:getDuration()
                            local new_duration = math.clamp(cur_duration + addition_time,0, max_time)
                            v:set("duration", new_duration)
                        end
                    end
                end
            elseif triggerType == QBuff.TRIGGER_TYPE_CHANGE_TRIGGER_CD then
                local id_list = string.split(buff:getTriggerBuffId(), ";")
                local id_cache = {}
                local target = self
                local targetType = buff:getTriggerBuffTargetType()
                if targetType == QBuff.BUFF_TARGET then
                    target = self:getTarget()
                end
                for k,v in ipairs(id_list) do
                    id_cache[v] = true
                end
                if target then
                    for k,v in ipairs(target._buffs) do
                        if id_cache[v:getId()] then
                            v:changeTriggerCD(buff)
                        end
                    end
                end
            end            
            if triggerType == QBuff.TRIGGER_TYPE_DAMAGE or triggerType == QBuff.TRIGGER_TYPE_DAMAGE_HEAL then
                buff:triggerDamage(actor)
            end
            if triggerType == QBuff.TRIGGER_TYPE_HEAL or triggerType == QBuff.TRIGGER_TYPE_DAMAGE_HEAL then
                buff:triggerHeal(self)
            end

            if ok then
                buff:coolDown()
            end
        end
    end
end

function QActor:isIdle()
    return self.fsm__:isState("idle")
end

function QActor:isAttacking()
    return (self._currentSkill ~= nil)
end

function QActor:isWalking()
    return self.fsm__:isState("walking")
end

function QActor:setManualMode(mode)
    self._manual = mode
end

function QActor:getManualMode()
    return self._manual
end

function QActor:isManualMode()
    return self._manual ~= QActor.AUTO
end

-- 获取上次被谁攻击了
function QActor:getLastAttacker()
    return self._lastAttacker
end

-- 获取上次攻击过的对象
function QActor:getLastAttackee()
    return self._lastAttackee
end

-- 获取被复活的次数
function QActor:getReviveCount()
    if self._revive_count == nil then
        self._revive_count = 0
    end

    return self._revive_count
end

-- 清除上次攻击过的对象，一般用于角色的ai在战斗中被替换时
function QActor:clearLastAttackee()
    self._lastAttackee = nil
end

function QActor:clearLastAttacker()
    self._lastAttacker = nil
end

function calcDamageWithOriginalDamage(attacker, skill, attackee, original_damage, isAOE)
    if attacker == nil or attackee == nil or skill == nil then
        return 0, ""
    end

    local skillAttackType = skill:getAttackType()
    local skillHitType = skill:getHitType()

    local dragonModifier = skill:getDragonModifier()

    -- 检查是否有level check dice
    local lcd_dodge, lcd_block = nil, nil, nil
    if skillAttackType == QSkill.ATTACK and skillHitType == QSkill.HIT then
        local lcd = skill:getLevelCheckDice()
        if lcd > 0 then
            local skill_lvl = math.max(skill:getLevel(), 10)
            local target_lvl = attackee:getLevel()
            local is_hit = skill_lvl + math.floor(app.random() * (Level_check_dice + 1)) >= target_lvl
            if is_hit then
                lcd_dodge, lcd_block = 0, 0
            else
                lcd_dodge, lcd_block = math.max((target_lvl - skill_lvl) * 5, 70), 0
            end
        end
    end

    local p = app.random() * 100 -- app.random result a real number in [0, 1)

    local blocked = false

    -- 圆桌定律计算
    if skillAttackType == QSkill.ATTACK then
        if skillHitType == QSkill.HIT then
            local dodge = lcd_dodge and lcd_dodge or calcFinalDodge(attacker, attackee)
            if (p > 0 and p < dodge) then
                -- 被闪避
                return 0, "闪避", nil, "dodge"
            end
        
            p = p - math.max(0, dodge)
        
            local deflection = attackee:getDeflection() - attacker:getPrecise()
            if (p > 0 and p < deflection) then
                -- 被偏转
                return 0, "闪避", nil, "dodge"
            end

            p = p - math.max(0, deflection)

            local block = lcd_block and lcd_block or calcFinalBlock(attacker, attackee)
            if (p > 0 and p < block) then
                -- 被格挡
                blocked = true
            end
        
            p = p - math.max(0, block)

        elseif skillHitType == QSkill.STRIKE or skillHitType == QSkill.CRITICAL then
            -- STRIKE与CRITICAL必命中
            local dodge = calcFinalDodge(attacker, attackee)
            p = p - math.max(0, dodge)
            
            local deflection = attackee:getDeflection() - attacker:getPrecise()
            if (p > 0 and p < deflection) then
                -- 被偏转
                return 0, "闪避", nil, "dodge"
            end
            p = p - math.max(0, deflection)

            local block = calcFinalBlock(attacker, attackee)
            p = p - math.max(0, block)

        end
    elseif skillAttackType == QSkill.ASSIST then
        return 0, ""
    elseif skillAttackType == QSkill.TREAT then
        
    else
        assert(false, "calcDamage: unknown attack type: " .. skillAttackType)
    end

    local damage = original_damage

    -- 最终伤害 和 伤害浮动
    local randomValue = app.random()
    damage = damage * (0.8 + randomValue * 0.4)

    -- 格挡 和 暴击
    local tip = ""
    local critical = false
    if blocked then
        damage = damage * 0.5
        tip = "格挡 "
    else
        local finalCrit = calcFinalCrit(attacker, attackee)
        if skillHitType == QSkill.CRITICAL or (p > 0 and p < finalCrit) then
            -- 暴击
            local attackerCritDamage = attacker:getCritDamage(attackee)
            damage = damage * attackerCritDamage
            tip = damage > 0 and "暴击 " or ""
            critical = true
        end
    end

    -- 羁绊技能伤害增幅
    local multiplier = attacker._additionalManualSkillDamageMultiplier
    if multiplier ~= 1 then
        if skill:getSkillType() == skill.MANUAL then
            damage = damage * multiplier
        end
    end

    -- pvp伤害属性系数
    if app.battle:isPVPMode() then
        if skillAttackType == QSkill.ATTACK then
            if skillDamageType == QSkill.PHYSICAL then
                damage = damage * math.max(1 + attacker:getPVPPhysicalAttackPercent() - attackee:getPVPPhysicalReducePercent(), 0)
            elseif skillDamageType == QSkill.MAGIC then
                damage = damage * math.max(1 + attacker:getPVPMagicAttackPercent() - attackee:getPVPMagicReducePercent(), 0)
            end
        end
    end
    
    if attacker:isSoulSpirit() and skillAttackType == QSkill.ATTACK then
        local soulDamagePercentAttack = attacker:getSoulDamagePercentAttack()
        local soulDamagePercentBeattackReduce = attackee:getSoulDamagePercentBeattackReduce()
        local finalSoulDamagePercent = soulDamagePercentAttack - soulDamagePercentBeattackReduce
        finalSoulDamagePercent = math.max(1 + finalSoulDamagePercent, 0.1)
        damage = damage * finalSoulDamagePercent
    end

    -- aoe伤害系数
    if isAOE then
        if skillAttackType == QSkill.ATTACK then
            damage = damage * (1 + attacker:getAOEAttackPercent())
        end
    end

    if skillAttackType == QSkill.TREAT then
        -- 治疗的文字显示: 前面附加一个加号"+"
        tip = tip .. "+"
    end

    local damageThreshold = skill:getDamageThreshold()
    if damageThreshold then
        damage = math.min(damageThreshold * attackee:getMaxHp(), damage)
    end

    if skillAttackType == QSkill.ATTACK then
        damage = damage * dragonModifier
    end
    damage = math.ceil(damage)

    return damage, tip, critical, blocked and "block" or "hit"
end

function calcDamage(attacker, skill, attackee, split_number, isAOE)
    if attacker == nil or attackee == nil or skill == nil then
        return 0, ""
    end
    
    -- 斩杀线
    if not attackee:isBoss() then
        local execute_percent = skill:getExecutePercent()
        if execute_percent and execute_percent > 0 then
            local current_percent = attackee:getHp() / attackee:getMaxHp()
            if current_percent <= execute_percent then
                return attackee:getHp(), "-", false, "hit", attackee:getHp(), true, true, true
            end
        end
    end

    local ignore_absorb = skill:ignoreAbsorb() or attacker:isUnderStatus("ignore_absorb")

    local skillAttackType = skill:getAttackType()
    local skillHitType = skill:getHitType()

    local forceNormalDamage = skill:getForceNormalDamage()
    local actorPercentDamage = 0

    local dragonModifier = skill:getDragonModifier()

    local p0 = app.random() * 100
    local deflection = attackee:getDeflection() - attacker:getPrecise()

    local damageTargetPercent = skill:getDamageTargetPercent()
    if damageTargetPercent then
        local damageTargetPercentCondtion = skill:getDamageTargetPercentCondition()
        if damageTargetPercentCondtion == "all"
            or (damageTargetPercentCondtion == "pve" and not app.battle:isPVPMode())
            or (damageTargetPercentCondtion == "pvp" and app.battle:isPVPMode())
        then
            actorPercentDamage = attackee:getMaxHp() * damageTargetPercent
            if not forceNormalDamage then
                if skillAttackType == QSkill.ATTACK then
                    actorPercentDamage = actorPercentDamage * dragonModifier
                    if (p0 > 0 and p0 < deflection) then
                        return 0, "闪避", nil, "dodge"
                    else
                        return actorPercentDamage, "-", false, "hit", actorPercentDamage, ignore_absorb
                    end
                elseif skillAttackType == QSkill.TREAT then
                    return actorPercentDamage, "+", false, "hit", actorPercentDamage, ignore_absorb
                else
                    return 0, ""
                end
            end
        end
    end

    local damageSelfPercent = skill:getDamageSelfPercent()
    if damageSelfPercent then
        actorPercentDamage = attacker:getMaxHp() * damageSelfPercent
        if not forceNormalDamage then
            if skillAttackType == QSkill.ATTACK then
                actorPercentDamage = actorPercentDamage * dragonModifier
                if (p0 > 0 and p0 < deflection) then
                    return 0, "闪避", nil, "dodge"
                else
                    return actorPercentDamage, "-", false, "hit", actorPercentDamage, ignore_absorb
                end
            elseif skillAttackType == QSkill.TREAT then
                return actorPercentDamage, "+", false, "hit", actorPercentDamage, ignore_absorb
            else
                return 0, ""
            end
        end
    end

    -- 检查是否有level check dice
    local lcd_dodge, lcd_block = nil, nil, nil
    if skillAttackType == QSkill.ATTACK and skillHitType == QSkill.HIT then
        local lcd = skill:getLevelCheckDice()
        if lcd > 0 then
            local skill_lvl = math.max(skill:getSkillLevel(), 10)
            local target_lvl = attackee:getLevel()
            local is_hit = skill_lvl + math.floor(app.random() * (lcd + 1)) >= target_lvl
            if is_hit then
                lcd_dodge, lcd_block = 0, 0
            else
                lcd_dodge, lcd_block = math.min((target_lvl - skill_lvl) * 5, 70), 0
            end
        end
    end

    local p = app.random() * 100 -- app.random result a real number in [0, 1)

    local blocked = false

    -- 圆桌定律计算
    if skillAttackType == QSkill.ATTACK then
        if skillHitType == QSkill.HIT then
            local dodge = lcd_dodge and lcd_dodge or calcFinalDodge(attacker, attackee)

            if (p > 0 and p < dodge) then
                -- 被闪避
                return 0, "闪避", nil, "dodge"
            end
        
            p = p - math.max(0, dodge)
            
            if (p > 0 and p < deflection) then
                -- 被偏转
                return 0, "闪避", nil, "dodge"
            end

            p = p - math.max(0, deflection)

            local block = lcd_block and lcd_block or calcFinalBlock(attacker, attackee)
            if (p > 0 and p < block) then
                -- 被格挡
                blocked = true
            end
        
            p = p - math.max(0, block)

        elseif skillHitType == QSkill.STRIKE or skillHitType == QSkill.CRITICAL then
            -- STRIKE与CRITICAL必命中
            local dodge = calcFinalDodge(attacker, attackee)
            
            p = p - math.max(0, dodge)

            if (p > 0 and p < deflection) then
                -- 被偏转
                return 0, "闪避", nil, "dodge"
            end
            p = p - math.max(0, deflection)

            local block = calcFinalBlock(attacker, attackee)
            p = p - math.max(0, block)

        end
    elseif skillAttackType == QSkill.ASSIST then
        return 0, ""
    elseif skillAttackType == QSkill.TREAT then
        
    else
        assert(false, "calcDamage: unknown attack type: " .. skill:getAttackType())
    end

    -- 攻击方的伤害
    local physicalDamage = 0
    local magicDamage = 0

    local attack = attacker:getAttack()
    local skillDamageType = skill:getDamageType()

    if skillDamageType == QSkill.PHYSICAL then
        local attackeePhysicalArmor = attackee:getPhysicalArmor() * (1 - attacker:getIgnorePhysicalArmorPercentFinal(attackee))
        local attackerPhysicalPenetration = attacker:getPhysicalPenetration()
        attackeePhysicalArmor = math.max(0, attackeePhysicalArmor - attackerPhysicalPenetration)
        physicalDamage = attack * attack / (attack + attackeePhysicalArmor)

    elseif skillDamageType == QSkill.MAGIC then
        if skillAttackType == QSkill.TREAT then
            magicDamage = attack
        else
            local attackeeMagicArmor = attackee:getMagicArmor() * (1 - attacker:getIgnoreMagicArmorPercentFinal(attackee))
            local attackerMagicPenetration = attacker:getMagicPenetration()
            attackeeMagicArmor = math.max(0, attackeeMagicArmor - attackerMagicPenetration)
            magicDamage = attack * attack / (attack + attackeeMagicArmor)
        end

    else
        assert(false, "skill: " .. tostring(skill:getId()) .. "[" .. skill:getName() .. "] has unknown damage type: " .. skillDamageType)
    end

    -- 技能的伤害
    local isBonusDamage, bonusLevel = skill:isBonusDamageConditionMet(attackee)
    local skillDamagePercent = skill:getDamagePercent()
    local skillPhysicalDamage = skill:getPhysicalDamage()
    local skillMagicDamage = skill:getMagicDamage()
    local skillBonusDamagePercent = skill:getBonusDamagePercent(bonusLevel)
    local skillBonusPhysicalDamage = skill:getBonusPhysicalDamage(bonusLevel)
    local skillBonusMagicDamage = skill:getBonusMagicDamage(bonusLevel)

    local skill_damage_percent = (isBonusDamage and skillBonusDamagePercent) or skillDamagePercent
    local skill_phsical_damage = (isBonusDamage and skillBonusPhysicalDamage) or skillPhysicalDamage
    local skill_magic_damage = (isBonusDamage and skillBonusMagicDamage) or skillMagicDamage

    if isBonusDamage and skill:isBonusConsumeStatus() then
        attackee:removeBuffByStatus(skill:getBonusConsumeStatus())
    end

    -- 攻击方的伤害加成
    local physicalDamagePercent = attacker:getPhysicalDamagePercentAttack()
    local magicDamagePercent = attacker:getMagicDamagePercentAttack()
    local magicTreatPercent = attacker:getMagicTreatPercentAttack()

    -- 被攻击方的伤害加成
    local physicalDamagePercentUnderAttack = attackee:getPhysicalDamagePercentUnderAttack()
    local magicDamagePercentUnderAttack = attackee:getMagicDamagePercentUnderAttack()
    local magicTreatPercentUnderAttack = attackee:getMagicTreatPercentUnderAttack()

    -- 攻击方的物理伤害
    physicalDamage = (physicalDamage * (1 + skill_damage_percent) + skill_phsical_damage)

    -- 攻击方的法术伤害
    if skillAttackType == QSkill.TREAT then
        -- 攻击转换为治疗效果时 x2，效果更明显
        local coefficient = 1
        local globalConfig = db:getConfiguration()
        if globalConfig.TREAT_DAMAGE_COEFFICIENT ~= nil and globalConfig.TREAT_DAMAGE_COEFFICIENT.value ~= nil then
            coefficient = globalConfig.TREAT_DAMAGE_COEFFICIENT.value 
        end
        magicDamage = (magicDamage * (1 + skill_damage_percent) + skill_magic_damage) * coefficient
    else
        magicDamage = (magicDamage * (1 + skill_damage_percent) + skill_magic_damage)
    end

    -- 检查是否有inherit damage覆盖计算，对不起上面辛辛苦苦的代码了
    local inheritDamage = skill:getInHeritedDamage()
    if inheritDamage then
        if skillDamageType == QSkill.PHYSICAL then
            physicalDamage = inheritDamage
        elseif skillDamageType == QSkill.MAGIC then
            magicDamage = inheritDamage
        end
        if inheritDamage > 0 and skill:inheritDamageIgnoreCoefficient() then
            if skillAttackType == QSkill.ATTACK then
                inheritDamage = inheritDamage * dragonModifier
            end
            return inheritDamage, "-", false, "hit", inheritDamage, ignore_absorb
        end
    end

    -- 平分计算
    if split_number and split_number > 0 then
        physicalDamage = physicalDamage / split_number
        magicDamage = magicDamage / split_number
    end

    local real_physical_percent = physicalDamagePercent + physicalDamagePercentUnderAttack 
    local real_magic_percent = magicDamagePercent + magicDamagePercentUnderAttack
    real_physical_percent = real_physical_percent < -0.8 and -0.8 or real_physical_percent
    real_magic_percent = real_magic_percent< -0.8 and -0.8 or real_magic_percent

    -- 最终物理伤害
    physicalDamage = physicalDamage * (1 + real_physical_percent)

    -- 最终法术伤害
    if skillAttackType == QSkill.TREAT then
        magicDamage = magicDamage * math.max((1 + magicTreatPercent + magicTreatPercentUnderAttack), 0)
        physicalDamage = physicalDamage * math.max((1 + magicTreatPercent + magicTreatPercentUnderAttack), 0)
    else
        magicDamage = magicDamage * (1 + real_magic_percent)
    end

    -- 开始计算最终伤害
    local damage = physicalDamage + magicDamage

    -- 受到连击点数影响
    local skillIsNeedComboPoints = skill:isNeedComboPoints()

    if skillIsNeedComboPoints then
        local combo_points_coefficient = attacker:getComboPointsCoefficient()
        damage = damage * combo_points_coefficient
    end

    -- PVP系数影响
    local isPVPMode = app.battle:isPVPMode()

    if isPVPMode then
        local isInArena = app.battle:isInArena() and not app.battle:isPVPMultipleWaveNew() and not app.battle:isSotoTeam()
        local isInSunwell = app.battle:isInSunwell()
        local isInSilverMine = app.battle:isInSilverMine()
        local isPVPMultipleWaveNew = app.battle:isPVPMultipleWaveNew()
        local isSotoTeam = app.battle:isSotoTeam()
        local isTotemChallenge = app.battle:isInTotemChallenge()
        local isInMetalAbyss = app.battle:isInMetalAbyss() 
        if isInArena then
            if skill:getAttackType() == QSkill.TREAT then
                damage = damage * QActor.ARENA_TREAT_COEFFICIENT
            else
                damage = damage * QActor.ARENA_FINAL_DAMAGE_COEFFICIENT
            end

        elseif isInSunwell then
            if skill:getAttackType() == QSkill.TREAT then
                damage = damage * QActor.SUNWELL_TREAT_COEFFICIENT
            else
                damage = damage * QActor.SUNWELL_FINAL_DAMAGE_COEFFICIENT
            end

        elseif isInSilverMine then
            if skill:getAttackType() == QSkill.TREAT then
                damage = damage * QActor.SILVERMINE_TREAT_COEFFICIENT
            else
                damage = damage * QActor.SILVERMINE_FINAL_DAMAGE_COEFFICIENT
            end
        elseif isInMetalAbyss then

            if skill:getAttackType() == QSkill.TREAT then
                damage = damage * QActor.ABYSS_TREAT_COEFFICIENT
            else
                damage = damage * QActor.ABYSS_FINAL_DAMAGE_COEFFICIENT
            end

        elseif isPVPMultipleWaveNew then

            if skill:getAttackType() == QSkill.TREAT then
                damage = damage * QActor.STORM_ARENA_TREAT_COEFFICIENT
            else
                damage = damage * QActor.STORM_ARENA_FINAL_DAMAGE_COEFFICIENT
            end
        elseif isSotoTeam then
            if skill:getAttackType() == QSkill.TREAT then
                local cofe = QActor.SOTO_TEAM_TREAT_COEFFICIENT
                if app.battle:isSotoTeamEquilibrium() then cofe = QActor.SOTO_TEAM_EQUILIBRIUM_TREAT_COEFFICIENT end
                damage = damage * cofe
            else
                damage = damage * QActor.SOTO_TEAM_FINAL_DAMAGE_COEFFICIENT
            end
        elseif isTotemChallenge then
            if skill:getAttackType() == QSkill.TREAT then
                local cofe = QActor.TOTEM_CHALLENGE_TREAT_COEFFICIENT 
                if app.battle:isSotoTeamEquilibrium() then cofe = QActor.TOTEM_CHALLENGE_EQUILIBRIUM_TREAT_COEFFICIENT end
                damage = damage * cofe
            else
                damage = damage * QActor.TOTEM_CHALLENGE_FINAL_DAMAGE_COEFFICIENT
            end
        else
            if skill:getAttackType() == QSkill.TREAT then
                damage = damage * QActor.ARENA_TREAT_COEFFICIENT
            else
                damage = damage * QActor.ARENA_FINAL_DAMAGE_COEFFICIENT
            end

        end
    else
        local pveDamageAmendCoef = attacker:getPVEDamagePercentAttack() - attackee:getPVEDamagePercentBeattack()
        pveDamageAmendCoef = math.max(pveDamageAmendCoef, -0.8)
        damage = damage * math.max(1 + pveDamageAmendCoef, 0)
    end

    -- 海神岛伤害系数
    if skillAttackType == QSkill.ATTACK then
        local battleDamageCoefficient = app.battle:getDamageCoefficient()
        damage = damage * battleDamageCoefficient
    end

    -- 小怪的伤害系数
    local damage_coefficient = attacker._propertyCoefficient.damage
    if damage_coefficient and not skill:isTalentSkill() then
        damage = damage * (damage_coefficient + 1)
    end

    -- 技能增强数值
    local enhance_value = skill:getEnhanceValue()
    if enhance_value then
        damage = damage * (1 + enhance_value)
    end

    -- 保存original_damage用于aoe快速计算伤害
    local original_damage = damage

    -- 最终伤害 和 伤害浮动
    local randomValue = app.random()
    damage = damage * (0.8 + randomValue * 0.4)

    -- 格挡 和 暴击
    local tip = ""
    local critical = false
    if blocked then
        damage = damage * 0.5
        tip = "格挡 "
    else
        if not skill:isUncriticalSkill() then
            local finalCrit = calcFinalCrit(attacker, attackee)
            if skillHitType == QSkill.CRITICAL or (p > 0 and p < finalCrit) then
                -- 暴击
                local attackerCritDamage = attacker:getCritDamage(attackee)

                damage = damage * attackerCritDamage
                tip = damage > 0 and "暴击 " or ""
                critical = true
            end
        end
    end

    -- 羁绊技能伤害增幅
    local multiplier = attacker._additionalManualSkillDamageMultiplier
    if multiplier ~= 1 then
        if skill:getSkillType() == skill.MANUAL then
            damage = damage * multiplier
        end
    end

    -- pvp伤害属性系数
    if app.battle:isPVPMode() and not app.battle:isInTotemChallenge() then
        local real_pvp_physical_damge_percent = attacker:getPVPPhysicalAttackPercent() - attackee:getPVPPhysicalReducePercent()
        real_pvp_physical_damge_percent = real_pvp_physical_damge_percent < -0.8 and -0.8 or real_pvp_physical_damge_percent
        local real_pvp_magic_damage_percent = attacker:getPVPMagicAttackPercent() - attackee:getPVPMagicReducePercent()
        real_pvp_magic_damage_percent = real_pvp_magic_damage_percent < -0.8 and -0.8 or real_pvp_magic_damage_percent

        if skillAttackType == QSkill.ATTACK then
            if skillDamageType == QSkill.PHYSICAL then
                damage = damage * math.max(1 + real_pvp_physical_damge_percent, 0)
            elseif skillDamageType == QSkill.MAGIC then
                damage = damage * math.max(1 + real_pvp_magic_damage_percent, 0)
            end
        end
    end

    if attacker:isSoulSpirit() and skillAttackType == QSkill.ATTACK then
        local soulDamagePercentAttack = attacker:getSoulDamagePercentAttack()
        local soulDamagePercentBeattackReduce = attackee:getSoulDamagePercentBeattackReduce()
        local finalSoulDamagePercent = soulDamagePercentAttack - soulDamagePercentBeattackReduce
        finalSoulDamagePercent = math.max(1 + finalSoulDamagePercent, 0.1)
        damage = damage * finalSoulDamagePercent
    end

    -- aoe伤害系数
    if isAOE then
        if skillAttackType == QSkill.ATTACK then
            damage = damage * (1 + attacker:getAOEAttackPercent())
        end
    end

    if skillAttackType == QSkill.TREAT then
        -- 治疗的文字显示: 前面附加一个加号"+"
        tip = tip .. "+"
    else
        tip = tip .. "-"
    end

    -- 加上actorPercentDamage
    if actorPercentDamage > 0 then
        if blocked then
            damage = damage + actorPercentDamage * 0.5
        else
            damage = damage + actorPercentDamage
        end
    end

    -- 战斗模块相关数据放大
    damage = app.battle:addDamage(damage, attacker)

    local damageThreshold = skill:getDamageThreshold()
    if damageThreshold then
        damage = math.min(damageThreshold * attackee:getMaxHp(), damage)
    end

    if skillAttackType == QSkill.ATTACK then
        damage = damage * dragonModifier
    end
    damage = math.ceil(damage)

    return damage, tip, critical, blocked and "block" or "hit", original_damage, ignore_absorb
end

function QActor:getFixedDamage()
    local damage = 0
    local trigger = false
    for i,skill in pairs(self:getPassiveSkills()) do
        if skill:getTriggerCondition() == QSkill.TRIGGER_CONDITION_FIXED_DAMAGE then
            damage = damage + skill:getFixedDamage()
            trigger = true
        end
    end
    return trigger,damage
end

function QActor:getCalcDamage(attacker, skill, attackee, split_number, isAOE)
    return calcDamage(attacker, skill, attackee, split_number, isAOE)
end

--自己击中目标
function QActor:hit(skill, attackee, split_number, override_damage, original_damage, isAOE, isBullet, damage_scale, ignoreAbsorbPercent)
    if app.battle:hasWinOrLose() then
        return
    end

    if skill == nil or attackee == nil then
        return 
    end

    if attackee:isDead() == true or (self:isDead() == true and not self:isDoingDeadSkill()) then 
        return 
    end

    -- 附带伤害（毒药之类）不会触发攻击类事件
    local _is_triggered = false
    local _sb_director = nil
    for _, sb in ipairs(self._sbDirectors) do
        if sb:getSkill() == skill then
            _sb_director = sb
            if sb._is_triggered then
                _is_triggered = true
            end
            break
        end
    end

    local tip_modifiers = {}

    -- 确定attacker，如果是
    local attacker = skill:getDamager() or self

    -- 忽略攻击目标
    if app.grid:isIgoreHurt(attacker, attackee) then
        -- override_damage = attacker:getIgnoreHurtResulteArgs()
        return
    end

    -- passive skill: trigger_type is trigger_property_modifier, start
    local propertyModifierEndCallback = nil
    do -- if _is_triggered == false then 
        local sub_tip_modifiers = nil
        propertyModifierEndCallback, sub_tip_modifiers = attacker:triggerPassiveSkillAsPropertyModifier(skill:getSkillType() == QSkill.MANUAL and QSkill.TRIGGER_CONDITION_MANUAL_SKILL or QSkill.TRIGGER_CONDITION_SKILL, attackee, skill)
        table.merge(tip_modifiers, sub_tip_modifiers)
        sub_tip_modifiers = nil
    end

    for k,v in pairs(skill:getPropertyPromotion()) do
        attacker:insertPropertyValue(k, skill, "+", v)
    end

    local damage, tip, critical, hit_status, ignore_absorb, immune_tip, rawTip, ignore_immune, isExecute
    if override_damage then
        damage, tip, critical, hit_status = override_damage.damage, override_damage.tip, override_damage.critical, override_damage.hit_status

    elseif original_damage then
        damage, tip, critical, hit_status, original_damage = calcDamageWithOriginalDamage(attacker, skill, attackee, original_damage, isAOE)
    else
        damage, tip, critical, hit_status, original_damage, ignore_absorb, ignore_immune, isExecute = calcDamage(attacker, skill, attackee, split_number, isAOE)
    end

    if damage_scale then
        damage = damage * damage_scale
    end

    -- 使用储存的治疗量来增强伤害
    local use_save_treat_percent, use_save_treat_flag, save_treat_scale = skill:getUseSaveTreatPercent()
    if use_save_treat_flag then
        local addition_damage = 0
        for i,buff in ipairs(attacker:getBuffs()) do
            if buff:isSaveTreat() and buff:getSaveTreatFlag() == use_save_treat_flag then
                local damage_add = buff:getSaveTreat() * use_save_treat_percent
                addition_damage = addition_damage + damage_add * save_treat_scale
                buff:reduceSaveTreat(damage_add)
            end
        end
        damage = damage + addition_damage
    end

    if hit_status ~= "dodge" then
        local triggered,fixed_damage = attackee:getFixedDamage()
        if triggered then
            damage = fixed_damage
        end
    end

    -- passive skill: trigger is trigger_property_modifier, end
    if  propertyModifierEndCallback ~= nil --[[_is_triggered == false]] then 
        propertyModifierEndCallback()
    end
    for k,v in pairs(skill:getPropertyPromotion()) do
        attacker:removePropertyValue(k, skill)
    end

    -- passive skill: trigger_type is trigger_damage_modifier
    if damage > 0 --[[and _is_triggered == false]] then -- dodge(miss), block won't trigger damage_modifier
        -- i'm just 2 lazy to distinguish between critical/non critical, heal/non-heal, normal-skill/all-skill, got-hit/hit
        local damageModifier, sub_tip_modifiers = attacker:triggerPassiveSkillAsDamageModifier(skill:getSkillType() == QSkill.MANUAL and QSkill.TRIGGER_CONDITION_MANUAL_SKILL or QSkill.TRIGGER_CONDITION_SKILL, attackee)
        damage = damage * damageModifier
        table.merge(tip_modifiers, sub_tip_modifiers)
        sub_tip_modifiers = nil
    end

    rawTip = {
        isHero = attackee:getType() ~= ACTOR_TYPES.NPC, 
        isDodge = hit_status == "dodge", 
        isBlock = hit_status == "block", 
        isCritical = critical, 
        isExecute = isExecute, --是否是斩杀
        isTreat = skill:getAttackType() == QSkill.TREAT, 
        number = damage
    }


    local absorb = 0
    local overKill = 0
    local immuned = false
    local attackType = skill:getAttackType()

    if attackType == QSkill.TREAT then
        if damage > 0 then
            local _
             _, damage = attackee:increaseHp(damage, attacker, skill)
            -- app.battle:addTreatHistory(attacker:getUDID(), damage, skill:getId())
            rawTip.number = damage
        end

        if attackee:getMaxHp() == attackee:getHp() then
            -- 治疗任务完成后，魂师需要恢复自动模式
            if skill:getActor():isManualMode() then
                skill:getActor():setManualMode(QActor.AUTO)
            end
        end
    elseif attackType == QSkill.ATTACK then
        -- 检查伤害免疫
        local immune_physical_damage = attackee:isImmunePhysicalDamage()
        local immune_magic_damage = attackee:isImmuneMagicDamage()
        local damage_type = skill:getDamageType()
        if immune_physical_damage and damage_type == QSkill.PHYSICAL and not ignore_immune then
            attackee:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = global.immune_physical, rawTip = {
                isHero = attackee:getType() ~= ACTOR_TYPES.NPC,
                isImmune = true}})
            immuned = true
            attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_IMMUNE_PHYSICAL_DAMAGE, attacker, QBuff.TRIGGER_TARGET_SELF)
            return original_damage
        elseif immune_magic_damage and damage_type == QSkill.MAGIC and not ignore_immune then
            attackee:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = global.immune_magic, rawTip = {
                isHero = attackee:getType() ~= ACTOR_TYPES.NPC,
                isImmune = true}})
            immuned = true
            attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_IMMUNE_MAGIC_DAMAGE, attacker, QBuff.TRIGGER_TARGET_SELF)
            return original_damage
        else
            attackee._hitlog:addNewHit(attacker:getId(), damage, skill:getId(), skill:getActor():getTalentHatred())
            
            -- if damage > 0 then
                -- app.battle:addDamageHistory(attacker:getUDID(), damage, skill:getId())

            local skillActor = skill:getActor()
            local attackeePreAttacker = attackee._lastAttacker
            if not skillActor:isGhost() and not skillActor:isSoulSpirit() and not skillActor:isIdleSupport() then
                if (self:isHealth() or skillActor ~= attackee) and not skillActor:isNeutral() then
                    attackee._lastAttacker = skill:getDamager() or skillActor
                end
            end

            local split_hit_targets = attackee:getSplitHitTargets()
            if split_hit_targets and (not isExecute) and (not attackee:isLockHp()) then
                for _, split_info in ipairs(split_hit_targets) do
                    local cfg = split_info.cfg
                    local target_num = #cfg.targets
                    if target_num > 1 then
                        local percent = cfg.percent
                        if percent == nil then
                            percent = (target_num - 1)/target_num
                        end
                        local split_damage = (damage * percent)/(target_num - 1)
                        if split_damage > 0 then
                            for i,hero in ipairs(cfg.targets) do
                                if hero ~= attackee and not ((damage_type == QSkill.PHYSICAL and hero:isImmunePhysicalDamage()) or (damage_type == QSkill.MAGIC and hero:isImmuneMagicDamage())) then
                                    local _, value, absorb = hero:decreaseHp(split_damage, attacker, skill, nil, true, false, false, false, false, nil, ignoreAbsorbPercent)
                                    if absorb > 0 then
                                        local absorb_tip = "吸收 "
                                        hero:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
                                            isHero = hero:getType() ~= ACTOR_TYPES.NPC, 
                                            isDodge = false, 
                                            isBlock = false, 
                                            isCritical = false, 
                                            isTreat = false,
                                            isAbsorb = true, 
                                            number = absorb
                                        }})
                                    end
                                    if value > 0 then
                                        local tip = ""
                                        hero:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = tip .. tostring(math.floor(value)),
                                            rawTip = {
                                                isHero = hero:getType() ~= ACTOR_TYPES.NPC, 
                                                isDodge = false, 
                                                isBlock = false, 
                                                isCritical = false, 
                                                isTreat = false, 
                                                number = value
                                            }})
                                    end
                                end
                            end
                        end
                        damage = damage * (1 - percent)
                    end
                end
            end

            if damage > 0 then
                local value = attackee:getAdaptivityHelmet()
                if value ~= 0 and attackeePreAttacker and attackeePreAttacker == attackee._lastAttacker then
                    damage = damage * (1 - value)
                end
                if --[[(_is_triggered == false or skill:isAllowTrigger()) and]] not attackee:isBoss() and not attackee:isEliteBoss() then
                    attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_DAMAGE, attackee, damage, _sb_director)
                end
                
                local percent = 0
                for _, tab in ipairs(attackee._strikeAgreementers) do
                    if tab.percent and tab.actor then
                        percent = percent + tab.percent
                        if percent <= 1 then
                            tab.actor:dispatchEvent({name = QActor.DECREASEHP_EVENT, hp = damage * tab.percent,
                                attacker = attacker, skill = skill, no_render = nil, isAOE = isAOE, ignoreAbsorb = ignore_absorb})
                        else
                            percent = 1
                        end
                    end
                end

                local _
                _, damage, absorb, overKill = attackee:decreaseHp(damage * (1-percent), attacker, skill, nil, isAOE, ignore_absorb, nil, isExecute, isBullet, nil, ignoreAbsorbPercent)
                overKill = overKill or 0
                rawTip.number = damage
            end
            -- end

            local index = -1
            while index ~= 0 do
                index = 0
                for i, buff in ipairs(attackee._buffs) do
                    if buff.effects.can_be_removed_with_hit == true then
                        index = i
                        break
                    end
                end
                if index ~= 0 then
                    attackee:removeBuffByIndex(index)
                end
            end
        end
    end

    local damage_type = skill:getDamageType()

    if _is_triggered == false or skill:isAllowTrigger() then
        -- passive skill
        attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_SKILL, attackee, damage, _sb_director) -- 技能
        if skill:getSkillType() == QSkill.ACTIVE then
            if skill:isTalentSkill() then
                if skill:getAttackType() == QSkill.TREAT then
                    attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_NORMAL_SKILL_TREAT, attackee, damage, _sb_director) -- 治疗普攻
                else
                    attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_NORMAL_SKILL_NOT_TREAT, attackee, damage, _sb_director) -- 非治疗普攻
                end
                attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_NORMAL_SKILL, attackee, damage, _sb_director) -- 普通技能
            else
                attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_ACTIVE_NOT_NORMAL, attackee, damage, _sb_director) -- 非普攻的自动技能
            end
            attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_ACTIVE_SKILL, attackee, damage, _sb_director) -- 主动技能
        end
        if skill:getSkillType() == QSkill.MANUAL then
            attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_MANUAL_SKILL, attackee, damage, _sb_director) -- 手动技能
            if attackType == QSkill.ATTACK then
                -- attacker:triggerPassiveSkill(QSkill.TRIGGER_EVENT_MANUAL_SKILL_DAMAGE, attackee, damage, _sb_director) -- 手动技能
                attacker:dispatchEvent({name = QSkill.TRIGGER_EVENT_MANUAL_SKILL_DAMAGE, actor = attackee, damage = damage,
                    sbThatCauseCondition = _sb_director})
            end
        end
        if critical then
            attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_SKILL_CRITICAL, attackee, damage, _sb_director) -- 技能暴击
        end
        if attackType == QSkill.TREAT then
            attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_SKILL_TREAT, attackee, damage, _sb_director) -- 治疗技能
            if critical then
                attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_SKILL_TREAT_CRITICAL, attackee, damage, _sb_director) -- 治疗技能暴击
            end
        elseif attackType == QSkill.ATTACK then
            attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_SKILL_ATTACK, attackee, damage, _sb_director) -- 攻击技能
            if critical then
                attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_SKILL_ATTACK_CRITICAL, attackee, damage, _sb_director) -- 攻击技能暴击
            end
            if skill:getDamageType() == QSkill.PHYSICAL then
                attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_PHYSICAL_SKILL, attackee, damage, _sb_director)
            else
                attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_MAGIC_SKILL, attackee, damage, _sb_director)
            end
        end
        if attackee:isDead() == false then
            if hit_status == "block" then
                attackee:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_BLOCK, attacker, damage, _sb_director)
                attackee:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT, attacker, damage, _sb_director)
                if damage_type == QSkill.PHYSICAL then
                    attackee:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT_PHYSICAL, attacker, damage, _sb_director)
                elseif damage_type == QSkill.MAGIC then
                    attackee:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT_MAGIC, attacker, damage, _sb_director)
                end
            elseif hit_status == "hit" and attackType == QSkill.ATTACK then
                attackee:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT, attacker, damage, _sb_director)
                if damage_type == QSkill.PHYSICAL then
                    attackee:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT_PHYSICAL, attacker, damage, _sb_director)
                elseif damage_type == QSkill.MAGIC then
                    attackee:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT_MAGIC, attacker, damage, _sb_director)
                end
            elseif hit_status == "dodge" then
                attackee:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_DODGE, attacker, damage, _sb_director)
            end
            if attackeePreAttacker and attackeePreAttacker ~= attackee._lastAttacker then
                attackee:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_DIFF_ATTACKER, attacker, damage, _sb_director)
            end
        end
        if isAOE and attackType == QSkill.ATTACK and damage > 0 then
            attackee:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT_BY_ENEMY_AOE, attacker, damage, _sb_director) -- aoe
        end
        
        -- buff already applied
        -- as attacker for others
        if not app.battle:isGhost(attacker) then
            local teammates = app.battle:getMyTeammates(attacker, false)
            local enemies = app.battle:getMyEnemies(attacker)
            local teamSoulSpirits = app.battle:getTeamSoulSpirit(attacker)
            for _, soulSpirit in ipairs(teamSoulSpirits) do
                if attackType == QSkill.TREAT then
                    soulSpirit:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_TREAT, attackee, QBuff.TRIGGER_TARGET_TEAMMATE_OF_SOULSPIRIT, damage, _sb_director) -- 治疗技能
                    if critical then
                        soulSpirit:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_TREAT_CRITICAL, attackee, QBuff.TRIGGER_TARGET_TEAMMATE_OF_SOULSPIRIT, damage, _sb_director) -- 治疗技能暴击
                    end
                elseif attackType == QSkill.ATTACK then
                    soulSpirit:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_ATTACK, attackee, QBuff.TRIGGER_TARGET_TEAMMATE_OF_SOULSPIRIT, damage, _sb_director) -- 攻击技能
                    if critical then
                        soulSpirit:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_ATTACK_CRITICAL, attackee, QBuff.TRIGGER_TARGET_TEAMMATE_OF_SOULSPIRIT, damage, _sb_director) -- 攻击技能暴击
                    end
                end
            end
            for _, mate in ipairs(teammates) do
                if skill:getSkillType() == QSkill.ACTIVE then
                    mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_ACTIVE_SKILL, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                    if skill:isTalentSkill() then
                        if skill:getAttackType() == QSkill.TREAT then
                            mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL_TREAT, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                        else
                            mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL_NOT_TREAT, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                        end
                        mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                    else
                        mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_ACTIVE_NOT_NORMAL, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                    end
                end
                if skill:getSkillType() == QSkill.MANUAL then
                    mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_MANUAL_SKILL, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                end
                mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                if critical then
                    mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_CRITICAL, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director) -- 技能暴击
                end
                if attackType == QSkill.TREAT then
                    mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_TREAT, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director) -- 治疗技能
                    if critical then
                        mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_TREAT_CRITICAL, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director) -- 治疗技能暴击
                    end
                elseif attackType == QSkill.ATTACK then
                    mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_ATTACK, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director) -- 攻击技能
                    if critical then
                        mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_ATTACK_CRITICAL, attackee, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director) -- 攻击技能暴击
                    end
                end
            end
            for _, enemy in ipairs(enemies) do
                if skill:getSkillType() == QSkill.ACTIVE then
                    enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_ACTIVE_SKILL, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                    if skill:isTalentSkill() then
                        if skill:getAttackType() == QSkill.TREAT then
                            enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL_TREAT, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                        else
                            enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL_NOT_TREAT, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                        end
                        enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                    else
                        enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_ACTIVE_NOT_NORMAL, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                    end
                end
                if skill:getSkillType() == QSkill.MANUAL then
                    enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_MANUAL_SKILL, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                end
                enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                if critical then
                    enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_CRITICAL, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director) -- 技能暴击
                end
                if attackType == QSkill.TREAT then
                    enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_TREAT, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director) -- 治疗技能
                    if critical then
                        enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_TREAT_CRITICAL, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director) -- 治疗技能暴击
                    end
                elseif attackType == QSkill.ATTACK then
                    enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_ATTACK, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director) -- 攻击技能
                    if critical then
                        enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_ATTACK_CRITICAL, attackee, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director) -- 攻击技能暴击
                    end
                end
            end
        end
        -- as attackee for others
        local teammates = app.battle:getMyTeammates(attackee, false)
        local enemies = app.battle:getMyEnemies(attackee)
        for _, mate in ipairs(teammates) do
            if hit_status == "hit" and attackType == QSkill.ATTACK then
                mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT, attacker, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                if damage_type == QSkill.PHYSICAL then
                    mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT_PHYSICAL, attacker, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                elseif damage_type == QSkill.MAGIC then
                    mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT_MAGIC, attacker, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                end
                if skill:isTalentSkill() then
                    mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL_HIT, attacker, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                end
            elseif hit_status == "block" then
                mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_BLOCK, attacker, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT, attacker, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                if damage_type == QSkill.PHYSICAL then
                    mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT_PHYSICAL, attacker, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                elseif damage_type == QSkill.MAGIC then
                    mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT_MAGIC, attacker, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                end
                if skill:isTalentSkill() then
                    mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL_HIT, attacker, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
                end
            elseif hit_status == "dodge" then
                mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_DODGE, attacker, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
            elseif hit_status == "miss" then
                mate:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_MISS, attacker, QBuff.TRIGGER_TARGET_TEAMMATE, damage, _sb_director)
            end
        end
        for _, enemy in ipairs(enemies) do
            if hit_status == "hit" and attackType == QSkill.ATTACK then
                enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT, attacker, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                if damage_type == QSkill.PHYSICAL then
                    enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT_PHYSICAL, attacker, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                elseif damage_type == QSkill.MAGIC then
                    enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT_MAGIC, attacker, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                end
                if skill:isTalentSkill() then
                    enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL_HIT, attacker, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                end
            elseif hit_status == "block" then
                enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_BLOCK, attacker, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT, attacker, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                if damage_type == QSkill.PHYSICAL then
                    enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT_PHYSICAL, attacker, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                elseif damage_type == QSkill.MAGIC then
                    enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT_MAGIC, attacker, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                end
                if skill:isTalentSkill() then
                    enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL_HIT, attacker, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
                end
            elseif hit_status == "dodge" then
                enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_DODGE, attacker, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
            elseif hit_status == "miss" then
                enemy:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_MISS, attacker, QBuff.TRIGGER_TARGET_ENEMY, damage, _sb_director)
            end
        end
        -- attacker and attackee self
        if skill:getSkillType() == QSkill.ACTIVE then
            attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_ACTIVE_SKILL, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
            if skill:isTalentSkill() then
                if skill:getAttackType() == QSkill.TREAT then
                    attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL_TREAT, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
                else
                    attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL_NOT_TREAT, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
                end
                attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
            else
                attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_ACTIVE_NOT_NORMAL, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
            end
        end
        if skill:getSkillType() == QSkill.MANUAL then
            attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_MANUAL_SKILL, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
        end
        attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
        if critical then
            attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_CRITICAL, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director) -- 技能暴击
        end
        if attackType == QSkill.TREAT then
            attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_TREAT, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director) -- 治疗技能
            if critical then
                attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_TREAT_CRITICAL, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director) -- 治疗技能暴击
            end
        elseif attackType == QSkill.ATTACK then
            attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_ATTACK, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director) -- 攻击技能
            if critical then
                attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SKILL_ATTACK_CRITICAL, attackee, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director) -- 攻击技能暴击
            end
        end
        if not attackee:isDead() then
            if hit_status == "hit" and attackType == QSkill.ATTACK then
                attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT, attacker, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
                if damage_type == QSkill.PHYSICAL then
                    attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT_PHYSICAL, attacker, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
                elseif damage_type == QSkill.MAGIC then
                    attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_HIT_MAGIC, attacker, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
                end
                if skill:isTalentSkill() then
                    attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_NORMAL_SKILL_HIT, attacker, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
                end
            elseif hit_status == "block" then
                attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_BLOCK, attacker, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
            elseif hit_status == "dodge" then
                attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_DODGE, attacker, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
            elseif hit_status == "miss" then
                attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_MISS, attacker, QBuff.TRIGGER_TARGET_SELF, damage, _sb_director)
            end
        end

        if attackType == QSkill.ATTACK then
            for _,listener in ipairs(attackee._custom_event_list) do
                if listener.name == QActor.CUSTOM_EVENT_HIT then
                    listener.callback(attacker)
                end
            end
        end
        
    end

    if attackType ~= QSkill.ATTACK or hit_status == "hit" or hit_status == "block" then
        -- trigger apply buff
        attacker:triggerBuff(skill, attackee)

        -- trigger change rage
        attacker:triggerRage(skill, attackee)
    end

    -- 注意，这里先applyBuff，再dispatch UNDER_ATTACK_EVENT。因为在UNDER_ATTACK_EVENT的响应中
    -- 会启动Tint颜色， 这个action会使用当前的displayColor，从而将Buff设置的displayColor覆盖掉。
    -- 最终的现象是Buff的颜色看起来没有生效。
    if absorb > 0 and not isExecute then
        local absorb_tip = "吸收 "
        attackee:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
            isHero = attackee:getType() ~= ACTOR_TYPES.NPC, 
            isDodge = false, 
            isBlock = false, 
            isCritical = false, 
            isTreat = false,
            isAbsorb = true, 
            number = absorb
        }})    
    end

    if isExecute and skill:getExecuteEffect() then
        attackee:playSkillEffect(skill:getExecuteEffect(), nil, {attacker = attacker, attackee = attackee})
    end

    -- 直接伤害只有在大于1时才会提示伤害数值
    if damage > 1 or skill:getAttackType() == QSkill.ASSIST or hit_status == "dodge" or hit_status == "miss" then
        if not immuned and (damage > 0 or string.len(tip) > 0) then
            if damage > 0 then
                tip = tip .. tostring(math.floor(damage))
            end
            -- skill tip modifier
            tip_modifiers[#tip_modifiers + 1] = skill:getTipModifier()
            -- buff tip modifier
            if skill:getAttackType() == QSkill.ATTACK then
                for _, buff in ipairs(attackee:getBuffs()) do
                    tip_modifiers[#tip_modifiers + 1] = buff:getTipModifier()
                end
            end

            attackee:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = (skill:getAttackType() == QSkill.TREAT), 
                isCritical = critical, tip = tip, rawTip = rawTip, tip_modifiers = tip_modifiers})
        end
    end

    -- 触发击退
    if hit_status == "hit" and not attackee:isSupportHero() then
        local is_knockback = true
        for _, buff in ipairs(attackee._buffs) do
            if not buff:isImmuned() and not buff.effects.is_knockback then
                is_knockback = false
                break
            end
        end
        local beatback_chance = skill:getBeatbackChance()
        local beatback_beatback_distance = math.abs(skill:getBeatbackDistance())
        if beatback_chance > 0 and app.random() < beatback_chance then
            if is_knockback then
                local pos = clone(attackee:getPosition())
                if pos.x >= BATTLE_AREA.left and pos.x <= BATTLE_AREA.right then
                    if skill:isBeatbackDirectionByAttacker() then
                        pos.x = pos.x + (attacker:isFlipX() and beatback_beatback_distance or -beatback_beatback_distance)
                    else
                        pos.x = pos.x + ((attackee:getPosition().x - self:getPosition().x > 0) and beatback_beatback_distance or -beatback_beatback_distance)
                    end
                    app.grid:beatbackActorTo(attackee, pos, skill:getBeatbackHeight(), skill:getBeatBackTime())
                end
            else
                attackee:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = "免疫",
                rawTip = {
                    isHero = attackee:getType() ~= ACTOR_TYPES.NPC, 
                    isImmune = true,
                    number = 0
                }})
            end
        end
        local blowup_chance = skill:getBlowupChance()
        local blowup_height = skill:getBlowupHeight(attackee)
        local blowup_uptime = skill:getBlowupUpTime()
        local blowup_keeptime = skill:getBlowupKeepTime()
        local blowup_downtime = skill:getBlowupDownTime()
        local blowup_falldamage = skill:getBlowupFallDamage()
        if blowup_chance > 0 and app.random() < blowup_chance then
            if is_knockback then
                app.grid:blowupActor(attackee, blowup_height, blowup_uptime, blowup_uptime + blowup_keeptime, blowup_uptime + blowup_keeptime + blowup_downtime, blowup_falldamage,
                    attacker, skill)
            else
                attackee:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = "免疫",
                rawTip = {
                    isHero = attackee:getType() ~= ACTOR_TYPES.NPC, 
                    isImmune = true,
                    number = 0
                }})
            end
        end
    end

    -- 物理伤害吸血，魔法伤害吸血
    if (damage - overKill) > 0 and attackType == QSkill.ATTACK then
        local drainBloodAmount = 0
        local drainBloodPhysical = attacker._drainBloodPhysical
        if drainBloodPhysical > 0 and skill:getDamageType() == QSkill.PHYSICAL then
            drainBloodAmount = drainBloodPhysical * (damage - overKill)
        end
        local drainBloodMagic = attacker._drainBloodMagic
        if drainBloodMagic > 0 and skill:getDamageType() == QSkill.MAGIC then
            drainBloodAmount = drainBloodMagic * (damage - overKill)
        end
        if drainBloodAmount > 0 then
            local _, dHp = attacker:increaseHp(drainBloodAmount, attacker, skill, nil, nil, QBuff.SAVE_TREAT_FROM_DRAIN_BLOOD)
            if dHp > 0 then
                attacker:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = true, 
                    isCritical = false, tip = "", rawTip = {
                        isHero = attacker:getType() == ACTOR_TYPES.HERO, 
                        isCritical = false, 
                        isTreat = true,
                        number = dHp,
                    }})
            end
        end
        if override_damage == nil or override_damage.ignore_damage_to_absorb ~= true then
            for i, buff in ipairs(attacker:getBuffs()) do
                local v = buff:getDamageToAbsorb()
                if v > 0 then
                    local value = buff:calcGainEffect("absorb_damage_value", v * (damage - overKill))
                    local buff_value = buff:getAbsorbDamageValue()
                    value = buff:setAbsorbDamageValue(buff_value + value, true)
                    attacker:dispatchAbsorbChangeEvent(value - buff_value)
                end
            end
        end
    end

    return original_damage, damage
end

function QActor:getCurrentSkill()
    return self._currentSkill
end

function QActor:cancelTalentSkill()
    if self._currentSkill and (self._currentSkill == self:getTalentSkill() or self._currentSkill == self:getTalentSkill2()) then
        self:_cancelCurrentSkill()
    end
end

function QActor:getExecutingSkills()
    local skills = {}
    for _, sbDirector in ipairs(self._sbDirectors) do
        table.insert(skills, sbDirector:getSkill())
    end

    return skills
end

function QActor:getCurrentSkillTarget()
    if self._currentSBDirector == nil then
        return nil
    else 
        return self._currentSBDirector:getTarget()
    end
end

function QActor:getSkillId(config, skillIds)
    if config == nil or skillIds == nil then
        return
    end
    if config.OPTIONS ~= nil and config.OPTIONS.skill_id ~= nil then
        if config.OPTIONS.level then
            table.insert(skillIds, tostring(config.OPTIONS.skill_id) .. "," .. tostring(config.OPTIONS.level))
        else
            table.insert(skillIds, config.OPTIONS.skill_id)
        end
    end

    if config.ARGS ~= nil then
        for _, conf in pairs(config.ARGS) do
            self:getSkillId(conf, skillIds)
        end
    end
end

function QActor:getSkillIdWithAiType(aiType)
    local skillIds = {}
    if aiType ~= nil then
        local config = QFileCache.sharedFileCache():getAIConfigByName(aiType)
        if config ~= nil then
            self:getSkillId(config, skillIds)
        end
    end
    return skillIds
end

function QActor:getVictorySkillId()
    local skillId = self:get("victory_skill")
    if not skillId or skillId == -1 then
        return nil
    else
        return skillId
    end
end

function QActor:getVictorySkill()
    return self._victorySkill
end

function QActor:playVictorySkill()
    if self._victorySkill then
        self:attack(self._victorySkill)
    end
end

-- 对拖拽的处理，如果触发了冲锋等技能，则返回true，否则返回false
-- 
function QActor:_onDrag(position, action, is_focus)
    self:triggerPassiveSkill(action, self)

    local activeSkill = nil
    for _, skill in pairs(self._activeSkills) do
        local condition_met = false
        local skill_condition = skill:getTriggerCondition()

        if skill_condition == QSkill.TRIGGER_CONDITION_DRAG_OR_DRAG_ATTACK then
            condition_met = (action == QSkill.TRIGGER_CONDITION_DRAG and self:isRanged()) or (action == QSkill.TRIGGER_CONDITION_DRAG_ATTACK and not self:isRanged())
        else
            condition_met = action == skill_condition
        end

        if condition_met and skill:isReady() == true then
            if skill:isInSkillRange(self:getPosition(), position, false) == true then
                local probability = skill:getTriggerProbability()
                if probability >= app.random(1, 100) and self:canAttack(skill, nil, true) and self:canAttackWithBuff(skill) then
                    if skill_condition == QSkill.TRIGGER_CONDITION_DRAG_OR_DRAG_ATTACK then
                        activeSkill = skill
                        break
                    else
                        activeSkill = activeSkill or skill
                    end
                end
            end
        end
    end

    if activeSkill ~= nil then
        if activeSkill:isChargeSkill() or ALLOW_MULTIPLE_CHARGE then
            self._dragPosition = position
            self._targetPosition = position
            self:attack(activeSkill)
            return true
        else
            local callback = nil
            app.battle:registerCharge(self, self:getTarget(), function(allow)
                if allow then
                    self._dragPosition = position
                    self._targetPosition = position
                    self:attack(activeSkill)
                end
                if callback then
                    callback(allow)
                end
            end)
            return function(cb)
                callback = cb
            end
        end
    end

    if is_focus and self:isRanged() then
        app.grid:moveActorTo(self, self:getPosition())
    end

    return false
end

function QActor:onDragAttack(target, is_focus)
    if self._isLockDrag or self._isLockTarget > 0 or target:isNeutral() then
        return
    end

    -- 不立即执行操作
    local actionEvents = self._actionEvents
    table.insert(actionEvents, {cat = QActor.ACTION_DRAG_ATTACK, target = target, is_focus = is_focus})
end

function QActor:onDragMove(position)
    if self.fsm__:getState() == "victorious" or app.battle:isBattleEnded() then
        return
    end

    if self._isLockDrag or self._isLockTarget > 0 then
        return
    end

    -- 不立即执行操作
    local actionEvents = self._actionEvents
    table.insert(actionEvents, {cat = QActor.ACTION_DRAG_MOVE, position = {x = math.round(position.x or self:getPosition().x or 0), y = math.round(position.y or self:getPosition().y) or 0}})
end

function QActor:onUseManualSkill(skill, ignore_resource)
    local actionEvents = self._actionEvents
    table.insert(actionEvents, {cat = QActor.ACTION_MANUAL_SKILL, ig = ignore_resource})
end

function QActor:_updateActionEvents()
    if not app.battle:isInReplay() then
        -- if app.battle:isCurrentFrameRecord() then
            local actionEvents = self._actionEvents
            for _, evt in ipairs(actionEvents) do
                self:_doActionEvent(evt)
                    -- 保存操作事件到Replay
                if evt.cat == QActor.ACTION_DRAG_ATTACK then
                    app.battle:savePlayerAction(self:getUDID(), evt.cat, {target = evt.target:getUDID(), is_focus = evt.is_focus})
                elseif evt.cat == QActor.ACTION_DRAG_MOVE then
                    -- evt.position是一个userdata(CCPosition)，必须要转到table
                    app.battle:savePlayerAction(self:getUDID(), evt.cat, {x = evt.position.x, y = evt.position.y})
                elseif evt.cat == QActor.ACTION_MANUAL_SKILL then
                    app.battle:savePlayerAction(self:getUDID(), evt.cat, {ig = evt.ig})
                elseif evt.cat == QActor.ACTION_ONMARK then
                    app.battle:savePlayerAction(self:getUDID(), evt.cat)
                elseif evt.cat == QActor.ACTION_ONUNMARK then
                    app.battle:savePlayerAction(self:getUDID(), evt.cat)
                end
            end
            self._actionEvents = {}
        -- end
    else
        local actions = app.battle:loadPlayerAction(self:getUDID())
        if actions then
            for _, action in ipairs(actions) do
                local evt = {cat = action.c}
                if evt.cat == QActor.ACTION_DRAG_ATTACK then
                    evt.target = app.battle:getActorByUDID(action.p.target)
                    evt.is_focus = action.p.is_focus
                elseif evt.cat == QActor.ACTION_DRAG_MOVE then
                    evt.position = qccp(action.p.x or 0, action.p.y or 0)
                elseif evt.cat == QActor.ACTION_MANUAL_SKILL then
                    evt.ig = action.p and action.p.ig -- backward compatible
                end
                self:_doActionEvent(evt)
            end
        end
    end
end

function QActor:_doActionEvent(evt)
    if evt.cat == QActor.ACTION_DRAG_ATTACK then
        if evt.target then
            local target = evt.target
            self:setTarget(target)
            self:setManualMode(QActor.ATTACK)
            self:_onDrag(target:getPosition(), QSkill.TRIGGER_CONDITION_DRAG_ATTACK, evt.is_focus)
        end
    elseif evt.cat == QActor.ACTION_DRAG_MOVE then
        local position = evt.position
        local ret = self:_onDrag(position, QSkill.TRIGGER_CONDITION_DRAG)
        if type(ret) == "function" then
            ret(function(allow)
                if not allow then
                    -- 没有触发技能，移动到目标地点
                    app.grid:moveActorTo(self, position)
                end
                self:setManualMode(QActor.STAY)
            end)
        else
            if ret == false then
                -- 没有触发技能，移动到目标地点
                app.grid:moveActorTo(self, position)
            end
            self:setManualMode(QActor.STAY)
        end
    elseif evt.cat == QActor.ACTION_MANUAL_SKILL then
        local skills = self:getManualSkills()
        local skill = skills[next(skills)]
        if self:isSoulSpirit() then skill = self:getFirstManualSkill() end
        if self:isSupportHero() then
            if self:isSupportSkillReady() then
                app.battle:doSupportSkill(self, skill, evt.ig)
            end
        else
            -- nzhang: 正常模式下大招会让自己突破子弹时间的静止，除了斗魂场模式
            if self:isInBulletTime() == true and not app.battle:isInArena() then
                self:inBulletTime(false)
                self:setAnimationScale(1.0, "bullet_time")
            end
            self:attack(skill)
        end
    elseif evt.cat == QActor.ACTION_ONMARK then
        self:_doOnMarked()
    elseif evt.cat == QActor.ACTION_ONUNMARK then
        self:_doOnUnMarked()
    end
end

function QActor:registerVictorySkill(victorySkillId)
    if victorySkillId ~= nil then
        self._victorySkill = QSkill.new(victorySkillId, {}, self)
        self._skills[victorySkillId] = self._victorySkill
    end
end

function QActor:onVictory()
    local victorySkillId = self:getVictorySkillId()
    self:registerVictorySkill(victorySkillId)
    self.fsm__:doEvent("victory")
    self.fsm__:doEvent("ready", global.victory_animation_duration)
end

function QActor:getHitLog()
    return self._hitlog
end

-- state callbacks
function QActor:_onChangeState(event)
    -- clear delayed "ready" event
    if self._delayedReadyHandler ~= nil then
        app.battle:removePerformWithHandler(self._delayedReadyHandler)
        self._delayedReadyHandler = nil
    end

    if event.to == "victorious" then
        self._victory = true
    end

    if event.to == "idle" then
        self:_verifyFlip()
    end

    if event.to == "beatbacking" then
        self:_verifyBeatbackFlip()
    end

    if event.to == "dead" then
        self._isDead = true
    else
        self._isDead = false
    end

    self:dispatchEvent({name = QActor.CHANGE_STATE_EVENT, from = event.from, to = event.to, args = event.args})
end

-- 启动状态机时，设定角色默认 Hp
function QActor:_onStart(event)
    self:setFullHp()

    self:dispatchEvent({name = QActor.START_EVENT})
end

function QActor:_onReady(event)
    self:dispatchEvent({name = QActor.READY_EVENT})
end

function QActor:_onAttack(event)
    self:_verifyFlip()
    self:dispatchEvent({name = QActor.ATTACK_EVENT, skill = event.args[1].skill, options = event.options})
end

function QActor:_onSkill(event)
    self:_verifyFlip()
    self:dispatchEvent({name = QActor.ATTACK_EVENT, skill = event.args[1].skill, options = event.options})
end

function QActor:_onMove(event)
    local deltaX = self._targetPosition.x - self._position.x
    local deltaY = self._targetPosition.y - self._position.y

    if self._direction == QActor.DIRECTION_LEFT and deltaX > EPSILON then
        self:_setFlipX()
    elseif self._direction == QActor.DIRECTION_RIGHT and deltaX < -EPSILON then
        self:_setFlipX()
    end

    if not self:_checkReverse() then
        if not IsServerSide then
            local view = app.scene:getActorViewFromModel(self)
            if view then
                view:_playWalkingAnimation()
            end
        end
    end

    self:dispatchEvent({name = QActor.MOVE_EVENT, from = self._position, to = self._targetPosition})
end

function QActor:_onFreeze(event)
    self:dispatchEvent({name = QActor.FREEZE_EVENT})
end

function QActor:_onThaw(event)
    self:dispatchEvent({name = QActor.THAW_EVENT})
end

function QActor:_onKill(event)
    self._hpValidate:set(0)
    self._hp = 0
    self:dispatchEvent({name = QActor.KILL_EVENT})

    self:onUnMarked()
    self:setFuncMark(nil)

    local attacker = self:getLastAttacker()
    if attacker and not attacker:isDead() and not attacker:isPet() and not attacker:isGhost() then
        -- 不能触发伤害类技能，因为目标已经死亡
        attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_KILL_ENEMY, self)
        self:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_SELF_DEATH, attacker)
        self:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_SELF_DEATH, attacker)
    end

    if not self:isPet() and not self:isGhost() and not self:isSoulSpirit() then
        if not app.battle:isPVPMode() and not app.battle:isPVPMultipleWave() and not self:isHero() then
            app.battle:setKillEnemyCount(1)
        end
    end

    if not self._no_dead_skill_or_animation then
        local dead_skill = self:get("dead_skill") or -1
        if self._deadSkill then
            self:attack(self:getSkillWithId(self._deadSkill))
            self._isDoingDeadSkill = true
        elseif dead_skill ~= -1 then
            self._skills[dead_skill] = QSkill.new(dead_skill, {}, self)
            self:attack(self:getSkillWithId(dead_skill))
            self._isDoingDeadSkill = true
        end
    end

    if not self:isGhost() and not self:isPet() and not self:isSoulSpirit() then
        for _, actor in ipairs(app.battle:getMyTeammates(self, false)) do
            actor:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_DEATH, self, 0)
        end
        for _, actor in ipairs(app.battle:getMyEnemies(self)) do
            actor:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_DEATH, self, 0)
        end
    end

    if self:getHunterPet() then
        self:getHunterPet():suicide() -- NPC_CLEANUP
        if self:getType() == ACTOR_TYPES.HERO or self:getType() == ACTOR_TYPES.HERO_NPC then
            app.battle:dispatchEvent({name = QBattleManager.HERO_CLEANUP, hero = self:getHunterPet()})
        else
            app.battle:dispatchEvent({name = QBattleManager.NPC_CLEANUP, npc = self:getHunterPet()})
            app.battle:dispatchEvent({name = QBattleManager.NPC_DEATH_LOGGED, npc = self:getHunterPet()})
        end
    end
    self._isInBulletTime = false
end

function QActor:_onRelive(event)
    self:setFullHp()
    self:dispatchEvent({name = QActor.RELIVE_EVENT})
end

function QActor:_onVictory(event)
    self:dispatchEvent({name = QActor.VICTORY_EVENT})
end

function QActor:_onBeforeReady(event)
    local cooldown = checknumber(event.args[1])
    if cooldown > 0 then
        -- 如果开火后的冷却时间大于 0，则需要等待

        if self._delayedReadyHandler ~= nil then
            app.battle:removePerformWithHandler(self._delayedReadyHandler)
        end

        self._delayedReadyHandler = app.battle:performWithDelay(function()
            -- printf("QActor ========= delayed ======== ready triggered")
            self._delayedReadyHandler = nil
            self.fsm__:doEvent("ready")
        end, cooldown, nil, nil, nil, true)
        return false
    end

    return true
end

function QActor:_onTargetKill(event)
    -- 攻击敌人任务完成后，魂师需要恢复自动模式
    if self:getManualMode() == QActor.ATTACK then
        self:setManualMode(QActor.AUTO)
    end
    if self:isLockTarget() then
        self:unlockTarget()
    end
    self:setTarget(nil)

    if self:isWalking() then
        self:stopMoving()
    end
end

function QActor:isImmuneStatus(status)
    local statusImmuned = false
    for _, buff in ipairs(self._buffs) do
        if buff:isImmuneStatus(status) then
            statusImmuned = true
            break
        end
    end
    return statusImmuned
end

function QActor:isImmuneBuff(newBuff)
    local newBuffImmuned = false
    for _, buff in ipairs(self._buffs) do
        if buff:isImmuneBuff(newBuff) then
            newBuffImmuned = true
            break
        end
    end
    return newBuffImmuned
end

function QActor:isImmuneSkill(skill)
    local skillImmuned = false
    for _, buff in ipairs(self._buffs) do
        if buff:isImmuneSkill(skill) then
            skillImmuned = true
            break
        end
    end
    return skillImmuned
end

function QActor:isImmuneTrap(trap)
    local immuned = false
    for _, buff in ipairs(self._buffs) do
        if buff:isImmuneTrap(trap) then
            immuned = true
            break
        end
    end
    return immuned
end

function QActor:isUnderStatus(status, needCount)
    if needCount then
        local result = false
        local count = 0
        -- buffs and auras
        if self._status_list[status] then
            for buff, has in pairs(self._status_list[status]) do
                result = true
                count = count + 1
            end
        end
        -- traps
        if app.battle ~= nil then
            for _, trapDirector in ipairs(app.battle:getTrapDirectors()) do
                if trapDirector:isExecute() == true and trapDirector:isTragInfluenceActor(self) then
                    if trapDirector:getTrap():getStatus() == status then
                        result = true
                        count = count + 1
                    end
                end
            end
        end
        return result, count
    else
        -- buffs and auras
        if self._status_list[status] then
            for buff, has in pairs(self._status_list[status]) do
                return true
            end
        end
        -- traps
        if app.battle ~= nil then
            for _, trapDirector in ipairs(app.battle:getTrapDirectors()) do
                if trapDirector:isExecute() == true and trapDirector:isTragInfluenceActor(self) then
                    if trapDirector:getTrap():getStatus() == status then
                        return true
                    end
                end
            end
        end

        return false
    end
end

function QActor:removeCannotControlMoveBuff()
    local again = true
    while again do
        again = false
        for index, buff in ipairs(self._buffs) do
            if not buff:isImmuned() and not buff.effects.can_control_move then
                self:removeBuffByIndex(index)
                again = true
                break
            end
        end
    end
end

function QActor:addReplaceBuff(replace_buff)
    local replace_buffs = self._replace_buffs
    if replace_buffs == nil then
        replace_buffs = {}
    end
    table.merge(replace_buffs, replace_buff)
    self._replace_buffs = replace_buffs
end

function QActor:hasSameIDBuff(buffId)
    for _, buff in ipairs(self._buffs) do
        if buff:getId() == buffId then
            return true, buff
        end
    end

    return false, nil
end

function QActor:_tryReplaceBuff(id)
    local replace_buffs = self._replace_buffs
    if replace_buffs then
        local replace_id = replace_buffs[id] 
        if replace_id then
            return replace_id
        end
    end
    return id
end

function QActor:applyBuff(id, attacker, skill, buff, replace_field)
    if id == nil then
        return
    end

    if self:isDead() == true then
        return
    end

    if skill then
        attacker = skill:getDamager() or attacker
    end

    local id, level = q.parseIDAndLevel(id, 1, skill)
    if attacker then
        id = attacker:_tryReplaceBuff(id)
    end

    local newBuff = QBuff.new(id, self, attacker, level, skill, replace_field)

    if self:isSupport() and (newBuff.effects.can_use_skill == false or newBuff.effects.can_cast_spell == false or newBuff.effects.can_charge_or_blink == false) then
        return
    end

    -- check if any existing buff immune the status new buff brings?
    local newBuffImmuned = false
    for i, buff in ipairs(self._buffs) do
        if buff:isImmuneBuff(newBuff) then
            newBuffImmuned = true
            break
        end
    end
    if newBuffImmuned then
        newBuff:setImmuned(true)
        if self._lastImmunedTime == nil or app.battle:getTime() - self._lastImmunedTime > 0.5 then
            self._lastImmunedTime = app.battle:getTime()
            if not newBuff:hideImmuneWord() then
                self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = "免疫", 
                    rawTip = {
                        isHero = self:getType() ~= ACTOR_TYPES.NPC, 
                        isImmune = true,
                        number = 0
                    }})
            end
        end
        return
    end

    -- check if have same exclusive group buff
    -- re-caculate damage if it is a 
    if newBuff:hasOverrideGroup() then
        for i, buff in ipairs(self._buffs) do
            local override, replace = newBuff:canOverride(buff)
            if override then
                if replace then
                    if newBuff.effects.interval_time > 0.0 then
                        local leftPrecent = 1.0 - buff:getCurrentExecuteCount() / buff:getExecuteCount()
                        newBuff:setPhysicalDamageValue(newBuff:getPhysicalDamageValue() + buff:getPhysicalDamageValue() * leftPrecent)
                        newBuff:setMagicDamageValue(newBuff:getMagicDamageValue() + buff:getMagicDamageValue() * leftPrecent)
                        newBuff:setMagicTreatValue(newBuff:getMagicTreatValue() + buff:getMagicTreatValue() * leftPrecent)
                        newBuff:setRageValue(newBuff:getRageValue() + buff:getRageValue() * leftPrecent)
                        newBuff:setMagicTreatPercent(newBuff:getMagicTreatPercent() + buff:getMagicTreatPercent() * leftPrecent)
                        for i = 1, 10 do
                            newBuff:setEffectValueByIndex(i, newBuff:getEffectValueByIndex(i) + buff:getEffectValueByIndex(i))
                        end
                    end
                    if buff:getAbsorbDamageValue() > 0 then 
                        newBuff:setAbsorbDamageValue(newBuff:getAbsorbDamageValue() + buff:getAbsorbDamageValue()) -- buff:getAbsorbDamageValue() 本身就是剩余值
                    end
                    self:removeBuffByIndex(i)
                else
                    if newBuff.effects.interval_time > 0.0 then
                        buff:setPhysicalDamageValue(newBuff:getPhysicalDamageValue() + buff:getPhysicalDamageValue() * leftPrecent)
                        buff:setMagicDamageValue(newBuff:getMagicDamageValue() + buff:getMagicDamageValue() * leftPrecent)
                        buff:setMagicTreatValue(newBuff:getMagicTreatValue() + buff:getMagicTreatValue() * leftPrecent)
                        buff:setRageValue(newBuff:getRageValue() + buff:getRageValue() * leftPrecent)
                        buff:setMagicTreatPercent(newBuff:getMagicTreatPercent() + buff:getMagicTreatPercent() * leftPrecent)
                        for i = 1, 10 do
                            buff:setEffectValueByIndex(i, newBuff:getEffectValueByIndex(i) + buff:getEffectValueByIndex(i))
                        end
                        buff:restart()
                    end
                    if newBuff:getAbsorbDamageValue() > 0 then 
                        buff:setAbsorbDamageValue(newBuff:getAbsorbDamageValue() + buff:getAbsorbDamageValue()) -- buff:getAbsorbDamageValue() 本身就是剩余值
                    end
                    return
                end
                break
            end
        end
    end

    -- check if have same buff id
    local stack_number = newBuff:getStackNumber()
    local same_buffs = {}
    if stack_number <= 1 then
        for i, buff in ipairs(self._buffs) do
            if newBuff:getId() == buff:getId() then
                newBuff:setOldBuffScale(self:getSizeScale(buff))
                self:removeBuffByIndex(i, true)
                break
            end
        end
    else
        local oldest_index = nil
        for i, buff in ipairs(self._buffs) do
            if newBuff:getId() == buff:getId() then
                if oldest_index == nil then
                    oldest_index = i
                end
                table.insert(same_buffs, buff)
            end
        end
        -- stack full event
        if newBuff:checkCondition(newBuff.TRIGGER_CONDITION_STACK_FULL) and stack_number == (#same_buffs + 1) then
            self:_triggerAlreadyAppliedBuff(newBuff, newBuff.TRIGGER_CONDITION_STACK_FULL, attacker, nil, nil)
            if newBuff:isAutoClear() then
                for _, buffToRemove in ipairs(same_buffs) do
                    self:removeBuffByInstance(buffToRemove, true)
                end
                return
            end
            -- return
        elseif newBuff:checkCondition(newBuff.TRIGGER_CONDITION_ATTACKER_STACK_FULL) and stack_number <= (#same_buffs + 1) and attacker then
            attacker:_triggerAlreadyAppliedBuff(newBuff, newBuff.TRIGGER_CONDITION_ATTACKER_STACK_FULL, self, nil, nil)
            if newBuff:isAutoClear() then
                for _, buffToRemove in ipairs(same_buffs) do
                    self:removeBuffByInstance(buffToRemove, true)
                end
                return
            end
        end
        local over = #same_buffs >= stack_number
        local count = 1
        local count_total = math.min(#same_buffs + 1, stack_number)
        if over then --这里先移除因为在remove的时候也会刷新最后一层特效
            newBuff:setOldBuffScale(self:getSizeScale(self._buffs[oldest_index]))
            self:removeBuffByIndex(oldest_index, true)
        end
        for _, buff in ipairs(same_buffs) do
            -- 更新堆叠层数
            buff:setStackCount(count, count_total)
            count = count + 1
            -- 下层buff特效消失
            buff:mute()
            -- 下层buff持续时间刷新
            buff:rewind()
            self:dispatchEvent({name = QActor.BUFF_MUTED, buff = buff})
        end
        -- 设置新buff的堆叠层数，层数可能会与特效的选择有关联
        newBuff:setStackCount(count, count_total)
    end

    self:setSizeScale(newBuff:getOldBuffScale(),newBuff) --立刻让oldScale生效

    -- check if replace actor view
    if newBuff.effects.replace_character ~= -1 and newBuff.effects.replace_character ~= self._replaceCharacterId then
        self._target_before_replace_ai = self:getTarget()
        
        local characterId = newBuff.effects.replace_character
        local properties = db:getCharacterByID(characterId)
        local npc_skill = properties.npc_skill
        local npc_skill2 = properties.npc_skill2
        if IsServerSide then
            app.battle:replaceActorViewWithCharacterId(self, newBuff.effects.replace_character)
        else
            app.scene:replaceActorViewWithCharacterId(self, newBuff.effects.replace_character)
        end
        if self:getType() == ACTOR_TYPES.NPC then
            if npc_skill and db:getSkillByID(npc_skill) then
                local talent_skill_1 = self:getTalentSkill()
                if talent_skill_1 then
                    self._skills[talent_skill_1:getId()] = nil
                end
                local talent_skill_2 = self:getTalentSkill2()
                if talent_skill_2 then
                    self._skills[talent_skill_2:getId()] = nil
                end
                if db:getSkillByID(npc_skill) ~= nil then 
                    if self._skills[npc_skill] == nil then
                        self._skills[npc_skill] = QSkill.new(npc_skill, db:getSkillByID(npc_skill), self)
                    end
                end
                if db:getSkillByID(npc_skill2) ~= nil then 
                    if self._skills[npc_skill2] == nil then
                        self._skills[npc_skill2] = QSkill.new(npc_skill2, db:getSkillByID(npc_skill2), self) 
                    end
                end
                self._replaceCharacterTalentSkill = {talentSkill1 = self._skills[npc_skill], talentSkill2 = self._skills[npc_skill2]}
            end
            local skillIdsForAi = self:getSkillIdWithAiType(properties.npc_ai)
            for _, skillId in ipairs(skillIdsForAi) do
                if self._skills[skillId] == nil then
                    local id, level = self:_parseSkillID(skillId)
                    if id and level then
                        self._skills[id] = QSkill.new(id, db:getSkillByID(id), self, level)
                    end
                end
            end

            if newBuff:getRelaceCharacterSkills() then
                self._replace_character_skill_lists[newBuff] = {}
                local replace_skill_list = string.split(newBuff:getRelaceCharacterSkills(), ";")
                for i,info in ipairs(replace_skill_list) do
                    local _s = string.split(info, ",")
                    local oldSkill, newSkill = tonumber(_s[1]), tonumber(_s[2])
                    if self._skills[oldSkill] then
                        local level = self._skills[oldSkill]:getSkillLevel()
                        local skill = QSkill.new(newSkill, {}, self, level)
                        skill:coolDown()
                        self._replace_character_skill_lists[newBuff][skill] = self._skills[oldSkill]
                        self._skills[oldSkill] = nil
                        self._skills[newSkill] = skill
                    end
                end
            end

            self._manualSkills = {}
            self._activeSkills = {}
            self._passiveSkills = {}
            self:_classifySkillByType()
            self:_cancelCurrentSkill()
            self:resetNextAttackSkill()
        elseif self:getType() == ACTOR_TYPES.HERO_NPC or self:getType() == ACTOR_TYPES.HERO then
            if npc_skill and db:getSkillByID(npc_skill) then
                local talent_skill_1 = self:getTalentSkill()
                if talent_skill_1 then
                    self._skills[talent_skill_1:getId()] = nil
                end
                local talent_skill_2 = self:getTalentSkill2()
                if talent_skill_2 then
                    self._skills[talent_skill_2:getId()] = nil
                end
                if db:getSkillByID(npc_skill) ~= nil then 
                    if self._skills[npc_skill] == nil then
                        self._skills[npc_skill] = QSkill.new(npc_skill, db:getSkillByID(npc_skill), self)
                    end
                end
                if db:getSkillByID(npc_skill2) ~= nil then 
                    if self._skills[npc_skill2] == nil then
                        self._skills[npc_skill2] = QSkill.new(npc_skill2, db:getSkillByID(npc_skill2), self) 
                    end
                end
                self._replaceCharacterTalentSkill = {talentSkill1 = self._skills[npc_skill], talentSkill2 = self._skills[npc_skill2]}
            end

            if newBuff:getRelaceCharacterSkills() then
                self._replace_character_skill_lists[newBuff] = {}
                local replace_skill_list = string.split(newBuff:getRelaceCharacterSkills(), ";")
                for i,info in ipairs(replace_skill_list) do
                    local _s = string.split(info, ",")
                    local oldSkill, newSkill = tonumber(_s[1]), tonumber(_s[2])
                    if self._skills[oldSkill] then
                        local level = self._skills[oldSkill]:getSkillLevel()
                        local skill = QSkill.new(newSkill, {}, self, level)
                        skill:coolDown()
                        self._replace_character_skill_lists[newBuff][skill] = self._skills[oldSkill]
                        self._skills[oldSkill] = nil
                        self._skills[newSkill] = skill
                    end
                end
            end

            self._manualSkills = {}
            self._activeSkills = {}
            self._passiveSkills = {}
            self:_classifySkillByType()
            self:_cancelCurrentSkill()
            self:resetNextAttackSkill()
        end

        if newBuff:getReplaceCharacterEnterSkill() then
            local skillId,level = q.parseIDAndLevel(newBuff:getReplaceCharacterEnterSkill(), 1, nil, newBuff)
            if self._skills[skillId] == nil then
                self._skills[skillId] = QSkill.new(skillId, {}, self, level)
            end
            self:attack(self._skills[skillId], nil, nil, true)
        end

    elseif string.len(newBuff.effects.replace_ai) > 0 then
        self._target_before_replace_ai = self:getTarget()

        app.battle:replaceActorAIAndPosition(self, newBuff.effects.replace_ai)
    end

    -- check have absorb
    local absorbValue = newBuff:getAbsorbDamageValue()
    if nil ~= absorbValue and absorbValue > 0 then
        self:dispatchAbsorbChangeEvent(absorbValue)
        if ENABLE_DEBUG_ABSORB and attacker and skill then
            local _type = attacker:getType()
            if _type == ACTOR_TYPES.HERO or _type == ACTOR_TYPES.HERO_NPC then
                app.battle._battleLog:onHeroDoAbsorb(attacker:getActorID(), absorbValue, attacker, nil, skill)
            else
                app.battle._battleLog:onEnemyDoAbsorb(attacker:getActorID(), absorbValue, attacker, nil, skill)
            end
        end
    end

    -- check if can move
    if newBuff.effects.can_control_move == false and not self:isBlowingup() and not self:isBeatbacking() then
        self:stopMoving()
    end

    -- check if is using skill
    if newBuff.effects.can_use_skill == false then
        self:_cancelCurrentSkillByOther()
    elseif newBuff.effects.can_cast_spell == false then
        local current_skill = self._currentSkill
        if current_skill and not current_skill:isTalentSkill() and current_skill:getDamageType() == current_skill.MAGIC then
            self:_cancelCurrentSkillByOther()
        end
    end

    -- check if all pause
    if newBuff.effects.time_stop == true then
        self:inTimeStop(true)
    end

    if newBuff.effects.lock_hp then
        self:setLockHp(true)
    end

    local value = newBuff.effects.adaptivity_helmet
    if value ~= 0 then
        self:setAdaptivityHelmet(value)
    end

    -- check if immune physical/magic damage
    if newBuff:isImmunePhysicalDamage() then
        self._immune_physical_damage = self._immune_physical_damage + 1
    end
    if newBuff:isImmuneMagicDamage() then
        self._immune_magic_damage = self._immune_magic_damage + 1
    end
    
    if not newBuff:isImmuned() and not newBuff:isAura() then
        newBuff:applyStatusForActor()
    end

    self._buff_effect_reduce = self._buff_effect_reduce + newBuff:getBuffEffectReduce()
    self._buff_effect_reduce_from_other = self._buff_effect_reduce_from_other + newBuff:getBuffFromOtherEffectReduce()


    -- drain blood physical/magic
    self._drainBloodPhysical = self._drainBloodPhysical + newBuff:get("drain_blood_physical")
    self._drainBloodMagic = self._drainBloodMagic + newBuff:get("drain_blood_magic")

    self:setNeutralizeDamage(newBuff:getNeutralizeDamage())
    
    table.insert(self._buffs, newBuff)

    if newBuff:isControlBuff() then
        if attacker then
            attacker:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_CONTROL, self, QBuff.TRIGGER_TARGET_SELF)
        end
        self:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_BE_CONTROLED, self, QBuff.TRIGGER_TARGET_SELF)
    end

    local bufferEventListener = cc.EventProxy.new(newBuff)
    bufferEventListener:addEventListener(newBuff.TRIGGER, handler(self, self._onBuffTrigger))
    table.insert(self._buffEventListeners, bufferEventListener)

    if attacker ~= nil then
        table.insert(self._buffAttacker, {buffId = id, attackerUDID = attacker:getUDID()})
    end

    self:dispatchEvent({name = QActor.BUFF_STARTED, buff = newBuff})

    if attacker and newBuff:getAbsorbDamageValue() > 0 then
        attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_TREATING, self, newBuff:getAbsorbDamageValue()) -- 治疗的瞬间

        if skill == nil or skill:ignoreSaveTreat() == false then
            local save_value = newBuff:getAbsorbDamageValue()
            for i,buff in pairs(attacker:getBuffs()) do
                if buff:isSaveTreat() and buff:getSaveTreatTarget() == "attacker" then
                    buff:saveTreat(save_value)
                end
            end

            for i,buff in pairs(self:getBuffs()) do
                if buff:isSaveTreat() and buff:getSaveTreatTarget() == "attackee" then
                    buff:saveTreat(save_value)
                end
            end
        end
    end

    return newBuff
end

function QActor:removeBuffByIndex(index, ignore_custom_event)
    if index == nil then
        return
    end

    if table.nums(self._buffs) < index then
        return
    end

    local buff = self._buffs[index]
    if buff == nil then
        return
    end

    -- check if replace actor view
    if not buff:isImmuned() then
        if buff.effects.replace_character ~= -1 then
            if not buff.effects.keep_replace_character then
                if IsServerSide then
                    app.battle:replaceActorViewWithCharacterId(self, nil)
                else
                    app.scene:replaceActorViewWithCharacterId(self, nil)
                end
                self._replaceCharacterId = nil
            end

            -- 张南:太阳井要求魂师在被恐惧之后还能够攻击原来的目标，所以这里是一个hack
            if app.battle:isPVPMode() and app.battle:isInSunwell() then
                if self._target_before_replace_ai and not self._target_before_replace_ai:isDead() then
                    self:setTarget(self._target_before_replace_ai)
                    self._target_before_replace_ai = nil
                end
            end

            if self._replace_character_skill_lists[buff] then
                for newSkill,oldSkill in pairs(self._replace_character_skill_lists[buff]) do
                    self._skills[newSkill:getId()] = nil
                    self._skills[oldSkill:getId()] = oldSkill
                end
                self._replace_character_skill_lists[buff] = nil
            end

            if self._replaceCharacterTalentSkill then
                local talent_skill_1 = self:getTalentSkill()
                if talent_skill_1 then
                    self._skills[talent_skill_1:getId()] = nil
                end
                local talent_skill_2 = self:getTalentSkill2()
                if talent_skill_2 then
                    self._skills[talent_skill_2:getId()] = nil
                end
                self._replaceCharacterTalentSkill = nil
                local talent_skill_1 = self:getTalentSkill()
                if talent_skill_1 then
                    self._skills[talent_skill_1:getId()] = talent_skill_1
                end
                local talent_skill_2 = self:getTalentSkill2()
                if talent_skill_2 then
                    self._skills[talent_skill_2:getId()] = talent_skill_2
                end
            end
            self._manualSkills = {}
            self._activeSkills = {}
            self._passiveSkills = {}
            self:_classifySkillByType()
            self:_cancelCurrentSkill()
            self:resetNextAttackSkill()
        end
        if string.len(buff.effects.replace_ai) > 0 then
            app.battle:replaceActorAIAndPosition(self, nil)

            -- 张南:太阳井要求魂师在被恐惧之后还能够攻击原来的目标，所以这里是一个hack
            if app.battle:isPVPMode() and app.battle:isInSunwell() then
                if self._target_before_replace_ai and not self._target_before_replace_ai:isDead() then
                    self:setTarget(self._target_before_replace_ai)
                    self._target_before_replace_ai = nil
                end
            end
        end
        if buff:isAbsorbDamage() then
            local damage =buff:getAbsorbDamageValue()
            self:dispatchAbsorbChangeEvent(-damage)
        end
    end

    -- check if all pause
    if not buff:isImmuned() then
        if buff.effects.time_stop == true then
            self:inTimeStop(false)
        end
        if buff.effects.lock_hp == true then
            self:setLockHp(false)
        end
        local value = buff.effects.adaptivity_helmet
        if value ~= 0 then
            self:setAdaptivityHelmet(-value)
        end
        self:setNeutralizeDamage(-buff:getNeutralizeDamage())
    end

    if not buff:isImmuned() and not buff:isAura() then
        buff:removeStatusForActor()
    end

    -- check if immune physical/magic damage
    if not buff:isImmuned() then
        if buff:isImmunePhysicalDamage() then
            self._immune_physical_damage = self._immune_physical_damage - 1
        end
        if buff:isImmuneMagicDamage() then
            self._immune_magic_damage = self._immune_magic_damage - 1
        end
    end

    -- drain blood physical/magic
    self._drainBloodPhysical = self._drainBloodPhysical - buff:get("drain_blood_physical")
    self._drainBloodMagic = self._drainBloodMagic - buff:get("drain_blood_magic")
    self._buff_effect_reduce = self._buff_effect_reduce - buff:getBuffEffectReduce()
    self._buff_effect_reduce_from_other = self._buff_effect_reduce_from_other - buff:getBuffEffectReduce()

    local bufferEventListener = self._buffEventListeners[index]
    self:dispatchEvent({name = QActor.BUFF_ENDED, buff = buff})
    if bufferEventListener then
        bufferEventListener:removeAllEventListeners()
        table.remove(self._buffEventListeners, index)
    end
    table.remove(self._buffs, index)
    table.remove(self._buffAttacker, index)

    local same_buffs = {}
    local oldest_index = nil
    local remoev_id = buff:getId()
    for i, buff in ipairs(self._buffs) do
        if remoev_id == buff:getId() then
            if oldest_index == nil then
                oldest_index = i
            end
            table.insert(same_buffs, buff)
        end
    end

    if oldest_index ~= nil then
        local oldestBuff = same_buffs[#same_buffs]
        local count = 1
        for _, buff in ipairs(same_buffs) do
            -- 更新堆叠层数
            buff:setStackCount(count)
            count = count + 1
            -- 下层buff特效消失
            buff:mute()
            self:dispatchEvent({name = QActor.BUFF_MUTED, buff = buff})
        end
        oldestBuff._muted = false
        self:dispatchEvent({name = QActor.BUFF_STARTED, buff = oldestBuff, is_remove = true})
    end

    --触发buff移除的自定义事件，这个一定要放到remove后面 防止有些情况下会造成死循环
    if not ignore_custom_event then
        for i, cfg in ipairs(self._custom_event_list) do
            if cfg.obj == buff then
                if cfg and cfg.name == QActor.CUSTOM_EVENT_BUFF_REMOVE_WHEN_DEATH and self:getHp() <= 0 then
                    cfg.callback()
                end
            end
        end
        for _,listener in ipairs(self._custom_event_list) do
            if listener.name == QActor.CUSTOM_EVENT_BUFF_REMOVE and listener.buff_id == buff:getId() then
                listener.callback()
            end
        end
    end

    if buff:getId() == global.attack_mark_effect then
        self._isMarked = false
    end

    if not buff:isImmuned() then
        buff:onRemove()
    end
end

function QActor:removeBuffByID(id, ignore_custom_event)
    if id == nil then
        return
    end

    for i, buff in ipairs(self._buffs) do
        if buff:getId() == id then
            self:removeBuffByIndex(i, ignore_custom_event)
            return
        end
    end
end

function QActor:removeSameBuffByID(id, ignore_custom_event)
    if id == nil then
        return
    end

    for i = #self._buffs, 1, -1 do
        if self._buffs[i]:getId() == id then
            self:removeBuffByIndex(i, ignore_custom_event)
        end
    end
end

function QActor:removeBuffByInstance(buffInstance, ignore_custom_event)
    if buffInstance == nil then
        return
    end

    for i, buff in ipairs(self._buffs) do
        if buff == buffInstance then
            self:removeBuffByIndex(i, ignore_custom_event)
            return
        end
    end
end

function QActor:removeBuffByStatus(status, ignore_custom_event)
    if status == nil then
        return
    end

    local buffs = self._buffs
    local count = #buffs
    local index = 1
    while true do
        local buff = buffs[index]
        if buff == nil then
            break
        elseif buff:hasStatus(status) then
            self:removeBuffByIndex(index, ignore_custom_event)
        else
            index = index + 1
        end
    end
end

function QActor:removeAllBuff()
    while table.nums(self._buffs) > 0 do
        self:removeBuffByIndex(1)
    end
end

function QActor:_runBuff(dt)
    for _, buff in ipairs(self._buffs) do
        if not buff:isImmuned() then
            buff:visit(dt)
        end
    end

    local buffs = self._buffs
    local len = #buffs
    local buff = nil
    local end_list = {}
    for i = 1, len do
        buff = buffs[i]
        if buff == nil then
            break
        elseif buff:isEnded() then
            self:removeBuffByIndex(i)
            table.insert(end_list, buff)
            i = i - 1
        end
    end

    for i,buff in ipairs(end_list) do
        self:_buffEnded(buff)
        buff:onBuffEnd()
    end
end

function QActor:_buffEnded(buff)
    local actor = buff:getAttacker()
    if actor then
        actor:_onBuffRemoved(buff)
    end
end

function QActor:_onBuffRemoved(buff)
    if buff:isImmuned() then return end
    if buff:isSaveDamage() then
        local attackee = buff:getBuffOwner()
        local save_damgage,damage_type = buff:calcSaveDamage()
        local is_immuned = false
        if damage_type == QSkill.PHYSICAL and attackee:isImmunePhysicalDamage() then
            is_immuned = true
            attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_IMMUNE_PHYSICAL_DAMAGE, self, QBuff.TRIGGER_TARGET_SELF)
        elseif damage_type == QSkill.MAGIC and attackee:isImmuneMagicDamage() then
            is_immuned = true
            attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_IMMUNE_MAGIC_DAMAGE, self, QBuff.TRIGGER_TARGET_SELF)
        end
        if save_damgage > 0 and is_immuned == false then
            local _, damage, absorb = attackee:decreaseHp( save_damgage, self, buff:getSkill())
            if absorb > 0 then
                local absorb_tip = "吸收 "
                attackee:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
                    isHero = attackee:getType() ~= ACTOR_TYPES.NPC, 
                    isDodge = false, 
                    isBlock = false, 
                    isCritical = false, 
                    isTreat = false,
                    isAbsorb = true, 
                    number = math.ceil(absorb),
                }})
            end
            attackee:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip_modifiers = {},
                isCritical = false, tip = "", rawTip = {
                    isHero = attackee:getType() ~= ACTOR_TYPES.NPC,
                    isDodge = false,
                    isBlock = false,
                    isCritical = false,
                    isTreat = false,
                    isAbsorb = false,
                    number = math.ceil(damage),
                }})
        end
    end

    local status = buff:getTriggerRemoveSkillStatus()
    if status == nil or status == "" then return end
    for _,skill in pairs(self:getPassiveSkills()) do
        if skill:isReadyAndConditionMet() and skill:getStatus() == status then
            self:triggerAttack(skill, buff:getBuffOwner(), true, nil, buff)
        end
    end
    
end

function QActor:_getAttackerUDIDWithBuffId(buffId)
    if buffId == nil then
        return nil
    end
    for _, item in ipairs(self._buffAttacker) do
        if item.buffId == buffId then
            return item.attackerUDID
        end
    end
    return nil
end

function QActor:_projectDrainBloodBall(buff, hp)
    local drainer = buff:getAttacker()
    if hp == 0 or not drainer or drainer:isDead() then
        return
    end

    local bullet = QBullet.new(self, {drainer}, nil, {effect_id = "vampiric_3", is_not_loop = true, is_throw = true, from_target = true, hp = hp})
    app.battle:addBullet(bullet)
end

function QActor:_onBuffTrigger(event)
    if app.battle:hasWinOrLose() then
        return
    end

    if app.battle:isPausedBetweenWave() == true then
        return
    end
    
    local buff = event.buff
    if buff == nil then
        return
    end

    if buff:isImmuned() then
        return
    end

    local value = 0
    local absorb = 0
    local immune_physical_damage = self:isImmunePhysicalDamage()
    local immune_magic_damage = self:isImmuneMagicDamage()
    if self:isDead() == false and buff:getPhysicalDamageValue(self) ~= 0 then
        if immune_physical_damage then
            if buff:isDrainBlood() then
                self:removeBuffByID(buff:getId())
            else
                self:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_IMMUNE_PHYSICAL_DAMAGE, buff:getAttacker(), QBuff.TRIGGER_TARGET_SELF)
                self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = global.immune_physical})
            end
        else
            if buff:getDotGrowCoefficient() > 0 then
                value = buff:getDotGrowValue(buff:getPhysicalDamageValue(self))
            else
                value = buff:getPhysicalDamageValue(self) / buff:getExecuteCount()
            end
            local critical = false
            if buff:getAttacker() then
                local finalCrit = calcFinalCrit(buff:getAttacker(), self)
                if app.random(1, 100) < finalCrit then
                    value = value * buff:getAttacker():getCritDamage(self)
                    critical = true
                end
            end
            -- 海神岛伤害系数
            value = value * app.battle:getDamageCoefficient()
            value = math.ceil(value)
            -- printInfo("buff PhysicalDamageValue " .. tostring(value))
            -- aoe伤害系数
            if event.isAura then
                value = value * (1 + buff:getAttacker():getAOEAttackPercent())
            end

            if not self:isBoss() and not self:isEliteBoss() then
                buff:getAttacker():triggerPassiveSkill(QSkill.TRIGGER_CONDITION_DAMAGE, self, value, nil, buff)
            end
            _, value, absorb = self:decreaseHp(value, buff:getAttacker(), buff:getSkill(), nil, event.isAura)
            if absorb > 0 then
                local absorb_tip = "吸收 "
                self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
                    isHero = self:getType() ~= ACTOR_TYPES.NPC, 
                    isDodge = false, 
                    isBlock = false, 
                    isCritical = false, 
                    isTreat = false,
                    isAbsorb = true, 
                    number = absorb
                }})
            end
            if value > 0 then
                local tip = critical and "暴击 " or ""
                self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, isCritical = critical, tip = tip .. tostring(math.floor(value)),
                    rawTip = {
                        isHero = self:getType() ~= ACTOR_TYPES.NPC, 
                        isDodge = false, 
                        isBlock = false, 
                        isCritical = critical, 
                        isTreat = false, 
                        number = value
                    }})
            end
            -- app.battle:addDamageHistory(self:_getAttackerUDIDWithBuffId(buff:getId()), value, buff:getId())

            -- 发射吸血球
            if buff:isDrainBlood() then
                self:_projectDrainBloodBall(buff, value + absorb)
            end

            -- 触发hit condition
            self:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT, buff:getAttacker(), value, nil, buff, nil)
            self:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT_PHYSICAL, buff:getAttacker(), value, nil, buff, nil)
        end
    end

    if self:isDead() == false and buff:getMagicDamageValue(self) ~= 0 then
        if immune_magic_damage then
            if buff:isDrainBlood() then
                self:removeBuffByID(buff:getId())
            else
                self:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_IMMUNE_MAGIC_DAMAGE, buff:getAttacker(), QBuff.TRIGGER_TARGET_SELF)
                self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, tip = global.immune_magic})
            end
        else
            if buff:getDotGrowCoefficient() > 0 then
                value = buff:getDotGrowValue(buff:getMagicDamageValue(self))
            else
                value = buff:getMagicDamageValue(self) / buff:getExecuteCount()
            end
            local critical = false
            if buff:getAttacker() then
                local finalCrit = calcFinalCrit(buff:getAttacker(), self)
                if app.random(1, 100) < finalCrit then
                    value = value * buff:getAttacker():getCritDamage(self)
                    critical = true
                end
            end
            -- 海神岛伤害系数
            value = value * app.battle:getDamageCoefficient()
            value = math.ceil(value)
            -- aoe伤害系数
            if event.isAura then
                value = value * (1 + buff:getAttacker():getAOEAttackPercent())
            end
            if not self:isBoss() and not self:isEliteBoss() then
                buff:getAttacker():triggerPassiveSkill(QSkill.TRIGGER_CONDITION_DAMAGE, self, value, nil, buff)
            end
            _, value, absorb = self:decreaseHp(value, buff:getAttacker(), buff:getSkill(), nil, event.isAura, nil, not buff:isAddToLog())
            if absorb > 0 then
                local absorb_tip = "吸收 "
                self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
                    isHero = self:getType() ~= ACTOR_TYPES.NPC, 
                    isDodge = false, 
                    isBlock = false, 
                    isCritical = false, 
                    isTreat = false,
                    isAbsorb = true, 
                    number = absorb
                }})
            end
            if value > 0 then
                local tip = critical and "暴击 " or ""
                self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, isCritical = critical, tip = tip .. tostring(math.floor(value)),
                    rawTip = {
                        isHero = self:getType() ~= ACTOR_TYPES.NPC, 
                        isDodge = false, 
                        isBlock = false, 
                        isCritical = critical, 
                        isTreat = false, 
                        number = value
                    }})
            end
            -- app.battle:addDamageHistory(self:_getAttackerUDIDWithBuffId(buff:getId()), value, buff:getId())

            -- 发射吸血球
            if buff:isDrainBlood() then
                self:_projectDrainBloodBall(buff, value + absorb)
            end

            -- 触发hit condition
            self:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT, buff:getAttacker(), value, nil, buff, nil)
            self:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT_MAGIC, buff:getAttacker(), value, nil, buff, nil)
        end
    end
    
    if self:isDead() == false and buff:getMagicTreatValue(self) ~= 0 then
        if buff:getDotGrowCoefficient() > 0 then
            value = buff:getDotGrowValue(buff:getMagicTreatValue(self))
        else
            value = buff:getMagicTreatValue(self) / buff:getExecuteCount()
        end
        local critical = false
        if buff:getAttacker() then
            local finalCrit = calcFinalCrit(buff:getAttacker(), self)
            if app.random(1, 100) < finalCrit then
                value = value * buff:getAttacker():getCritDamage(self)
                critical = true
            end
        end
        value = math.ceil(value)
        local _, value = self:increaseHp(value, buff:getAttacker(), buff:getSkill())
        if value > 0 then
            local tip = critical and "暴击 " or ""
            self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = true, isCritical = critical, tip = tip .. "+" .. tostring(math.floor(value)),
                    rawTip = {
                        isHero = self:getType() ~= ACTOR_TYPES.NPC, 
                        isDodge = false, 
                        isBlock = false, 
                        isCritical = critical, 
                        isTreat = true, 
                        number = value
                    }})
        end
        -- app.battle:addTreatHistory(self:_getAttackerUDIDWithBuffId(buff:getId()), value, buff:getId())
    end

    if self:isDead() == false and buff:getMagicTreatPercent() ~= 0 then
        if buff:getDotGrowCoefficient() > 0 then
            value = buff:getDotGrowValue(buff:getMagicTreatPercent())
        else
            value = buff:getMagicTreatPercent() / buff:getExecuteCount()
        end
        value = math.ceil(value * self:getMaxHp())
        local _, value = self:increaseHp(value, buff:getAttacker(), buff:getSkill())
        if value > 0 then
            self:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = true, isCritical = false, tip = "+" .. tostring(math.floor(value)),
                    rawTip = {
                        isHero = self:getType() ~= ACTOR_TYPES.NPC, 
                        isDodge = false, 
                        isBlock = false, 
                        isCritical = false, 
                        isTreat = true, 
                        number = value
                    }})
        end
        -- app.battle:addTreatHistory(self:_getAttackerUDIDWithBuffId(buff:getId()), value, buff:getId())
    end

    if self:isDead() == false and buff:getRageValue() ~= 0 then
        if buff:getDotGrowCoefficient() > 0 then
            value = buff:getDotGrowValue(buff:getRageValue())
        else
            value = buff:getRageValue() / buff:getExecuteCount()
        end
        self:changeRage(value)
    end

    if self:isDead() == false then
        if not IsServerSide then
            local actorView = app.scene:getActorViewFromModel(self)
            if actorView then
                actorView:_onBuffTrigger(event)
            end
        end
    end
end

--[[ 
    func is invoke after effect animation complete if it is not a nil value
    options: 
        isFlipX
        isLoop
        isRandomPosition
        targetPosition
        isAttackEffect
        skillId
        rotateToPosition
--]]
function QActor:playSkillEffect(effectID, func, options)
    if effectID == nil then
        return
    end
    self:dispatchEvent({name = QActor.PLAY_SKILL_EFFECT, effectID = effectID, callFunc = func, options = options})
end

function QActor:stopSkillEffect(effectID)
    if effectID == nil then
        return
    end
    self:dispatchEvent({name = QActor.STOP_SKILL_EFFECT, effectID = effectID})
end

function QActor:onAttackFinished(isCanceled, skill)
    if self._currentSkill ~= nil and self:getTarget() then
        -- 将攻击方也放入hitlog，用于保持战斗的持续性。
        self._hitlog:addNewHit(self:getTarget():getId(), QHitLog.NO_DAMAGE, self._currentSkill:getId(), self:getTarget():getTalentHatred())
    end

    if self._currentSkill ~= nil and self._currentSkill:isNeedATarget() == true then
        self._lastAttackee = self._target
    end

    local target, isCaptureRage = nil, nil

    if self._currentSBDirector ~= nil then
       target = self._currentSBDirector:getTarget()
    end

    if target then isCaptureRage = target:isUnderStatus("capture_rage") end

    -- 技能释放完毕获得怒气
    if self._currentSkill ~= nil and self:hasRage() and not isCanceled then
        local gainRage = self._rageInfo.skill_coefficient * self._currentSkill:getRageGain()
        if target and isCaptureRage then
            target:_changeRage(gainRage)
        else
            self:_changeRage(gainRage)
        end
    end

    if self._currentSkill ~= nil then
        local rageSkillGainPercent = math.clamp(1, self:_getActorNumberPropertyValue("rage_skill_gain_percent"), -1)
        if self._currentSkill == self:getTalentSkill() or self._currentSkill == self:getTalentSkill2() then
            self:_changeRage(self:getActorPropValue("normal_skill_rage_gain") * (1 + rageSkillGainPercent))
            if target then
                target:_changeRage(-self:getActorPropValue("normal_skill_rage_reduce"))
            end
        end
        if self._currentSkill:getSkillType() == QSkill.ACTIVE then
            self:_changeRage(self:getActorPropValue("active_skill_rage_gain"))
        end
    end

    if isCanceled ~= true then
        self._currentSkill = nil
        self._currentSBDirector = nil
    end

    if self:isForceAuto() and self:getManualMode() ~= QActor.AUTO and not isCanceled then
        if self.gridPos then
            local targetPos = app.grid:_toScreenPos(self.gridPos)
            if q.is2PointsClose(self:getPosition(), targetPos) then
                self:setManualMode(QActor.AUTO)
            end
        end
    end

    if self:isDead() == false then
        self.fsm__:doEvent("ready")
    end

    if app.battle:isSotoTeam() and self:isCandidate() then
        local appearSkillId = self:getAppearSkillId() or 32002
        if skill:getId() == appearSkillId then
            app.battle:onCandidateHeroEnter(self)
        end
    end

    self:dispatchEvent({name = QActor.SKILL_END, skillId = skill:getId()})
end

function QActor:_runSkill(deltaTime)
    for _, sbDirector in ipairs(self._sbDirectors) do
        sbDirector:visit(deltaTime)
    end

    if nil ~= self._deadBehavior then
        self._deadBehavior:visit(deltaTime)
        if self._deadBehavior:isFinished() == true then
            self._deadBehavior = nil
        end
    end
    
    local index = 1
    while index <= #self._sbDirectors do
        local sbDirector = self._sbDirectors[index]
        if sbDirector:isSkillFinished() == true then
            table.remove(self._sbDirectors, index)
            index = index - 1
        end
        index = index + 1
    end
    if #self._sbDirectors == 0 and self._isDoingDeadSkill then
        self._isDoingDeadSkill = false
    end
end

function QActor:_runOtherDamagerSkill(deltaTime)
    for _, sbDirector in ipairs(self._sbDirectors) do
        local skill = sbDirector:getSkill()
        if skill and skill:getDamager() and skill:getDamager() ~= skill:getActor() then
            sbDirector:visit(deltaTime)
        end
    end
    
    local index = 1
    while index <= table.nums(self._sbDirectors) do
        local sbDirector = self._sbDirectors[index]
        if sbDirector:isSkillFinished() == true then
            table.remove(self._sbDirectors, index)
            index = index - 1
        end
        index = index + 1
    end

    if #self._sbDirectors == 0 and self._isDoingDeadSkill then
        self._isDoingDeadSkill = false
    end
end

function QActor:_runAllowBulletTimeBuff(dt)
    for _, buff in ipairs(self._buffs) do
        if not buff:isImmuned() and buff:isAllowBulletTime() then
            buff:visit(dt)
        end
    end

    local buffs = self._buffs
    local len = #buffs
    local buff = nil
    for i = 1, len do
        buff = buffs[i]
        if buff == nil then
            break
        elseif buff:isEnded() and buff:isAllowBulletTime() then
            self:removeBuffByIndex(i)
            i = i - 1
        end
    end
end

function QActor:_runAllowBulletTimeSkill(dt)
    local sbDirectors = self._sbDirectors

    local skill = nil
    local deadSkillId = self:getDeadSkillID()
    for _, sbDirector in ipairs(sbDirectors) do
        skill = sbDirector:getSkill()
        if skill:isAllowBulletTime() or skill:getId() == deadSkillId then
            sbDirector:visit(dt)
        end
    end
    
    local index = 1
    while index <= #sbDirectors do
        local sbDirector = sbDirectors[index]
        if sbDirector:isSkillFinished() == true and sbDirector:getSkill():isAllowBulletTime() then
            table.remove(sbDirectors, index)
            index = index - 1
        end
        index = index + 1
    end

    if #sbDirectors == 0 and self._isDoingDeadSkill then
        self._isDoingDeadSkill = false
    end
end

function QActor:_cancelCurrentSkill()
    if self._currentSBDirector ~= nil then
        if self._currentSBDirector:isUncancellable() then
            -- 技能虽然被打断，但是可以技能行为任然可以执行下去(暴风雪、暗影箭雨之类的东西)
            if self._currentSkill == self:getTalentSkill() or self._currentSkill == self:getTalentSkill2() then
                self._currentSkill:_stopCd()
            end

            self:dispatchEvent({name = QActor.CANCEL_SKILL, skillId = self._currentSkill:getId()})
            self._currentSBDirector = nil
            self._currentSkill = nil

            self._isDoingDeadSkill = false
        else
            if self._currentSkill == self:getTalentSkill() or self._currentSkill == self:getTalentSkill2() then
                self._currentSkill:_stopCd()
            end

            self:dispatchEvent({name = QActor.CANCEL_SKILL, skillId = self._currentSkill:getId()})
            self._currentSBDirector:cancel()
            table.removebyvalue(self._sbDirectors, self._currentSBDirector)
            self._currentSBDirector = nil
            self._currentSkill = nil

            self._isDoingDeadSkill = false
        end
        self:setAnimationScale(1.0, "label-mark")
    end
end

function QActor:_cancelCurrentSkillByOther()
    if (app.battle:getSupportSkillHero() == self or app.battle:getSupportSkillEnemy() == self) and self._currentSkill == self:getFirstManualSkill() then
        return
    end

    self:_cancelCurrentSkill()
end

function QActor:cancelAllSkills()
    for _, sbDirector in ipairs(self._sbDirectors) do
        self:dispatchEvent({name = QActor.CANCEL_SKILL, skillId = sbDirector:getSkill():getId()})
        sbDirector:cancel()
    end
    self._sbDirectors = {}
    self._currentSBDirector = nil
    self._currentSkill = nil
end

function QActor:_onBattleFrame(event)
    if self:isExile() then return end
    if app.battle:isPVPMultipleWave() then
        if not app.grid:hasActor(self) then
            return
        end
    end

    if self:isSupport() then
        local master = self:getHunterMaster()
        if master == nil then
            if self ~= app.battle:getSupportSkillHero()
                and self ~= app.battle:getSupportSkillHero2()
                and self ~= app.battle:getSupportSkillHero3()
                and self ~= app.battle:getSupportSkillEnemy()
                and self ~= app.battle:getSupportSkillEnemy2()
                and self ~= app.battle:getSupportSkillEnemy3()
            then
                return
            end
        else
            if master ~= app.battle:getSupportSkillHero()
                and master ~= app.battle:getSupportSkillHero2()
                and master ~= app.battle:getSupportSkillHero3()
                and master ~= app.battle:getSupportSkillEnemy()
                and master ~= app.battle:getSupportSkillEnemy2()
                and master ~= app.battle:getSupportSkillEnemy3()
            then
                return
            end
        end
    end
    if self:isCandidate() then
        if not self._candidate then
            return
        end
    end

    self:_validateProperty()

    if app.battle:isPauseRecord() then
        return
    end

    -- if self:getType() == ACTOR_TYPES.HERO then
    --     printf(string.format("hero position: %d, %d", self:getPosition().x, self:getPosition().y))
    -- end

    -- update skill cd
    if not app.battle:isInBulletTime() then
        for _, skill in pairs(self._skills) do
            skill:update(event.deltaTime)
        end
    end

    -- 更新自动释放设置的生效
    self:_updateForceAuto()
    -- 更新战斗操作的生效
    self:_updateActionEvents()

    self:updateAnimation(event.deltaTime)

    -- 更新忽略伤害的目标
    if self._ignoreHurtArgs then
        self:_updateIgnoreHurtTarget()
    end

    -- if self._isInBulletTime == true then
    --     if app.battle:isInArena() then
    --         -- 斗魂场中对额外标记的buff和skill可以跑
    --         self:_runAllowBulletTimeBuff(event.deltaTime)
    --         self:_runAllowBulletTimeSkill(event.deltaTime)
    --     end
    --     return
    -- end

    if app.battle:isInArena() then
        if self._isInBulletTime
            or (app.battle:getShowActor() and app.battle:getShowActor() ~= self) then
            -- 斗魂场中对额外标记的buff和skill可以跑
            self:_runAllowBulletTimeBuff(event.deltaTime)
            self:_runAllowBulletTimeSkill(event.deltaTime)
            return
        end
    end

    if self._passiveBuffApplied == false then
        self:_applyPassiveSkillBuffs()
        self._passiveBuffApplied = true
    end

    if not self._isInBulletTime then
        self:_runBuff(event.deltaTime)
        self:_updateRage(event.deltaTime)
    end
    
    -- 在黑屏期间，时间静止不起效
    if (self._isInBulletTime and self._isInTimeStop > 0) or (not self._isInBulletTime and self._isInTimeStop <= 0)
        or (not self._isInBulletTime and app.battle:isInBulletTime()) then
        self:_runSkill(event.deltaTime)

        if self._isInTimeStop > 0 then
            self:setAnimationScale(1, "time_stop")
        end
    else
        self:_runOtherDamagerSkill(event.deltaTime)

        if self._isInTimeStop > 0 then
            self:setAnimationScale(0, "time_stop")
        end
    end

    if not self:isInTimeStop() then
        self:_checkReverse()
    end

    -- 处理死亡后的从blow up状态的衰落
    if self:isDead() and self.blowupParam then
        local currentHeight = self:getHeight()
        local finished = false
        if currentHeight then
            local blowupParam = self.blowupParam
            currentHeight = math.max(currentHeight - blowupParam.height * event.deltaTime / (blowupParam.down - blowupParam.keep), 0)
            self:setActorHeight(currentHeight)
            if currentHeight == 0 then
                finished = true
            end
        else
            finished = true
        end
        if finished then
            self.blowupParam = nil
            return
        end
    end

    -- 处理等待中的技能队列，一帧最多处理一个未处理技能
    local arr = self._sbDirectorsWaitingList
    local lastTime = nil
    for index, obj in ipairs(arr) do
        if obj[3] == nil then
            local currentTime = app.battle:getTime()
            if lastTime == nil or currentTime - lastTime >= obj[2] then
                table.insert(self._sbDirectors, obj[1])
                obj[3] = currentTime
                if index > 1 then
                    table.remove(arr, 1)
                end
            end
            break
        else
            lastTime = obj[3]
        end
    end
end

function QActor:_onFrameBetweenEndAndStop(dt)
    if not app.battle and self._frameIdBetweenEndAndStop then
        scheduler.unscheduleGlobal(self._frameIdBetweenEndAndStop)
        self._frameIdBetweenEndAndStop = nil
        return
    end

    if self:isSupport() 
        and self ~= app.battle:getSupportSkillHero()
        and self ~= app.battle:getSupportSkillHero2()
        and self ~= app.battle:getSupportSkillHero3()
        and self ~= app.battle:getSupportSkillEnemy()
        and self ~= app.battle:getSupportSkillEnemy2()
        and self ~= app.battle:getSupportSkillEnemy3()
    then
        return
    end

    self:_runBuff(dt)
    self:_runSkill(dt)
    self:_updateRage(dt)
end

function QActor:_onBattleEnded(event)
    self:_disableHpChangeByPropertyChange()

    -- skill
    if not self:isDoingDeadSkill() then
        self:_cancelCurrentSkill()
    end
    for _, sbDirector in ipairs(self._sbDirectors) do
        if not (self:isDoingDeadSkill() and self._currentSBDirector == sbDirector) then
            sbDirector:cancel()
        end
    end
    if not self:isDoingDeadSkill() then
        self._sbDirectors = {}
    else
        self._sbDirectors = {self._currentSBDirector}
    end

    -- buff
    self:removeAllBuff()
    self._buffs = {}
    self._buffEventListeners = {}
    self._buffAttacker = {}
    self._passiveBuffApplied = false

    self._isInBulletTime = false
    self._grid_walking_attack_count = 0
    self._waveended = false
    self._battlepause = false
    self._isInTimeStop = 0

    for _, skill in pairs(self._skills) do
        skill:pauseCoolDown()
        skill:cleanup()
    end

    -- reset property stack
    self:_clearActorNumberPropertyValue()
    self:_applyStaticActorNumberProperties()

    self:_enableHpChangeByPropertyChange()

    if not self._frameIdBetweenEndAndStop then
        self._frameIdBetweenEndAndStop = scheduler.scheduleUpdateGlobal(handler(self, QActor._onFrameBetweenEndAndStop))
    end

    self:dispatchEvent({name = QActor.END})
end 

function QActor:_onBattleStop(event)
    if self._frameIdBetweenEndAndStop then
        scheduler.unscheduleGlobal(self._frameIdBetweenEndAndStop)
        self._frameIdBetweenEndAndStop = nil
    end

    if self._victorySkill ~= nil then
        self:_cancelCurrentSkill()
        for _, sbDirector in ipairs(self._sbDirectors) do
            sbDirector:cancel()
        end
        self._sbDirectors = {}
    end

    if  self._battleEventListener ~= nil then
        self._battleEventListener:removeAllEventListeners()
        self._battleEventListener = nil
    end

    self._hitlog:clearAll()
    self:setTarget(nil)
    self._isMarked = false
end

function QActor:_onBattlePause(event)
    self._battlepause = true

    -- for _, skill in pairs(self._skills) do
    --     skill:pauseCoolDown()
    -- end
end

function QActor:_onBattleResume(event)
    self._battlepause = false

    if not self._battlepause and not self._waveended then
        -- for _, skill in pairs(self._skills) do
        --     skill:resumeCoolDown()
        -- end
    end
end

function QActor:_onWaveEnded(event)
    self._waveended = true

    self:_cancelCurrentSkill()
    self:forceStopBeatback()
    self:forceStopBlowup()

    for _, skill in pairs(self._skills) do
        skill:pauseCoolDown()
    end
end

function QActor:_onWaveConfirmed(event)
    self._waveended = false

    -- nzhang: to fix bladestorm
    self:_cancelCurrentSkill()

    if not self._battlepause and not self._waveended then
        for _, skill in pairs(self._skills) do
            skill:resumeCoolDown()
        end
    end

    -- gain rage
    if self:hasRage() then
        self:_changeRage(self._rageInfo.next_wave_rage)
    end
end

function QActor:onMarked()
    if self:isNeutral() or self:isExile() then
        return
    end

    local actionEvents = self._actionEvents
    actionEvents[#actionEvents + 1] = {cat = QActor.ACTION_ONMARK}
end

function QActor:onUnMarked()
    if self:isNeutral() or self:isExile() then
        return
    end

    local actionEvents = self._actionEvents
    actionEvents[#actionEvents + 1] = {cat = QActor.ACTION_ONUNMARK}
end

local _lastMarkedTime = nil
function QActor:_doOnMarked()
    if self._isMarked == true then
        return false
    end

    self:applyBuff(global.attack_mark_effect)
    self:dispatchEvent({name = QActor.MARK_STARTED})
    if _lastMarkedTime == nil or q.time() - _lastMarkedTime > 4 then
        if not IsServerSide then
            -- QSoundEffect.new(global.attack_mark_sound_effect, {isInBattle = true, effectDelay = 0}):play(false)
        end
        _lastMarkedTime = q.time()
    end

    self._isMarked = true
    self._onMarkedTime = app.battle:getTime()
end

function QActor:_doOnUnMarked()
    self:removeBuffByID(global.attack_mark_effect)
    self:dispatchEvent({name = QActor.MARK_ENDED})

    self._isMarked = false
end

function QActor:isMarked()
    return self._isMarked, self._onMarkedTime
end

function QActor:isReverseWalk()
    if self:isWalking() ~= true then return false end

    if self.gridMidPos == nil and self.gridPos == nil then
        return false
    end

    local targetPos
    if self.gridMidPos ~= nil then
        targetPos = app.grid:_toScreenPos(self.gridMidPos)
    else
        targetPos = app.grid:_toScreenPos(self.gridPos)
    end
    local selfPos = self:getPosition()
    local directionRight = targetPos.x - selfPos.x > 0

    local facingRight = self:getDirection() == self.DIRECTION_RIGHT

    return directionRight == not facingRight
end

function QActor:isInBulletTime()
    return self._isInBulletTime
end

function QActor:inBulletTime(isIn)
    self._isInBulletTime = isIn or false
    if self._isInBulletTime == true then
        for _, skill in pairs(self._skills) do
            skill:pauseCoolDown()
        end
    else
        for _, skill in pairs(self._skills) do
            skill:resumeCoolDown()
        end
    end
end

function QActor:isInTimeStop()
    return self._isInTimeStop > 0
end

function QActor:inTimeStop(isIn)
    self._isInTimeStop = self._isInTimeStop + (isIn and 1 or -1)
    if self._isInTimeStop < 0 then self._isInTimeStop = 0 end
    if self._isInTimeStop > 0 then
        self:setAnimationScale(0, "time_stop")
        for _, skill in pairs(self._skills) do
            skill:pauseCoolDown()
        end
    else
        self:setAnimationScale(1, "time_stop")
        for _, skill in pairs(self._skills) do
            skill:resumeCoolDown()
        end
    end
end   

function QActor:setLockHp(isLock)
    self._isLockHp = math.max(self._isLockHp + (isLock and 1 or -1), 0)
end

function QActor:setReplaceCharacterId(id)
    self._replaceCharacterId = id
    if self._replaceCharacterId ~= nil then
        self._replaceCharacterDisplayId = db:getCharacterByID(self._replaceCharacterId).display_id
        self._replaceDisplayInfo = db:getCharacterDisplayByID(self._replaceCharacterDisplayId)
    else
        self._replaceCharacterDisplayId = nil
        self._replaceDisplayInfo = nil
    end
end

function QActor:getReplaceCharacterId()
    return self._replaceCharacterId
end

function QActor:willReplaceActorView()
    self:_cancelCurrentSkill()

    for _, buff in ipairs(self._buffs) do
        self:dispatchEvent({name = QActor.BUFF_ENDED, buff = buff})
    end
end

function QActor:didReplaceActorView()
    for _, buff in ipairs(self._buffs) do
        self:dispatchEvent({name = QActor.BUFF_STARTED, buff = buff, replace = true})
    end
end

function QActor:CanControlMove()
    if self._forbidMoving then
        return false
    end

    for _, buff in ipairs(self._buffs) do
        if not buff:isImmuned() and buff.effects.can_control_move == false then
            return false
        end
    end
    return true
end

function QActor:CanChargeOrBlink()
    for _, buff in ipairs(self._buffs) do
        if not buff:isImmuned() and buff.effects.can_charge_or_blink == false then
            return false
        end
    end
    return true
end

function QActor:StartOneTrack(target, interval, always)
    self:dispatchEvent({name = QActor.ONE_TRACK_START_EVENT, track_target = target, interval = interval, always = always})
end

function QActor:EndOneTrack()
    self:dispatchEvent({name = QActor.ONE_TRACK_END_EVENT,})
end

function QActor:setForceAuto(force)
    if self:getType() ~= ACTOR_TYPES.HERO and self:getType() ~= ACTOR_TYPES.HERO_NPC then
        self._forceAuto = force
        if force and self:getManualMode() ~= QActor.AUTO then
            if not self:isAttacking() then
                self:setManualMode(QActor.AUTO)
            end
        end
        self:dispatchEvent({name = QActor.FORCE_AUTO_CHANGED_EVENT, forceAuto = force})
    else
        -- 只有在飞回放模式下setForceAuto才能被调用
        if not app.battle:isInReplay() then
            -- 自动技能释放的设置必须要能够被回放，因此setForceAuto必须被记录，且必须在同一个块代码区中执行。
            -- self._forceAuto_change的执行会在QActor:_updateForceAuto()中。
            self._forceAuto_change = not not force
        end
    end
end

function QActor:isForceAuto()
    -- 如果是不完整的战斗记录（比如打了一半让服务器算剩余），或者是空战斗记录（比如扫荡要塞），那么就需要判断是不是要开启自动技能，否则对玩家会不利
    if app.battle:isInReplay() and not app.battle:hasReplayFrame() then
        return true
    end

    if app.battle:isForceAuto() then
        return true
    else
        return self._forceAuto or (app.battle:isInArena() and not app.battle:isArenaAllowControl()) or (app.battle:isInSilverMine() and app.battle:isPVPMode())
    end
end

--只有战斗帧中才会被调到
function QActor:_updateForceAuto()
    if self:getType() == ACTOR_TYPES.HERO or self:getType() == ACTOR_TYPES.HERO_NPC then
        if not app.battle:isInReplay() then
            if self._forceAuto_change ~= nil --[[and app.battle:isCurrentFrameRecord()-]] then
                local force = self._forceAuto_change
                self._forceAuto_change = nil

                self._forceAuto = force
                if force and self:getManualMode() ~= QActor.AUTO then
                    if not self:isAttacking() then
                        self:setManualMode(QActor.AUTO)
                    end
                end
                self:dispatchEvent({name = QActor.FORCE_AUTO_CHANGED_EVENT, forceAuto = force})
                -- 记录force auto 改变事件
                app.battle:saveForceAutoChange(self:getActorID(), force)
            end
        else
            local force = app.battle:loadForceAutoChange(self:getActorID())
            if force ~= nil then
                self._forceAuto = force
                if force and self:getManualMode() ~= QActor.AUTO then
                    if not self:isAttacking() then
                        self:setManualMode(QActor.AUTO)
                    end
                end
                self:dispatchEvent({name = QActor.FORCE_AUTO_CHANGED_EVENT, forceAuto = force})
            end
        end
    end
end

function QActor:getComboPoints()
    if self:isSupportHero() then
        return self._combo_points_max
    else
        return self._combo_points
    end
end

function QActor:getComboPointsMax()
    return self._combo_points_max
end

function QActor:getComboPointsTotal()
    return self._combo_points_total
end

function QActor:getConsumableComboPoints()
    return self._combo_points <= self._combo_points_max and self._combo_points or self._combo_points_max
end

function QActor:getComboPointsCoefficient()
    if self._coefficient_table == nil then
        local config = db:getConfiguration()
        self._coefficient_table = {}
        self._coefficient_table[1] = config.ONE_COMBO_POINTS.value
        self._coefficient_table[2] = config.TWO_COMBO_POINTS.value
        self._coefficient_table[3] = config.THREE_COMBO_POINTS.value
        self._coefficient_table[4] = config.FOUR_COMBO_POINTS.value
        self._coefficient_table[5] = config.FIVE_COMBO_POINTS.value
    end
    if self:isSupportHero() then
        return self._coefficient_table[self._combo_points_max]
    else
        -- 张南：存在不知道的原因导致消耗的连击点数(self._combo_points_consumed)是0
        return self._coefficient_table[self._combo_points_consumed] or 0
    end
end

function QActor:consumeComboPoints()
    if self:isSupportHero() then
        self._combo_points_consumed = self._combo_points_max
    else
        self._combo_points_consumed = (self._combo_points > self._combo_points_max) and self._combo_points_max or self._combo_points
    end

    self._combo_points = self._combo_points - self._combo_points_max
    if self._combo_points < 0 then
        self._combo_points = 0
    end

    self:dispatchEvent({name = QActor.CP_CHANGED_EVENT})

    local coefficient = self:getComboPointsCoefficient()
    return coefficient
end

function QActor:getComboPointsConsumed()
    if self:isSupportHero() then
        return self._combo_points_max
    else
        return self._combo_points_consumed
    end
end

function QActor:gainComboPoints(combo_points)
    local max = math.ceil(combo_points)
    local min = math.floor(combo_points)
    combo_points = combo_points > (app.random(min * 10000, max * 10000) / 10000) and max or min

    if combo_points == 0 then
        return
    end

    local combo_points = combo_points + self._combo_points
    if combo_points > self._combo_points_total then
        combo_points = self._combo_points_total
    end
    self._combo_points = combo_points

    self:dispatchEvent({name = QActor.CP_CHANGED_EVENT})
end

function QActor:setComboPoints(combo_points)
    self._combo_points = math.clamp(combo_points, 0, self._combo_points_total)

    self:dispatchEvent({name = QActor.CP_CHANGED_EVENT})
end

function QActor:isNeedComboPoints()
    -- do return true end

    return self._is_need_combo
end

function QActor:getComboPointsAuto()
    return self._combo_points_auto
end

function QActor:isDoingDeadSkill()
    return self._isDoingDeadSkill
end

function QActor:forbidNormalAttack()
    self._forbidNormalAttack = true
end

function QActor:allowNormalAttack()
    self._forbidNormalAttack = nil
end

function QActor:isForbidNormalAttack()
    return self._forbidNormalAttack
end

function QActor:isHero()
    return self._isHero
end

function QActor:getBreakthroughValue()
    return self._breakthrough_value
end

function QActor:getGradeValue()
    return self._grade_value
end

function QActor:setIsGhost(isGhost)
    self._isGhost = isGhost
end

function QActor:setGhostCanBeAttacked(v)
    self._ghost_can_be_attacked = v
end

function QActor:isAttackedGhost()
    return self._ghost_can_be_attacked or false
end

-- 是否是鬼魂 没有仇恨
function QActor:isGhost()
    return self._isGhost
end

function QActor:isSoulSpirit()
    return self._isSoulSpirit 
end

function QActor:setIsPet(isPet)
    self._isPet = isPet
end

-- 是否是宠物 战斗结束不会消失，会归位
function QActor:isPet()
    return self._isPet
end

function QActor:setIsBoss(isBoss)
    self._isBoss = isBoss
end

function QActor:isBoss()
    return self._isBoss
end

function QActor:setIsNpcBoss(isNpcBoss)
    self._isNpcBoss = isNpcBoss
end

function QActor:isNpcBoss()
    return self._isNpcBoss
end

function QActor:setIsControlNPC(isControlNPC)
    self._isControlNPC = isControlNPC
end

-- 是否是可控制的NPC
function QActor:isControlNPC()
    return self._isControlNPC
end

function QActor:isImmunePhysicalDamage()
    return self._immune_physical_damage > 0
end

function QActor:isImmuneMagicDamage()
    return self._immune_magic_damage > 0
end

function QActor:_getCharacterData(id, data_type, npc_difficulty, npc_level)
    return db:getCharacterData(id, data_type, npc_difficulty, npc_level)
end

function QActor:setPropertyCoefficient(attack, hp, damage, armor)
    self._propertyCoefficient.attack = attack
    self._propertyCoefficient.hp = hp
    self._propertyCoefficient.damage = damage
    self._propertyCoefficient.armor = armor

    self:setFullHp()
end

function QActor:getAttackCoefficient()
    return self._propertyCoefficient.attack or 0
end

function QActor:getHpCoefficient()
    return self._propertyCoefficient.hp or 0
end

function QActor:getDamageCoefficient()
    return self._propertyCoefficient.damage or 0
end

function QActor:getArmorCoefficient()
    return self._propertyCoefficient.armor or 0
end

function QActor:_parseSkillID(skill_id)
    local id, level = nil
    if type(skill_id) == "number" then
        id = skill_id
        level = 1
    elseif type(skill_id) == "string" then
        if string.find(skill_id, ",") then
            local objs = string.split(skill_id, ",")
            id = tonumber(objs[1])
            level = tonumber(objs[2])
        elseif string.find(skill_id, ":") then
            local objs = string.split(skill_id, ":")
            id = tonumber(objs[1])
            level = tonumber(objs[2])
        else
            id = tonumber(skill_id)
            level = 1
        end
    end

    if id == nil or level == nil then
        return nil, nil
    end

    local skill_info = db:getSkillByID(id)

    if skill_info and db:getSkillDataByIdAndLevel(skill_info.to_skill_data or id, level) then
        return id, level
    end
end

function QActor:summonHunterPet(no_ai)
    if self._hunterPetActor then
        return
    end
    -- summon pet
    local pet_id = self._pet_id
    if pet_id ~= -1 then
        local pos = clone(self:getPosition())
        if self:getType() == ACTOR_TYPES.NPC then
            pos.x = pos.x + 25
        else
            pos.x = pos.x - 25
        end
        
        local ghostConfig = {
            ghost_id = pet_id,
            summoner = self,
            life_span = 600,
            screen_pos = pos,
            is_normal_pet = true,
            pet_hp_per = 1,
            pet_atk_per = 1,
            no_ai = no_ai,
            skin_id = self._skin_info.pet_skin_id,
        }
        self._hunterPetActor = app.battle:summonGhosts(ghostConfig)
        self._hunterPetActor:setIsGhost(true)
        self._hunterPetActor._hunterMasterActor = self
        self:_applyPassiveSkillValueForPet(self._hunterPetActor)
    end

    return self._hunterPetActor
end

function QActor:_applyPassiveSkillValueForPet(pet)
    local skillData = nil
    local skillConfig = nil
    for _, skill in pairs(self._passiveSkills) do
        skillConfig = db:getSkillByID(skill:getId())
        skillData = db:getSkillDataByIdAndLevel(skill:getId(), skill:getSkillLevel())
        if skillConfig.addition_for_pet then
            local count = 1
            while true do
                local key = skillData["addition_type_"..count]
                local value = skillData["addition_value_"..count]
                if key == nil then
                    break
                end
                pet:insertPropertyValue(key, "PassiveSkillForPet", "+", value)
                count = count + 1
            end
        end
    end
end

function QActor:getHunterPet()
    return self._hunterPetActor
end

function QActor:getHunterMaster()
    return self._hunterMasterActor
end

function QActor:isHunter()
    return self._pet_id ~= -1
end

function QActor:setIsHunter(isHunter)
    self._isHunter = isHunter
end

function QActor:petAttackByID(skill_id)
    if self:getHunterMaster() then
        local petSkill = self._skills[skill_id]
        if petSkill == nil then
            petSkill = QSkill.new(skill_id, {}, self)
            self._skills[skill_id] = petSkill
        end
        self:attack(petSkill)
    end
end

function QActor:getBuffByID(id)
    for _, buff in ipairs(self._buffs) do
        if buff:getId() == id then
            return buff
        end
    end
end

function QActor:getBuffs()
    return self._buffs
end

--[[
    怒气相关
]]
-- 战斗（重新）开始时调用
local function nilor(v1, v2)
    return (v1 == nil) and v2 or v1
end
function QActor:_initRageCoefficients()
    if self._rageInfo == nil then
        local actor_rage = clone(db:getCharacterRageByCharacterID(self:getActorID()))
        local dungeon_rage = clone(app.battle:getRageCoefficients(self))

        if actor_rage == nil then
            actor_rage = {}
        end
        actor_rage.enter_rage = nilor(actor_rage.enter_rage, 0)
        actor_rage.beattack_coefficient = nilor(actor_rage.beattack_coefficient, 1)
        actor_rage.kill_coefficient = nilor(actor_rage.kill_coefficient, 1)
        actor_rage.bekill_rage = nilor(actor_rage.bekill_rage, 0)
        actor_rage.next_wave_rage = nilor(actor_rage.next_wave_rage, 0)
        actor_rage.rage_per_second = nilor(actor_rage.rage_per_second, 0)
        actor_rage.talent_rage = nilor(actor_rage.talent_rage, 0)
        if dungeon_rage == nil then
            dungeon_rage = {}
        end
        dungeon_rage.enter_coefficient = nilor(dungeon_rage.enter_coefficient, 1)
        dungeon_rage.beattack_coefficient = nilor(dungeon_rage.beattack_coefficient, 1)
        dungeon_rage.skill_coefficient = nilor(dungeon_rage.skill_coefficient, 1)
        dungeon_rage.kill_coefficient = nilor(dungeon_rage.kill_coefficient, 1)
        dungeon_rage.bekill_coefficient = nilor(dungeon_rage.bekill_coefficient, 1)
        dungeon_rage.next_wave_coefficient = nilor(dungeon_rage.next_wave_coefficient, 1)
        dungeon_rage.rage_reserve = dungeon_rage.rage_reserve or true

        -- TOFIX self._equipProp.enter_rage or 0
        actor_rage.enter_rage = (dungeon_rage.enter_rage or actor_rage.enter_rage) * dungeon_rage.enter_coefficient -- 进场怒气
        actor_rage.beattack_coefficient = actor_rage.beattack_coefficient * dungeon_rage.beattack_coefficient -- 受击获得怒气系数（乘以血量）
        actor_rage.skill_coefficient = dungeon_rage.skill_coefficient -- 技能获得怒气系数（乘以skill.rage_gain）
        actor_rage.kill_coefficient = actor_rage.kill_coefficient * dungeon_rage.kill_coefficient -- 击杀怒气系数（乘以被击杀者的bekill_rage)
        actor_rage.bekill_rage = actor_rage.bekill_rage * dungeon_rage.bekill_coefficient -- 被击杀提供怒气（乘以击杀者的kill_coefficient，提供给击杀者）
        actor_rage.next_wave_rage = actor_rage.next_wave_rage * dungeon_rage.next_wave_coefficient -- 切波次提供的怒气
        actor_rage.rage_per_second = actor_rage.rage_per_second -- 魂师自身每秒获得的怒气
        actor_rage.rage_reserve = dungeon_rage.rage_reserve -- 魂师的怒气是否留到下一场战斗
        actor_rage.rage_win = dungeon_rage.rage_win or 0
        self._rageInfo = actor_rage
        -- glyphs: pve_enter_rage, pvp_enter_rage
        actor_rage.enter_rage = actor_rage.enter_rage + (app.battle:isPVPMode() and self:getActorPropValue("pvp_enter_rage") or self:getActorPropValue("pve_enter_rage"))
    end

    local rageInfo = self._rageInfo
    if rageInfo then
        self:_changeRage(rageInfo.enter_rage + self:_getActorNumberPropertyValue("enter_rage"))
    end
end

function QActor:_changeRage(dRage, support, showTip)
    if not self:hasRage() or (self:isSupportHero() and not support) then
        return
    end

    if dRage > 0 then
        dRage = math.max(dRage * (1 + self:_getActorNumberPropertyValue("rage_increase_coefficient")), 0)
    end

    local oldRage = self._rage
    local addtion = self:isSupportHero() and 0 or self:getRageLimitUpper()
    local newRage = math.clamp(oldRage + dRage, 0, self._rage_total + addtion)
    self._rage = newRage
    if self._rage >= self._rage_total and self:isDead() ~= true then
        self:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_RAGE_FULL, self)
    end
    self:dispatchEvent({name = QActor.RP_CHANGED_EVENT, old_rage = oldRage, new_rage = newRage, showTip = showTip})
end

function QActor:_updateRage(dt)
    if not self:hasRage() then
        return
    end

    local lastTime = self._lastRageTickTime
    if lastTime == nil then
        lastTime = 0
    end
    lastTime = lastTime + dt
    local count = math.floor(lastTime)
    if count > 0 then
        self:changeRage(count * self._rageInfo.rage_per_second)
        self._lastRageTickTime = lastTime - count
    else
        self._lastRageTickTime = lastTime
    end

    -- glyphs: rage_per_five_second, rage_per_five_second_for_team
    local lastTime = self._lastRageTickTimePerFiveSecond
    if lastTime == nil then
        lastTime = 0
    end
    lastTime = lastTime + dt
    local count = math.floor(lastTime)
    if count >= 5 then
        self:changeRage(self:getActorPropValue("rage_per_five_second"))
        for _, actor in ipairs(app.battle:getMyTeammates(self, true)) do
            actor:changeRage(self:getActorPropValue("rage_per_five_second_for_team"))
        end
        self._lastRageTickTimePerFiveSecond = lastTime - count
    else
        self._lastRageTickTimePerFiveSecond = lastTime
    end
end

function QActor:hasRage()
    return false
end

function QActor:getRageInfo()
    if self:hasRage() then
        return self._rageInfo
    end
end

function QActor:getRage()
    return self._rage
end

function QActor:getRageTotal()
    return self._rage_total
end

function QActor:changeRage(dRage, support, showTip)
    if dRage == nil then
        return
    end

    self:_changeRage(dRage, support, showTip)
end

function QActor:setRage(rage, support)
    self:_changeRage(rage - self._rage, support)
end

function QActor:isRageReserve()
    return self:hasRage() and self._rageInfo.rage_reserve
end

function QActor:getRageWin()
    return self._rageInfo.rage_win
end

function QActor:isRageEnough()
    return DEBUG_RAGE_ALWAYS_ENOUGH or (self._rage >= self._rage_total)
end

function QActor:consumeRage()
    self:_changeRage(-self._rage_total, self:isSupportHero())
end

function QActor:getSkillDirectors()
    return self._sbDirectors
end

function QActor:isAlternate()
    return self:isCandidate()
end

function QActor:setIsCandidate(b)
    self._isCandidate = b
end

function QActor:isCandidate()
    return self._isCandidate
end

function QActor:isSupportHero()
    return false
end

function QActor:isSupport()
    return self:isSupportHero() or (self:getHunterMaster() and self:getHunterMaster():isSupportHero())
end

function QActor:isIdleSupport()
    if self:isSupportHero() then
        return not (table.indexof(app.battle:getHeroes(), self) or table.indexof(app.battle:getEnemies(), self))
    elseif self:getHunterMaster() and self:getHunterMaster():isSupportHero() then
        return not (table.indexof(app.battle:getHeroes(), self:getHunterMaster()) or table.indexof(app.battle:getEnemies(), self:getHunterMaster()))
    end
    return false
end

function QActor:isActiveSupport()
    if self:isSupportHero() then
        return (table.indexof(app.battle:getHeroes(), self) or table.indexof(app.battle:getEnemies(), self))
    elseif self:getHunterMaster() and self:getHunterMaster():isSupportHero() then
        return (table.indexof(app.battle:getHeroes(), self:getHunterMaster()) or table.indexof(app.battle:getEnemies(), self:getHunterMaster()))
    end
    return false
end

function QActor:isSupportSkillCountAvailable()
    return not SUPPORT_SKILL_ONLY_ONCE or self._supportSkillUsageCount == 0
end

function QActor:isSupportSkillReady(ignore_resource)
    local skills = self._manualSkills
    local skill = skills[next(skills)]
    local actor = self

    if SUPPORT_SKILL_ONLY_ONCE then
        if self._supportSkillUsageCount >= 1 then
            return false
        end
    end

    if not ignore_resource then
        if not self:isRageEnough() then
            return false
        end
    end

    if not skill:isCDOK() then
        return false
    end

    if table.indexof(app.battle:getHeroes(), self) or table.indexof(app.battle:getEnemies(), self) then
        return false
    end

    -- 判断技能是否需要目标
    if skill:getRangeType() == skill.SINGLE then
        if skill:getTargetType() == skill.TARGET then
            local targets
            if actor:isHealth() then
                targets = app.battle:getMyTeammates(actor)
            else
                targets = app.battle:getMyEnemies(actor)
            end
            if #targets == 0 then
                return false
            end
        end
    elseif skill:getRangeType() == skill.MULTIPLE then
        if skill:getZoneType() == skill.ZONE_FAN and skill:getSectorCenter() == skill.CENTER_TARGET then
            local targets
            if actor:isHealth() then
                targets = app.battle:getMyTeammates(actor)
            else
                targets = app.battle:getMyEnemies(actor)
            end
            if #targets == 0 then
                return false
            end
        end
    end

    if app.battle:isBattleEnded() then
        return false
    end

    return true
end

function QActor:getAttackType()
    return self:get("attack_type")
end

function QActor:isDoingSkill(skill)
    for _, sb in ipairs(self._sbDirectors) do
        if sb:getSkill() == skill then
            return true
        end
    end
    return false
end

function QActor:isDoingSkillByID(skill_id)
    for _, sb in ipairs(self._sbDirectors) do
        if sb:getSkill():getId() == skill_id then
            return true
        end
    end
    return false
end

function QActor:speak(bullshit, duration, type, offset, scale)
    self:dispatchEvent({name = QActor.SPEAK_EVENT, bullshit = bullshit,
        duration = duration, type = type, offset = offset, scale = scale})
end

function QActor:showCCB(ccbFileName, animationName, duration)
    self:dispatchEvent({name = QActor.SHOW_CCB,ccb = ccbFileName,ccbDuration = duration,animation = animationName})
end

function QActor:enableAnimationControlMove()
    if self._animationControlMove == false then
        self._animationControlMove = true
        self._animationControlMoveStartPosition = clone(self:getPosition())
    end
end

function QActor:disableAnimationControlMove()
    if self._animationControlMove == true then
        self._animationControlMove = false
        self._animationControlMoveStartPosition = nil
    end
end

function QActor:onAnimationWillUpdate(view)
    if self._animationControlMove then
        self._lastRootBonePosition = view:getRootBonePosition()
    end
end

function QActor:onAnimationDidUpdatedBeforeWorldTransform(view)
    if self._animationControlMove then
        local p = self._lastRootBonePosition
        if p then
            np = view:getRootBonePosition()
            view:setRootBonePosition({x = p.x, y = np.y})
        end
    end
end

function QActor:getCurrentSBDirector()
    return self._currentSBDirector
end

function QActor:setFuncMark(func, time)
    if IsServerSide then
        return
    end

    local effect = nil
    if func == "t" then
        effect = "defense_mark_1"
    elseif func == "health" then
        effect = "treatment_mark_1"
    elseif func == "dps" then
        effect = "attack_mark_1"
    end

    local view = app.scene:getActorViewFromModel(self)
    if view then
        view:displayFuncMark(effect, time)
    end
end

function QActor:setAdditionalManualSkillDamagePercent(percent)
    self._additionalManualSkillDamageMultiplier = percent + 1
end

function QActor:getAdditionalManualSkillDamagePercent()
    return self._additionalManualSkillDamageMultiplier - 1
end

function QActor:_validateProperty()
    if not IsServerSide and not app.battle:isInEditor() and not app.battle:isInReplay() then
        self._hpValidate:validate(self._hp)
        for _, obj in pairs(self._number_properties) do
            obj.validate()
        end
    end
end

function QActor:setSuperSkillID(superSkillID)
    self._superSkillID = superSkillID
end

function QActor:getSuperSkillID()
    return self._superSkillID
end

function QActor:setDeputyActorIDs(deputies)
    self._deputies = deputies
end

function QActor:getDeputyActorIDs()
    return self._deputies
end

function QActor:setImmuneAoE(immuneAoE)
    self._immuneAoE = immuneAoE
end

function QActor:isImmuneAoE()
    return self._immuneAoE
end

function QActor:_checkReverse()
    if self:getState() == "walking" and self:getTarget() ~= nil and self:getTarget():isDead() == false 
        and table.find(app.battle:getMyEnemies(self), self:getTarget()) 
        and self:getCurrentSkill() == nil then

        if self:getTalentSkill():isRemoteSkill() == false then
            if self:getManualMode() ~= self.STAY then
                if self.gridPos then
                    local distance = q.distOf2Points(self:getTarget():getPosition(), app.grid:_toScreenPos(self.gridPos))
                    local left_distance = q.distOf2Points(self:getPosition(), app.grid:_toScreenPos(self.gridPos))
                    if left_distance < 1.414 * distance then
                        if self:isReverseWalk() == false then
                            self:_verifyFlip()
                            if not IsServerSide then
                                app.scene:getActorViewFromModel(self):_playWalkingAnimation()
                            end
                            return true
                        end
                    end
                end
            elseif self:getTargetPosition() then 
                local actor = self
                local target = self:getTarget()
                local talentSkill = actor:getTalentSkill()
                if talentSkill then
                    local actorWidth = actor:getRect().size.width / 2
                    local targetWidth = target:getRect().size.width / 2
                    local _, skillRange = talentSkill:getSkillRange(false)

                    local dx = math.abs(actor:getTargetPosition().x - target:getPosition().x)
                    local dy = math.abs(actor:getTargetPosition().y - target:getPosition().y)

                    if dx - actorWidth - targetWidth < skillRange and dy < skillRange * 0.6 then
                        local distance = q.distOf2Points(self:getTarget():getPosition(), self:getTargetPosition())
                        local left_distance = q.distOf2Points(self:getPosition(), self:getTargetPosition())
                        if left_distance < 1.414 * distance then
                            if self:isReverseWalk() == false then
                                self:_verifyFlip()
                                if not IsServerSide then
                                    app.scene:getActorViewFromModel(self):_playWalkingAnimation()
                                end
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
end

function QActor:_initGlyphs(glyphs)
    for _, config in ipairs(db:getGlyphSkillsByGlyphs(glyphs)) do
        -- glyph skills
        local skill_id = config.skill_id
        local id, level
        if skill_id then
            local skillIDs = string.split(tostring(skill_id), ";")
            for _, skillID in ipairs(skillIDs) do
                id, level = self:_parseSkillID(skillID)
                self._skills[id] = QSkill.new(id, {}, self, level)
            end
        end
    end
end

function QActor:getActorPropValue(prop_key)
    return self._actorProp:getPropValueByKey(prop_key)
end

function QActor:getAbsorbDamageValue()
    local absorbValue = 0
    for _, buff in ipairs(self._buffs) do
        if buff:isAbsorbDamage() then
            absorbValue = absorbValue + buff:getAbsorbDamageValue()
        end
    end
    return absorbValue
end

function QActor:checkHpCondition(hpBefore, hpAfter, obj)
    local func = obj.func
    local value = obj.value
    if func == "percent_less" then
        return hpAfter / (self:getMaxHp()) < value
    elseif func == "percent_more" then
        return value <= hpAfter / (self:getMaxHp())
    end
end

function QActor:onHpChangeForEvents(hpBefore, hpAfter)
    if app.battle == nil then
        return
    end
    for k,obj in ipairs(self._custom_event_list) do
        if obj.name == QActor.CUSTOM_EVENT_HP_CHANGE and self:checkHpCondition(hpBefore, hpAfter, obj) then
            obj.callback()
        end
    end
end

function QActor:onHpChangeForPassiveSkills(hpBefore, hpAfter)
    if app.battle == nil then
        return
    end
    for _, skill in pairs(self._passiveSkills) do
        local condition = skill:getTriggerCondition()
        if condition == QSkill.TRIGGER_CONDITION_HP_SEGMENT_EVENT then
            if hpBefore ~= hpAfter and skill:isReady() == true then
                local probability = skill:getTriggerProbability()
                local hpMax = self:getMaxHp()
                local hpPercentBefore, hpPercentAfter = hpBefore / hpMax, hpAfter / hpMax
                local segments = skill:getHPSegment()
                for _, segment in ipairs(segments) do
                    if hpPercentBefore >= segment and hpPercentAfter <= segment then
                        -- trigger buff
                        if probability >= app.random(1, 100) then
                            if skill:getTriggerType() == QSkill.TRIGGER_TYPE_BUFF then
                                local buffId = skill:getTriggerBuffId()
                                local buffTargetType = skill:getTriggerBuffTargetType()
                                self:_doTriggerBuff(buffId, buffTargetType, self, skill)
                                
                            elseif skill:getTriggerType() == QSkill.TRIGGER_TYPE_ATTACK then
                                local skillId, level = skill:getTriggerSkillId()
                                if level == "y" then level = skill:getSkillLevel() end
                                local triggerSkill = self._skills[skillId]
                                if triggerSkill == nil then
                                    triggerSkill = QSkill.new(skillId, db:getSkillByID(skillId), self, level)
                                    triggerSkill:setIsTriggeredSkill(true)
                                    self._skills[skillId] = triggerSkill
                                end
                                if triggerSkill:isReadyAndConditionMet() then
                                    local sbDirector = nil
                                    if (condition == QSkill.TRIGGER_CONDITION_HIT or condition == QSkill.TRIGGER_CONDITION_HIT_PHYSICAL or condition == QSkill.TRIGGER_CONDITION_HIT_MAGIC) and triggerSkill:isNeedATarget() then
                                        sbDirector = self:triggerAttack(triggerSkill)
                                    else
                                        sbDirector = self:triggerAttack(triggerSkill)
                                    end
                                end
                            elseif skill:getTriggerType() == QSkill.TRIGGER_TYPE_COMBO then
                                local combo_points = skill:getTriggerComboPoints()
                                self:gainComboPoints(combo_points)
                            elseif skill:getTriggerType() == QSkill.TRIGGER_TYPE_CD_REDUCE then
                                local manual_skills = self:getManualSkills()
                                manual_skills[next(manual_skills)]:reduceCoolDownTime(QActor.ARENA_BEATTACKED_CD_REDUCE)
                            elseif skill:getTriggerType() == QSkill.TRIGGER_TYPE_RAGE then
                                self:changeRage(skill:getTriggerRage())
                            end
                            skill:coolDown()
                            self:dispatchEvent({name = QActor.TRIGGER_PASSIVE_SKILL, sprite_frame = skill:getTriggerSpriteFrame(), skill = skill})
                        end
                    end
                end
            end
        elseif condition == QSkill.TRIGGER_CONDITION_HP_SEGMENT_STATUS then
            local segments = skill:getHPSegment()
            for index, segment in ipairs(segments) do
                local hpMax = self:getMaxHp()
                local hpPercentBefore, hpPercentAfter = hpBefore / hpMax, hpAfter / hpMax
                if hpPercentAfter <= segment then
                    -- trigger buff
                    if skill:getTriggerType() == QSkill.TRIGGER_TYPE_BUFF then
                        if skill:getSegmentBuff(index) == nil then
                            local buffId = skill:getTriggerBuffId(index)
                            local buffTargetType = skill:getTriggerBuffTargetType()
                            local newBuff = self:_doTriggerBuff(buffId, buffTargetType, self, skill)
                            skill:setSegmentBuff(index, newBuff)
                            self:dispatchEvent({name = QActor.TRIGGER_PASSIVE_SKILL, sprite_frame = skill:getTriggerSpriteFrame(), skill = skill})
                        end
                    end
                else
                    -- untrigger buff
                    if skill:getTriggerType() == QSkill.TRIGGER_TYPE_BUFF then
                        if skill:getSegmentBuff(index) then
                            local buff = skill:getSegmentBuff(index)
                            buff:getBuffOwner():removeBuffByInstance(buff)
                            skill:setSegmentBuff(index, nil)
                        end
                    end
                end
            end
        elseif condition == QSkill.TRIGGER_CONDITION_EXCLUSIVE_HP_SEGMENT_STATUS then
            local segments = skill:getHPSegment()
            local leftSegment = 0
            for index, segment in ipairs(segments) do
                local hpMax = self:getMaxHp()
                local hpPercentBefore, hpPercentAfter = hpBefore / hpMax, hpAfter / hpMax
                if hpPercentAfter > leftSegment and hpPercentAfter <= segment then
                    -- trigger buff
                    if skill:getTriggerType() == QSkill.TRIGGER_TYPE_BUFF then
                        if skill:getSegmentBuff(index) == nil then
                            local buffId = skill:getTriggerBuffId(index)
                            local buffTargetType = skill:getTriggerBuffTargetType()
                            local newBuff = self:_doTriggerBuff(buffId, buffTargetType, self, skill)
                            skill:setSegmentBuff(index, newBuff)
                            self:dispatchEvent({name = QActor.TRIGGER_PASSIVE_SKILL, sprite_frame = skill:getTriggerSpriteFrame(), skill = skill})
                        end
                    end
                else
                    -- untrigger buff
                    if skill:getTriggerType() == QSkill.TRIGGER_TYPE_BUFF then
                        if skill:getSegmentBuff(index) then
                            local buff = skill:getSegmentBuff(index)
                            buff:getBuffOwner():removeBuffByInstance(buff)
                            skill:setSegmentBuff(index, nil)
                        end
                    end
                end
                leftSegment = segment
            end
        end
    end
end

-- hp sharing (hp group) protocols
function QActor:_createHpGroup()
    if self._hpGroup then
        return self._hpGroup
    end

    local hpGroup = {main = self, subs = {}}
    self._hpGroup = hpGroup
    return self._hpGroup
end

function QActor:_getHpGroup()
    return self._hpGroup
end

function QActor:_decreaseHp_HpGroup(...)
    return QActor.decreaseHp(self._hpGroup.main, ...)
end

function QActor:connectToHpGroup(actor)
    if self._hpGroup then
        -- reconnect hp group is not allowed
        return
    end

    local hpGroup = actor:_getHpGroup() or actor:_createHpGroup()
    hpGroup.subs[self] = self
    self._hpGroup = hpGroup

    self:dispatchEvent({name = QActor.HP_CHANGED_EVENT, dHP = 0, hpBeforeLastChange = hpGroup.main._hpBeforeLastChange, hp = hpGroup.main._hp})
end

function QActor:hasHpGroup()
    return self._hpGroup ~= nil
end

function QActor:isHpGroupMain()
    return self._hpGroup ~= nil and self._hpGroup.main == self
end

function QActor:dispatchHpChangeEvent(dHp, hpBeforeLastChange, hp)
    local hpGroup = self._hpGroup
    local evt = {name = QActor.HP_CHANGED_EVENT, dHP = dHp, hpBeforeLastChange = hpBeforeLastChange, hp = hp}
    if hpGroup then
        hpGroup.main:dispatchEvent(evt)
        for sub in pairs(hpGroup.subs) do
            sub:dispatchEvent(evt)
        end
    else
        self:dispatchEvent(evt)
    end
end

function QActor:setActorHeight(height)
    self._height = height
    self:dispatchEvent({name = QActor.SET_HEIGHT_EVENT, height = height})
end

function QActor:getHeight()
    return self._height
end

function QActor:getModifySkillTable()
    return self._modifySkillTable or {}
end

function QActor:mergeModifySkillTable(properties, id)
    local t = self:getModifySkillTable()
    table.merge(properties, t[id] or {})
end

function QActor:getEnhanceSkillValueByID(id)
    if self._enhanceSkillTable then
        return self._enhanceSkillTable[id]
    end
end

function QActor:getModifyBuffTable()
    return self._modifyBuffTable
end

function QActor:mergeModifyBuffTable(properties, id)
    local t = self:getModifyBuffTable()
    table.merge(properties, t[id] or {})
end

function QActor:forbidMove()
    self._forbidMoving = true
end

function QActor:allowMove()
    self._forbidMoving = false
end

function QActor:getHitDummy()
    return self._hit_dummy
end

function QActor:setIsWeak(isWeak)
    self._isWeak = isWeak
end

function QActor:isWeak()
    return self._isWeak
end
    
function QActor:doDeadBehavior()
    if nil ~= self._deadBehaviorFile then
        self._deadBehavior = QSBDeadDirector.new(self, self._deadBehaviorFile)
    end
end

function QActor:getDeadBehavior()
    return self._deadBehavior 
end

function QActor:setDeadBehaviorFile(file)
    self._deadBehaviorFile = file
end

function QActor:getDeadBehaviorFile()
    return self._deadBehaviorFile
end


function QActor:setIsEliteBoss(isEliteBoss)
    self._isEliteBoss = isEliteBoss
end

function QActor:isEliteBoss()
    -- if self._hpGroup then
    --     return self._hpGroup.main._isEliteBoss
    -- end
    return self._isEliteBoss
end

-- 是否正在复活
function QActor:isReviving()
    return self._isReviving
end

function QActor:setIsReviving(isReviving)
    self._isReviving = isReviving
end

function QActor:addIgnoreHurtTarget(target)
    if #self._ignoreHurtTargetsList > 0 then
        for _, actor in ipairs(self._ignoreHurtTargetsList) do
            if actor == target then
                break
            end
        end
    end
    table.insert(self._ignoreHurtTargetsList, target)
end

function QActor:removeIgnoreHurtTarget(target)
    if #self._ignoreHurtTargetsList > 0 then
        for index, actor in ipairs(self._ignoreHurtTargetsList) do
            if actor == target then
                table.remove(self._ignoreHurtTargetsList, index)
                break
            end
        end
    end
end

function QActor:isIgnoreHurtTarget(target)
    if #self._ignoreHurtTargetsList > 0 then
        for _, actor in ipairs(self._ignoreHurtTargetsList) do
            if actor == target then
                return true
            end
        end
    end

    return false
end

function QActor:getIgnoreHurtResulteArgs()
    return {damage = 0, tip = "", critical = false, hit_status = "hit"}
end

function QActor:enableIgnoreHurtArgs(arg)
    self._ignoreHurtArgs = arg
end

function QActor:disableIgnoreHurtArgs()
    self._ignoreHurtArgs = nil
    self._ignoreHurtTargetsList = {}
end

function QActor:_updateIgnoreHurtTarget()
    local enemies = app.battle:getAllMyEnemies(self)

    if (self._position.x - self._ignoreHurtArgs.bratticePosX) * self._ignoreHurtArgs.ignoreDirect < 0 then
        self._ignoreHurtTargetsList = {}
    else
        for _, enemy in ipairs(enemies) do
            if (enemy:getPosition().x - self._ignoreHurtArgs.bratticePosX) * self._ignoreHurtArgs.ignoreDirect < 0 then
                self:addIgnoreHurtTarget(enemy)
            else
                self:removeIgnoreHurtTarget(enemy)
            end
        end
    end
end

function QActor:dispatchAbsorbChangeEvent(absorbValue)
    self:dispatchEvent({name = QActor.ABSORB_CHANGE_EVENT, absorb = absorbValue})
end

function QActor:getMountId()
    return self._mount_id
end

function QActor:isOpenArtifact()
    return false
end

function QActor:isTeammate(actor)
    local actorType = actor:getType()
    if actorType == ACTOR_TYPES.NPC and self._type == ACTOR_TYPES.NPC then
        return true
    end
    if actorType ~= ACTOR_TYPES.NPC and self._type ~= ACTOR_TYPES.NPC then
        return true
    end

    return false
end

function QActor:addStrikeAgreementers(actor, percent)
    table.insert(self._strikeAgreementers, {actor = actor, percent = percent})
end

function QActor:removeStrikeAgreementers(actor)
    local removeIdx = nil
    for index, tab in ipairs(self._strikeAgreementers) do
        if tab.actor == actor then
            removeIdx = index
            break
        end
    end

    if removeIdx ~= nil then
        table.remove(self._strikeAgreementers, removeIdx)
    end
end

function QActor:getStrikeAgreementers()
    return self._strikeAgreementers
end

function QActor:isStoryActor()
    return self._uuid > 1000
end

function QActor:getSkinInfo()
    return self._skin_info
end

function QActor:getSkinSkillBySkillId(skillId)
    return self._skin_info.replace_skills[skillId]
end

function QActor:isImmuneDeath()
    local other_buff
    for k,buff in pairs(self:getBuffs()) do
        if not buff:isImmuned() and buff.effects.immune_death then
            if buff:getAttacker() == self then 
                return true,buff
            elseif other_buff == nil then
                other_buff = buff
            end
        end
    end
    if other_buff then
        return true, other_buff
    end
    return false
end

function QActor:isLockHp()
    return self._isLockHp > 0
end

--获取护盾的使用量
function QActor:getUseAbsorbDamageValue()
    return self._use_absorb_damage_value
end

function QActor:insertExtralProp(property_name, value)
    if self._extralPorp == nil then
        self._extralPorp = {}
    end

    if self._extralPorp[property_name] then
        self._extralPorp[property_name] = self._extralPorp[property_name] + value
    else
        self._extralPorp[property_name] = value
    end
end

function QActor:getActorPropInfo()
    return self._actorProp
end

function QActor:getBuffEffectReduce()
    return self._buff_effect_reduce
end

function QActor:getBuffEffectReduceFromOther()
    return self._buff_effect_reduce_from_other
end

function QActor:getLastTriggerImmuneDeathAttacker()
    return self._last_trigger_immune_death_attacker
end

function QActor:getArtifactBreakthrough()
    return self._artifact_breakthrough
end

function QActor:insertSplitHitTargets(cfg, skill)
    if self._split_hit_targets == nil then
        self._split_hit_targets = {}
    end
    table.insert(self._split_hit_targets, {skill = skill, cfg = cfg})
end

function QActor:getSplitHitTargets()
    return self._split_hit_targets
end

function QActor:removeSplitHitTargets(skill)
    if self._split_hit_targets == nil then 
        return
    end
    local len = #self._split_hit_targets
    for i = len, 1, -1 do
        if self._split_hit_targets[i] and self._split_hit_targets[i].skill == skill then
            table.remove(self._split_hit_targets, i)
        end
    end
end

function QActor:isSS()
    return self._is_SS
end

function QActor:getAppearSkillId()
end

function QActor:setAIReloadTargets(b)
    self._isAIReloadTargets = b
end

function QActor:getAIReloadTargets()
    return self._isAIReloadTargets
end

function QActor:isInfiniteHpBoss()
    return self:isBoss() and app.battle:isBossHpInfiniteDungeon()
end

function QActor:setAdaptivityHelmet(num)
    self._adaptivityHelmetValue = math.clamp(self._adaptivityHelmetValue + num, 0, 1)
end

function QActor:getAdaptivityHelmet()
    return self._adaptivityHelmetValue
end

function QActor:isCopyHero()
    return false
end

function QActor:getCopyHeroColor()
    return self._copy_hero_color, self._copy_hero_color2
end

function QActor:setCopyHeroColor(color, color2)
    self._copy_hero_color = color
    self._copy_hero_color2 = color2
end

function QActor:setCopyHeroFinalOpcity(opcity)
    self._finalOpcity = opcity
end

function QActor:getCopyHeroFinalOpcity()
    return self._finalOpcity
end

function QActor:getTotemChallengeAffix()
    return {kind = -1}
end

function QActor:exileActor(isSkip)
    self._ai_skip_self = isSkip
end

function QActor:isExile()
    return self._ai_skip_self
end

function QActor:addFunctionCallBack(functionCallback)
    local functionName = functionCallback.name
    if self._functionCallBack[functionName] == nil then
        self._functionCallBack[functionName] = {functionCallback}
        local func = self.class[functionName]
        if func then
            self[functionName] = function(...)
                local params = table.pack(...)
                --如果要修改传进函数里的参数那么就直接params[index] = value
                --如果要修改返回值里的那么就result[index] = value
                for i,callback in ipairs(self._functionCallBack[functionName]) do
                    if callback.functionBefore then
                        callback.functionBefore(params)
                    end
                end
                local result = table.pack(func(table.unpack(params, 1, params.n)))
                for i,callback in ipairs(self._functionCallBack[functionName]) do
                    if callback.functionEnd then
                        callback.functionEnd(params, result)
                    end
                end
                return table.unpack(result, 1, result.n)
            end
        end
    else
        table.insert(self._functionCallBack[functionName], functionCallback)
    end
end

function QActor:removeFunctionCallBack(functionCallback)
    local functionName = functionCallback.name
    if self._functionCallBack[functionName] then
        table.removebyvalue(self._functionCallBack[functionName], functionCallback, true)
        if #self._functionCallBack[functionName] == 0 then
            self._functionCallBack[functionName] = nil
            self[functionName] = self.class[functionName]
        end
    else
        self[functionName] = self.class[functionName]
    end
end

function QActor:addApplyCountByStatus(status)
    if self._custom_status_list[status] == nil then
        self._custom_status_list[status] = 0
    end
    self._custom_status_list[status] = self._custom_status_list[status] + 1
end

function QActor:reduceApplyCountByStatus(status)
    if self._custom_status_list[status] == nil then
        return
    end
    if 0 < self._custom_status_list[status] then
        self._custom_status_list[status] = self._custom_status_list[status] - 1
    end
end

function QActor:setApplyCountByStatus(status, num)
    if self._custom_status_list[status] == nil then
        self._custom_status_list[status] = 0
    end
    self._custom_status_list[status] = num
end

function QActor:getApplyCountByStatus(status)
    return self._custom_status_list[status] or 0
end

function QActor:setAbsorbRenderLimit(limit)
    self._absorbRenderLimit = limit
    self._absorbRenderValue = 0
end

function QActor:addAbsorbRenderValue(value)
    self._absorbRenderValue = math.min(self._absorbRenderValue + value,
        self._absorbRenderLimit)
end

function QActor:isAbsorbRenderValue()
    return self._absorbRenderValue < self._absorbRenderLimit
end

function QActor:getAbsorbRenderDamage()
    return self:_getActorNumberPropertyValue("absorb_render_damage_cofficient")
end

function QActor:getAbsorbRenderHeal()
    return self:_getActorNumberPropertyValue("absorb_render_heal_cofficient")
end

function QActor:getSkinId()
    return self._skin_id
end

function QActor:setNeutralizeDamage(value)
    self._neutralizeDamage = self._neutralizeDamage + value
end

function QActor:getNeutralizeDamage()
    return self._neutralizeDamage
end

function QActor:setGroupAbsorb(absorb_tbl)
    table.insert(self._group_absorbs, absorb_tbl)
end

function QActor:removeGroupAbsorb(absorb_tbl)
    table.removebyvalue(self._group_absorbs, absorb_tbl)
end

return QActor

