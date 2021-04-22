
local zidan_tongyong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false, effect_id = "pf_guimei02_attack01_1"},
		}, 
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 26},
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {
						start_pos = {x = 120,y = 125},effect_id = "pf_guimei02_attack01_2"
					},
				},
            },
        },
		{
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 43},
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return zidan_tongyong

