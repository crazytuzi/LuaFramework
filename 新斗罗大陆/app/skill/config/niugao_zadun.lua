local niugao_zidong1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
			CLASS = "action.QSBPlaySound"
        },	
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "niugao_attack13_1", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "niugao_attack13_1_1", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },	
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 30},
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
                    OPTIONS = {delay_frame = 93},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return niugao_zidong1