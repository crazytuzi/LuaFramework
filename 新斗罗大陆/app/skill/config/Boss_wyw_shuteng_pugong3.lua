
local jinzhan_tongyong = {
        
        CLASS = "composite.QSBParallel",
        ARGS = {
 {
            CLASS = "composite.QSBSequence",
            ARGS = {
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 1},
                            },
                            {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_13", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_14", is_hit_effect = false, ground_layer = true},
                                            },

                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_4_1", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_4_2", is_hit_effect = false, ground_layer = true},
                                            },
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 8, duration = 0.2, count = 2, level = 5},
                                            },   


                                        },

                       

                             },
                             {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 62},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            -- {
                                            --     CLASS = "action.QSBStopLoopEffect",
                                            --     OPTIONS = {effect_id = "wyw_attack11_13"},
                                            -- }, 
                                            -- {
                                            --     CLASS = "action.QSBStopLoopEffect",
                                            --     OPTIONS = {effect_id = "wyw_attack11_14"},
                                            -- }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_15", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_16", is_hit_effect = false},
                                            }, 
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 8, duration = 0.2, count = 2, level = 5},
                                            },                                              


                                        },

                             },
                              {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 39},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            -- {
                                            --     CLASS = "action.QSBStopLoopEffect",
                                            --     OPTIONS = {effect_id = "wyw_attack11_3"},
                                            -- }, 
                                            -- {
                                            --     CLASS = "action.QSBStopLoopEffect",
                                            --     OPTIONS = {effect_id = "wyw_attack11_4"},
                                            -- }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_15", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_16", is_hit_effect = false},
                                            },
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 8, duration = 0.2, count = 2, level = 5},
                                            },                                               


                                        },

                             },  

                              {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 39},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            -- {
                                            --     CLASS = "action.QSBStopLoopEffect",
                                            --     OPTIONS = {effect_id = "wyw_attack11_3"},
                                            -- }, 
                                            -- {
                                            --     CLASS = "action.QSBStopLoopEffect",
                                            --     OPTIONS = {effect_id = "wyw_attack11_4"},
                                            -- }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_15", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_16", is_hit_effect = false},
                                            }, 
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 8, duration = 0.2, count = 2, level = 5},
                                            },                                              


                                        },

                             },

                              {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 39},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            -- {
                                            --     CLASS = "action.QSBStopLoopEffect",
                                            --     OPTIONS = {effect_id = "wyw_attack11_3"},
                                            -- }, 
                                            -- {
                                            --     CLASS = "action.QSBStopLoopEffect",
                                            --     OPTIONS = {effect_id = "wyw_attack11_4"},
                                            -- }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_15", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_16", is_hit_effect = false},
                                            },
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 8, duration = 0.2, count = 2, level = 5},
                                            },                                               


                                        },

                             },

                             {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 28},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_4_1"},
                                            }, 
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_4_2"},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_17", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_18", is_hit_effect = false},
                                            },                                             


                                        },

                             },                        













                    },

        },


        
        {
             CLASS = "composite.QSBSequence",
             OPTIONS = {forward_mode = true},
             ARGS = {
                {
                    CLASS = "action.QSBUncancellable",
                },
                {
                    CLASS = "action.QSBSetCannotBeLocked",
                },
                -- {
                --     CLASS = "action.QSBPlayAnimation",
                --     OPTIONS = {animation = "attack21"},
                -- },
    {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 38},
                                },
                            },
                        }, 
                        -- {
                        --     CLASS = "action.QSBJumpAppear",
                        --     OPTIONS = {jump_animation = "attack21", direction = "right"},
                        -- },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = { animation = "attack21"},
                        },     
                    },
                },


                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame =4},
                },

                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack02_1"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 1},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack02_1"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 1},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack02_1"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 1},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack02_1"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 6},
                },
        }
    },
                {

                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "dead", no_stand = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 10},
                },


                {
                    CLASS = "action.QSBSuicide",
                   
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 10},
                },

                {
                    CLASS = "action.QSBAttackFinish",
                },



            },
        },
    },
}   

return jinzhan_tongyong