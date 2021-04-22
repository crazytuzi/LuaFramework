local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_sszzq_stand_1",is_hit_effect = false},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_sszzq_stand_2",is_hit_effect = true},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong