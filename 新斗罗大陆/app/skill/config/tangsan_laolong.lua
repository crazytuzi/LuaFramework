
local tangsan_laolong = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBHitTarget",
        --         },
        --         {
        --             CLASS = "action.QSBHitTarget",
        --         },
        --         {
        --             CLASS = "action.QSBHitTarget",
        --         },
        --         {
        --             CLASS = "action.QSBHitTarget",
        --         },
        --         {
        --             CLASS = "action.QSBHitTarget",
        --         },        
        --     },
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack11_1"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "tangsan_attack11_1_1_1", is_hit_effect = false},
                                }, 
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.05, revertable = true},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 20 / 24 * 30, pass_key = {"pos"}}
                                },
                                {
                                    CLASS = "action.QSBTeleportToAbsolutePosition",
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "shanxian_gg_3", is_hit_effect = false},
                                        },
                                        {
                                            CLASS = "action.QSBActorFadeIn",
                                            OPTIONS = {duration = 0.15, revertable = true},
                                        },
                                    },
                                },
                            }
                        },
                        {
                            CLASS = "action.QSBTeleportToTargetPos",
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="tangsan_bylhz_zd"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                },
                                {
                                    CLASS = "action.QSBSummonGhosts",
                                    OPTIONS = {
                                        actor_id = 3948, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -300, y = 0}, 
                                        appear_skill = 52140,--[[入场技能]]direction = "right",
                                        percents = {attack = 0, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                        extends_level_skills = {52140}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 4},
                                },
                                {
                                    CLASS = "action.QSBSummonGhosts",
                                    OPTIONS = {
                                        actor_id = 3948, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 300, y = 0}, 
                                        appear_skill = 52140,--[[入场技能]]direction = "left",
                                        percents = {attack = 0, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                        extends_level_skills = {52140}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 7},
                                },
                                {
                                    CLASS = "action.QSBSummonGhosts",
                                    OPTIONS = {
                                        actor_id = 3948, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -200, y = 150}, 
                                        appear_skill = 52141,--[[入场技能]]direction = "right",
                                        percents = {attack = 0, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                        extends_level_skills = {52141}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 10},
                                },
                                {
                                    CLASS = "action.QSBSummonGhosts",
                                    OPTIONS = {
                                        actor_id = 3948, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 200, y = 150}, 
                                        appear_skill = 52141,--[[入场技能]]direction = "left",
                                        percents = {attack = 0, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                        extends_level_skills = {52141}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame =  6 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "tangsan_attack01_3_2"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame =  6 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.05, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.1, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.1, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 10, duration = 0.2, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 10, duration = 0.2, count = 2,},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return tangsan_laolong

