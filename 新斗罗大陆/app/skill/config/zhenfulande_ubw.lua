local shifa_tongyong =
 {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {  
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
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
                          OPTIONS = {delay_time = 44 / 24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                  CLASS = "action.QSBPlaySceneEffect",
                                  OPTIONS = {effect_id = "fulande_quanping", pos  = {x = 840 , y = 850}, ground_layer = true},
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 5 / 24 },
                                        },                   
                                        {
                                            CLASS = "action.QSBShakeScreen",
                                            OPTIONS = {amplitude = 5, duration = 0.25, count = 3,},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 25 / 24 },
                                        },                   
                                        {
                                            CLASS = "action.QSBShakeScreen",
                                            OPTIONS = {amplitude = 5, duration = 0.25, count = 3,},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 55 / 24 },
                                        },                   
                                        {
                                            CLASS = "action.QSBShakeScreen",
                                            OPTIONS = {amplitude = 10, duration = 0.25, count = 3,},
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong