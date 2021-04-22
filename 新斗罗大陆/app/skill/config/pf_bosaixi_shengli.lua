local pf_bosaixi_shengli = {
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
                    OPTIONS = {delay_time = 1.37},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_bosaixi01_shengli1", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_bosaixi01_shengli2", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_bosaixi01_shengli3", is_hit_effect = false},
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
                    OPTIONS = {delay_time = 2.43},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_bosaixi01_shengli1", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_bosaixi01_shengli2", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_bosaixi01_shengli3", is_hit_effect = false},
                        },
                    },
                },
            },
        },
    },
}

return pf_bosaixi_shengli