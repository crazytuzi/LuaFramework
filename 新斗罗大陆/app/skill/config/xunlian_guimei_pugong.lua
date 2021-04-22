
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
		-- {
			-- CLASS = "action.QSBPlayEffect",
			-- OPTIONS = {is_hit_effect = false, effect_id = "boss_guimei_attack01_1"},
		-- }, 
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
						start_pos = {x = 140,y = 195}
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

