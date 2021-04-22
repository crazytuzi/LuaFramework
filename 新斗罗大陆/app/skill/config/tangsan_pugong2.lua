
local tangsan_pugong2 = {
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
                    OPTIONS = {delay_time = 0.66},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "tangsan_attack02_1", is_hit_effect = false},
                },
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.85},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 100,y = 86}},
                },
            },
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.18},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 100,y = 86}},
                },
            },
        },
    },
}

return tangsan_pugong2