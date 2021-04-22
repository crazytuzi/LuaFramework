--  创建人：刘悦璘
--  创建时间：2018.04.07
--  NPC：大地之王
--  类型：攻击
local npc_dadizhiwang_xuanfengzhan = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        
        -- 上免疫控制buff
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "npc_dadizhiwang_jiansu_debuff"},
                },
            },
        },
        
        {
            CLASS = "action.QSBPlaySound"
        },

        -- 技能行为（攻击动作，特效）
        -- {
        --     CLASS = "composite.QSBParallel",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBApplyBuff",
        --             OPTIONS = {buff_id = "xuanfengzhan_debuff"},
        --         },

        --     },
        -- },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack15", is_loop = true},
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = true}
                },
                {
                    CLASS = "action.QSBHitTimer",
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.35},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "typg_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.35},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "typg_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.35},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "typg_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.35},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "typg_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.35},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "typg_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.35},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "typg_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.35},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "typg_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.35},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "typg_3", delay_per_hit = 0.05, delay_all = 0.45},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.35},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "typg_3", delay_per_hit = 0.05, delay_all = 0.45},
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
                    OPTIONS = {buff_id = "npc_dadizhiwang_jiansu_debuff"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
            },
        },
        
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false},
                },
            },
        },
        {
            CLASS = "action.QSBActorStand",
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return npc_dadizhiwang_xuanfengzhan