local boss_huliena9_shandiantuibo = {
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    { 
                        {
                            CLASS = "action.QSBPlayAnimation",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleLaser",
                                    OPTIONS = {effect_id = "huliena_attack11_2", speed = 1200, interval_time = 0 , count = 1, is_bullet = true},
                                }, 
                            },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}
return boss_huliena9_shandiantuibo