
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
                                                OPTIONS = {effect_id = "wyw_attack11_7", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_8", is_hit_effect = false, ground_layer = true},
                                            },
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_1", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_2", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_3", is_hit_effect = false, ground_layer = true},
                                            },   


                                        },

                       

                             },
                             {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 78},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {

                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_9", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_10", is_hit_effect = false},
                                            },
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 5, duration = 0.2, count = 3, level = 5},
                                            },                                              


                                        },

                             },
                              {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 45},
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
                                                OPTIONS = {effect_id = "wyw_attack11_9", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_10", is_hit_effect = false},
                                            }, 
                                             {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 5, duration = 0.2, count = 2, level = 5},
                                            },                                              


                                        },

                             },  

                              {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 45},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_9", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_10", is_hit_effect = false},
                                            },
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 5, duration = 0.2, count = 2, level = 5},
                                            },                                               


                                        },

                             },

                             {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 34},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_1"},
                                            }, 
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_2"},
                                            }, 
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_3"},
                                            },
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_11", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_12", is_hit_effect = false},
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
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = { animation = "attack21"},
                        },   
                    },
                },

                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 19},
                },

                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack01"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 2},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack01"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 2},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack01"},
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = { delay_frame = 2},
                -- },
                -- {
                --      CLASS = "action.QSBPlayAnimation",
                --      OPTIONS = {animation = "attack01"},
                -- },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 14},
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