local jump_appear = 
{
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 3/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga1"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 5/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga2"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 7/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga3"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 9/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga4"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 11/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga5"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 13/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga6"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 15/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga7"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 17/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga8"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 19/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga9"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 21/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga10"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 4/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangb1"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 6/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangb2"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 8/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangb3"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 10/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangb4"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 12/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangb5"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 14/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangb6"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 16/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangb7"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 18/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangb8"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 20/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangb9"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 22/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangb10"},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 4/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 8, duration = 0.3, count = 4,},
                                },
                            },
                        },                      
                    },
                }, 
                {
                    CLASS = "action.QSBJumpAppear",
                    OPTIONS = {jump_animation = "attack21"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1/24 },
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="mahongjun_fhhx2_sf"},
                        },    
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0/24 },
                        },
                        -- {
                        --     CLASS = "action.QSBPlaySound",
                        --     OPTIONS = {sound_id ="liuerlong_cheer"},
                        -- },    
                    },
                },   
            },
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return jump_appear