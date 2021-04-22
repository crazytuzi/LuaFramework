local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 3},
                },
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
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_ssayin_attack13_1", is_hit_effect = false},
				},
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {effect_id = "pf_ssayin_attack13_2", is_hit_effect = false},
                -- },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssayin_attack13_3", is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssayin_attack13_4", is_hit_effect = true},
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
                    OPTIONS = {delay_frame = 55},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return ssqianshitangsan_pugong1