
local tangsan_htc_zidong2 = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false},
		},
		{
			CLASS = "action.QSBPlayAnimation",
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 32},
                },
				{
					CLASS = "composite.QSBParallel",
					ARGS = {  
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "tangsan_htc_attack14_3", is_hit_effect = false},
						}, 
						{
							CLASS = "action.QSBHitTarget",
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
                    OPTIONS = {delay_frame = 53},
                },
				{
					CLASS = "action.QSBAttackFinish"
				},
            },
        },
    },
}

return tangsan_htc_zidong2