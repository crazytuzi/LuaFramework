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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2/30 ,pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBActorFadeOut",
                            OPTIONS = {duration = 0.01, revertable = true,no_cancel = true, pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBTeleportToAbsolutePosition",
                            -- OPTIONS = {pos = {x = 500, y = 320}},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1 ,pass_key = {"pos"}},
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
                                            OPTIONS = {delay_time = 1.2 },
                                        },                                                                  
                                        {
                                            CLASS = "action.QSBPlayAnimation",
                                            OPTIONS = {animation = "attack21"},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 1.1 },
                                        },                                                                  
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {is_hit_effect = false, effect_id = "pf1_sspbosaixi_appear01"},
                                        }, 
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 0.5 },
                                        },                                                                  
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {is_hit_effect = false, effect_id = "pf1_sspbosaixi_appear02"},
                                        }, 
                                    },
                                },                               

                            },
                        },                        
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "sszhuzhuqing_mianyi"},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2.75 },
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
            },
        },
    },
}

return cnxiaowu_jipao