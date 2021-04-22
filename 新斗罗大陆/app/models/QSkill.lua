local QSkill
if IsServerSide then
    local EventProtocol = import("EventProtocol")
    QSkill = class("QSkill", EventProtocol)
else
    local QModelBase = import("..models.QModelBase")
    QSkill = class("QSkill", QModelBase)
end

-- skill type
QSkill.MANUAL = "manual"
QSkill.ACTIVE = "active"
QSkill.PASSIVE = "passive"
QSkill.TEAM = "team"

-- target type
-- single range
QSkill.SELF = "self"
QSkill.TARGET = "target"
QSkill.COUNTERATTACK_TARGET = "counterattack_target"
-- multiple range
QSkill.ENEMY = "enemy"
QSkill.TEAMMATE = "teammate"
QSkill.TEAMMATE_AND_SELF = "teammate_and_self"

-- range type
QSkill.SINGLE = "single"
QSkill.MULTIPLE = "multiple"

-- zone type
QSkill.ZONE_FAN = "fan"
QSkill.ZONE_RECT = "rect"

-- sector center type
QSkill.CENTER_SELF = "self"
QSkill.CENTER_TARGET = "target"
QSkill.CENTER_COORDINATE = "coord"
QSkill.CENTER_TRAP = "trap"
QSkill.CENTER_RANDOM_TEAMMATE_AND_SELF = "random_teammate_and_self"
QSkill.CENTER_RANDOM_ENEMY = "random_enemy"

-- damage type
QSkill.PHYSICAL = "physical"
QSkill.MAGIC = "magic"

-- buff target type
QSkill.BUFF_SELF = "self"
QSkill.BUFF_TARGET = "target"
QSkill.BUFF_MAIN_TARGET = "main_target"
QSkill.BUFF_OTHER_TARGET = "other_target"
QSkill.BUFF_TEAMMATE_AND_SELF = "teammate_and_self"
QSkill.BUFF_ENEMY = "enemy"
QSkill.BUFF_TEAMMATE = "teammate"
QSkill.BUFF_ENEMY_TARGET = "enemy_target"

-- rage target type
QSkill.RAGE_SELF = "self"
QSkill.RAGE_TARGET = "target"
QSkill.RAGE_MAIN_TARGET = "main_target"
QSkill.RAGE_OTHER_TARGET = "other_target"

-- attack type
QSkill.ATTACK = "attack"
QSkill.TREAT = "treat"
QSkill.ASSIST = "assist"

-- hit type
QSkill.HIT = "hit"
QSkill.STRIKE = "strike"
QSkill.CRITICAL = "critical"

-- passive skill triggrt type
QSkill.TRIGGER_TYPE_BUFF = "buff"
QSkill.TRIGGER_TYPE_ATTACK = "attack"
QSkill.TRIGGER_TYPE_COMBO = "combo"
QSkill.TRIGGER_TYPE_CD_REDUCE = "cd_reduce"
QSkill.TRIGGER_TYPE_RAGE = "rage"
QSkill.TRIGGER_TYPE_PROPERTY_MODIFIER = "property_modifier"
QSkill.TRIGGER_TYPE_DAMAGE_MODIFIER = "damage_modifier"
QSkill.TRIGGER_TYPE_DEPRESS_RECOVER_HP = "depress_recover_hp"
QSkill.TRIGGER_TYPE_COUNT_DAMAGE = "count_damage"

-- passive skill triggrt condition
QSkill.TRIGGER_CONDITION_HIT = "hit"
QSkill.TRIGGER_CONDITION_HIT_PHYSICAL = "hit_physical"
QSkill.TRIGGER_CONDITION_HIT_MAGIC = "hit_magic"
QSkill.TRIGGER_CONDITION_BLOCK = "block"
QSkill.TRIGGER_CONDITION_DODGE = "dodge"
QSkill.TRIGGER_CONDITION_SKILL = "skill"
QSkill.TRIGGER_CONDITION_NORMAL_SKILL = "normal_skill"
QSkill.TRIGGER_CONDITION_ACTIVE_SKILL = "active_skill"
QSkill.TRIGGER_CONDITION_MANUAL_SKILL = "manual_skill"
QSkill.TRIGGER_CONDITION_SKILL_CRITICAL = "skill_critical"
QSkill.TRIGGER_CONDITION_SKILL_ATTACK = "skill_attack"
QSkill.TRIGGER_CONDITION_SKILL_ATTACK_CRITICAL = "skill_attack_critical"
QSkill.TRIGGER_CONDITION_SKILL_TREAT = "skill_treat"
QSkill.TRIGGER_CONDITION_SKILL_TREAT_CRITICAL = "skill_treat_critical"
QSkill.TRIGGER_CONDITION_DRAG = "drag"
QSkill.TRIGGER_CONDITION_DRAG_ATTACK = "drag_attack"
QSkill.TRIGGER_CONDITION_DRAG_OR_DRAG_ATTACK = "drag_or_drag_attack"
QSkill.TRIGGER_CONDITION_HP_SEGMENT_EVENT = "hp_segment_event"
QSkill.TRIGGER_CONDITION_HP_SEGMENT_STATUS = "hp_segment_status"
QSkill.TRIGGER_CONDITION_EXCLUSIVE_HP_SEGMENT_STATUS = "exclusive_hp_segment_status"
QSkill.TRIGGER_CONDITION_TARGET_HP_SEGMENT_STATUS = "target_hp_segment_status"
QSkill.TRIGGER_CONDITION_ENEMY_CAST_AOE = "enemy_cast_aoe"
QSkill.TRIGGER_CONDITION_ENEMY_CAST_AOE_SMALL = "enemy_cast_aoe_small"
QSkill.TRIGGER_CONDITION_HIT_BY_ENEMY_AOE = "hit_by_enemy_aoe"
QSkill.TRIGGER_CONDITION_DEATH = "death"
QSkill.TRIGGER_CONDITION_ACTIVE_NOT_NORMAL = "active_not_normal"
QSkill.TRIGGER_CONDITION_KILL_ENEMY = "kill_enemy"
QSkill.TRIGGER_CONDITION_SELF_DEATH = "self_death"
QSkill.TRIGGER_CONDITION_DAMAGE = "damage"
QSkill.TRIGGER_CONDITION_PHYSICAL_SKILL = "physical_skill"
QSkill.TRIGGER_CONDITION_MAGIC_SKILL = "magic_skill"
QSkill.TRIGGER_CONDITION_MAGIC_KILL = "magic_kill"
QSkill.TRIGGER_CONDITION_PHYSICAL_KILL = "physical_kill"

QSkill.TRIGGER_CONDITION_NORMAL_SKILL_TREAT = "normal_skill_treat"
QSkill.TRIGGER_CONDITION_NORMAL_SKILL_NOT_TREAT = "normal_skill_attack"

QSkill.TRIGGER_CONDITION_FIXED_DAMAGE = "fixed_damage"
QSkill.TRIGGER_CONDITION_USE_MANUAL_SKILL = "use_manual_skill"
QSkill.TRIGGER_CONDITION_USE_ACTIVE_NOT_MANUAL = "use_active_not_normal"

QSkill.TRIGGER_CONDITION_TREATING = "treating"

QSkill.TRIGGER_CONDITION_ENEMY_HERO_USE_SKILL = "enemy_hero_use_manual_skill"
QSkill.TRIGGER_CONDITION_BUFF_OWNER_DEATH = "buff_owner_death"

QSkill.TRIGGER_CONDITION_BULLET_DAMAGE = "bullet_damage"
QSkill.TRIGGER_CONDITION_COUNT_FULL = "count_full"

QSkill.TRIGGER_CONDITION_RAGE_FULL = "rage_full"
QSkill.TRIGGER_CONDITION_DIFF_ATTACKER = "diff_attacker"

-- 触发skill的事件
QSkill.TRIGGER_EVENT_MANUAL_SKILL_DAMAGE = "manual_skill_damage"

-- skill event
QSkill.EVENT_SKILL_DISABLE = "qskill.event_skill_disable"
QSkill.EVENT_SKILL_ENABLE = "qskill.event_skill_enable"

QSkill.REMOVE_ALL = "all"

local SKIN_IGNORE_PROP = {"id"}

-- 吹飞技能决定高度函数
local function BLOWUP_HEIGHT(skillHeight, actorWidth, actorHeight)
    return skillHeight
end

local function stringToNumberArray(str)
    if type(str) == "string" then
        local arr = {}
        local words = string.split(str, ";")
        for _, word in ipairs(words) do
            arr[#arr + 1] = tonumber(word)
        end
        return arr
    else
        return {tonumber(str)}
    end
end

local function getBonusProperty(t, l)
    return t[math.min(#t, l or 1)]
end

function QSkill:get(key)
    return self._getInfo[key]
end

function QSkill:set(key, value)
    self._getInfo[key] = value
end

function QSkill:getOriginal(key)
    return self._originalProp[key]
end

function QSkill:getId()
    return self:get("id")
end

function QSkill:ctor(id, properties, actor, level)
    if level == nil then
        level = 1
    end

    QSkill.super.ctor(self)

    local skillInfo = db:getSkillByID(id)
    local prop = q.cloneShrinkedObject(skillInfo)

    -- 皮肤技能会替换一些字段
    if actor then
        local skinSkillId = actor:getSkinSkillBySkillId(id)
        if skinSkillId then
            local skinProp = q.cloneShrinkedObject(db:getSkillByID(skinSkillId))
            for i,name in ipairs(SKIN_IGNORE_PROP) do
                skinProp[name] = nil
            end
            table.merge(prop, skinProp)
        end
    end

    local data = db:getSkillDataByIdAndLevel(prop.to_skill_data or id, level)
    data = q.cloneShrinkedObject(data)
    table.merge(prop, data)

    if prop.to_skill_data then
        prop.id = id
    end
    
    table.merge(prop, properties)
    if actor then
        actor:mergeModifySkillTable(prop, id)
        self._enhance_value = actor:getEnhanceSkillValueByID(id)
    end
    self._originalProp = clone(prop)
    if prop.modify_skill_property and prop.modify_skill_id then
        local propertyNames = string.split(prop.modify_skill_property, ";")
        for _, propertyName in ipairs(propertyNames) do
            prop[propertyName] = nil
        end
    end
    self._getInfo = prop

    self._id = self:get("id") or ""
    self._name = self:get("name") or ""
    self._display_name = self:get("name_display") or ""
    self._type = self:get("type") or ""
    self._attack_type = self:get("attack_type") or ""
    self._hit_type = self:get("hit_type") or "hit"
    self._damage_type = self:get("damage_type") or ""
    self._damage_target_percent = self:get("damage_target_percent")
    self._damage_target_percent_condition = self:get("damage_target_percent_condition") or "pvp"
    self._damage_self_percent = self:get("damage_self_percent")
    self._force_normal_damage = self:get("force_normal_damage")
    self._damage_p = self:get("damage_p") or 1
    self._physical_damage = self:get("physical_damage") or 1
    self._magic_damage = self:get("magic_damage") or 1
    self._bonus_damage_p = stringToNumberArray(self:get("bonus_damage_p") or 1)
    self._bonus_physical_damage = stringToNumberArray(self:get("bonus_physical_damage") or 1)
    self._bonus_magic_damage = stringToNumberArray(self:get("bonus_magic_damage") or 1)
    self._bonus_consume_status = self:get("bonus_consume_status") or false
    self._damage_split = self:get("damage_split") or false
    self._prjor = self:get("prjor") or 0
    self._cd = self:get("cd") or 1
    self._max_cast_count_before_cd = self:get("max_cast_count_before_cd") or 1
    self._cast_count_for_cd = 0
    self._minimum_interval = self:get("minimum_interval") or 0
    self._range_type = self:get("range_type")
    self._additional_target = self:get("additional_target")
    self._target_type = self:get("target_type") or "target"
    self._distance = (self:get("distance") or 1)
    self._distance_tolerance = (self:get("distance_tolerance") or 0)
    self._distance_minimum = (self:get("distance_minimum") or 0)
    self._zone_type = self:get("zone_type") or "fan"
    self._zone_speed = self:get("zone_speed") or 0
    self._cancel_while_move = (self:get("cancel_while_move") == nil) and true or self:get("cancel_while_move") 
    self._stop_moving = self:get("stop_moving") or false
    self._allow_moving = self:get("allow_moving") or false
    self._actor_attack_animation = self:get("actor_attack_animation") or ""
    self._sound = self:get("sound")
    self._soundDelay = self:get("sound_delay")
    self._bullet_speed = self:get("bullet_speed") or 1500
    self._skill_behavior = self:get("skill_behavior") or ""
    self._auto_target = self:get("auto_target") or false
    self._is_affected_by_haste = self:get("is_affected_by_haste") or false
    if self:get("is_cd_affected_by_haste") ~= nil then
        self._is_cd_affected_by_haste = self:get("is_cd_affected_by_haste")
    else
        self._is_cd_affected_by_haste = true
    end
    self._status = self:get("status") or ""
    self._behavior_status = self:get("behavior_status") or ""
    self._combo_points_need = self:get("combo_points_need") or false
    self._combo_points_gain = self:get("combo_points_gain") or 0
    self._rage_gain = self:get("rage_gain") or 0
    self._local_name = self:get("local_name") or ""
    self._trigger_skill_id = prop.trigger_skill_id
    self._trigger_condition_detail = prop.trigger_condition_detail
    self._level = level
    self._ghostLimit = self:get("ghost_limit")
    self._blowupChance = self:get("blowup_chance") or 0
    self._blowupHeight = self:get("blowup_height") or 150
    self._blowupUpTime = self:get("blowup_uptime") or 0.15
    self._blowupKeepTime = self:get("blowup_keeptime") or 0.5
    self._blowupDownTime = self:get("blowup_downtime") or 0.15
    self._blowupFallDamage = self:get("blowup_falldamage") or 0
    self._drainBloodPercent = self:get("drain_percent") or 0
    self._drainBloodForTeammate = self:get("drain_for_teammate") or false
    self._drainBloodSplit = self:get("drain_split") or false
    self._modify_skill_id = self:get("modify_skill_id")
    self._modify_skill_property = self:get("modify_skill_property")
    self._allowTrigger = self:get("allow_trigger") or false
    self._each_target_trigger_once = self:get("each_target_trigger_once") or false
    self._periodByTarget = self:get("period_by_target") or false -- 标示技能每一次释放都会有不同的效果（比如hit effect, damage之类），并且效果的变化是按照固定周期来的（hint: hit_effect是个数组），周期的重置由target的切换触发
    self._periodByTargetNum = self:get("period_by_target_num") or false -- 周期的重启由群体技能target的数量触发
    self._periodByBuffStatus = self:get("period_by_buff_status") -- 周期的重置由target身上的相同类型的buff数量触发
    self._periodByTeamHp = self:get("period_by_team_hp")
    self._periodByTeamHpCoef = self:get("period_by_team_hp_coef") or 0

    -- buff modifier
    self._modify_buff_id = self:get("modify_buff_id")
    self._modify_buff_property = self:get("modify_buff_property")
    self._modify_buff_id2 = self:get("modify_buff_id2")
    self._modify_buff_property2 = self:get("modify_buff_property2")
    self._enhance_skill_id = self:get("enhance_skill_id")
    self._enhance_skill_value = self:get("enhance_skill_value")
    self._exec_p = self:get("exec_p") or 0
    self._rage_atk = self:get("rage_atk") or 0
    self._beatback_time = self:get("beatback_time") or 0.15
    self._trigger_display_name = self:get("trigger_display_name") or false
    self._display_name_with_level = self:get("display_name_with_level") or false
    self._exec_effect = self:get("exec_effect")
    self._ignore_rage = self:get("ignore_rage") or false
    self._absorb_reduce_percent = self:get("absorb_reduce_percent")
    self._trigger_buff_once = self:get("trigger_buff_once") or false
    self._use_save_treat_percent_config = self:get("use_save_treat_percent_config") or nil
    self._depress_recover_hp_percent = self:get("depress_recover_hp_percent") or 0
    self._max_depress_recover_hp = self:get("max_depress_recover_hp") or 1
    self._show_mount_icon_start = self:get("show_mount_icon_start") or false
    self._skill_id_for_ghost = self:get("skill_id_for_ghost") or nil
    self._ignore_absorb = self:get("ignore_absorb") or false
    self._damage_threshold = self:get("damage_threshold") or nil
    self._godArmSkillAddFor = self:get("god_arm_skill_add_for")
    self._lock_num = self:get("lock_num") --锁定相同ID的passive skill触发次数
    -- damage*damge_absorb_scale < absorb_value时的伤害放大系数
    self._damage_absorb_scale = self:get("damage_absorb_scale")
    self._ignore_save_treat = self:get("ignore_save_treat") or false
    self._trigger_skill_immediately = self:get("trigger_skill_immediately") or false
    self._dragon_modifier = self:get("dragon_modifier") or 1

    self._property_promotion = {}

    if self:get("first_cd") == nil then
        self:set("first_cd", self:get("cd") or 1)
    end

    if self:get("over_treat_to_absorb") then
        local strs = string.split(self:get("over_treat_to_absorb"), ";")
        local config = {buff_id = strs[1], percent = tonumber(strs[2])}
        self._over_treat_to_absorb = config
    end

    if self:get("count_full_cfg") then
        local strs = string.split(self:get("count_full_cfg"), ";")
        self._count_full_cfg = {percent = tonumber(strs[1] or 0), count = tonumber(strs[2] or 1), not_clear_other = strs[3] and strs[3] == 'y'}
    end

    if self:get("arena_first_cd") == nil then
        self:set("arena_first_cd", self:get("cd") or 1)
    end

    if self:get("arena_cd") == nil then
        self:set("arena_cd", self:get("cd") or 1)
    end

    if self:get("buff_replace") ~= nil then
        local words = string.split(self:get("buff_replace"), ";")
        local replace_buff = {}
        local replace = nil
        for _, word in ipairs(words) do
            if string.len(word) >= 4 then
                replace = string.split(word, "->")
                if #replace == 2 then
                    replace_buff[replace[1]] = replace[2]
                end
            end
        end
        actor:addReplaceBuff(replace_buff)
    end

    self._actor = actor
    self._cdTimer = QTimer.new()
    self._ready = true
    self._periodTarget = nil -- 上一次周期效果时的target
    self._periodCount = 0 -- 周期数

    self._remove_status = {}
    for _, status in ipairs(string.split(self:get("remove_status"), ";")) do
        self._remove_status[status] = true
    end

    self._isUsed = 0
    self._cd_progress = 0
    self:_prepareAdditionEffects()
    self._cache = {}
    self._damagePFromScritp = nil --来自脚本的伤害系数，以后关于这个值的机制优先使用脚本，扩展性更好一点。

    if self:get("trigger_by_hit_count") then
        self._hit_list = setmetatable({}, {__mode = "k"})
        local cfg = string.split(self:get("trigger_by_hit_count"), ";")
        self._hit_count_cfg = {num = tonumber(cfg[1]), time = tonumber(cfg[2])}
        actor:addCustomEventListener(self, actor.CUSTOM_EVENT_HIT, nil, handler(self, self._onHitCallBack))
    end

    self:addTriggerEvent()
end

function QSkill:_onHitCallBack(attacker)
    if attacker == nil or attacker:isRanged() then return end
    local cur_time = app.battle:getDungeonDuration() - app.battle:getTimeLeft()
    if self._hit_list[attacker] == nil then
        self._hit_list[attacker] = {hit_count = 0, last_hit_time = cur_time}
    end
    local hit_cfg = self._hit_list[attacker]
    if cur_time - hit_cfg.last_hit_time <= self._hit_count_cfg.time then
        hit_cfg.hit_count = math.min(hit_cfg.hit_count + 1, self._hit_count_cfg.num)
    else
        hit_cfg.hit_count = 0
    end
    hit_cfg.last_hit_time = cur_time
end

function QSkill:isExtraConditionMet()
    if self._hit_list then
        local minNum = self._hit_count_cfg.num
        for actor,cfg in pairs(self._hit_list) do
            if cfg.hit_count >= minNum then
                return true
            end
        end
        return false
    else
        return true
    end
end

function QSkill:update(dt)
    if self._cdTimer:isStarted() then
        self._cdTimer.onTimer(dt)
    end
end

function QSkill:resetState()
    self:resetCoolDown()
    self._isUsed = 0
end

function QSkill:getName()
    return self._name
end

function QSkill:getLocalName()
    return self._local_name
end

-- 用于npc技能名字显示
function QSkill:getDisplayName()
    return self._display_name
end

function QSkill:getSkillLevel()
    return self._level
end

function QSkill:getIcon()
    return self:get("icon")
end

function QSkill:getDescription()
    return self:get("description")
end

local key = "isTalentSkill"
function QSkill:isTalentSkill()
    -- if we can find it from talent table, then it's talent skill, otherwise it is not
    if self._cache[key] == nil then
        self._cache[key] = false
        if self._actor:getTalentSkill() == self or self._actor:getTalentSkill2() == self then
            self._cache[key] = true
        end
    end

    return self._cache[key]
end

function QSkill:getDamageTargetPercent()
    return self._damage_target_percent
end

function QSkill:getDamageTargetPercentCondition()
    return self._damage_target_percent_condition
end

function QSkill:getDamageSelfPercent()
    return self._damage_self_percent
end

function QSkill:getForceNormalDamage()
    return self._force_normal_damage
end

function QSkill:getDamagePercent()
    -- 优先使用来自脚本设置的系数
    if self._damagePFromScritp then
        return self._damagePFromScritp
    end

    if nil ~= self:getPeriodByBuffNum() then
        local _, count = self._actor:isUnderStatus(self:getPeriodByBuffNum(), true)
        if count == 0 then count = 1 end
        local property = string.split(tostring(self._damage_p), ";")
        property = property[math.min(count, #property)]
        
        return property
    elseif self:isPeriodByTargetNum() then
        return tostring(self:_getTargetNumPeriodProperty(self._damage_p))
    else
        local property = tonumber(self:_getTargetPeriodProperty(self._damage_p))
        if self._periodByTeamHpCoef ~= 0 then
            local teammates = app.battle:getMyTeammates(self._actor, true, true)
            local deadHeroes
            if self._actor:getType() == ACTOR_TYPES.HERO then
                deadHeroes = app.battle:getDeadHeroes()
            else
                deadHeroes = app.battle:getDeadEnemies()
            end
            local lostHpPercent = #deadHeroes
            for _, actor in ipairs(teammates) do
                lostHpPercent = lostHpPercent + (1.0 - actor:getHp() / actor:getMaxHp())
            end
            lostHpPercent = lostHpPercent / 4.0
            local tab = string.split(self._periodByTeamHp, ";")
            local coef = math.min(math.floor(lostHpPercent / self._periodByTeamHpCoef) * tonumber(tab[1]), tonumber(tab[2]))
            property = property * (1 + coef)
        end
        return property
    end
end

function QSkill:getBonusDamagePercent(bonusLevel)
    return getBonusProperty(self._bonus_damage_p, bonusLevel)
end

function QSkill:getZoneType(index)
    index = index or 1
    return string.split(self._zone_type,";")[index]
end

function QSkill:getZoneSpeed()
    return self._zone_speed
end

function QSkill:isZoneFollow()
    return self:get("is_zone_follow") or false
end

function QSkill:getRectWidth(index)
    local str =  tostring(self:get("rect_width"))
    index = index or 1
    return tonumber(string.split(str,";")[index]) or 0
end

function QSkill:getRectHeight(index)
    local str =  tostring(self:get("rect_height"))
    index = index or 1
    return tonumber(string.split(str,";")[index]) or 0
end

function QSkill:getRectCenterOffset(index)
    local str =  self:get("rect_center_offset")
    if not str then
        return  ""
    end
    index = index or 1
    return string.split(str,";")[index] or ""
end

-- 以谁为释放中心(自己/目标)
function QSkill:getSectorCenter()
    return self:get("sector_center") or "target"
end

-- 以谁为释放中心(自己/目标)
function QSkill:getSectorCenterTrapStatus()
    return self:get("sector_center_trap_status")
end

function QSkill:getSectorCenterOffset()
    return self:get("sector_center_offset") or ""
end

function QSkill:getSectorRadius()
    return self:get("sector_radius") or 0
end

function QSkill:getSectorDegree()
    return self:get("sector_degree") or 360
end

function QSkill:getSectorX()
    return self:get("sector_x") or 0
end

function QSkill:getSectorY()
    return self:get("sector_y") or 0
end

function QSkill:getYRatio()
    return self:get("y_ratio") or 2
end

function QSkill:getTargetType()
    return self._target_type
end

function QSkill:getTargetID()
    return self:get("target_id") or ""
end

function QSkill:getLevelCheckDice()
    return self:get("level_check_dice") or 0
end

function QSkill:getHealerHpCondition()
    return self:get("healer_hp_condition") or 0.8
end

function QSkill:isNeedATarget()
    if (self:getRangeType() == QSkill.SINGLE and self:getTargetType() ~= QSkill.SELF) 
        or (self:getRangeType() == QSkill.MULTIPLE
            and self:getZoneType() == QSkill.ZONE_FAN
            and self:getSectorCenter() == QSkill.CENTER_TARGET) then 
        -- local actor = self:getActor()
        -- local target = actor:getTarget()
        -- if self:get("auto_target") and not target then
        --     local actor_position = actor:getPosition()
        --     local enemies = app.battle:getMyEnemies(actor)
        --     for _, enemy in ipairs(enemies) do
        --         local enemy_position = enemy:getPosition()
        --         if not enemy:isDead() and self:isInSkillRange(actor_position, enemy_position, actor, enemy) then
        --             if app.grid then
        --                 local area = app.grid:getRangeArea()
        --                 if enemy_position.x >= area.left and enemy_position.x <= area.right and enemy_position.y >= area.bottom and enemy_position.y <= area.top then
        --                     return false
        --                 end
        --             end
        --         end
        --     end
        -- end
        return true
    end
    return false
end

-- 作用域类型(单体/群体)
function QSkill:getRangeType()
    return self._range_type
end

function QSkill:isAdditionalTarget()
    return self._additional_target
end

function QSkill:getDamageSplit()
    return self._damage_split
end

function QSkill:isBonusDamageConditionMet(target)
    local cond = self:get("bonus_damage_cond")
    if cond == nil or cond == "" then
        return false
    end
    return self:_calculateCondition(cond, true, target)
end

function QSkill:isBonusConsumeStatus()
    return self._bonus_consume_status
end

function QSkill:getBonusConsumeStatus()
    local cond = self:get("bonus_damage_cond")
    local words = string.split(cond, "_")
    local status = ""
    for i = 3, #words do
        status = status .. words[i]
        if i ~= #words then
            status = status .. "_"
        end
    end
    return status
end

function QSkill:getPhysicalDamage()
    return tostring(self:_getTargetPeriodProperty(self._physical_damage))
end

function QSkill:getMagicDamage()
    return tostring(self:_getTargetPeriodProperty(self._magic_damage))
end

function QSkill:getBonusPhysicalDamage(bonusLevel)
    return getBonusProperty(self._bonus_physical_damage, bonusLevel)
end

function QSkill:getBonusMagicDamage(bonusLevel)
    return getBonusProperty(self._bonus_magic_damage, bonusLevel)
end

function QSkill:getDamageType()
    return self._damage_type
end

function QSkill:getAttackType()
    return self._attack_type
end

function QSkill:getHitType()
    return self._hit_type
end

function QSkill:getEnhanceValue()
    return self._enhance_value
end

function QSkill:setEnhanceValue(enhance_value)
    self._enhance_value = enhance_value
end

function QSkill:getAttackDistanceMinimum()
    -- return self:get("distance_minimum") * global.pixel_per_unit
    return self._distance_minimum * global.pixel_per_unit
end

function QSkill:getAttackDistance()
    -- return self:get("distance") * global.pixel_per_unit
    -- if self._actor:isSoulSpirit() and self._distance == 10 then
    --     return 20 * global.pixel_per_unit
    -- else
        return self._distance * global.pixel_per_unit
    -- end
end

function QSkill:getAttackDistanceTolerance()
    -- return self:get("distance_tolerance") * global.pixel_per_unit
    return self._distance_tolerance * global.pixel_per_unit
end

function QSkill:getSkillRange(isIncludeTolerance)
    local minmum = self:getAttackDistanceMinimum()
    local maxmum = self:getAttackDistance()
    if isIncludeTolerance == true then
        maxmum = maxmum + self:getAttackDistanceTolerance()
    end
    return minmum, maxmum
end

function QSkill:getActorAttackAnimation()
    return self._actor_attack_animation
end

function QSkill:getSound()
    return self._sound
end

function QSkill:getSoundDelay()
    return self._soundDelay
end

function QSkill:getAttackEffectID()
    local effectID = self:get("attack_effect") or ""
    if string.len(effectID) == 0 then
        effectID = nil
    end
    return effectID
end

function QSkill:getBulletEffectID()
    local effectID = self:get("bullet_effect") or ""
    if string.len(effectID) == 0 then
        effectID = nil
    end
    return effectID
end

function QSkill:getBulletSpeed()
    return self._bullet_speed
end

function QSkill:getHitEffectID()
    local effectID = self:get("hit_effect") or ""
    if string.len(effectID) == 0 then
        effectID = nil
    end
    return self:_getTargetPeriodProperty(effectID)
end

function QSkill:getSecondHitEffectID()
    local effectID = self:get("second_hit_effect") or ""
    if string.len(effectID) == 0 then
        effectID = nil
    end
    return effectID
end

function QSkill:getInterval()
    return self:get("interval") or 1
end

function QSkill:getMinimumInterval()
    return self._minimum_interval
end

function QSkill:getCdTime() 
    local cd = 0
    if self._isUsed == 0 then
        if app.battle:isPVPMode() and app.battle:isInArena() then
            cd = self:get("arena_first_cd")
        elseif app.battle:isPVPMode() and app.battle:isInSunwell() then
            cd = self:get("cd") or 1
        else
            if self:get("enter_cd") == nil then
                cd = self:get("first_cd")
            else
                cd = self:get("enter_cd")
            end
        end

        -- glyphs: pvp_manual_skill_first_cd_reduce
        if app.battle:isPVPMode() and self:getSkillType() == QSkill.MANUAL then
            cd = cd - self:getActor():getActorPropValue("pvp_manual_skill_first_cd_reduce")
            cd = math.max(cd, 0)
        end
    else
        if app.battle:isPVPMode() and app.battle:isInArena() then
            cd = self:get("arena_cd")
        else
            if self._isUsed == 1 and self:get("enter_cd") ~= nil then
                cd = self:get("first_cd")
            else
                cd = self:get("cd") or 1
            end
        end
    end
    return cd
end

function QSkill:getBuffId1()
    return self:get("buff_id_1") or ""
end

function QSkill:getBuffId2()
    return self:get("buff_id_2") or ""
end

function QSkill:getBuffId3()
    return self:get("buff_id_3") or ""
end

function QSkill:getBuffTargetType1()
    return self:get("buff_target_type_1") or ""
end

function QSkill:getBuffTargetType2()
    return self:get("buff_target_type_2") or ""
end

function QSkill:getBuffTargetType3()
    return self:get("buff_target_type_3") or ""
end

function QSkill:isBuffConditionMet1()
    local orconds = {}
    local andconds = {}

    local orresults = {}
    local andresults = {}

    local max = 2
    local index = 1
    while index <= max do
        local orcond = self:get("buff_1_or_cond_" .. index)
        if orcond ~= nil and orcond ~= "" then
            table.insert(orconds, orcond)
            index = index + 1
        else
            index = index + 1
        end
    end
    local index = 1
    while index <= max do
        local andcond = self:get("buff_1_and_cond_" .. index)
        if andcond ~= nil and andcond ~= "" then
            table.insert(andconds, andcond)
            index = index + 1
        else
            index = index + 1
        end
    end

    for _, cond in ipairs(orconds) do
        local result = self:_calculateCondition(cond)
        table.insert(orresults, result)
    end
    for _, cond in ipairs(andconds) do
        local result = self:_calculateCondition(cond)
        table.insert(andresults, result)
    end

    local met = true
    for _, result in ipairs(andresults) do
        met = met and result
    end
    for _, result in ipairs(orresults) do
        met = met or result
    end

    return met
end

function QSkill:isBuffConditionMet2()
    local orconds = {}
    local andconds = {}

    local orresults = {}
    local andresults = {}

    local max = 2
    local index = 1
    while index <= max do
        local orcond = self:get("buff_2_or_cond_" .. index)
        if orcond ~= nil and orcond ~= "" then
            table.insert(orconds, orcond)
            index = index + 1
        else
            index = index + 1
        end
    end
    local index = 1
    while index <= max do
        local andcond = self:get("buff_2_and_cond_" .. index)
        if andcond ~= nil and andcond ~= "" then
            table.insert(andconds, andcond)
            index = index + 1
        else
            index = index + 1
        end
    end

    for _, cond in ipairs(orconds) do
        local result = self:_calculateCondition(cond)
        table.insert(orresults, result)
    end
    for _, cond in ipairs(andconds) do
        local result = self:_calculateCondition(cond)
        table.insert(andresults, result)
    end

    local met = true
    for _, result in ipairs(andresults) do
        met = met and result
    end
    for _, result in ipairs(orresults) do
        met = met or result
    end

    return met
end

function QSkill:isBuffConditionMet3()
    local orconds = {}
    local andconds = {}

    local orresults = {}
    local andresults = {}

    local max = 2
    local index = 1
    while index <= max do
        local orcond = self:get("buff_3_or_cond_" .. index)
        if orcond ~= nil and orcond ~= "" then
            table.insert(orconds, orcond)
            index = index + 1
        else
            index = index + 1
        end
    end
    local index = 1
    while index <= max do
        local andcond = self:get("buff_3_and_cond_" .. index)
        if andcond ~= nil and andcond ~= "" then
            table.insert(andconds, andcond)
            index = index + 1
        else
            index = index + 1
        end
    end

    for _, cond in ipairs(orconds) do
        local result = self:_calculateCondition(cond)
        table.insert(orresults, result)
    end
    for _, cond in ipairs(andconds) do
        local result = self:_calculateCondition(cond)
        table.insert(andresults, result)
    end

    local met = true
    for _, result in ipairs(andresults) do
        met = met and result
    end
    for _, result in ipairs(orresults) do
        met = met or result
    end

    return met
end

function QSkill:getTrapId()
    local trapId = self:get("trap_id") or ""
    if string.len(trapId) <= 0 then
        return nil
    end
    return trapId
end

function QSkill:getRage1()
    return self:get("rage_1") or 0
end

function QSkill:getRageTargetType1()
    return self:get("rage_target_type_1") or ""
end

function QSkill:getSkillBehaviorName()
    return self._skill_behavior
end

function QSkill:setSkillBehaviorName(behavior)
    self._skill_behavior = behavior
end

function QSkill:getSkillType()
    return self._type
end

function QSkill:getSkillPriority()
    return self._prjor
end

function QSkill:getActor()
    return self._actor
end

function QSkill:isReady()
    if self:isNeedRage() and not self._actor:isSoulSpirit() then
        -- 如果是需要怒气的技能，不需要看是否冷却
        return self:getActor():isRageEnough()
    end

    if not self._ready then return false end

    if not self:isNeedComboPoints() or self:getActor():getComboPoints() > 0 then
        return true
    else 
        return false
    end
end

function QSkill:isCDOK()
    return self._ready or false
end

function QSkill:isTreatSkill()
    return self._attack_type == treat
end

function QSkill:isBulletSkill()
    return self._bullet_effect ~= nil 
end

function QSkill:isRemoteSkill()
    local distance = self:getAttackDistance()
    return (distance >= global.ranged_attack_distance * global.pixel_per_unit)
end

function QSkill:getTriggerType()
    return self._additionEffects.trigger_type
end

function QSkill:getTriggerCondition()
    if string.len(self._additionEffects.trigger_condition) == 0 then
        return nil
    end
    return self._additionEffects.trigger_condition
end

function QSkill:getTriggerConditionDetail()
    return self._trigger_condition_detail
end

function QSkill:getTriggerConditionSkillID()
    return self._additionEffects.trigger_condition_skill_id
end

function QSkill:getTriggerProbability()
    return self._additionEffects.trigger_probability
end

function QSkill:getTriggerBuffId(index)
    local trigger_buff_id = self._additionEffects.trigger_buff_id
    return trigger_buff_id[math.min(#trigger_buff_id, index or 1)]
end

function QSkill:getTriggerBuffTargetType()
    return self._additionEffects.trigger_buff_target_type
end

function QSkill:getTriggerSkillId()
    local trigger_skill_id = self._trigger_skill_id
    if type(trigger_skill_id) == "number" then
        return trigger_skill_id
    elseif type(trigger_skill_id) == "string" then
        if string.find(trigger_skill_id, ";") then
            local objs = string.split(trigger_skill_id, ";")
            return tonumber(objs[1]), objs[2]
        elseif  string.find(trigger_skill_id, ",") then
            local objs = string.split(trigger_skill_id, ",")
            return tonumber(objs[1], tonumber(objs[2]))
        else
            return tonumber(trigger_skill_id)
        end
    end
end

function QSkill:getTriggerSkillAsCurrent()
    return self._additionEffects.trigger_skill_as_current
end

function QSkill:getTriggerSkillInheritPercent()
    return self:get("trigger_skill_inherit_percent") or 0
end

function QSkill:getTriggerComboPoints()
    return self:get("trigger_combo_points") or 0
end

function QSkill:getTriggerRage()
    return self:get("trigger_rage") or 0
end

function QSkill:getTriggerPropertyModifier()
    return self:get("trigger_property_modifier") or ""
end

function QSkill:getTriggerDamageModifier()
    return self:get("trigger_damage_modifier") or 1
end

function QSkill:canRemoveBuff()
    return self._additionEffects.can_remove_buff
end

function QSkill:isCancelWhileMove()
    return self._additionEffects.cancel_while_move
end

function QSkill:isStopMoving()
    return self._additionEffects.stop_moving
end

function QSkill:isAllowMoving()
    return self._additionEffects.allow_moving
end

function QSkill:isSelectActor()
    return self:get("is_select_actor")
end

function QSkill:getStatus()
    return self._status
end

function QSkill:getBehaviorStatus()
    return self._behavior_status
end

function QSkill:isRemoveStatus(status)
    if status == nil or self._remove_status[QSkill.REMOVE_ALL] then return true end
    if type(status) == "string" then
        return status ~= "" and self._remove_status[status]
    else
        for remove_status,v in pairs(self._remove_status) do
            if status[remove_status] then
                return true
            end
        end
    end
end

function QSkill:getAdditionValueWithKey(key)
    return self._additionEffects[key]
end

function QSkill:isAdditionForMain()
    return self:get("addition_for_main") or false
end

function QSkill:_prepareAdditionEffects()
    self._additionEffects = {
        -- 触发效果(攻击和受击时有几率触发)
        trigger_condition = nil, -- skill or hit
        trigger_condition_skill_id = nil,
        trigger_probability = 0,
        trigger_type = nil, -- buff or attack
        trigger_buff_id = nil,
        trigger_buff_target_type = nil,
        -- trigger_skill_id = nil,
        trigger_skill_as_current = false,
        -- 特殊效果
        can_remove_buff = false, -- 能取消某些buff
        cancel_while_move = true, -- 移动时技能自动撤销
        stop_moving = false, -- 释放时停止移动
        allow_moving = false, -- 释放时，stop_moving为true时，是否允许移动
        -- 特殊机制
        duration_time = 0,  -- 持续时间
        interval_time = 0,  -- 间隔时间
    }

    -- table.merge(self._additionEffects, clone(global.additions))

    self:_setAdditionEffect(self:get("addition_type_1"), self:get("addition_value_1") or 0)
    self:_setAdditionEffect(self:get("addition_type_2"), self:get("addition_value_2") or 0)
    self:_setAdditionEffect(self:get("addition_type_3"), self:get("addition_value_3") or 0)
    self:_setAdditionEffect(self:get("addition_type_4"), self:get("addition_value_4") or 0)
    self:_setAdditionEffect(self:get("addition_type_5"), self:get("addition_value_5") or 0)
    self:_setAdditionEffect(self:get("addition_type_6"), self:get("addition_value_6") or 0)
    self:_setAdditionEffect("trigger_condition", self:get("trigger_condition") or "")
    self:_setAdditionEffect("trigger_condition_skill_id", self:get("trigger_condition_skill_id"))
    self:_setAdditionEffect("trigger_probability", self:get("trigger_probability") or 1)
    self:_setAdditionEffect("trigger_type", self:get("trigger_type" or ""))
    self:_setAdditionEffect("trigger_buff_id", string.split(self:get("trigger_buff_id" or ""), ","))
    self:_setAdditionEffect("trigger_buff_target_type", self:get("trigger_buff_target_type") or "")
    -- self:_setAdditionEffect("trigger_skill_id", self._trigger_skill_id)
    self:_setAdditionEffect("trigger_skill_as_current", self:get("trigger_skill_as_current") or false)
    self:_setAdditionEffect("can_remove_buff", self:get("can_remove_buff") or false)
    self:_setAdditionEffect("cancel_while_move", (self:get("cancel_while_move") == nil) and true or self:get("cancel_while_move"))
    self:_setAdditionEffect("stop_moving", self:get("stop_moving") or false)
    self:_setAdditionEffect("allow_moving", self:get("allow_moving") or false)

    self._additionEffects.trigger_probability = self._additionEffects.trigger_probability * 100

end

function QSkill:_setAdditionEffect(prop, value)
    if prop ~= nil and string.len(prop) > 0 then
        self._additionEffects[prop] = value
    end
end

function QSkill:_setEffectValueToBoolean(key)
    if key == nil or self._additionEffects[key] == nil then
        return
    end

    if type(self._additionEffects[key]) == "boolean" then
        return
    end

    if self._additionEffects[key] == 0 then
        self._additionEffects[key] = false
    else
        self._additionEffects[key] = true
    end
end

function QSkill:coolDown(cd_time, isSupport)
    if not self._ready then 
        return 
    end

    if self:isNeedRage() and self:getSkillType() == QSkill.MANUAL and not isSupport then
        self._cd_time = 1.0 
        self._cd_progress = 1.0
        return
    end

    local cd_time = cd_time or self:getCdTime()
    if cd_time == 0 then
        self._isUsed = self._isUsed + 1
        return
    end

    self._cast_count_for_cd = self._cast_count_for_cd + 1
    if self._cast_count_for_cd < self._max_cast_count_before_cd then
        return
    else
        self._cast_count_for_cd = 0
    end

    self._cd_time = cd_time or self:getCdTime()
    self._cd_progress = 0.0
    self:_startCd()
    self._isUsed = self._isUsed + 1

    if self._hit_list then
        for actor,cfg in pairs(self._hit_list) do
            cfg.hit_count = 0
        end
    end
end

function QSkill:reduceCoolDownTime(time)
    if self._ready == true then
        return
    end

    if time == nil or time <= 0 then
        return
    end

    self._cdTimer.onTimer(time)
end

function QSkill:getLeftCoolDownTime()
    if self._cd_time then
        return self._cd_time * (1 - self._cd_progress)
    end
    return 0
end

function QSkill:resetCoolDown()
    if not self._ready then 
        self._cdTimer:stop()
        self._cdTimer:removeCountdown(QDEF.EVENT_CD_CHANGED)
        self._ready = true
    end
end

function QSkill:pauseCoolDown(isForce)
    if isForce then
        self._force_pause_cooldown = true
    end
    self._cdTimer:pause()
end

function QSkill:resumeCoolDown(isForce)
    if self._force_pause_cooldown == true and isForce ~= true then
        return
    end
    self._force_pause_cooldown = nil
    self._cdTimer:resume()
end

function QSkill:getCDProgress()
    return self._cd_progress
end

function QSkill:_startCd()
    self._ready = false

    self:dispatchEvent({name = QDEF.EVENT_CD_STARTED, skill = self})

    self._cdTimer:addEventListener(QDEF.EVENT_CD_CHANGED, handler(self, self._onCdChanged))
    self._cdTimer:addCountdown(QDEF.EVENT_CD_CHANGED, 600, 0.1)
    self._cdTimer:start()
end

function QSkill:_stopCd()
    self._ready = true

    self:dispatchEvent({name = QDEF.EVENT_CD_CHANGED, skill = self, cd_progress = 0})
    self:dispatchEvent({name = QDEF.EVENT_CD_STOPPED, skill = self})

    self._cdTimer:stop()
    self._cdTimer:removeCountdown(QDEF.EVENT_CD_CHANGED)
end

function QSkill:_onCdChanged(event)
    -- TOFIX: 把技能的冷却放入battle的tick中去
    if app.battle == nil then
        self._cdTimer:stop()
        self._cdTimer:removeCountdown(QDEF.EVENT_CD_CHANGED)
        return
    end

    event.skillId = self:getId()

    local actor = self:getActor()

    local cd_time = self._cd_time
    local cd_progress = self._cd_progress
    local coefficient = self:isCDAffectedByHaste() and self._actor:getMaxHasteCoefficient() or 1
    cd_progress = cd_progress + coefficient * event.dt / cd_time * app.battle:getTimeGear()
    self._cd_progress = cd_progress

    if self._cd_progress >= 1 then
        self:_stopCd()
    end
    
    event.skill = self
    event.cd_progress = cd_progress
    self:dispatchEvent(event)
end

function QSkill:isInSkillRange(startPosition, targetPosition, actor, target, isIncludeTolerance)
    local deltaX = startPosition.x - targetPosition.x
    local deltaY = (startPosition.y - targetPosition.y) * 2
    local deltaY2 = deltaY * deltaY
    if deltaY2 < global.melee_distance_y_for_skill then
        deltaY2 = global.melee_distance_y_for_skill
    end
    -- deltaY = math.max(math.abs(deltaY), (global.melee_distance_y + 1) * 24 * 0.6)
    -- local distance = deltaX * deltaX + deltaY * deltaY
    local distance = deltaX * deltaX + deltaY2

    local minmum, maxmum = self:getSkillRange(isIncludeTolerance)
    if actor and target then
        local actorWidth = actor:getRect().size.width * 0.5
        local targetWidth = target:getRect().size.width * 0.5
        maxmum = maxmum + actorWidth + targetWidth
    end
    minmum = minmum * minmum
    maxmum = maxmum * maxmum

    -- target should in outer rect and not in inner rect
    if distance <= maxmum then
        if minmum <= 0 or distance > minmum then
            return true
        end
    end
    return false
end

-- todo performance fix
function QSkill:_calculateCondition(cond, getConditionLevel, target, attackee)
    local met = false
    local conditionLevel
    local condition = cond
    if condition ~= "" then
        local words = string.split(condition, "_")
        while #words >= 2 do
            met = false
            if words[1] == "probability" then
                local probability = tonumber(words[2])
                if type(probability) == "number" then
                    met = probability * 100 >= app.random(1, 100)
                end
            elseif #words >= 3 then
                -- 角色单词
                local actor = nil
                if words[1] == "target" then
                    actor = target or (self._actor and self._actor:getTarget())
                elseif words[1] == "self" then
                    actor = self._actor
                elseif words[1] == "attackee" then
                    actor = attackee
                else
                    met = false
                end
                if actor == nil then
                    break
                end

                -- 比较值
                if words[2] == "hp" then
                    if #words == 5 then
                        local value = nil
                        local value2 = nil
                        value = actor:getHp()
                        value2 = actor:getMaxHp()

                        -- 调整比较值
                        local value_adjust = nil
                        if words[3] == "percent" then
                            value_adjust = value / value2
                        elseif words[3] == "value" then
                            value_adjust = value
                        else
                            met = false
                        end
                        if value_adjust == nil then
                            break
                        end

                        -- 取得条件数值
                        local condition_value = tonumber(words[5])
                        assert(type(condition_value) == "number", "")

                        -- 比较符号
                        if words[4] == "smaller" then
                            met = value_adjust <= condition_value
                        elseif words[4] == "greater" then
                            met = value_adjust >= condition_value
                        else
                            met = false
                        end
                    end
                elseif words[2] == "status" then
                    local status = ""
                    for i = 3, #words do
                        status = status .. words[i]
                        if i ~= #words then
                            status = status .. "_"
                        end
                    end
                    met, conditionLevel = actor:isUnderStatus(status, getConditionLevel)
                else
                    met = false
                end
            end

            break
        end
    end

    return met, conditionLevel
end


-- 把cd冷却与所有的与或条件一起考虑的"condition是否met"
-- todo performance fix
function QSkill:isReadyAndConditionMet(ignore_cd, attackee)
    if self:isNeedRage() and not self:getActor():isRageEnough() then
    -- check use condition - rage
        return false
    end

    if self:isNeedComboPoints() and self:getActor():getComboPoints() <= 0 then
        return false
    end

    local orconds = {}
    local andconds = {}

    local orresults = {}
    local andresults = {}

    local index = 1
    local max = 2
    while index <= max do
        local orcond = self:get("or_cond_" .. index)
        if orcond ~= nil and orcond ~= "" then
            table.insert(orconds, orcond)
            index = index + 1
        else
            index = index + 1
        end
    end
    local index = 1
    while index <= max do
        local andcond = self:get("and_cond_" .. index)
        if andcond ~= nil and andcond ~= "" then
            table.insert(andconds, andcond)
            index = index + 1
        else
            index = index + 1
        end
    end

    for _, cond in ipairs(orconds) do
        local result = self:_calculateCondition(cond, nil, nil, attackee)
        table.insert(orresults, result)
    end
    for _, cond in ipairs(andconds) do
        local result = self:_calculateCondition(cond, nil, nil, attackee)
        table.insert(andresults, result)
    end

    local met = ignore_cd and true or self:isReady()
    for _, result in ipairs(andresults) do
        met = met and result
    end
    for _, result in ipairs(orresults) do
        met = met or result
    end

    return met
end

function QSkill:isAffectedByHaste()
    return self._is_affected_by_haste
end

function QSkill:isCDAffectedByHaste()
    if self._actor:isSupport() then
        return false
    end
    return self._is_cd_affected_by_haste
end

function QSkill:getComboPointsGain()
    return self._combo_points_gain
end

function QSkill:isNeedComboPoints()
    return self._combo_points_need
end

function QSkill:isNeedRage()
    local isNeedRage = self._isNeedRage
    if isNeedRage == nil then
        if self:get("haveNotRage") == true then
            isNeedRage = false 
        else
            isNeedRage = self._actor:hasRage() and
            (self:getSkillType() == QSkill.MANUAL and self ~= self._actor:getVictorySkill()) and
            not self:isNeedComboPoints()
        end
        isNeedRage = not not isNeedRage
        self._isNeedRage = isNeedRage
    end
    return isNeedRage
end

function QSkill:getRageGain()
    return self._rage_gain
end

function QSkill:isAdditionOn()
    return self._addition_on
end

function QSkill:setInheritedDamage(inherited_damage)
    self._inherited_damage = inherited_damage
end

function QSkill:getInHeritedDamage()
    return self._inherited_damage
end

function QSkill:getBattleForce()
    return self:get("battle_force") or 0
end

function QSkill:getTipModifier()
    return self:get("tip_modifier")
end

function QSkill:getTriggerTipModifier()
    return self:get("trigger_tip_modifier")
end

function QSkill:getTriggerSpriteFrame()
    return self:get("trigger_sprite_frame")
end

function QSkill:isTriggerDisplayName()
    return self._trigger_display_name
end

function QSkill:isDisplayNameWithLevel()
    return self._display_name_with_level
end

function QSkill:getGhostHP()
    return self:get("ghost_hp") or 0.01
end

function QSkill:getBeatbackChance()
    return self:get("beatback_chance") or 0
end

function QSkill:getBeatbackDistance()
    return self:get("beatback_distance") or 50
end

function QSkill:getBeatbackHeight()
    return self:get("beatback_height") or 0
end

function QSkill:isBeatbackDirectionByAttacker()
    return self:get("isBeatbackDirectionByAttacker") or false
end

function QSkill:getBlowupChance()
    return self._blowupChance
end

function QSkill:getBlowupHeight(attackee)
    local rect = attackee:getRect()
    return BLOWUP_HEIGHT(self._blowupHeight, rect.width, rect.height)
end

function QSkill:getBlowupUpTime()
    return self._blowupUpTime
end

function QSkill:getBlowupKeepTime()
    return self._blowupKeepTime
end

function QSkill:getBlowupDownTime()
    return self._blowupDownTime
end

function QSkill:getBlowupFallDamage()
    return self._blowupFallDamage
end

function QSkill:isTriggeredSkill()
    return self._isTriggeredSkill
end

function QSkill:setIsTriggeredSkill(is)
    self._isTriggeredSkill = is
end

function QSkill:getBaoqi()
    return self:get("baoqi") or -1
end

-- damager参与到伤害数值的计算(仅仅作为伤害数值计算时代替attacker出现，在计算距离、范围、AI等逻辑方面不参与）
function QSkill:setDamager(damager)
    self._damager = damager
end

function QSkill:getDamager()
    return self._damager
end

function QSkill:cleanup()
    self._cdTimer:stop()
    self._cdTimer:removeCountdown(QDEF.EVENT_CD_CHANGED)

    self._actor:removeCustomEventListener(self)
end

function QSkill:getHPSegment()
    if self._segments == nil then
        local segments = {}
        local str = self:get("trigger_hp_segment") or ""
        local words = string.split(str, ";")
        for _, word in ipairs(words) do
            if (word ~= "") then
                segments[#segments + 1] = tonumber(word)
            end
        end
        table.sort(segments, function(segmentA, segmentB) return segmentA < segmentB end)
        self._segments = segments
    end
    return self._segments
end

function QSkill:setSegmentBuff(index, buff)
    if self._segmentsBuff == nil then
        self._segmentsBuff = {}
    end
    self._segmentsBuff[index] = buff
end

function QSkill:getSegmentBuff(index)
    if self._segmentsBuff == nil then
        self._segmentsBuff = {}
    else
        return self._segmentsBuff[index]
    end
end

function QSkill:isAllowBulletTime()
    return self:get("allow_bullet_time")
end

function QSkill:addSummonedGhost(ghost)
    if self._summonedGhosts == nil then
        self._summonedGhosts = {}
    end
    self._summonedGhosts[#self._summonedGhosts + 1] = ghost
end

function QSkill:getSummonedGhosts()
    if self._summonedGhosts == nil then
        self._summonedGhosts = {}
    end
    return self._summonedGhosts
end

function QSkill:getLivingSummonedGhostCount()
    local count = 0
    for _, ghost in ipairs(self:getSummonedGhosts()) do
        if not ghost:isDead() then
            count = count + 1
        end
    end
    return count
end

function QSkill:getGhostLimit()
    return self._ghostLimit
end

function QSkill:getDrainBloodPercent()
    return self._drainBloodPercent
end

function QSkill:getDrainBloodForTeammate()
    return self._drainBloodForTeammate
end

function QSkill:getDrainBloodSplit()
    return self._drainBloodSplit
end

function QSkill:getModifySkillID()
    return self._modify_skill_id
end

function QSkill:getModifySkillProperty()
    return self._modify_skill_property
end

function QSkill:getModifyBuffID()
    return self._modify_buff_id
end

function QSkill:getModifyBuffProperty()
    return self._modify_buff_property
end

function QSkill:getModifyBuffID2()
    return self._modify_buff_id2
end

function QSkill:getModifyBuffProperty2()
    return self._modify_buff_property2
end

function QSkill:getEnhanceSkillID()
    return self._enhance_skill_id
end

function QSkill:getEnhanceSkillValue()
    return self._enhance_skill_value
end

function QSkill:setIsGodSkill()
    self._is_god_skill = true
end

function QSkill:isGodSkill()
    return self._is_god_skill == true
end

function QSkill:setMountId(mountId)
    self._mountId = mountId
    local config = db:getCharacterByID(mountId)
    if config then
        self._mountAnimationFileName = config.aid_bust
        self._mountLabelFileName = db:getSkillByID(self:getId()).zuoqi_label
    end
end

function QSkill:getMountId()
    return self._mountId
end

function QSkill:getMountAnimationFileName()
    return self._mountAnimationFileName
end

function QSkill:getMountLabelFileName()
    return self._mountLabelFileName
end

function QSkill:isAllowTrigger()
    return self._allowTrigger
end

function QSkill:isEachTargetTriggerOnce()
    return self._each_target_trigger_once
end

function QSkill:_getTargetPeriodProperty(property)
    if self._periodByTarget then
        property = string.split(tostring(property), ";")
        property = property[math.fmod(self._periodCount, #property) + 1]
        return property
    else
        return property
    end
end

function QSkill:isPeriodByTarget()
    return self._periodByTarget
end

function QSkill:changePeriodTarget(target)
    if self._periodTarget == target then
        self._periodCount = self._periodCount + 1
    else
        self._periodCount = 0
    end
    self._periodTarget = target
end

function QSkill:isPeriodByTargetNum()
    return self._periodByTargetNum
end

function QSkill:setMuiltipleTargets(targets)
    self._muiltipleTargets = targets
end

function QSkill:getMuiltipleTargets()
    return self._muiltipleTargets
end

function QSkill:getPeriodByBuffNum()
    return self._periodByBuffStatus
end

function QSkill:_getTargetNumPeriodProperty(property)
    if self._periodByTargetNum and self:getRangeType() == QSkill.MULTIPLE
        and self._muiltipleTargets and #self._muiltipleTargets > 0 then
        
        property = string.split(tostring(property), ";")
        property = property[math.min(#self._muiltipleTargets, #property)]
    end

    return property
end

function QSkill:getExecutePercent()
    return self._exec_p
end

function QSkill:getRageAttack()
    return self._rage_atk
end

function QSkill:isChargeSkill()
    if self:getSkillType() == QSkill.ACTIVE and
        not self:getActor():isRanged()
    then
        local cond = self:getTriggerCondition()
        return 
            cond == QSkill.TRIGGER_CONDITION_DRAG_OR_DRAG_ATTACK or
            cond == QSkill.TRIGGER_CONDITION_DRAG or
            cond == QSkill.TRIGGER_CONDITION_DRAG_ATTACK
    end
    return false
end

function QSkill:getTargetDeadBehavior()
    return self:get("target_dead_behavior") or nil
end

-- 获取大招奥义icon
function QSkill:getStrokesIcon()
    return self:get("strokes_icon") or nil
end

function QSkill:getStrokesDelay()
    return self:get("strokes_delay") or 0
end

-- 获取矩形的旋转角度
function QSkill:getRectAngle(index)
    local str =  tostring(self:get("rect_angle"))
    index = index or 1
    return tonumber(string.split(str,";")[index]) or 0
end

function QSkill:isMoveSkill()
    return self:get("is_move_skill")
end

function QSkill:getBeatBackTime()
    return self._beatback_time
end

function QSkill:getTriggerCondition2()
    return self:get("trigger_or_condition1")
end

function QSkill:getTriggerCondition3()
    return self:get("trigger_or_condition2")
end

function QSkill:checkCondition(condition)
    if self:getTriggerCondition() == condition then
        return true
    elseif self:getTriggerCondition2() == condition then
        return true
    elseif self:getTriggerCondition3() == condition then
        return true
    end
    return false
end

function QSkill:getFixedDamage()
    return self:get("fixed_damage_value") or 0
end

function QSkill:getExecuteEffect()
    return self._exec_effect
end

function QSkill:ignoreRage()
    return self._ignore_rage
end

function QSkill:ignoreAbsorb()
    return self._ignore_absorb
end

function QSkill:getReduceAbsorbPercent()
    return self._absorb_reduce_percent
end

function QSkill:isTriggerBuffOnce()
    return self._trigger_buff_once
end

function QSkill:ignoreSaveTreat()
    return self._ignore_save_treat or self._use_save_treat_percent_config ~= nil
end

function QSkill:getUseSaveTreatPercent()
    if self._use_save_treat_config then
        return self._use_save_treat_config[1],self._use_save_treat_config[2],self._use_save_treat_config[3]
    end

    local cfgs = string.split(self._use_save_treat_percent_config,";")
    self._use_save_treat_config = {tonumber(cfgs[1]) or 0, cfgs[2], tonumber(cfgs[3]) or 1}
    return self._use_save_treat_config[1],self._use_save_treat_config[2],self._use_save_treat_config[3]
end

function QSkill:getDepressRecoverHpLimit()
    return self._max_depress_recover_hp
end

function QSkill:showMountIconWithBattleStart()
    return self._show_mount_icon_start
end

function QSkill:getSkillIdForGhost()
    return self._skill_id_for_ghost
end

function QSkill:countDamage(actor, damage)
    if not self._count_full_cfg then
        return false
    end
    if not self._count_damage_tbl then
        self._count_damage_tbl = {}
    end
    if not self._count_damage_tbl[actor] then
        self._count_damage_tbl[actor] = {}
    end
    table.insert(self._count_damage_tbl[actor], damage)
    if #self._count_damage_tbl[actor] >= self._count_full_cfg.count then
        local damage = 0
        for i,v in ipairs(self._count_damage_tbl[actor]) do
            damage = damage + v
        end
        damage = damage * self._count_full_cfg.percent
        if self._count_full_cfg.not_clear_other then
            self._count_damage_tbl[actor] = {}
        else
            self._count_damage_tbl = {}
        end
        return true, actor, damage
    end
    return false
end

function QSkill:addPropertyPromotion(name, value)
    self._property_promotion[name] = value
end

function QSkill:removePropertyPromotion()
    self._property_promotion = {}
end

function QSkill:getPropertyPromotion()
    return self._property_promotion
end

function QSkill:setDamagePercentFromScript(damageP)
    self._damagePFromScritp = damageP
end

function QSkill:getDamageThreshold()
    return self._damage_threshold
end

function QSkill:getGodSkillLabel()
    return self:get("god_skill_label")
end

function QSkill:disableChangeTargetWithBehavior()
    return self:get("disable_change_target_with_behavior") or false
end

function QSkill:isIgnoreRageAbsorbReducePercent()
    return self:get("ignore_rage_absorb_reduce_percent") or false
end

function QSkill:inheritDamageIgnoreCoefficient()
    return self:get("inherit_damage_ignore_coefficient") or false
end

function QSkill:isAllowNoTarget()
    return self:get("allow_no_target") or false
end

function QSkill:isUncriticalSkill()
    return self:get("is_uncritical") or false
end

function QSkill:isLockSkill()
    return self:get("lock_num") ~= nil
end

function QSkill:getSurplusTrigger()
    if self._lock_map_key == nil then self._lock_map_key = self._id .. "locked_num" .. self._actor:getType() end
    local lockedNum = app.battle:getFromMap(self._lock_map_key) or 0
    return self:get("lock_num") - lockedNum
end

function QSkill:addLockNum()
    if self._lock_map_key == nil then self._lock_map_key = self._id .. "locked_num" .. self._actor:getType() end
    local lockedNum = app.battle:getFromMap(self._lock_map_key) or 0
    app.battle:setFromMap(self._lock_map_key, lockedNum + 1)
end

function QSkill:sumLockNum()
    if self._lock_map_key == nil then self._lock_map_key = self._id .. "locked_num" .. self._actor:getType() end
    local lockedNum = app.battle:getFromMap(self._lock_map_key) or 0
    if lockedNum <= 0 then return end
    app.battle:setFromMap(self._lock_map_key, lockedNum - 1)
end

function QSkill:getDamgeAbsorbScale()
    return self._damage_absorb_scale
end

function QSkill:getOverTreatToAbsorb()
    return self._over_treat_to_absorb
end

function QSkill:isTriggerSkillImmediately()
    return self._trigger_skill_immediately
end

function QSkill:getDragonModifier()
    if app.battle:isInUnionDragonWar() then
        return self._dragon_modifier
    else
        return 1.0
    end
end

function QSkill:triggerSelf(event)
    event.skill = self
    self._actor:triggerPassiveSkillByEvent(event)
end

function QSkill:addTriggerEvent()
    if self._actor and self:getTriggerCondition() == self.TRIGGER_EVENT_MANUAL_SKILL_DAMAGE then
        self._triggerEventHandle = cc.EventProxy.new(self._actor)
        self._triggerEventHandle:addEventListener(self.TRIGGER_EVENT_MANUAL_SKILL_DAMAGE,
            handler(self, self.triggerSelf))
    end
end

function QSkill:removeTriggerEvent()
    self._triggerEventHandle:removeAllEventListeners()
    self._triggerEventHandle = nil
end

return QSkill
