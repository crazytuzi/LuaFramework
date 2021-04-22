local boss_niugao_banpindun = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBRoledirection",
            OPTIONS = {direction = "left"},       
        },
		{
			CLASS = "action.QSBEnableBrattice",       
		},
		{
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13_1",no_stand = true},       
                },
                {
                    CLASS = "action.QSBSummonMonsters",
                    OPTIONS = {wave = -2,attacker_level = true},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 37},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "niugao_attack13_1_3_1",is_hit_effect = false},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayLoopEffect",
                                    OPTIONS = {effect_id = "niugao_attack13_1_3_2",is_hit_effect = false},
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack13_2", is_loop = true ,is_keep_animation = true,no_stand = true},       
                                }, 
                                {
                                    CLASS = "action.QSBActorKeepAnimation",
                                    OPTIONS = {is_keep_animation = true}
                                },
                            },
                        },
                    },
                },
            },
        },
        
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 6},
        },
        {
            CLASS = "action.QSBSummonMonsters",
            OPTIONS = {wave = -3,attacker_level = true},
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 6},
        },
        {
            CLASS = "action.QSBSummonMonsters",
            OPTIONS = {wave = -4,attacker_level = true},
        },
		{
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 4},
        },
		{
			CLASS = "action.QSBStopLoopEffect",
			OPTIONS = {effect_id = "niugao_attack13_1_3_2",is_hit_effect = false},
		},
		{
			CLASS = "action.QSBDisableBrattice",       
		},
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = false}
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
return boss_niugao_banpindun