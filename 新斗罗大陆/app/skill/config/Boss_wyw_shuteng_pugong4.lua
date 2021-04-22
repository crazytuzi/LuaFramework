
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
                                                OPTIONS = {effect_id = "wyw_attack11_25", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_26", is_hit_effect = false, ground_layer = true},
                                            },

                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_6_1", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_6_2", is_hit_effect = false, ground_layer = true},
                                            }, 


                                        },

                       

                             },
                             {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 56},
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
                                                OPTIONS = {effect_id = "wyw_attack11_27", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_28", is_hit_effect = false},
                                            }, 
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 10, duration = 0.2, count = 2, level = 5},
                                            },                                             


                                        },

                             },
                              {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 37},
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
                                                OPTIONS = {effect_id = "wyw_attack11_27", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_28", is_hit_effect = false},
                                            }, 
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 10, duration = 0.2, count = 2, level = 5},
                                            },                                             


                                        },

                             },  

                              {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 38},
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
                                                OPTIONS = {effect_id = "wyw_attack11_27", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_28", is_hit_effect = false},
                                            },
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 10, duration = 0.2, count = 2, level = 5},
                                            },                                              


                                        },

                             },

                               {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 37},
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
                                                OPTIONS = {effect_id = "wyw_attack11_27", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_28", is_hit_effect = false},
                                            }, 
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 10, duration = 0.2, count = 2, level = 5},
                                            },                                             


                                        },

                             },

                             {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 35},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_6_1"},
                                            }, 
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_6_2"},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_29", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_30", is_hit_effect = false},
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
                    --     OPTIONS = {jump_animation = "attack21",direction = "left"},
                    -- }, 
                    {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = { animation = "attack21"},
                    },

                },
            },

                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 1},
                },

                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack03_1"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 1},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack03_1"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame =1},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack03_1"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame =1},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack03_1"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 10 },
                },

        },
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