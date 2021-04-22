local niugao_pugong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
			CLASS = "action.QSBPlaySound"
        },	
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "niugao_attack02_1", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },	
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 16},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
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
                    OPTIONS = {delay_frame = 38},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return niugao_pugong