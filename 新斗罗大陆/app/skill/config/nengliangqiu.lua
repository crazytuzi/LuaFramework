
local shoot = {
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
            CLASS = "composite.QSBSequence",
            ARGS = {
            	{
                    CLASS = "action.QSBDelayByAttack",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.15},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "energy_missiles_1"},
                }, 
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "energy_missiles_2", speed = 2360, hit_effect_id = "energy_missiles_3", start_pos = {x = 132, y = 143}, end_pos = {x = 0, y = 0}},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.35},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "energy_missiles_1"},
                }, 
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "energy_missiles_2", speed = 2360, hit_effect_id = "energy_missiles_3", start_pos = {x = 132, y = 143}, end_pos = {x = 0, y = 0}},
                },
            },
		},
    },
}

return shoot