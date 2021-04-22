-- 技能 巨掌黑虎大招
-- 技能ID 35001
-- 群体攻击, 对出血者暴击概率提升
--[[
    hunling 巨掌黑虎
    ID:2001
    psf 2019-6-12
]]--

local hl_juzhh_dazhao = {
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
                    OPTIONS = {delay_frame = 18},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {--[[effect_id = "pf_zhuzhuqing01_attack01_1", ]]is_hit_effect = false, haste = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 25},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = { is_hit_effect = true},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsIsUnderStatus",
                                    OPTIONS = {is_attackee = true, status = "chuxie"},
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {property_promotion = { critical_chance = 0.3 }},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                        },
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = { is_hit_effect = true},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsIsUnderStatus",
                                    OPTIONS = {is_attackee = true, status = "chuxie"},
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {property_promotion = { critical_chance = 0.3 }},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                        },
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = { is_hit_effect = true},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 3},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsIsUnderStatus",
                                    OPTIONS = {is_attackee = true, status = "chuxie"},
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {property_promotion = { critical_chance = 0.3 }},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                        },
                                    },
                                },
                            },
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

return hl_juzhh_dazhao