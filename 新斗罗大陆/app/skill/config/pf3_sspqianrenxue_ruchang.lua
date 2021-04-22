local cnxiaowu_jipao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBArgsPosition",
                            OPTIONS = {is_attacker = true , enter_stop_position = true},
                        },
                        {
                            CLASS = "action.QSBActorFadeOut",
                            OPTIONS = {duration = 0.01, revertable = true,no_cancel = true, pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 4/30 ,pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBTeleportToAbsolutePosition",
                            -- OPTIONS = {pos = {x = 500, y = 320}},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.1 ,pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBActorFadeIn",
                            OPTIONS = {duration = 0.5, revertable = true},
                        }, 
                        -- {
                        --     CLASS = "action.QSBActorFadeOut",
                        --     OPTIONS = {duration = 0.01, revertable = true,no_cancel = true},
                        -- },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 3 / 30 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                -- {
                                --     CLASS = "composite.QSBSequence",
                                --     ARGS = 
                                --     {
                                --         {
                                --             CLASS = "action.QSBDelayTime",
                                --             OPTIONS = {delay_time = 1.2 },
                                --         },
                                --         {
                                --             CLASS = "action.QSBActorFadeIn",
                                --             OPTIONS = {duration = 0.5, revertable = true},
                                --         },                                                                
                                --     },
                                -- },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 0.3 },
                                        },                                                                  
                                        {
                                            CLASS = "action.QSBPlayAnimation",
                                            OPTIONS = {animation = "atk21"},
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
                                            OPTIONS = {delay_frame = 20 },
                                        },                                                                  
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack21_1"},
                                        }, 
                                    },
                                },                              
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 20 },
                                        },                                                                  
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack21_2"},
                                        }, 
                                    },
                                },   
                            },
                        },                        
                    },
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "sszhuzhuqing_mianyi"},
                },
            },
        },
    },
}

return cnxiaowu_jipao