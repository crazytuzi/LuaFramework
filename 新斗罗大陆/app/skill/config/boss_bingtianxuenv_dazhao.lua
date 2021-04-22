-- 技能 冰天雪女大招
-- 技能ID 35046~50
-- 大寒无雪：全屏aoe形成巨大冰暴旋风攻击对手，有概率冰冻目标，每层冰锁会提升冰冻概率，
-- 暴击概率以及暴击伤害（1,2,3层冰冻概率提高15,30,50%，每层暴击率提升20%，爆伤提升100%）
--[[
    hunling 冰天雪女
    ID:2007 
    psf 2019-6-14
]]--

local hl_bingtianxuenv_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {--[[effect_id = "bingtianxuenv_attack11_1",]] is_hit_effect = false, haste = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 41},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = {
                                        failed_select = 4,
                                        {expression = "target:buff_num:boss_bingtianxuenv_pugong_debuff=1", select = 1},
                                        {expression = "target:buff_num:boss_bingtianxuenv_pugong_debuff=2", select = 2},
                                        {expression = "target:buff_num:boss_bingtianxuenv_pugong_debuff=3", select = 3},
                                    }
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {property_promotion = { critical_chance = 0.2,critical_damage = 0.2 }},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {property_promotion = { critical_chance = 0.4,critical_damage = 0.2 }},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {property_promotion = { critical_chance = 0.6,critical_damage = 0.2 }},
                                        },
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {all_enemy = true, buff_id = "boss_bingtianxuenv_dazhao_trigger_debuff_3"},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = { is_hit_effect = true},
                        },
                    },
                },
            },
        },
    },
}

return hl_bingtianxuenv_dazhao