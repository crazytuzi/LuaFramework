local pf_chengniantangsan02_shengli = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "victory"},
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 34},
                },
                {
					CLASS = "composite.QSBParallel",
					ARGS = {  
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "pf_chengniantangsan01_victory", is_hit_effect = false},
						}, 
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "pf_chengniantangsan01_victory_1", is_hit_effect = false},
						}, 
					},
				},
            },
        },
    },
}

return pf_chengniantangsan02_shengli