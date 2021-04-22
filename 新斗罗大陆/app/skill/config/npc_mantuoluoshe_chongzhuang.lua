local shifa_tongyong = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
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
                    OPTIONS = {animation = "attack13" },
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
                             },
                        },
                    },
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "tishi_kuang_w1_l20" , is_hit_effect = false},
                },
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = 
                     {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 40/24 },
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack16" },
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