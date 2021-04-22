local boss_shenhaimojing_jiguang = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = true, revertable = true},
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
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "bingfengyujing" , is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlaySound"
                },
            },
        },
		{
			CLASS = "action.QSBLockTarget",
			OPTIONS = {is_lock_target = false},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_shenhaimojing_jiguang