local boss_chaoxuemuzhu_chanrao = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBLockTarget",     --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        -- {
        --     CLASS = "action.QSBPlaySound"
        -- },
        {
            CLASS = "composite.QSBParallel",
            ARGS =
            {
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {is_hit_effect = false},
                -- },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack15"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 1 },
                        },
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {effect_id = "shenglt_dxmz_attack03_1", is_hit_effect = false},
                        -- },



                    },
                },
                  {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {

                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 33},
                        },

                        -- {
                        --     CLASS = "action.QSBBullet",
                        --     OPTIONS = {start_pos = {x = 125,y = 125}, effect_id = "shenglt_dxmz_attack03_2", speed = 2400},

                        -- },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack15"},
                        },
             

                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 37 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS =
                            {
                                -- {
                                --     CLASS = "action.QSBPlayEffect",
                                --     OPTIONS = {effect_id = "shenglt_dxmz_attack03_3",is_hit_effect = true},
                                -- },
                                 {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "wyw_attack15_1",is_hit_effect = false},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "wyw_attack15_2",is_hit_effect = false},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "boss_wyw_chaorao_front"},
                                }, 
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true ,buff_id = "boss_wyw_chaorao_back"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true ,buff_id = "boss_wyw_chanrao_dot"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true ,buff_id = "boss_wyw_chanrao_heal_reduction"},
                                },


                                -- {
                                --     CLASS = "action.QSBSummonGhosts",
                                --     OPTIONS = {actor_id = 4186, life_span = 21,number = 1, relative_pos = {x = 0, y = -50}, appear_skill = 56008, enablehp = true,hp_percent = 0.02,no_fog = false,is_attacked_ghost = true},
                                -- },
                                -- {
                                --     CLASS = "action.QSBApplyBuff",
                                --     OPTIONS = {is_target = true ,buff_id = "chaorao_yishang"},
                                -- },
                            },
                        },
                    },
                },
                -- {
                    -- CLASS = "composite.QSBSequence",
                    -- OPTIONS = {revertable = true},
                    -- ARGS = 
                    -- {
                        -- {
                            -- CLASS = "action.QSBDelayTime",
                            -- OPTIONS = {delay_time = 50 /24 },
                        -- },
                        -- {
                            -- CLASS = "action.QSBArgsPosition",
                            -- OPTIONS = {is_attackee = true},
                        -- },
                        -- pass_key = {"pos"}
                        -- {
                            -- CLASS = "action.QSBMultipleTrap",
                            -- OPTIONS = {trapId = "shemao_xuanwo",count = 1,},
                        -- },
                    -- },
                -- },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 45 },
                        },
                        -- {
                        --     CLASS = "action.QSBApplyBuff",
                        --     OPTIONS = {is_target = true, buff_id = "boss_changqianglaoyu1"},
                        -- }, 
                        {
                            CLASS = "action.QSBArgsGetHeroDamagePerSecond",
                            OPTIONS = {coefficient = 12, set_black_board = {asd = "damage"}},
                        },

   

                        {
                            CLASS = "action.QSBSummonGhosts",
                            OPTIONS = {get_black_board = {hp_fixed = "asd"}, actor_id = 4192, life_span = 21,number = 1, relative_pos = {x = 0, y = -50}, appear_skill = 56008, enablehp = true,hp_percent = 0,no_fog = false,is_attacked_ghost = true},
                        },
                        

                        {
                            CLASS = "action.QSBLockTarget",
                            OPTIONS = {is_lock_target = false},
                        },
                        -- {
                        --         CLASS = "action.QSBActorFadeOut",
                        --        OPTIONS = {duration = 0.1, revertable = true, is_target = true},
                        -- },

                    },
                },
            },
        },
        -- {
        --  CLASS = "action.QSBRemoveBuff",
        --  OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        -- },
    },
}

return boss_chaoxuemuzhu_chanrao