local npc_haimahunshi_xuanshuibingfeng = 
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
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0.3, attacker_face = false,attacker_underfoot = true,count = 4, distance = 240, trapId = "jinshu_shinian_bingdongxianjing"},
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

return npc_haimahunshi_xuanshuibingfeng