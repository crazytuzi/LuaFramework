
local ayin_zhenji_zidong1plus = {
	CLASS = "composite.QSBParallel",
    ARGS = {
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",            --自动2
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "ayin_attack12_1", is_hit_effect = false},
                        },
                    },
                }, 
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "ayin_attack12_2", speed = 1000, target_teammate_random = true,random_num = 3},
                },
            },
		},
    },
}

return ayin_zhenji_zidong1plus