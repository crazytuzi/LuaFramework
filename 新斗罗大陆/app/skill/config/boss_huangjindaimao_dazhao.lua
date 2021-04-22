local boss_huangjindaimao_dazhao = {
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
                    OPTIONS = {delay_time = 1.16},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
        					CLASS = "action.QSBPlayEffect",
        					OPTIONS = {effect_id = "huangjindaimao_attack11_1", is_hit_effect = false, haste = true},
        				},
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "huangjindaimao_attack11_1_1", is_hit_effect = false, haste = true},
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
                    OPTIONS = {delay_time = 1.16},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = {"boss_huangjindaimao_tudun","boss_huangjindaimao_wumian"}, lowest_hp_teammate = true},
                },
            },
        },
    },
}

return boss_huangjindaimao_dazhao