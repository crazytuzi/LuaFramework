local boss_huangjindaimao_pugong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
                    OPTIONS = {delay_time = 0.7},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "huangjindaimao_attack01_1", is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.7},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {start_pos = {x = 125,y = 90}, effect_id = "huangjindaimao_attack01_2", speed = 1500, hit_effect_id = "huangjindaimao_attack01_3"},
                        },
                    },
                },
            },
        },
    },
}

return boss_huangjindaimao_pugong