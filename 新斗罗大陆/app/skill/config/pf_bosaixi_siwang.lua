local pf_bosaixi_siwang = {
     CLASS = "composite.QSBSequence",
     ARGS = {
     	{
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 45},
        },
     	{
            CLASS = "composite.QSBParallel",
            ARGS = 
            { 
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_bosaixi01_siwang1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_bosaixi01_siwang2", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_bosaixi01_siwang3", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return pf_bosaixi_siwang