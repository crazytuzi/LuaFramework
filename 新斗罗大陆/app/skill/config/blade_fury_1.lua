
local blade_fury = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        
    	-- 上免疫控制buff
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                -- {
                --     CLASS = "action.QSBApplyBuff",
                --     OPTIONS = {buff_id = "heti_black_arrow"},           -- 吸血buff
                -- },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_prepare_polymorph"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_polymorph_sheep_state"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_polymorph_sheep"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_stun"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_fear"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_silence"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_knockback"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_time_stop"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_winding_of_cane"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_stun_charge"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_freeze"},
                },
            },
        },

        -- 技能行为（攻击动作，特效）
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {is_loop = true},
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = true}
                },
                {
                    CLASS = "action.QSBPlayLoopEffect",
                    OPTIONS = {follow_actor_animation = true},
                },
                {
                    CLASS = "action.QSBHitTimer",
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "js_melee_hit_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "js_melee_hit_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "js_melee_hit_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "js_melee_hit_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "js_melee_hit_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "js_melee_hit_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "js_melee_hit_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "js_melee_hit_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false , effect_id = "jsshandian_1"},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.8},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false , effect_id = "jsshandian_1"},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.8},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false , effect_id = "jsshandian_1"},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.8},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false , effect_id = "jsshandian_1"},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.8},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false , effect_id = "jsshandian_1"},
                        },
                    },
                },
            },
        },

        -- 清楚免疫控制buff
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "heti_black_arrow"},       -- 去除吸血buff
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_prepare_polymorph"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_polymorph_sheep_state"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_polymorph_sheep"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_stun"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_fear"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_silence"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_knockback"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_time_stop"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_winding_of_cane"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_stun_charge"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_freeze"},
                },

                -- 移除可能存在合体buff
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "heti_blade_fury_buff"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBStopLoopEffect",
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false}
                },
                {
                    CLASS = "action.QSBActorStand",
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return blade_fury