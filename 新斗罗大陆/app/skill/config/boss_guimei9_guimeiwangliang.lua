
local boss_guimei9_guimeiwangliang = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
				{
					CLASS = "action.QSBPlaySound",
					OPTIONS = {revertable = true,},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "boss_guimei_attack13_1"},
				},
				{
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 35},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {  
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true},
								},
								{
									CLASS = "action.QSBMultipleHitTarget",
									OPTIONS = {hit_count = 2, interval_time = 0},
								},
							},
						},
					},
				},
            },
        }, 
		{
			CLASS = "action.QSBAttackFinish",
		},		
    },
}
return boss_guimei9_guimeiwangliang
