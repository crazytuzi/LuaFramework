
local tangsan_pugong1 = {
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
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.38},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "tangsan_attack01_1", is_hit_effect = false},
                }, 
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.38},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 100,y = 80}},
                },
            },
		},
    },
}

return tangsan_pugong1