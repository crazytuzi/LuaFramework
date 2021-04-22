
local fly_appear = {
	CLASS = "composite.QSBParallel",
    ARGS = {
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
                {
                    CLASS = "action.QSBDelayByAttack",
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {is_tornado = true, tornado_size = {width = 200, height =640}},
                },
            },
		},
    },
}

return fly_appear