
local guimei_zhenji_3_gj = {
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
						start_pos = {x = 120,y = 125},flip_follow_y = true,effect_id = "pf_guimei02_attack01_2",speed = 1750, hit_effect_id = "pf_guimei02_attack01_3", jump_info = {jump_number = 1}
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

return guimei_zhenji_3_gj