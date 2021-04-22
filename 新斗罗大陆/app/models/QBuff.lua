local QBuff
if IsServerSide then
    local EventProtocol = import("EventProtocol")
    QBuff = class("QBuff", EventProtocol)
else
    local QModelBase = import("..models.QModelBase")
    QBuff = class("QBuff", QModelBase)
end

QBuff.TRIGGER = "TRIGGER_BUFF"

local QSkill = import ".QSkill"

-- aura buff
QBuff.ENEMY = "enemy"
QBuff.TEAMMATE = "teammate"
QBuff.TEAMMATE_AND_SELF = "teammate_and_self"

-- hit buff target type
QBuff.BUFF_SELF = "self"
QBuff.BUFF_TARGET = "target"

-- buff trigger type
QBuff.TRIGGER_TYPE_BUFF = "buff"
QBuff.TRIGGER_TYPE_ATTACK = "attack"
QBuff.TRIGGER_TYPE_REMOVE_BUFF = "remove"
QBuff.TRIGGER_TYPE_REPLACE_BUFF = "replace"
QBuff.TRIGGER_TYPE_COMBO = "combo"
QBuff.TRIGGER_TYPE_CD_REDUCE = "cd_reduce"
QBuff.TRIGGER_TYPE_RAGE = "rage"
QBuff.TRIGGER_TYPE_HEAL = "heal"
QBuff.TRIGGER_TYPE_DAMAGE = "damage"
QBuff.TRIGGER_TYPE_DAMAGE_HEAL = "damage_heal"
QBuff.TRIGGER_TYPE_ADDITION_TIME = "addition_time"
QBuff.TRIGGER_TYPE_CHANGE_TRIGGER_CD = "change_trigger_cd"

-- buff trigger condition
QBuff.TRIGGER_CONDITION_HIT = "hit"
QBuff.TRIGGER_CONDITION_HIT_PHYSICAL = "hit_physical"
QBuff.TRIGGER_CONDITION_HIT_MAGIC = "hit_magic"
QBuff.TRIGGER_CONDITION_DODGE = "dodge"
QBuff.TRIGGER_CONDITION_BLOCK = "block"
QBuff.TRIGGER_CONDITION_MISS = "miss"
QBuff.TRIGGER_CONDITION_SKILL = "skill"
QBuff.TRIGGER_CONDITION_NORMAL_SKILL = "normal_skill"
QBuff.TRIGGER_CONDITION_ACTIVE_SKILL = "active_skill"
QBuff.TRIGGER_CONDITION_MANUAL_SKILL = "manual_skill"
QBuff.TRIGGER_CONDITION_SKILL_CRITICAL = "skill_critical"
QBuff.TRIGGER_CONDITION_SKILL_ATTACK = "skill_attack"
QBuff.TRIGGER_CONDITION_SKILL_ATTACK_CRITICAL = "skill_attack_critical"
QBuff.TRIGGER_CONDITION_SKILL_TREAT = "skill_treat"
QBuff.TRIGGER_CONDITION_SKILL_TREAT_CRITICAL = "skill_treat_critical"
QBuff.TRIGGER_CONDITION_TICK = "tick"
QBuff.TRIGGER_CONDITION_STACK_FULL = "stack_full"
QBuff.TRIGGER_CONDITION_ATTACKER_STACK_FULL = "attacker_stack_full"
QBuff.TRIGGER_CONDITION_ACTIVE_NOT_NORMAL = "active_not_normal"

QBuff.TRIGGER_CONDITION_NORMAL_SKILL_TREAT = "normal_skill_treat"
QBuff.TRIGGER_CONDITION_NORMAL_SKILL_NOT_TREAT = "normal_skill_attack"
QBuff.TRIGGER_CONDITION_BUFF_REMOVE = "buff_remove"
QBuff.TRIGGER_CONDITION_NORMAL_SKILL_HIT = "normal_skill_hit"

QBuff.TRIGGER_CONDITION_CONTROL = "control"
QBuff.TRIGGER_CONDITION_BE_CONTROLED = "be_controled"

QBuff.TRIGGER_CONDITION_CUSTOM_EVENT = "custom_event"

QBuff.TRIGGER_CONDITION_IMMUNE_PHYSICAL_DAMAGE = "immune_physical_damage"
QBuff.TRIGGER_CONDITION_IMMUNE_MAGIC_DAMAGE = "immune_magic_damage"

QBuff.TRIGGER_CONDITION_DAMAGE = "damage"

QBuff.TRIGGER_CONDITION_SAVE_TREAT_LIMIT = "save_treat_limit"
QBuff.TRIGGER_CONDITION_SAVE_DAMAGE_LIMIT = "save_damage_limit"
QBuff.TRIGGER_CONDITION_SELF_DEATH = "self_death"

QBuff.IMMUNE_ALL = "all"

-- buff trigger target
QBuff.TRIGGER_TARGET_SELF = "self"
QBuff.TRIGGER_TARGET_TEAMMATE = "teammate"
QBuff.TRIGGER_TARGET_TEAMMATE_AND_SELF = "teammate_and_self"
QBuff.TRIGGER_TARGET_ENEMY = "enemy"
QBuff.TRIGGER_TARGET_TEAMMATE_OF_SOULSPIRIT = "teammate_of_soulspirit"
-- custom event target 
QBuff.CUSTOM_EVENT_TARGET_SELF = "self"
QBuff.CUSTOM_EVENT_TARGET_TEAMMATE = "teammate"
QBuff.CUSTOM_EVENT_TARGET_TEAMMATE_AND_SELF = "teammate_and_self"
QBuff.CUSTOM_EVENT_TARGET_ENEMY = "enemy"
QBuff.CUSTOM_EVENT_TARGET_BUFF_ATTACKER = "buff_attacker"
-- save treat source 
QBuff.SAVE_TREAT_FROM_DRAIN_BLOOD = "drain_blood"

local _posEffectTable = {
    ["attack_value"] = 1, -- 正值表示正为增益，负为减益。数值的绝对值只是序号，可以随意赋值。
    ["attack_percent"] = 2,
    ["hp_value"] = 3,
    ["hp_percent"] = 4,
    ["armor_physical"] = 5,
    ["armor_physical_percent"] = 6,
    ["armor_magic"] = 7,
    ["hit_rating"] = 8,
    ["hit_chance"] = 9,
    ["dodge_rating"] = 10,
    ["dodge_chance"] = 11,
    ["block_rating"] = 12,
    ["block_chance"] = 13,
    ["critical_rating"] = 14,
    ["critical_chance"] = 15,
    ["critical_damage"] = 16,
    ["movespeed_value"] = 17,
    ["movespeed_percent"] = 18,
    ["haste_rating"] = 19,
    ["attackspeed_chance"] = 20,
    ["physical_damage_percent_attack"] = 22,
    ["physical_damage_percent_beattack_reduce"] = 23,
    ["magic_damage_percent_attack"] = 24,
    ["magic_damage_percent_beattack_reduce"] = 25,
    ["magic_treat_percent_attack"] = 26,
    ["magic_treat_percent_beattack"] = 27, -- 负值表示正为减益，负为增益。数值的绝对值只是序号，可以随意赋值。
    ["cri_reduce_rating"] = 28,
    ["cri_reduce_chance"] = 29,
    ["physical_penetration_value"] = 30,
    ["magic_penetration_value"] = 31,
    ["ignore_magic_armor_percent"] = 32,
    ["ignore_physical_armor_percent"] = 33,
    ["physical_damage_percent_beattack"] = -34,
    ["magic_damage_percent_beattack"] = -35,
    ["aoe_beattack_percent"] = -36,
    ["attack_steal_percent"] = 37,
    ["attackspeed_steal_percent"] = 38,
    ["armor_physical_stealed"] = 39,
    ["armor_magic_stealed"] = 40,
    ["absorb_damage_value"] = 41,
    ["absorb_damage_percent_attacker"] = 42,
    ["absorb_damage_percent_owner"] = 43,
    ["max_hp_stealed"] = 44,
}

local damage_reduction = {
    ["physicalArmor"] = "getPhysicalArmor",
    ["damage"] = "damage",

}

-- 定义属性
QBuff.schema = {}
QBuff.schema["name"]                                = {"string"} -- 字符串类型，没有默认值
QBuff.schema["is_aura"]                             = {"boolean", false} -- 是否是光环
QBuff.schema["aura_radius"]                         = {"number", 30} -- 光环半径，24pixel为一个单位
QBuff.schema["aura_radius_max"]                     = {"number", -1} -- 光环的最大半径
QBuff.schema["aura_target_type"]                    = {"string", "teammate_and_self"} -- 光环影响的对象
QBuff.schema["aura_target_effece_id"]               = {"string", ""} -- 光环影响到的对象身上的对象（受到interval_time的ticking的影响）
QBuff.schema["duration"]                            = {"number", 0}
QBuff.schema["mutative_time"]                       = {"number", 0}
QBuff.schema["interval_time"]                       = {"number", 0}
QBuff.schema["influence_with_attack"]               = {"boolean", false}
QBuff.schema["influence_coefficient"]               = {"number", 0}
QBuff.schema["effect_type_1"]                       = {"string", ""}
QBuff.schema["effect_type_2"]                       = {"string", ""}
QBuff.schema["effect_type_3"]                       = {"string", ""}
QBuff.schema["effect_type_4"]                       = {"string", ""}
QBuff.schema["effect_type_5"]                       = {"string", ""}
QBuff.schema["effect_type_6"]                       = {"string", ""}
QBuff.schema["effect_type_7"]                       = {"string", ""}
QBuff.schema["effect_type_8"]                       = {"string", ""}
QBuff.schema["effect_type_9"]                       = {"string", ""}
QBuff.schema["effect_type_10"]                      = {"string", ""}
QBuff.schema["effect_type_config"]                  = {"string", ""} -- 不是直接获取value提升，而是根据配置获取value提升
QBuff.schema["effect_type_config_f"]                = {"string", ""} -- 获取属性最终值来提升角色属性
QBuff.schema["effect_value_1"]                      = {"number", 0}
QBuff.schema["effect_value_2"]                      = {"number", 0}
QBuff.schema["effect_value_3"]                      = {"number", 0}
QBuff.schema["effect_value_4"]                      = {"number", 0}
QBuff.schema["effect_value_5"]                      = {"number", 0}
QBuff.schema["effect_value_6"]                      = {"number", 0}
QBuff.schema["effect_value_7"]                      = {"number", 0}
QBuff.schema["effect_value_8"]                      = {"number", 0}
QBuff.schema["effect_value_9"]                      = {"number", 0}
QBuff.schema["effect_value_10"]                     = {"number", 0}
QBuff.schema["effect_value_config"]                 = {"string", ""}
QBuff.schema["effect_value_config_f"]               = {"string", ""}
QBuff.schema["effect_condition"]                    = {"string", ""}
QBuff.schema["time_stop"]                           = {"boolean", false}
QBuff.schema["can_control_move"]                    = {"boolean", true}
QBuff.schema["can_charge_or_blink"]                 = {"boolean", true}
QBuff.schema["can_use_skill"]                       = {"boolean", true}
QBuff.schema["can_cast_spell"]                      = {"boolean", true}
QBuff.schema["can_be_removed_with_skill"]           = {"boolean", false}
QBuff.schema["can_be_removed_with_hit"]             = {"boolean", false}
QBuff.schema["adaptivity_helmet"]                   = {"number", 0}
QBuff.schema["is_knockback"]                        = {"boolean", true}
QBuff.schema["replace_character"]                   = {"number", -1}
QBuff.schema["keep_replace_character"]              = {"boolean", false}
QBuff.schema["replace_ai"]                          = {"string", ""}
QBuff.schema["color"]                               = {"string", ""}
QBuff.schema["gray"]                                = {"boolean", false}
QBuff.schema["begin_effect_id"]                     = {"string", ""}
QBuff.schema["effect_id"]                           = {"string", ""}
QBuff.schema["effect_id2"]                          = {"string", ""}
QBuff.schema["finish_effect_id"]                    = {"string", ""}
QBuff.schema["status"]                              = {"string", ""}
QBuff.schema["immune_status"]                       = {"string", ""}
QBuff.schema["immune_physical_damage"]              = {"boolean", false}
QBuff.schema["immune_magic_damage"]                 = {"boolean", false}
QBuff.schema["override_group"]                      = {"string", ""}
QBuff.schema["level"]                               = {"number", 0}
QBuff.schema["stack_number"]                        = {"number", 1}
QBuff.schema["trigger_condition"]                   = {"string", ""}
QBuff.schema["trigger_probability"]                 = {"number", 1}
QBuff.schema["trigger_max_count"]                   = {"number", -1}
QBuff.schema["trigger_target"]                      = {"string", "self"}
QBuff.schema["trigger_cd"]                          = {"number", 0}
QBuff.schema["trigger_type"]                        = {"string", ""}
QBuff.schema["trigger_buff_id"]                     = {"string", ""}
QBuff.schema["trigger_buff_target_type"]            = {"string", ""}
-- QBuff.schema["trigger_skill_id"]                    = {"number", -1}
QBuff.schema["trigger_skill_as_current"]            = {"boolean", false}
QBuff.schema["trigger_skill_inherit_percent"]       = {"number", 0}
QBuff.schema["trigger_combo_points"]                = {"number", 0}
QBuff.schema["trigger_rage"]                        = {"number", 0}
QBuff.schema["trigger_rage_percent"]                = {"number", 0}
QBuff.schema["trigger_period"]                      = {"number", 1}
QBuff.schema["trigger_damage_co"]                   = {"number", 0}
QBuff.schema["trigger_heal_co"]                     = {"number", 0}
QBuff.schema["absorb_damage_value"]                 = {"number", 0}
QBuff.schema["absorb_damage_percent_attacker"]      = {"number", 0}
QBuff.schema["absorb_damage_percent_owner"]         = {"number", 0}
QBuff.schema["absorb_render_damage_percent"]        = {"number", 0}
QBuff.schema["absorb_render_heal_percent"]          = {"number", 0}
QBuff.schema["absorb_damage_rage_ratio"]            = {"number", 1}
QBuff.schema["scale_percent"]                       = {"number", 0}
QBuff.schema["drain_blood"]                         = {"boolean", false} -- 用于dot，每跳的伤害可以返还给攻击者
QBuff.schema["no_tip"]                              = {"boolean", false}
QBuff.schema["tip_modifier"]                        = {"string"} -- 伤害浮动数字修饰词（仅仅针对受到伤害的buff owner起效，对受到治疗的情况无效）
QBuff.schema["allow_bullet_time"]                   = {"boolean", false} -- 允许在黑屏期间内运行
QBuff.schema["attack_steal_percent"]                = {"number", 0}
QBuff.schema["drain_blood_physical"]                = {"number", 0} -- 用于状态类buff，buff的持有者可以从其物理攻击伤害中吸血
QBuff.schema["drain_blood_magic"]                   = {"number", 0} -- 用于状态类buff，buff的持有者可以从其魔法攻击伤害中吸血

QBuff.schema["trigger_skill_use_attacker_prop"]     = {"boolean", false} -- 当buff触发技能的时候生效,当值为true时 buff触发的技能的伤害会取自buff的释放者，伤害统计中伤害也会统计在buff释放者身上
QBuff.schema["is_auto_clear"]                       = {"boolean",false}
QBuff.schema["is_ghost_buff"]                       = {"boolean",false}
QBuff.schema["trigger_or_condition1"]               = {"string",nil}
QBuff.schema["trigger_or_condition2"]               = {"string",nil}
QBuff.schema["is_neutralize_same_id"]               = {"boolean", false}
QBuff.schema["replace_standard_action"]             = {"string", ""}
QBuff.schema["trigger_remove_skill_status"]         = {"string",nil} --移除后触发的被动技能的id
QBuff.schema["save_damage_config"]                  = {"string", nil} --劫大招buff 格式是 系数;伤害上限 比如0.5;1
QBuff.schema["save_treat_config"]                   = {"string", nil} -- 吸收治疗量
QBuff.schema["save_treat_end_flag"]                 = {"boolean", false} --控制存储治疗量buff到duration移除的标识
QBuff.schema["addition_time_config"]                = {"string", nil}
QBuff.schema["replace_character_enter_skill"]       = {"string", nil}
QBuff.schema["property_effect_by_time"]             = {"boolean", false} -- 属性是否受时间影响

QBuff.schema["custom_event_name"]                   = {"string", nil} -- 自定义事件名称
QBuff.schema["custom_event_target_type"]            = {"string", "teammate_and_self"} --自定义事件目标类型
QBuff.schema["custom_event_params"]                 = {"string", nil} --自定义事件参数
QBuff.schema["custom_event_trigger_as_attacker"]    = {"boolean", false} -- 触发的目标

QBuff.schema["replace_character_skills"]            = {"string", nil} --变身替换技能

QBuff.schema["immune_death"]                        = {"boolean", false} -- 免疫死亡
QBuff.schema["immune_death_no_trigger"]             = {"boolean", false} -- 免疫死亡时不会触发passive skill
QBuff.schema["lock_hp"]                             = {"boolean", false} -- 锁血
QBuff.schema["damage_limit_config"]                 = {"string", nil} --伤害上限

QBuff.schema["attackspeed_steal_percent"]           = {"number", 0}
QBuff.schema["physical_penetration_by_attack"]      = {"number", 0}
QBuff.schema["magic_penetration_by_attack"]         = {"number", 0}
QBuff.schema["hp_affect_probability"]               = {"boolean", false}
QBuff.schema["hp_affect_probability_limit"]         = {"string", nil} 
QBuff.schema["steal_property_name"]                 = {"string", nil} 
QBuff.schema["steal_property_value"]                = {"number", 0} 
QBuff.schema["steal_dst"]                           = {"string", 0}
QBuff.schema["trigger_immediately"]                 = {"boolean", false}
QBuff.schema["buff_effect_reduce"]                  = {"number", 0}
QBuff.schema["buff_from_other_effect_reduce"]       = {"number", 0}
QBuff.schema["dot_grow_coefficient"]                = {"number", -1} -- dot 或者hot伤害的增长速度
QBuff.schema["hide_immune_word"]                    = {"boolean", false} -- 如果buff被免疫了 不显示免疫字符
QBuff.schema["change_trigger_cd_config"]            = {"string", nil} -- 如果buff被免疫了 不显示免疫字符
QBuff.schema["damage_to_absorb"]                    = {"number", 0} -- 伤害吸盾
QBuff.schema["absorb_segment_effect"]               = {"string", nil} -- 伤害特效
QBuff.schema["absorb_hp_segment"]                   = {"string", nil} -- 伤害特效用的
QBuff.schema["is_damage_hp_percent"]                = {"boolean", false} -- 伤害是生命百分比而不是绝对数值
QBuff.schema["is_damage_hp_percent_by_attacker"]    = {"boolean", false} -- 去自己的最大生命百分比作为伤害数值来源
QBuff.schema["absorb_value_limit"]                  = {"number", 0} -- 伤害是生命百分比而不是绝对数值
QBuff.schema["is_add_to_log"]                       = {"boolean", true} -- dot/hot 需不需要添加到伤害统计上
QBuff.schema["save_treat_type"]                     = {"string", "treat"}
QBuff.schema["save_treat_target"]                   = {"string", "attacker"}
QBuff.schema["sync_treat_coefficient"]              = {"number", 0}
QBuff.schema["damage_reduction_value"]              = {"number", 0}
QBuff.schema["damage_reduction_percent"]            = {"number", 0}
QBuff.schema["damage_reduction_data_source"]        = {"string", "physicalArmor"}
QBuff.schema["is_save_damage_ignore_attacker"]      = {"boolean", false}
QBuff.schema["use_new_stack_number"]                = {"boolean", false}
QBuff.schema["count_absorb_to_owner"]               = {"boolean", false}
QBuff.schema["treat_enhance_percent_by_lost_hp"]    = {"number", 0}
QBuff.schema["is_use_new_tick"]                     = {"boolean", false} --波赛西的tick时间，自身黑屏期间也会tick
QBuff.schema["is_right_tick"]                       = {"boolean", false} --使用新的tick时间，不会在黑屏期间tick
QBuff.schema["is_absolute_cost_absorb"]             = {"boolean", false} --会绕开无视护盾，护盾百分比穿透的属性
QBuff.schema["dragon_modifier"]                     = {"number", 1.0} -- 龙战伤害修饰参数
QBuff.schema["neutralize_damage"]                   = {"number", 0} -- 抵消伤害百分比
QBuff.schema["damage_reduction_no_render"]          = {"boolean", false} -- 抵消伤害百分比

function QBuff:get(key)
    local value = self._getInfo[key]
    if value ~= nil then
        return value
    else
        return QBuff.schema[key][2]
    end
end

function QBuff:set(key, value)
    self._getInfo[key] = value
end

function QBuff:getId()
    return self._id
end

local _pvpCoefficientsInitialized = false
local function InitializePVPCoefficients()
    if _pvpCoefficientsInitialized == false then
        local globalConfig = db:getConfiguration()
        local function getValue(k, dv)
            local v = dv
            if globalConfig[k] ~= nil and globalConfig[k].value ~= nil then
                v = globalConfig[k].value
            end
            QBuff[k] = v
        end
        getValue("ARENA_FINAL_DAMAGE_COEFFICIENT", 1)
        getValue("SUNWELL_FINAL_DAMAGE_COEFFICIENT", 1)
        getValue("SILVERMINE_FINAL_DAMAGE_COEFFICIENT", 1)
        getValue("ARENA_TREAT_COEFFICIENT", 1)
        getValue("SUNWELL_TREAT_COEFFICIENT", 1)
        getValue("SILVERMINE_TREAT_COEFFICIENT", 1)
        getValue("SOTO_TEAM_FINAL_DAMAGE_COEFFICIENT", 2)
        getValue("SOTO_TEAM_TREAT_COEFFICIENT", 1)
        _pvpCoefficientsInitialized = true
    end
end

function QBuff:ctor(id, actor, attacker, level, skill, replace_field)
    InitializePVPCoefficients()

    if level == nil then
        level = 1
    end

    local buffInfo = q.cloneShrinkedObject(db:getBuffByID(id))
    assert(buffInfo ~= nil, "buff id: " .. id .. " does not exist!")

    local dataInfo = q.cloneShrinkedObject(db:getBuffDataByIdAndLevel(buffInfo.to_buff_data or id, level))
    assert(dataInfo ~= nil, "buff_data id: " .. id .. " level: " .. level .. " does not exist!")
    -- TOFIX: SHRINK
    dataInfo.id = nil
    table.merge(buffInfo, dataInfo)
    if attacker then
        attacker:mergeModifyBuffTable(buffInfo, id)
    end

    if replace_field then
        table.merge(buffInfo, replace_field)
    end

    self._getInfo = buffInfo

    QBuff.super.ctor(self, buffInfo)

    self._id = self:get("id")

    self._passedTime = 0
    self._realPassedTime = 0
    self._lastTriggerTime = nil
    self._immuned = false
    self._actor = actor
    self._attacker = attacker
    self._attackerAttackValue = attacker and attacker:getAttack() or 0
    self._attackerPhysicalDamagePercentAttack = attacker and attacker:getPhysicalDamagePercentAttack() or 0
    self._attackerMagicDamagePercentAttack = attacker and attacker:getMagicDamagePercentAttack() or 0
    self._attackerMagicTreatPercentAttack = attacker and attacker:getMagicTreatPercentAttack() or 0
    self._aura_affectees = {}
    self._skill = skill
    self._enhance_value_multiply = 1 + ((skill and skill:getEnhanceValue()) or 0)
    self._save_damage = 0 --储存的伤害
    self._save_treat = 0 --储存的治疗
    self._trigger_immediately = self:get("trigger_immediately")
    self._hide_immune_word = self:get("hide_immune_word")
    self._change_trigger_cd_list = {}
    self._count_absorb_to_owner = self:get("count_absorb_to_owner")
    self._treat_enhance_percent_by_lost_hp = self:get("treat_enhance_percent_by_lost_hp")

    local damage_limit_config = self:get("damage_limit_config")
    if damage_limit_config then
        local cfg = string.split(damage_limit_config, ";")
        self._damage_limit_config = {limit = tonumber(cfg[1]), percent = tonumber(cfg[2]), hp = 0}
    end
    local absorb_hp_segment = self:get("absorb_hp_segment")
    local absorb_segment_effect = self:get("absorb_segment_effect")
    if absorb_hp_segment and absorb_segment_effect then
        local cfg = {}
        local segments = string.split(absorb_hp_segment, ";")
        local effects = string.split(absorb_segment_effect, ";")
        for i = 1, #segments do
            local value = segments[i]
            local effect = effects[i]
            if value and effect then
                table.insert(cfg, {segment = tonumber(value), effect = effect})
            else
                break
            end
        end
        table.sort(cfg, function(a,b) return a.segment < b.segment end)
        self._absorb_hp_segment_effect = cfg
    end

    self.effects = {
        -- 触发效果(一定的时间间隔内触发一次)
        interval_time = 0, --间隔时间
        physical_damage_value = 0, -- 物理伤害数值
        magic_damage_value = 0, -- 法术伤害数值
        treat_damage_value = 0, -- 治疗伤害数值
        rage_value = 0, -- 怒气数值
        treat_damage_percent = 0, -- 治疗百分比数值
        treat_damage_hp_percent = 0, -- 治疗百分比数值
        -- 吸收伤害效果
        absorb_damage_value = 0, -- 吸收物理和法术伤害值
        absorb_damage_percent_attacker = 0, -- 吸收物理和法术伤害值，值按buff释放者取
        absorb_damage_percent_owner = 0, -- 吸收物理和法术伤害值，值按buff受益者取
        -- 影响触发效果和吸收伤害效果的参数
        influence_with_attack = false, -- 是否受攻击力影响
        -- 特殊控制状态
        time_stop = false, -- 动作立即完全静止
        can_control_move = true, -- 玩家和AI能够控制移动
        can_use_skill = true, -- 能够使用技能
        can_cast_spell = true, -- 能够释放法术（非普攻类，非物理的技能）
        can_be_removed_with_skill = false, -- 此buff能够被自己释放的技能打断
        can_be_removed_with_hit = false, -- 此buff受攻击时能够被打断
        is_knockback = true, -- 此buff允许被击退
        replace_character = -1, -- 变身
        replace_ai = "", -- 变行为
        keep_replace_character = false, -- buff结束时，角色模型不会替换回来
        -- 状态已经状态免疫
        status = "", -- 该buff是什么状态
        immune_status = {}, -- 该buff能免疫什么状态
        override_group = "",
        level = 0,
        immune_death = false,-- 免疫死亡
        lock_hp = false, -- 锁血(不能扣血也不能回血)
        adaptivity_helmet = 0, -- 适应性头盔
        can_charge_or_blink = true, --能否冲锋或者闪现
    }
    -- 用于压入属性堆栈的effect
    self._effects = {}

    self:_setEffect(self:get("effect_type_1"), self:get("effect_value_1"))
    self:_setEffect(self:get("effect_type_2"), self:get("effect_value_2"))
    self:_setEffect(self:get("effect_type_3"), self:get("effect_value_3"))
    self:_setEffect(self:get("effect_type_4"), self:get("effect_value_4"))
    self:_setEffect(self:get("effect_type_5"), self:get("effect_value_5"))
    self:_setEffect(self:get("effect_type_6"), self:get("effect_value_6"))
    self:_setEffect(self:get("effect_type_7"), self:get("effect_value_7"))
    self:_setEffect(self:get("effect_type_8"), self:get("effect_value_8"))
    self:_setEffect(self:get("effect_type_9"), self:get("effect_value_9"))
    self:_setEffect(self:get("effect_type_10"), self:get("effect_value_10"))

    if self:get("effect_type_config") ~= "" and self:get("effect_value_config") ~= "" then
        local valueConfigList = string.split(self:get("effect_value_config"), ";")
        local valueType, valuePercent = valueConfigList[1], tonumber(valueConfigList[2])
        local typeConfig = string.split(self:get("effect_type_config"),";")
        local propType, srcType = typeConfig[1], typeConfig[2]
        local srcActor = self._actor
        if srcType == "attacker" then srcActor = self._attacker end
        valuePercent = valuePercent or 0
        self:_setEffect(propType, srcActor:_getActorNumberPropertyValue(valueType) * valuePercent)
    end

    if self:get("effect_type_config_f") ~= "" and self:get("effect_value_config_f") ~= "" then
        local valueConfigList = string.split(self:get("effect_value_config_f"), ";")
        local valueType, valuePercent = valueConfigList[1], tonumber(valueConfigList[2])
        local typeConfig = string.split(self:get("effect_type_config_f"),";")
        local propType, srcType = typeConfig[1], typeConfig[2]
        local srcActor = self._actor
        if srcType == "attacker" then srcActor = self._attacker end
        valuePercent = valuePercent or 0
        self:_setEffect(propType, srcActor[srcActor.funcTable[valueType]](srcActor) * valuePercent)
    end

    self.effects.interval_time = self:get("interval_time")
    self.effects.influence_with_attack = self:get("influence_with_attack")
    self.effects.influence_coefficient = self:get("influence_coefficient")
    self.effects.time_stop = self:get("time_stop")
    self.effects.can_control_move = self:get("can_control_move")
    self.effects.can_charge_or_blink = self:get("can_charge_or_blink")
    self.effects.can_use_skill = self:get("can_use_skill")
    self.effects.can_cast_spell = self:get("can_cast_spell")
    self.effects.can_be_removed_with_skill = self:get("can_be_removed_with_skill")
    self.effects.can_be_removed_with_hit = self:get("can_be_removed_with_hit")
    self.effects.is_knockback = self:get("is_knockback")
    self.effects.replace_character = self:get("replace_character")
    self.effects.keep_replace_character = self:get("keep_replace_character")
    self.effects.replace_ai = self:get("replace_ai")
    self.effects.override_group = self:get("override_group")
    self.effects.level = self:get("level")
    self.effects.absorb_damage_value = self:calcGainEffect("absorb_damage_value", self:get("absorb_damage_value"))
    self.effects.absorb_damage_percent_attacker = self:calcGainEffect("absorb_damage_percent_attacker", self:get("absorb_damage_percent_attacker"))
    self.effects.absorb_damage_percent_owner = self:calcGainEffect("absorb_damage_percent_owner", self:get("absorb_damage_percent_owner"))
    self.effects.effect_condition = self:get("effect_condition")
    self.effects.scale_percent = self:get("scale_percent")
    self.effects.immune_death = self:get("immune_death")
    self.effects.lock_hp = self:get("lock_hp")
    self.effects.adaptivity_helmet = self:get("adaptivity_helmet")
    local status = {}
    for i,k in ipairs(string.split(self:get("status"), ";")) do
        if k ~= "" then
            status[k] = true
        end
    end
    self.effects.status = status
    status = {}
    for i,k in ipairs(string.split(self:get("immune_status"), ";")) do
        status[k] = true
    end
    self.effects.immune_status = status
    local physical_penetration_by_attack = self:get("physical_penetration_by_attack")
    if physical_penetration_by_attack ~= 0 then
        self:_setEffect("extra_physical_penetration_value", physical_penetration_by_attack * actor:getAttack())
    end
    local magic_penetration_by_attack = self:get("magic_penetration_by_attack")
    if magic_penetration_by_attack ~= 0 then
        self:_setEffect("extra_magic_penetration_value", magic_penetration_by_attack * actor:getAttack())
    end

    self._trigger_skill_id = buffInfo.trigger_skill_id

    if self.effects.absorb_damage_value < 0 then
        self.effects.absorb_damage_value = 0
    end

    if self.effects.absorb_damage_percent_attacker < 0 then
        self.effects.absorb_damage_percent_attacker = 0
    end

    if self.effects.absorb_damage_percent_owner < 0 then
        self.effects.absorb_damage_percent_owner = 0
    end

    if self.effects.absorb_damage_value > 0 
        or self.effects.absorb_damage_percent_attacker > 0 
        or self.effects.absorb_damage_percent_owner > 0 
    then
        self._isAbsorbDamage = true
    end

    if self.effects.interval_time > 0 then
        self._executeCount = math.floor(self:get("duration") / self.effects.interval_time)
        self._currentExecute = 0
    end

    local attackValue = self:getAttackerAttackValue()
    local coefficient = self.effects.influence_coefficient + 1
    local combo_points_coefficient = (not attacker or not attacker:getCurrentSkill() or not attacker:getCurrentSkill():isNeedComboPoints()) and 1 or attacker:getComboPointsCoefficient()
    local damage_coefficient = (self._attacker and (not self._skill or not self._skill:isTalentSkill())) and self._attacker:getDamageCoefficient() or 0
    -- 如果是光环的话,物理法术的易伤和减免以及治疗的被治疗效果都应该取自受到影响的各个角色的QActor，而不是统一取自光环owner的QActor
    local attackee
    attackee = (self._attacker and self._attacker:getTarget()) or self._actor
    if self._attacker and attackee then
        if (self._attacker:getType() == ACTOR_TYPES.NPC and attackee:getType() == ACTOR_TYPES.NPC)
            or (self._attacker:getType() ~= ACTOR_TYPES.NPC and attackee:getType() ~= ACTOR_TYPES.NPC)
        then
            local enemies = app.battle:getMyEnemies(self._attacker)
            if (#enemies > 0) then
                attackee = enemies[1]
            end
        end
    end
    -- 物理DOT
    self._physical_damage_value = self.effects.physical_damage_value
    if self._physical_damage_value > 0 and not self:get("is_damage_hp_percent") then
        if self.effects.influence_with_attack == true then
            self._physical_damage_value = self._physical_damage_value + ((attackValue * attackValue) / (attackValue + attackee:getPhysicalArmor()) * coefficient)
        end
        -- self._physical_damage_value = self._physical_damage_value * (1 + attackee:getPhysicalDamagePercentUnderAttack())
        if app.battle:isPVPMode() then
            if app.battle:isInArena() then
                if app.battle:isSotoTeam() then
                    self._physical_damage_value = self._physical_damage_value * QBuff.SOTO_TEAM_FINAL_DAMAGE_COEFFICIENT
                else
                    self._physical_damage_value = self._physical_damage_value * QBuff.ARENA_FINAL_DAMAGE_COEFFICIENT
                end
            elseif app.battle:isInSunwell() then
                self._physical_damage_value = self._physical_damage_value * QBuff.SUNWELL_FINAL_DAMAGE_COEFFICIENT
            elseif app.battle:isInSilverMine() then
                self._physical_damage_value = self._physical_damage_value * QBuff.SILVERMINE_FINAL_DAMAGE_COEFFICIENT
            end
            self._physical_damage_value = self._physical_damage_value * math.max(1 + self._attacker:getPVPPhysicalAttackPercent() - attackee:getPVPPhysicalReducePercent(), 0)
        end
    end
    self._physical_damage_value = self._physical_damage_value * combo_points_coefficient * (damage_coefficient + 1)
    self._physical_damage_value = self._physical_damage_value * self._enhance_value_multiply
    -- self._physical_damage_value = app.battle:addDamage(self._physical_damage_value, attacker)
    -- 魔法DOT
    self._magic_damage_value = self.effects.magic_damage_value
    if self._magic_damage_value > 0 and not self:get("is_damage_hp_percent") then
        if self.effects.influence_with_attack == true then
            self._magic_damage_value = self._magic_damage_value + ((attackValue * attackValue) / (attackValue + attackee:getMagicArmor()) * coefficient)
        end
        -- self._magic_damage_value = self._magic_damage_value * (1 + attackee:getMagicDamagePercentUnderAttack())
        if app.battle:isPVPMode() then
            if app.battle:isInArena() then
                if app.battle:isSotoTeam() then
                    self._magic_damage_value = self._magic_damage_value * QBuff.SOTO_TEAM_FINAL_DAMAGE_COEFFICIENT
                else
                    self._magic_damage_value = self._magic_damage_value * QBuff.ARENA_FINAL_DAMAGE_COEFFICIENT
                end
            elseif app.battle:isInSunwell() then
                self._magic_damage_value = self._magic_damage_value * QBuff.SUNWELL_FINAL_DAMAGE_COEFFICIENT
            elseif app.battle:isInSilverMine() then
                self._magic_damage_value = self._magic_damage_value * QBuff.SILVERMINE_FINAL_DAMAGE_COEFFICIENT
            end
            self._magic_damage_value = self._magic_damage_value * math.max(1 + self._attacker:getPVPMagicAttackPercent() - attackee:getPVPMagicReducePercent(), 0)
        end
    end
    self._magic_damage_value = self._magic_damage_value * combo_points_coefficient * (damage_coefficient + 1)
    self._magic_damage_value = self._magic_damage_value * self._enhance_value_multiply
    -- self._magic_damage_value = app.battle:addDamage(self._magic_damage_value, attacker)
    -- 魔法HOT
    self._magic_treat_value = self.effects.treat_damage_value
    if self._magic_treat_value > 0 then
        if self.effects.influence_with_attack == true then
            self._magic_treat_value = self._magic_treat_value + (attackValue * 2 * coefficient)
        end
        if self.effects.treat_damage_hp_percent > 0 then
            self._magic_treat_value = self._magic_treat_value + actor:getMaxHp() * self.effects.treat_damage_hp_percent 
        end
        -- self._magic_treat_value = self._magic_treat_value * (1 + attackee:getMagicTreatPercentUnderAttack())
        if app.battle:isPVPMode() then
            if app.battle:isInArena() then
                if app.battle:isSotoTeam() then
                    self._magic_treat_value = self._magic_treat_value * QBuff.SOTO_TEAM_TREAT_COEFFICIENT
                else
                    self._magic_treat_value = self._magic_treat_value * QBuff.ARENA_TREAT_COEFFICIENT
                end
            elseif app.battle:isInSunwell() then
                self._magic_treat_value = self._magic_treat_value * QBuff.SUNWELL_TREAT_COEFFICIENT
            elseif app.battle:isInSilverMine() then
                self._magic_treat_value = self._magic_treat_value * QBuff.SILVERMINE_TREAT_COEFFICIENT
            end
        end
    end
    self._magic_treat_value = self._magic_treat_value * combo_points_coefficient * (damage_coefficient + 1)
    self._magic_treat_value = self._magic_treat_value * self._enhance_value_multiply
    -- 吸收伤害
    self._absorb_damage_value_left = self.effects.absorb_damage_value
    if self._absorb_damage_value_left > 0 then
        if self.effects.influence_with_attack == true then
            self._absorb_damage_value_left = self._absorb_damage_value_left + (attackValue * 2 * coefficient)
        end
        self._absorb_damage_value_left = self._absorb_damage_value_left * math.max((1 + attackee:getMagicTreatPercentUnderAttack()), 0)
        if app.battle:isPVPMode() then
            if app.battle:isInArena() then
                if app.battle:isSotoTeam() then
                    self._absorb_damage_value_left = self._absorb_damage_value_left * QBuff.SOTO_TEAM_TREAT_COEFFICIENT
                else
                    self._absorb_damage_value_left = self._absorb_damage_value_left * QBuff.ARENA_TREAT_COEFFICIENT
                end
            elseif app.battle:isInSunwell() then
                self._absorb_damage_value_left = self._absorb_damage_value_left * QBuff.SUNWELL_TREAT_COEFFICIENT
            elseif app.battle:isInSilverMine() then
                self._absorb_damage_value_left = self._absorb_damage_value_left * QBuff.SILVERMINE_TREAT_COEFFICIENT
            end
        end
    end
    if self.effects.absorb_damage_percent_attacker > 0 and attacker then
        local value = self.effects.absorb_damage_percent_attacker * attacker:getMaxHp()
        self._absorb_damage_value_left = self._absorb_damage_value_left + value
    end
    if self.effects.absorb_damage_percent_owner > 0 and actor then
        local value = self.effects.absorb_damage_percent_owner * actor:getMaxHp()
        self._absorb_damage_value_left = self._absorb_damage_value_left + value
    end
    self._absorb_damage_value_left = self._absorb_damage_value_left * combo_points_coefficient
    self._absorb_damage_value_left = self._absorb_damage_value_left * self._enhance_value_multiply
    -- 怒气ROT
    self._rage_value = self.effects.rage_value * combo_points_coefficient
    self._rage_value = self._rage_value * self._enhance_value_multiply
    -- 百分比治疗
    self._magic_treat_percent = self.effects.treat_damage_percent * combo_points_coefficient
    self._magic_treat_percent = self._magic_treat_percent * self._enhance_value_multiply

    if self:getPhysicalDamageValue(attackee) > 0 or self:getMagicDamageValue(attackee) > 0
        or self:getMagicTreatValue(attackee) > 0 or self._absorb_damage_value_left > 0
        or self._rage_value > 0 or self._magic_treat_percent > 0 then
        self._combo_points_coefficient_duration = 1
    else
        self._combo_points_coefficient_duration = combo_points_coefficient
    end

    self._affectingAuraActors = {}

    self._retainOwners = {}

    self._damage_to_absorb = self:get("damage_to_absorb")
    if self._damage_to_absorb > 0 then
        self._isAbsorbDamage = true
    end

    self._triggerPeriodCount = 1
    self._auraRadius = nil -- 非策划设置的半径而是由时间变化引起的变化半径
    self._auraScaleByTimeEffect = 0;

    if self:get("absorb_value_limit") > 0 then
        local limit = self:get("absorb_value_limit") * self._actor:getMaxHp()
        self._absorb_damage_value_left = math.min(self._absorb_damage_value_left, limit)
        self._absorb_value_limit = limit - self._absorb_damage_value_left
    end

    if self._absorb_hp_segment_effect then
        self:onAbsorbChange()
    end

    if self:checkCondition(QBuff.TRIGGER_CONDITION_CUSTOM_EVENT) then
        self:addCustomEventListener()
    end

    self._additionStackNumber = 0
    self._triggerCount = 0
end

function QBuff:addCustomEventListener()
    local event_name = self:get("custom_event_name")
    local target_type = self:get("custom_event_target_type")
    local params = self:get("custom_event_params")
    local targets
    if target_type == QBuff.CUSTOM_EVENT_TARGET_TEAMMATE_AND_SELF then
        targets = app.battle:getMyTeammates(self:getBuffOwner(), true)
    elseif target_type == QBuff.CUSTOM_EVENT_TARGET_TEAMMATE then
        targets = app.battle:getMyTeammates(self:getBuffOwner(), false)
    elseif target_type == QBuff.CUSTOM_EVENT_TARGET_ENEMY then
        targets = app.battle:getMyEnemies(self:getBuffOwner())
    elseif target_type == QBuff.CUSTOM_EVENT_TARGET_SELF then
        targets = {self:getBuffOwner()}
    elseif target_type == QBuff.CUSTOM_EVENT_TARGET_BUFF_ATTACKER then
        targets = {self:getAttacker()}
    end

    for i,target in ipairs(targets) do
        if self:get("custom_event_trigger_as_attacker") then
            self:getBuffOwner():addCustomEventListener(self, event_name, params, function() self:doTrigger(target, self:getBuffOwner(), true, target) end)
        else
            target:addCustomEventListener(self, event_name, params, function() self:doTrigger(self:getBuffOwner(), target, true) end)
        end
    end

    self._custom_listener_targets = targets
end

function QBuff:triggerDamage( attackee )
    if attackee:isDead() then
        return
    end
    local co = self:get("trigger_damage_co")
    local attacker = self._attacker
    local atk = attacker:getAttack() * co
    local skill = attacker:getTalentSkill()
    local damage
    if skill:getDamageType() == QSkill.PHYSICAL then
        local immune_physical_damage = attackee:isImmunePhysicalDamage()
        if immune_physical_damage then
            attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_IMMUNE_PHYSICAL_DAMAGE, attacker, QBuff.TRIGGER_TARGET_SELF)
            attackee:dispatchEvent({name = attackee.UNDER_ATTACK_EVENT, isTreat = false, tip = global.immune_physical})
            return
        end
        damage = atk * atk / (atk + math.max(0, attackee:getPhysicalArmor() - attacker:getPhysicalPenetration()))
        damage = damage * (1 + attackee:getPhysicalDamagePercentUnderAttack())
        if app.battle:isPVPMode() then
            damage = damage * math.max(1 + math.max(attacker:getPVPPhysicalAttackPercent() - attackee:getPVPPhysicalReducePercent(), -0.8), 0)
        end
    else
        local immune_magic_damage = attackee:isImmuneMagicDamage()
        if immune_magic_damage then
            attackee:triggerAlreadyAppliedBuff(QBuff.TRIGGER_CONDITION_IMMUNE_MAGIC_DAMAGE, attacker, QBuff.TRIGGER_TARGET_SELF)
            attackee:dispatchEvent({name = attackee.UNDER_ATTACK_EVENT, isTreat = false, tip = global.immune_magic})
            return
        end
        damage = atk * atk / (atk + math.max(0, attackee:getMagicArmor() - attacker:getMagicPenetration()))
        damage = damage * (1 + attackee:getMagicDamagePercentUnderAttack())
        if app.battle:isPVPMode() then
            damage = damage * math.max(1 + math.max(attacker:getPVPMagicAttackPercent() - attackee:getPVPMagicReducePercent(), -0.8), 0)
        end
    end
    if app.battle:isPVPMode() then
        if app.battle:isInArena() then
            if app.battle:isSotoTeam() then
                damage = damage * QBuff.SOTO_TEAM_FINAL_DAMAGE_COEFFICIENT
            else
                damage = damage * QBuff.ARENA_FINAL_DAMAGE_COEFFICIENT
            end
        elseif app.battle:isInSunwell() then
            damage = damage * QBuff.SUNWELL_FINAL_DAMAGE_COEFFICIENT
        elseif app.battle:isInSilverMine() then
            damage = damage * QBuff.SILVERMINE_FINAL_DAMAGE_COEFFICIENT
        end
    end
    damage = damage * self._enhance_value_multiply
    damage = app.battle:addDamage(damage, attacker)
    damage = damage * app.battle:getDamageCoefficient()
    damage = math.ceil(damage)
    local percent

    if not attackee:isBoss() and not attackee:isEliteBoss() then
        attacker:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_DAMAGE, attackee, damage, nil, self)
    end
    for _, tab in ipairs(attackee:getStrikeAgreementers()) do
        if tab.percent and tab.actor then
            percent = percent + tab.percent
            if percent <= 1 then
                tab.actor:dispatchEvent({name = attackee.DECREASEHP_EVENT,
                    hp = damage * percent, attacker = attacker,skill = self:getSkill(), no_render = nil})
            else
                percent = 1
            end
        end
    end
    damage = damage * self:getDragonModifer()
    local _, value, absorb = attackee:decreaseHp(damage * (1 - percent), attacker, self:getSkill(), nil, false)

    if absorb > 0 then
        local absorb_tip = "吸收 "
        attackee:dispatchEvent({name = attackee.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = absorb_tip .. tostring(math.floor(absorb)),rawTip = {
            isHero = attackee:getType() ~= ACTOR_TYPES.NPC, 
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
        attackee:dispatchEvent({name = attackee.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = tip .. tostring(math.floor(value)),
            rawTip = {
                isHero = attackee:getType() ~= ACTOR_TYPES.NPC, 
                isDodge = false, 
                isBlock = false, 
                isCritical = false, 
                isTreat = false, 
                number = value
            }})
    end
end

function QBuff:triggerHeal( attackee )
    if attackee:isDead() then
        return
    end
    local co = self:get("trigger_heal_co")
    local attacker = self._attacker
    local atk = attacker:getAttack() * co
    local heal = atk
    heal = heal * math.max((1 + attackee:getMagicTreatPercentUnderAttack()), 0)
    if app.battle:isPVPMode() then
        if app.battle:isInArena() then
            if app.battle:isSotoTeam() then
                heal = heal * QBuff.SOTO_TEAM_TREAT_COEFFICIENT
            else
                heal = heal * QBuff.ARENA_TREAT_COEFFICIENT
            end
        elseif app.battle:isInSunwell() then
            heal = heal * QBuff.SUNWELL_TREAT_COEFFICIENT
        elseif app.battle:isInSilverMine() then
            heal = heal * QBuff.SILVERMINE_TREAT_COEFFICIENT
        end
    end
    heal = heal * self._enhance_value_multiply
    local _
    _, heal = attackee:increaseHp(heal, attacker, self:getSkill())
    local value = heal
    if value > 0 then
        local tip = ""
        attackee:dispatchEvent({name = attackee.UNDER_ATTACK_EVENT, isTreat = true, isCritical = false, tip = tip .. "+" .. tostring(math.floor(value)),
                rawTip = {
                    isHero = attackee:getType() ~= ACTOR_TYPES.NPC, 
                    isDodge = false, 
                    isBlock = false, 
                    isCritical = false, 
                    isTreat = true, 
                    number = value
                }})
    end
end

function QBuff:_setEffectValueToBoolean(key)
    if key == nil or self.effects[key] == nil then
        return
    end

    if type(self.effects[key]) == "boolean" then
        return
    end

    if self.effects[key] == 0 then
        self.effects[key] = false
    else
        self.effects[key] = true
    end
end

function QBuff:getDuration()
    return self:get("duration") * self._combo_points_coefficient_duration
end

function QBuff:getMutativeTime()
    return self:get("mutative_time") * self._combo_points_coefficient_duration
end

function QBuff:getExecuteCount()
    return self._executeCount
end

function QBuff:getCurrentExecuteCount()
    return self._currentExecute
end

function QBuff:getBeginEffectID()
    local effectID = self:get("begin_effect_id")
    if string.len(effectID) == 0 then
        return nil
    end
    local stack_count = self._stackCount or 1
    local words = string.split(effectID, ";")
    local index = math.min(stack_count, #words)
    if string.len(words[index]) == 0 then
        return nil
    end
    return words[index]
end

function QBuff:getEffectID()
    local effectID = self:get("effect_id")
    if self._absorb_hp_segment_effect and self._absorb_hp_segment_effect.idx then
        return self._absorb_hp_segment_effect[self._absorb_hp_segment_effect.idx].effect, 1
    end
    if string.len(effectID) == 0 then
        effectID = nil
    end
    if effectID == nil then
        return effectID, 1
    else
        local stack_count = self._stackCount or 1
        local words = string.split(effectID, ";")
        local index = math.min(stack_count, #words)
        return words[index], index
    end
end

function QBuff:getEffectID2()
    local effectID = self:get("effect_id2")
    if string.len(effectID) == 0 then
        effectID = nil
    end
    if effectID == nil then
        return effectID, 1
    else
        local stack_count = self._stackCount or 1
        local words = string.split(effectID, ";")
        local index = math.min(stack_count, #words)
        return words[index], index
    end
end

function QBuff:getFinishEffectID()
    local effectID = self:get("finish_effect_id")
    if string.len(effectID) == 0 then
        return nil
    end
    local stack_count = self._stackCount or 1
    local words = string.split(effectID, ";")
    local index = math.min(stack_count, #words)
    if string.len(words[index]) == 0 then
        return nil
    end
    return words[index]
end

function QBuff:getColor()
    local rgb = string.split(self:get("color"), ",")
    if table.nums(rgb) ~= 3 then return nil end

    return ccc3(tonumber(rgb[1]), tonumber(rgb[2]), tonumber(rgb[3]))
end

function QBuff:getGray()
    return self:get("gray")
end

function QBuff:isDrainBlood()
    return self:get("drain_blood")
end

function QBuff:doTrigger(actor, target, attack_as_target, skillOwner)
    local probability = self:getTriggerProbability()
    local triggerType = self:getTriggerType()
    if probability >= app.random(1, 100) and not self:triggeredMaxCount() then
        self:addTriggerCount()
        if triggerType == QBuff.TRIGGER_TYPE_COMBO then
            local combo_points = self:getTriggerComboPoints()
            actor:gainComboPoints(combo_points)
        elseif triggerType == QBuff.TRIGGER_TYPE_RAGE then
            actor:changeRage(self:getTriggerRage())
            local ragePercent = self:getTriggerRagePercent()
            if ragePercent then
                local curRage = actor:getRage()
                actor:changeRage(self:getTriggerRagePercent() * curRage)
            end
        elseif triggerType == QBuff.TRIGGER_TYPE_BUFF then
            local buffId = self:getTriggerBuffId()
            local buffTargetType = self:getTriggerBuffTargetType()
            actor:_doTriggerBuff(buffId, buffTargetType, actor, self:getSkill(), self)
        elseif triggerType == QBuff.TRIGGER_TYPE_ATTACK then
            local skillId, level = self:getTriggerSkillId()
            local skillOwner = skillOwner or self:getBuffOwner()
            if level == "y" then level = self:getSkill():getSkillLevel() end
            local triggerSkill = skillOwner._skills[skillId]
            if triggerSkill == nil then
                triggerSkill = QSkill.new(skillId, {}, skillOwner, level)
                triggerSkill:setIsTriggeredSkill(true)
                triggerSkill:setEnhanceValue(self:getEnhanceValue())
                skillOwner._skills[skillId] = triggerSkill
            end
            if self:isTriggerSkillUseBuffAttackerProp() then
                triggerSkill:setDamager(self:getAttacker())
            end
            triggerSkill._isNeedRage = false
            if triggerSkill:isReadyAndConditionMet() then
                if attack_as_target then
                    if self:getTriggerSkillAsCurrent() then
                        skillOwner:attack(triggerSkill, false, target, self:triggerImmediately())
                    else
                        skillOwner:triggerAttack(triggerSkill, target, self:triggerImmediately(), nil, self)
                    end
                else
                    if self:getTriggerSkillAsCurrent() then
                        skillOwner:attack(triggerSkill, nil, nil, self:triggerImmediately())
                    else
                        skillOwner:triggerAttack(triggerSkill, nil, self:triggerImmediately(), nil, self)
                    end
                end
            end
        elseif triggerType == QBuff.TRIGGER_TYPE_REMOVE_BUFF then           
            app.battle:performWithDelay(function()
                local buffId = self:getTriggerBuffId()
                actor:removeBuffByID(buffId)
            end, 0)
        elseif triggerType == QBuff.TRIGGER_TYPE_REPLACE_BUFF then        
            app.battle:performWithDelay(function()
                local strbuffIds = self:getTriggerBuffId()
                local tabBuffIds = string.split(strbuffIds,";")
                local removeBuffId = tabBuffIds[1]
                local addBuffId = tabBuffIds[2]
                if removeBuffId then
                    if actor:getBuffByID(removeBuffId) then
                        actor:removeBuffByID(removeBuffId)
                    end
                end
                if addBuffId then
                    local buffTargetType = self:getTriggerBuffTargetType()
                    actor:_doTriggerBuff(addBuffId, buffTargetType, actor, self:getSkill(), self)
                end
            end, 0)
        end
    end
    self:coolDown()
end

function QBuff:isReady()
    local cd = self:getTriggerCD()
    if cd <= 0 then
        return true
    end

    local passTime = app.battle:getBattleDuration()
    if self:get("is_right_tick") then
        self._lastTimeTriggered = self._lastTimeTriggered or app.battle:getBattleDuration()
        local lastTimeTriggered = self._lastTimeTriggered
        return not lastTimeTriggered or passTime - lastTimeTriggered >= cd
    elseif self:get("is_use_new_tick") then
        self._lastTimeTriggered = self._lastTimeTriggered or self._passedTime
        local lastTimeTriggered = self._lastTimeTriggered
        return not lastTimeTriggered or self._passedTime - lastTimeTriggered >= cd
    else
        self._lastTimeTriggered = self._lastTimeTriggered or (app.battle:getTime() - self._passedTime)
        local lastTimeTriggered = self._lastTimeTriggered
        return not lastTimeTriggered or app.battle:getTime() - lastTimeTriggered >= cd 
    end
end

function QBuff:coolDown()
    self._change_trigger_cd_list = {}
    self._change_trigger_cd = nil
    local cd = self:getTriggerCD()
    if cd <= 0 then
        return
    end

    if self:get("is_right_tick") then
        self._lastTimeTriggered = app.battle:getBattleDuration()
    elseif self:get("is_use_new_tick") then
        self._lastTimeTriggered = self._passedTime
    else
        self._lastTimeTriggered = app.battle:getTime()
    end
end

function QBuff:resetCoolDown()
    local cd = self:getTriggerCD()
    if self:get("is_right_tick") then
        self._lastTimeTriggered = app.battle:getBattleDuration()
    elseif self:get("is_use_new_tick") then
        self._lastTimeTriggered = self._passedTime
    else
        self._lastTimeTriggered = app.battle:getTime() - cd
    end
end

function QBuff:getTriggerCD()
    return self._change_trigger_cd or self:get("trigger_cd")
end

function QBuff:changeTriggerCD(buff)
    if self._change_trigger_cd_list[buff] == nil then
        local change_time, max_count = buff:getChangeTriggerCdConfig()
        self._change_trigger_cd_list[buff] = {change_time = change_time, max_count = max_count, count = 0}
    end
    local cfg = self._change_trigger_cd_list[buff]
    cfg.count = cfg.count + 1
    if cfg.count <= cfg.max_count then
        self._change_trigger_cd = self:getTriggerCD() + cfg.change_time
    end
end

function QBuff:stealProperty(src, dst, percent, propertyGetFunc, addtionProperty)
    local value = propertyGetFunc()
    local attacker = self:getAttacker()
    local steal_value = math.max(value * percent, 0)
    if src ~= dst then
        src:insertPropertyValue(addtionProperty, self, "+", -steal_value)
        if dst then
            dst:insertPropertyValue(addtionProperty, self, "+", steal_value)
        end
    end
end

function QBuff:visit(dt)
    if app.battle:isPausedBetweenWave() == true then
        return
    end

    if self:get("is_use_new_tick") and not app.battle:isBattleStartCountDown() then
        return
    end

    self._passedTime = self._passedTime + dt
    self._realPassedTime = self._realPassedTime + dt

    if self:isImmuned() then
        return
    end
    if self._passedTime > self:getDuration() then
        return
    end

    -- TICK TRIGGER
    if self:checkCondition(QBuff.TRIGGER_CONDITION_TICK)  and self:isReady() then
        self:doTrigger(self:getBuffOwner(), self:getBuffOwner():getTarget())
    end


    -- body enlarge
    if not IsServerSide then
        local scale = self:get("scale_percent")
        if scale ~= 0 then
            local actor = self:getBuffOwner()
            local duration = self:getDuration()
            local half_duration = duration / 2
            local scale_time = half_duration > 0.5 and 0.5 or half_duration --从原比例到新比例变化时间
            local end_scale = 1.0 + scale
            local start_scale = self:getOldBuffScale()
            local real_scale    --当前帧设置的比例
            if self._realPassedTime < scale_time then   --原比例到新比例阶段
                real_scale = math.sampler(start_scale, end_scale, self._realPassedTime / scale_time)
            elseif self._realPassedTime > duration - scale_time and self._realPassedTime <= duration then   --新比例到原比例阶段
                real_scale = math.sampler(start_scale, end_scale, (duration - self._realPassedTime) / scale_time)
            elseif duration < self._realPassedTime then     --维持原比例阶段
                real_scale = start_scale
            else    --维持新比例阶段
                real_scale = end_scale
            end
            actor:setSizeScale(real_scale, self)
        end
    end

    if self:isAura() and self:isTimeEffectRadius() then
        if self._auraRadius == nil or self._auraRadius <= self:get("aura_radius_max") then
            local radiusDelta = self:get("aura_radius_max") - self:get("aura_radius")
            self._auraRadius = (self._passedTime / self:getMutativeTime()) * radiusDelta + self:get("aura_radius")
            self._auraScaleByTimeEffect = dt / self:getMutativeTime()
        else
            self._auraScaleByTimeEffect = 0
        end
    end

    -- buff and aura property effect
    if next(self._effects) or self:get("attack_steal_percent") > 0 or self:get("attackspeed_steal_percent") > 0
        or (self:get("steal_property_name") ~= nil and self:get("steal_property_value") > 0)  then
        local condition_met = self:isConditionMet()
        if self:isAura() then
            local buffOwner = self._actor
            local isIdleSupport = buffOwner:isIdleSupport()
            local targetType = self:getAuraTargetType()
            local mates = nil
            if targetType == QBuff.TRIGGER_TARGET_ENEMY then
                mates = app.battle:getMyEnemies(buffOwner)
            elseif targetType == QBuff.TRIGGER_TARGET_TEAMMATE_AND_SELF then
                mates = app.battle:getMyTeammates(buffOwner, true)
            elseif targetType == QBuff.TRIGGER_TARGET_TEAMMATE then
                mates = app.battle:getMyTeammates(buffOwner, false)
            end
            mates = mates or {}
            for _, actor in ipairs(mates) do
                if not actor:isDead() then
                    local affecting = self._affectingAuraActors[actor] and not isIdleSupport
                    if condition_met and self:isAuraAffectActor(actor) then
                        if not affecting then
                            for property_name, value in pairs(self._effects) do
                                value = self:calcGainEffect(property_name, value)
                                actor:insertPropertyValue(property_name, self, "+", value * self._enhance_value_multiply)
                            end
                            self:applyStatusForActor(actor)
                            self._affectingAuraActors[actor] = true
                        end
                    else
                        if affecting then
                            for property_name, value in pairs(self._effects) do
                                actor:removePropertyValue(property_name, self)
                            end
                            self:removeStatusForActor(actor)
                            self._affectingAuraActors[actor] = nil
                        end
                    end
                end
            end
        end
        if not self:isAura() then
            if self._stealPropertyDst == nil then
                local actor_dst = self:getAttacker()
                if self:get("steal_dst") == "teammates_lowest_hp" then 
                    local candidates = app.battle:getMyTeammates(actor_dst, true)
                    table.sort(candidates, function(e1, e2)
                        local d1 = e1:getHp() / e1:getMaxHp()
                        local d2 = e2:getHp() / e2:getMaxHp()
                        if d1 ~= d2 then
                            return d1 < d2
                        end
                    end)
                    actor_dst = candidates[1]
                end
                self._stealPropertyDst = actor_dst
            end
            local actor_dst = self._stealPropertyDst
            local actor_src = self:getBuffOwner()
            local isPropertyEffectByTime = self:get("property_effect_by_time")
            if condition_met and (not self._affectingBuffOwner or isPropertyEffectByTime) then
                for property_name, value in pairs(self._effects) do
                    if isPropertyEffectByTime then
                        local maxValue = value
                        local mutativeTime = self:getMutativeTime()
                        if mutativeTime < 0 then
                            value = math.min(maxValue, value * (math.max((mutativeTime - self._passedTime), 0) / mutativeTime))
                        else
                            value = math.min(maxValue, value * (self._passedTime / mutativeTime))
                        end
                    end
                    value = self:calcGainEffect(property_name, value)
                    if actor_src:getPropertyValue(property_name, self) == nil then
                        actor_src:insertPropertyValue(property_name, self, "+", value * self._enhance_value_multiply)
                    else
                        actor_src:modifyPropertyValue(property_name, self, "+", value * self._enhance_value_multiply)
                    end
                end
                -- 攻击力窃取
                local attack_steal_percent = self:get("attack_steal_percent")
                if attack_steal_percent > 0 then
                    attack_steal_percent = self:calcGainEffect("attack_steal_percent", attack_steal_percent) 
                    self:stealProperty(actor_src, actor_dst, attack_steal_percent, handler(actor_src, actor_src.getAttackWithoutSteal), "attack_value_stealed")
                end
                -- 攻速窃取
                local attackspeed_steal_percent = self:get("attackspeed_steal_percent")
                if attackspeed_steal_percent > 0 then
                    attackspeed_steal_percent = self:calcGainEffect("attackspeed_steal_percent", attackspeed_steal_percent) 
                    self:stealProperty(actor_src, actor_dst, attackspeed_steal_percent, handler(actor_src, actor_src.getHasteWithoutSteal), "attackspeed_stealed")
                end
                -- 其他属性窃取
                local steal_property_name = self:get("steal_property_name")
                local steal_property_value = self:get("steal_property_value")
                if steal_property_name ~= nil and steal_property_value > 0 then
                    steal_property_value = self:calcGainEffect(steal_property_name, steal_property_value) 
                    local propertyGetFunc
                    if steal_property_name == "armor_physical_stealed" then
                        propertyGetFunc = handler(actor_src, actor_src.getPhysicalArmorWithoutSteal)
                    elseif steal_property_name == "armor_magic_stealed" then
                        propertyGetFunc = handler(actor_src, actor_src.getMagicArmorWithoutSteal)
                    elseif steal_property_name == "crit_reduce_rating_stealed" then
                        propertyGetFunc = handler(actor_src, actor_src.getCritReduceWithoutStealed)    
                    elseif steal_property_name == "max_hp_stealed" then
                        propertyGetFunc = handler(actor_src, actor_src.getMaxHpWithoutStealed)
                    end
                    self:stealProperty(actor_src, actor_dst, steal_property_value, propertyGetFunc, steal_property_name)
                end
                self._affectingBuffOwner = true
            elseif not condition_met and self._affectingBuffOwner and not isPropertyEffectByTime then
                for property_name, value in pairs(self._effects) do
                    actor_src:removePropertyValue(property_name, self)
                end
                -- 攻击力窃取恢复
                actor_src:removePropertyValue("attack_value_stealed", self)
                actor_src:removePropertyValue("attackspeed_stealed", self)
                actor_src:removePropertyValue(self:get("steal_property_name"), self)
                if actor_dst then
                    actor_dst:removePropertyValue("attack_value_stealed", self)
                    actor_dst:removePropertyValue("attackspeed_stealed", self)
                    actor_dst:removePropertyValue(self:get("steal_property_name"), self)
                end
                self._affectingBuffOwner = nil
            end
        end
    end

    -- 相同ID的光环相交时相互抵消
    if self:isAura() and self:isNeutralizeSameId() then
        for _, actor in ipairs(app.battle:getMyTeammates(self._actor)) do
            local hasSameIDBuff, buff = actor:hasSameIDBuff(self:getId())
            if hasSameIDBuff and buff and buff:isAura() and buff:isNeutralizeSameId() then
                local pos1 = buff:getBuffOwner():getPosition()
                local pos2 = self._actor:getPosition()
                local distance = q.distOf2Points(pos1, pos2)
                if distance <= (self:getAuraRadius() * global.pixel_per_unit) then
                    buff:getBuffOwner():_triggerAlreadyAppliedBuff(self)
                    self._actor:_triggerAlreadyAppliedBuff(self)
                    break
                end
            end
        end
    end

    if self.effects.interval_time <= 0 then
        return
    end

    -- DOT/HOT
    if self.effects.interval_time > 0 and self._currentExecute <= self._executeCount then
        local coefficient = self:getAttacker() and (1 / self:getAttacker():getMaxHasteCoefficient()) or 1

        if self._lastTriggerTime == nil then
            self._lastTriggerTime = 0.25 - app.random(1, 50) / 200
            if self._lastTriggerTime > 0 then
                self:set("duration", self:get("duration") + self._lastTriggerTime)
            end
        end

        if (self._passedTime - self._lastTriggerTime) > self.effects.interval_time * coefficient then
            if not self:getBuffOwner():isIdleSupport() then
                if self:isAura() then
                    if self._aura_affectees then
                        for _, obj in ipairs(self._aura_affectees) do
                            obj.actor:_onBuffTrigger({name = QBuff.TRIGGER, buff = self})
                        end
                        self._aura_affectees = {}
                    end

                    if self._actor then
                        local buffOwner = self._actor
                        local targetType = self:getAuraTargetType()
                        if targetType == QBuff.TRIGGER_TARGET_ENEMY then
                            for _, actor in ipairs(app.battle:getMyEnemies(buffOwner)) do
                                if not actor:isImmuneAoE() and self:isAuraAffectActor(actor, true) then
                                    table.insert(self._aura_affectees, {actor = actor, time = self._passedTime})
                                end
                            end
                        elseif targetType == QBuff.TRIGGER_TARGET_TEAMMATE_AND_SELF then
                            for _, actor in ipairs(app.battle:getMyTeammates(buffOwner, true)) do
                                if not actor:isImmuneAoE() and self:isAuraAffectActor(actor, true) then
                                    table.insert(self._aura_affectees, {actor = actor, time = self._passedTime})
                                end
                            end
                        elseif targetType == QBuff.TRIGGER_TARGET_TEAMMATE then
                            for _, actor in ipairs(app.battle:getMyTeammates(buffOwner, false)) do
                                if not actor:isImmuneAoE() and self:isAuraAffectActor(actor, true) then
                                    table.insert(self._aura_affectees, {actor = actor, time = self._passedTime})
                                end
                            end
                        end

                        -- 错开光环HOT/DOT的起效时间
                        local standard_interval = self.effects.interval_time / #self._aura_affectees / 3
                        local start_time = 0
                        for index = #self._aura_affectees, 1, -1 do
                            local select_index = app.random(1, index)
                            local obj = self._aura_affectees[select_index]
                            self._aura_affectees[select_index] = self._aura_affectees[index]
                            self._aura_affectees[index] = obj
                            obj.time = obj.time + start_time
                            start_time = start_time + standard_interval
                        end
                    end
                else
                    self:dispatchEvent({name = QBuff.TRIGGER, buff = self})
                end
            end
            self._currentExecute = self._currentExecute + 1
            self._lastTriggerTime = self.effects.interval_time * coefficient + self._lastTriggerTime
        else
            local index = #self._aura_affectees
            if index > 0 then
                local obj = self._aura_affectees[index]
                if self._passedTime >= obj.time then
                    obj.actor:_onBuffTrigger({name = QBuff.TRIGGER, buff = self, isAura = true})
                    self._aura_affectees[index] = nil
                end
            end
        end
    end
end

function QBuff:isEnded()
    if next(self._retainOwners) ~= nil then
        return false
    end

    if self._isAbsorbDamage == true then
        if self._absorb_damage_value_left <= 0 then
            if self:getMagicDamageValue() <= 0 and self:getPhysicalDamageValue() <= 0 and self:getMagicTreatValue() <= 0 and self:getRageValue() <= 0 and self:getMagicTreatPercent() <= 0 and self._damage_to_absorb <= 0 then
                return true
            end
        end
    end

    if self:isSaveTreat() and self:getSaveTreat() > 0 and not self:get("save_treat_end_flag") then
        return false
    end

    return self._passedTime > self:getDuration()
end

function QBuff:onBuffEnd()
    if self:checkCondition(QBuff.TRIGGER_CONDITION_BUFF_REMOVE) then
        self:doTrigger(self:getBuffOwner(), self:getBuffOwner():getTarget())
    end
end

function QBuff:onRemove()
    if self:isImmuned() then
        return
    end
    
    -- body enlarge
    local scale = self:get("scale_percent")
    if scale ~= 0 then
        self:getBuffOwner():setSizeScale(1.0, self)
    end

    -- buff and aura property effect
    if self:isAura() and next(self._effects) ~= nil then
        local heroes = app.battle:getHeroes()
        local enemies = app.battle:getEnemies()
        for _, actor in ipairs(heroes) do 
            for property_name, value in pairs(self._effects) do
                actor:removePropertyValue(property_name, self)
            end
            -- self:removeStatusForActor(actor)
        end
        for _, actor in ipairs(enemies) do
            for property_name, value in pairs(self._effects) do
                actor:removePropertyValue(property_name, self)
            end
            -- self:removeStatusForActor(actor)
        end
    end
    if not self:isAura() and self._affectingBuffOwner then
        local actor = self:getBuffOwner()
        if next(self._effects) ~= nil then
            for property_name, value in pairs(self._effects) do
                actor:removePropertyValue(property_name, self)
            end
        end
        -- 攻击力窃取恢复
        local attacker = self._stealPropertyDst
        if self:get("attack_steal_percent") > 0 then
            actor:removePropertyValue("attack_value_stealed", self)
            if attacker and not attacker:isDead() then
                attacker:removePropertyValue("attack_value_stealed", self)
            end
        end
        -- 攻速窃取恢复
        if self:get("attackspeed_steal_percent") > 0 then 
            actor:removePropertyValue("attackspeed_stealed", self)
            if attacker and not attacker:isDead() then
                attacker:removePropertyValue("attackspeed_stealed", self)
            end
        end
        -- 其他属性窃取
        local steal_property_name = self:get("steal_property_name")
        if steal_property_name ~= nil and self:get("steal_property_value") > 0 then
            actor:removePropertyValue(steal_property_name, self)
            if attacker and not attacker:isDead() then
                attacker:removePropertyValue(steal_property_name, self)
            end
        end
    end

    if self._custom_listener_targets and #self._custom_listener_targets > 0 then
        for i,target in ipairs(self._custom_listener_targets) do
            target:removeCustomEventListener(self)
        end
    end

    self._affectingBuffOwner = nil
    self._affectingAuraActors = {}
end

function QBuff:_setEffect(prop, value)
    if prop ~= nil and string.len(prop) > 0 then
        self.effects[prop] = value

        if prop ~= "treat_damage_value" and prop ~= "physical_damage_value" and prop ~= "magic_damage_value" 
            and prop ~= "absorb_damage_value" and prop ~= "rage_value" 
            and prop ~= "absorb_damage_percent_attacker" and prop ~= "absorb_damage_percent_owner" then
            self._effects[prop] = value
        end
    end
end

function QBuff:setEffectValueByIndex(index, value)
    local prop = self:get("effect_type_" .. index)
    self:_setEffect(prop, value)
end

function QBuff:getEffectValueByIndex(index)
    return self._effects[self:get("effect_type_" .. index)] or 0
end

function QBuff:setImmuned(immuned)
    self._immuned = immuned
end

function QBuff:isImmuned()
    return self._immuned
end

function QBuff:hasStatus(status)
    return self.effects.status[status] or false
end

function QBuff:getStatus()
    return self.effects.status
end

function QBuff:isImmuneStatus(status)
    if next(self.effects.immune_status) == nil or status == nil or status == "" then
        return false
    else
        return self.effects.immune_status[QBuff.IMMUNE_ALL] or self.effects.immune_status[status]
    end
end

function QBuff:isImmuneBuff(buff)
    local status = buff:getStatus()
    if next(self.effects.immune_status) == nil or status == nil or next(status) == nil then
        return false
    else
        if self.effects.immune_status[QBuff.IMMUNE_ALL] then
            return true
        end
        for k,v  in pairs(status) do
            if v == true and self.effects.immune_status[k] then
                return true
            end
        end
        return false
    end
end

function QBuff:isImmuneSkill(skill)
    return self:isImmuneStatus(skill:getStatus())
end

function QBuff:isImmuneTrap(trap)
    return self:isImmuneStatus(trap:getStatus())
end

function QBuff:isImmunePhysicalDamage()
    return self:get("immune_physical_damage")
end

function QBuff:isImmuneMagicDamage()
    return self:get("immune_magic_damage")
end

function QBuff:hasOverrideGroup()
    return self.effects.override_group ~= nil and self.effects.override_group ~= ""
end

function QBuff:canOverride(buff)
    if self.effects.override_group == "" then
        return false, false
    else 
        if self.effects.override_group ~= buff.effects.override_group then 
            return false, false
        elseif self.effects.level >= buff.effects.level then
            return true, true
        else
            return true, false
        end
    end
end

function QBuff:isAura()
    return self:get("is_aura")
end

function QBuff:getAuraRadius()
    if self._auraRadius then
        return self._auraRadius
    end
    return self:get("aura_radius")
end

function QBuff:isTimeEffectRadius()
    return self:get("aura_radius_max") ~= -1
end

function QBuff:getAuraScaleByTimeEffect()
    return self._auraScaleByTimeEffect
end

function QBuff:getAuraTargetType()
    return self:get("aura_target_type")
end

function QBuff:getAuraTargetEffectID()
    return self:get("aura_target_effece_id")
end

function QBuff:isAuraAffectActor(actor, skip_team_check)
    assert(self._actor, "")
    assert(actor, "")
    assert(self:isAura(), "")

    if actor:isImmuneBuff(self) then
        return false
    end

    if not skip_team_check then
        local targetType = self:getAuraTargetType()
        if targetType == QBuff.ENEMY then
            local enemies = app.battle:getMyEnemies(self._actor)
            if not table.indexof(enemies, actor) then
                return false
            end
        elseif targetType == QBuff.TEAMMATE then
            local teammates = app.battle:getMyTeammates(self._actor, false)
            if not table.indexof(teammates, actor) then
                return false
            end
        elseif targetType == QBuff.TEAMMATE_AND_SELF then
            local teammates = app.battle:getMyTeammates(self._actor, true)
            if not table.indexof(teammates, actor) then
                return false
            end
        else
            return false
        end
    end

    local radius = self:getAuraRadius()
    if radius < 20 then
        radius = radius * global.pixel_per_unit
        local distance = q.distOf2Points(self._actor:getPosition(), actor:getPosition())
        if distance > radius then
            return false
        end
    end

    return true
end

function QBuff:getBuffOwner()
    return self._actor
end

function QBuff:getAttacker()
    return self._attacker
end

function QBuff:getAttackerAttackValue()
    return self._attackerAttackValue
end

function QBuff:getSkill()
    return self._skill
end

function QBuff:getTriggerType()
    return self:get("trigger_type")
end

function QBuff:getTriggerCondition()
    return self:get("trigger_condition")
end

function QBuff:getTriggerProbability()
    if not self:isAura() and self:get("hp_affect_probability") == true then
        local objs = string.split(self:get("hp_affect_probability_limit"), ";")
        local max, percent, base = tonumber(objs[1]), tonumber(objs[2]), tonumber(objs[3])
        local targetHp = self._actor:getHp() / self._actor:getMaxHp()
        local hpDelta = 1.0 - targetHp
        return math.min(hpDelta * percent + base, max) * 100
    end

    return self:get("trigger_probability") * 100
end

function QBuff:getTriggerTarget()
    return self:get("trigger_target")
end

function QBuff:getTriggerBuffId()
    return self:get("trigger_buff_id")
end

function QBuff:getTriggerBuffTargetType()
    return self:get("trigger_buff_target_type")
end

function QBuff:getTriggerSkillId()
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

function QBuff:getTriggerSkillAsCurrent()
    return self:get("trigger_skill_as_current")
end

function QBuff:getTriggerSkillInheritPercent()
    return self:get("trigger_skill_inherit_percent")
end

function QBuff:getTriggerComboPoints()
    return self:get("trigger_combo_points")
end

function QBuff:getTriggerRage()
    return self:get("trigger_rage")
end

function QBuff:getTriggerRagePercent()
    return self:get("trigger_rage_percent")
end

function QBuff:getLevel()
    return self:get("level")
end

function QBuff:isAbsorbDamage()
    return self._isAbsorbDamage
end

function QBuff:getAbsorbDamageValue()
    return self._absorb_damage_value_left
end

-- 累加时使用
function QBuff:setAbsorbDamageValue(value, checklimit)
    if checklimit and self._absorb_value_limit and self._absorb_damage_value_left < value then
        local dvalue = value - self._absorb_damage_value_left
        dvalue = math.clamp(dvalue, self._absorb_value_limit, 0)
        value = self._absorb_damage_value_left + dvalue
        self._absorb_value_limit = self._absorb_value_limit - dvalue
    end
    self._absorb_damage_value_left = value
    self:onAbsorbChange()
    return value
end

function QBuff:getAbsorbValueLimit()
    return self._absorb_value_limit
end

function QBuff:absorbDamageValue(damage_value)
    assert(damage_value >= 0 and damage_value <= self._absorb_damage_value_left, "")

    self._absorb_damage_value_left = self._absorb_damage_value_left - damage_value

    local absorb_render_damage_percent = self:get("absorb_render_damage_percent")
    local absorb_render_heal_percent = self:get("absorb_render_heal_percent")
    if self._actor:isAbsorbRenderValue() then
        absorb_render_damage_percent = absorb_render_damage_percent +
            self._actor:getAbsorbRenderDamage()
        absorb_render_heal_percent = absorb_render_heal_percent +
            self._actor:getAbsorbRenderHeal()
        self._actor:addAbsorbRenderValue(damage_value)
    end
    self:onAbsorbChange()
    return absorb_render_damage_percent * damage_value, 
           absorb_render_heal_percent * damage_value
end

function QBuff:getAbsorbDamageRageRatio()
    return self:get("absorb_damage_rage_ratio")
end

function QBuff:getPhysicalDamageValue(attackee)
    if attackee and self:get("is_damage_hp_percent") then
        if self:get("is_damage_hp_percent_by_attacker") then
            return self._physical_damage_value * self._attacker:getMaxHp()
        else
            return self._physical_damage_value * attackee:getMaxHp()
        end
    end

    if attackee then
        local physical_damage_value = self._physical_damage_value
        physical_damage_value = physical_damage_value * (1 +
            math.max(attackee:getPhysicalDamagePercentUnderAttack() + self._attackerPhysicalDamagePercentAttack, -0.8))
        physical_damage_value = app.battle:addDamage(physical_damage_value, self._attacker)
        physical_damage_value = physical_damage_value * self:getDragonModifer()
        return physical_damage_value
    else
        return self._physical_damage_value
    end
end

-- 累加时使用
function QBuff:setPhysicalDamageValue(value)
    self._physical_damage_value = value
end

function QBuff:getMagicDamageValue(attackee)
    if attackee and self:get("is_damage_hp_percent") then
        if self:get("is_damage_hp_percent_by_attacker") then
            return self._magic_damage_value * self._attacker:getMaxHp()
        else
            return self._magic_damage_value * attackee:getMaxHp()
        end
    end

    if attackee then
        local magic_damage_value = self._magic_damage_value
        magic_damage_value = magic_damage_value * (1 +
            math.max(attackee:getMagicDamagePercentUnderAttack() + self._attackerMagicDamagePercentAttack, -0.8))
        magic_damage_value = app.battle:addDamage(magic_damage_value, self._attacker)
        magic_damage_value = magic_damage_value * self:getDragonModifer()
        return magic_damage_value
    else
        return self._magic_damage_value
    end
end

-- 累加时使用
function QBuff:setMagicDamageValue(value)
    self._magic_damage_value = value
end

function QBuff:getMagicTreatValue(attackee)
    local magic_treat_value = self._magic_treat_value
    if 0 < self._treat_enhance_percent_by_lost_hp then
        local lostHPPercent =  math.floor(100 * (self._actor:getMaxHp() - self._actor:getHp()) / self._actor:getMaxHp())
        magic_treat_value = magic_treat_value * (1 + self._treat_enhance_percent_by_lost_hp * lostHPPercent)
    end
    if attackee then
        magic_treat_value = magic_treat_value * math.max((1 +
            attackee:getMagicTreatPercentUnderAttack() + self._attackerMagicTreatPercentAttack), 0)
        return magic_treat_value
    else
        return magic_treat_value
    end
end

-- 累加时使用
function QBuff:setMagicTreatValue(value)
    self._magic_treat_value = value
end

function QBuff:getRageValue()
    return self._rage_value
end

-- 累加时所用
function QBuff:setRageValue(value)
    self._rage_value = value
end

function QBuff:getMagicTreatPercent()
    local magic_treat_percent = self._magic_treat_percent
    if 0 < self._treat_enhance_percent_by_lost_hp then
        local lostHPPercent =  math.floor(100 * (self._actor:getMaxHp() - self._actor:getHp()) / self._actor:getMaxHp())
        magic_treat_percent = magic_treat_percent * (1 + self._treat_enhance_percent_by_lost_hp * lostHPPercent)
    end
    return magic_treat_percent
end

-- 累加时使用
function QBuff:setMagicTreatPercent(value)
    self._magic_treat_percent = value
end

function QBuff:getScalePercent()
    return self.effects.scale_percent
end

function QBuff:getEnhanceValue()
    return self._enhance_value_multiply - 1
end

function QBuff:isConditionMet()
    if self.effects.effect_condition == "" then
        return true
    else
        return self:_calculateCondition(self.effects.effect_condition)
    end
end

function QBuff:_calculateCondition(cond)
    assert(cond ~= nil and cond ~= "", "")

    local met = false
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
                    actor = self._actor and self._actor:getTarget()
                elseif words[1] == "self" then
                    actor = self._actor
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
                    met = actor:isUnderStatus(status)
                else
                    met = false
                end
            end

            break
        end
    end

    return met
end

function QBuff:retainBuff(owner)
    self._retainOwners[owner] = owner
end

function QBuff:releaseBuff(owner)
    self._retainOwners[owner] = nil
end

-- only for client
function QBuff:getTips()
    local return_obj = {}
    for k, v in pairs(self._effects) do
        repeat
            local config = db:getBuffTip(k)
            if not config then
                break
            end
            if v > 0 and config.increase_tip then
                table.insert(return_obj, config.increase_tip)
            elseif v < 0 and config.decrease_tip then
                table.insert(return_obj, config.decrease_tip)
            end
        until true
    end
    -- printTable(return_obj)
    return return_obj
end

function QBuff:getStackNumber()
    return self:get("stack_number")
end

function QBuff:additionStackNumber(num)
    self._additionStackNumber = self._additionStackNumber + num
end

function QBuff:isNoTip()
    return self:get("no_tip")
end

function QBuff:getTipModifier()
    return self:get("tip_modifier")
end

function QBuff:isAllowBulletTime()
    return self:get("allow_bullet_time")
end

function QBuff:setStackCount(count)
    self._stackCount = count
end

function QBuff:getStatckCount()
    return self._stackCount or 1
end

function QBuff:mute()
    self._muted = true
end

function QBuff:isMuted()
    return self._muted
end

function QBuff:rewind()
    self._passedTime = 0
end

function QBuff:isTriggerSkillUseBuffAttackerProp()
    return self:get("trigger_skill_use_attacker_prop")
end

function QBuff:isAutoClear()
    return self:get("is_auto_clear")
end

function QBuff:triggerPeriodCountdown()
    local triggerPeriodCount = self._triggerPeriodCount - 1
    self._triggerPeriodCount = triggerPeriodCount
    if triggerPeriodCount == 0 then
        self._triggerPeriodCount = self:get("trigger_period")
        return true
    else
        return false
    end
end

function QBuff:isGhostBuff()
    return self:get("is_ghost_buff")
end

function QBuff:getTriggerCondition2()
    return self:get("trigger_or_condition1")
end

function QBuff:getTriggerCondition3()
    return self:get("trigger_or_condition2")
end

function QBuff:isNeutralizeSameId()
    return self:get("is_neutralize_same_id")
end

function QBuff:checkCondition(condition)
    if self:getTriggerCondition() == condition then
        return true
    elseif self:getTriggerCondition2() == condition then
        return true
    elseif self:getTriggerCondition3() == condition then
        return true
    end
    return false
end

function QBuff:getOldBuffScale()
    return self._old_buff_scale or 1
end

function QBuff:setOldBuffScale( scale )
    self._old_buff_scale = scale
end

function QBuff:getReplaceStandardAction()
    return self:get("replace_standard_action")
end

function QBuff:getTriggerRemoveSkillStatus()
    return self:get("trigger_remove_skill_status") or nil
end

function QBuff:calcSaveDamage()
    local config = string.split(self:get("save_damage_config"), ";")
    local coefficient = tonumber(config[1]) or 0
    local limit = tonumber(config[2]) or 1
    local flag = tonumber(config[3])
    local skill_type = QSkill.MAGIC
    if flag == 1 then
        skill_type = QSkill.PHYSICAL
    else
        skill_type = QSkill.MAGIC
    end

    local damageLimit = self:getBuffOwner():getMaxHp() * limit
    if config[4] ~= nil and config[4] ~= "" then
        local limit2  = tonumber(config[4])
        damageLimit = math.min(damageLimit, limit2 * self._attacker:getMaxHp())
    end

    local rest = math.clamp(self:getSavedDamage() * coefficient, 0, damageLimit)
    return  rest, skill_type
end

function QBuff:isSaveDamage()
    return self:get("save_damage_config") ~= nil
end

function QBuff:getSaveTreatType()
    return self:get("save_treat_type")
end

function QBuff:getSaveTreatTarget()
    return self:get("save_treat_target")
end

function QBuff:getSavedDamage()
    return self._save_damage
end

function QBuff:saveDamage(damage)
    if self:checkCondition(QBuff.TRIGGER_CONDITION_SAVE_DAMAGE_LIMIT) then
        if self._save_damage_coefficient == nil then
            local cfgs = string.split(self:get("save_damage_config"), ";")
            self._save_damage_coefficient = tonumber(cfgs[1]) or 0
            if cfgs[2] then
                self._save_damage_limit = tonumber(cfgs[2]) * self:getBuffOwner():getMaxHp()
            end
        end
        self._save_damage = self._save_damage + damage * self._save_damage_coefficient
        if self._save_damage_limit then
            self._save_damage = math.min(self._save_damage, self._save_damage_limit)
            if self._save_damage == self._save_damage_limit then
                self:doTrigger(self:getBuffOwner(), self:getBuffOwner():getTarget())
            end
        end
    else
        self._save_damage = self._save_damage + damage
    end
end

function QBuff:isSaveTreat()
    return self:get("save_treat_config") ~= nil
end

function QBuff:getSaveTreat()
    return self._save_treat
end

function QBuff:reduceSaveTreat(number)
    self._save_treat = math.max(self._save_treat - number, 0)
end

function QBuff:saveTreat(treat)
    if self._save_treat_coefficient == nil then
        local cfgs = string.split(self:get("save_treat_config"), ";")
        local coefficient  = string.split(cfgs[1], ",")
        self._save_treat_coefficient = tonumber(coefficient[1]) or 0
        if coefficient[2] then
            self._save_treat_limit = tonumber(coefficient[2]) * self:getBuffOwner():getMaxHp()
        end
    end
    self._save_treat = self._save_treat + treat * self._save_treat_coefficient
    if self._save_treat_limit then
        self._save_treat = math.min(self._save_treat, self._save_treat_limit)
        if self._save_treat == self._save_treat_limit and self:checkCondition(QBuff.TRIGGER_CONDITION_SAVE_TREAT_LIMIT) and self:isReady() then
            self:doTrigger(self:getBuffOwner(), self:getBuffOwner():getTarget())
        end
    end
end

function QBuff:getSaveTreatFlag()
    if self._save_treat_flag then
        return self._save_treat_flag
    end
    local cfgs = string.split(self:get("save_treat_config"), ";")
    self._save_treat_flag = cfgs[2]
    return self._save_treat_flag
end

function QBuff:getSaveTreatSourceFlag()
    local cfgs = string.split(self:get("save_treat_config"), ";") or {}
    return cfgs[3]
end

function QBuff:getAdditionTimeConfig()
    local cfgs = string.split(self:get("addition_time_config"), ";")
    return tonumber(cfgs[1]),tonumber(cfgs[2])
end

function QBuff:getChangeTriggerCdConfig()
    local cfgs = string.split(self:get("change_trigger_cd_config"), ";")
    return tonumber(cfgs[1]), tonumber(cfgs[2])
end

function QBuff:isControlBuff()
    return not (self.effects.can_control_move and self.effects.can_use_skill and self.effects.can_cast_spell and self.effects.can_charge_or_blink)
end

function QBuff:getReplaceCharacterEnterSkill()
    return self:get("replace_character_enter_skill")
end

function QBuff:getRelaceCharacterSkills()
    return self:get("replace_character_skills")
end

function QBuff:hasDamageLimit()
    return self._damage_limit_config ~= nil
end

function QBuff:countDamage(hp)
    self._damage_limit_config.hp = self._damage_limit_config.hp + hp
    local over_hp = self._damage_limit_config.hp - self._damage_limit_config.limit * self._actor:getMaxHp()
    if over_hp  <= 0 then
        return hp
    end
    self._damage_limit_config.hp = self._damage_limit_config.limit * self._actor:getMaxHp()
    return hp - over_hp*self._damage_limit_config.percent
end

function QBuff:copy(buff)
    self._passedTime = buff._passedTime
end

function QBuff:triggerImmediately()
    return self._trigger_immediately
end

function QBuff:getBuffEffectReduce()
    return self:get("buff_effect_reduce")
end

function QBuff:getBuffFromOtherEffectReduce()
    return self:get("buff_from_other_effect_reduce")
end

function QBuff:calcGainEffect(name, value)
    if self._actor and _posEffectTable[name] and (_posEffectTable[name] * value) > 0 then
        return value * math.max((1 - self._actor:getBuffEffectReduce() 
                                   - (self._attacker == self._actor and 0 or self._actor:getBuffEffectReduceFromOther()))
                                , 0)
    end
    return value
end

function QBuff:getDotGrowCoefficient()
    return self:get("dot_grow_coefficient")
end

function QBuff:getDotGrowValue(value)
    local n = self:getCurrentExecuteCount() --这里的n其实是0,1,2,3所以不用减1
    local total_n = self:getExecuteCount()
    local coefficient = self:getDotGrowCoefficient()
    coefficient = coefficient < 0 and 1 or coefficient
    local an = (2 * value) / ((1 + coefficient) * total_n)
    local a1 = an * coefficient
    local d = total_n <= 1 and 0 or ((an - a1)/(total_n - 1))
    return a1 + n * d
end

function QBuff:hideImmuneWord()
    return self._hide_immune_word
end

function QBuff:getDamageToAbsorb()
    return self._damage_to_absorb
end

function QBuff:onAbsorbChange()
    if self._absorb_hp_segment_effect then
        local actor = self:getBuffOwner()
        if actor then
            local absorb = self:getAbsorbDamageValue()
            local maxHp = actor:getMaxHp()
            local idx = nil
            for i,cfg in ipairs(self._absorb_hp_segment_effect) do
                if absorb <= (cfg.segment * maxHp )then
                    idx = i
                end
            end
            if idx ~= self._absorb_hp_segment_effect.idx then
                self._absorb_hp_segment_effect.idx = idx
                actor:dispatchEvent({name = actor.BUFF_MUTED, buff = self})
                actor:dispatchEvent({name = actor.BUFF_STARTED, buff = self, replace = true})
            end
        end
    end
end

function QBuff:applyStatusForActor(actor)
    local status_list = self:getStatus()
    local actor = actor or self:getBuffOwner()
    if actor then
        for status, has in pairs(status_list) do
            if has then
                if actor._status_list[status] == nil then
                    actor._status_list[status] = {}
                end
                actor._status_list[status][self] = true
            end
        end
    end
end

function QBuff:removeStatusForActor(actor)
    local status_list = self:getStatus()
    local actor = actor or self:getBuffOwner()
    if actor then
        local status_list = self:getStatus()
        for status, has in pairs(status_list) do
            actor._status_list[status][self] = nil
        end
    end
end

function QBuff:isAddToLog()
    return self:get("is_add_to_log")
end

function QBuff:getSyncTreatCoefficient()
    return self:get("sync_treat_coefficient")
end

function QBuff:getDamageReductionDataSource()
    local key = self:get("damage_reduction_data_source")
    return damage_reduction[key]
end

function QBuff:isDamageReductionBuff()
    return self:get("damage_reduction_value") > 0
        and self:get("damage_reduction_percent") > 0
end

function QBuff:getDamageReductionValue()
    return self:get("damage_reduction_value")
end

function QBuff:getDamageReductionPercent()
    return self:get("damage_reduction_percent")
end

function QBuff:getDamageReductionNoRender()
    return self:get("damage_reduction_no_render")
end

function QBuff:isSaveDamageIgnoreAttacker()
    return self:get("is_save_damage_ignore_attacker")
end

function QBuff:immuneDeathNoTrigger()
    return self:get("immune_death_no_trigger")
end

function QBuff:isCountAbosrbToOwner()
    return self._count_absorb_to_owner
end

function QBuff:isAbsoluteCostAbsorb()
    return self:get("is_absolute_cost_absorb")
end

function QBuff:addTriggerCount()
    self._triggerCount = self._triggerCount + 1
end

function QBuff:getNeutralizeDamage()
    return self:get("neutralize_damage") * self._actor:getMaxHp()
end

function QBuff:triggeredMaxCount()
    if self:get("trigger_max_count") == -1 or self._triggerCount < self:get("trigger_max_count") then --没触发上限限制 或 小于触发上限
        return false
    else
        return true
    end
end

function QBuff:getDragonModifer()
    if app.battle:isInUnionDragonWar() then
        return self:get("dragon_modifier")
    else
        return 1.0
    end
end

return QBuff
