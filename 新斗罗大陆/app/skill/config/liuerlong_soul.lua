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
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_time = 3/24 },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
        --                             OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga1"},
        --                         },
        --                     },
        --                 },
        --             },
        --         },
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_time = 5/24 },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
        --                             OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga2"},
        --                         },
        --                     },
        --                 },
        --             },
        --         },
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_time = 7/24 },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
        --                             OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga3"},
        --                         },
        --                     },
        --                 },
        --             },
        --         },
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_time = 9/24 },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
        --                             OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga4"},
        --                         },
        --                     },
        --                 },
        --             },
        --         },
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_time = 11/24 },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
        --                             OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga5"},
        --                         },
        --                     },
        --                 },
        --             },
        --         },
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_time = 13/24 },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
        --                             OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga6"},
        --                         },
        --                     },
        --                 },
        --             },
        --         }, 
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_time = 15/24 },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
        --                             OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga7"},
        --                         },
        --                     },
        --                 },
        --             },
        --         }, 
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_time = 17/24 },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
        --                             OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga8"},
        --                         },
        --                     },
        --                 },
        --             },
        --         },
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_time = 19/24 },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
        --                             OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga9"},
        --                         },
        --                     },
        --                 },
        --             },
        --         }, 
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_time = 21/24 },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
        --                             OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchanga10"},
        --                         },
        --                     },
        --                 },
        --             },
        --         },  
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
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangc1"},
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
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangc2"},
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
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangc3"},
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
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangc4"},
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
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangc5"},
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
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangc6"},
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
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangc7"},
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
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangc8"},
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
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangc9"},
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
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "liuerlong_ruchangc10"},
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
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack21"},       
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