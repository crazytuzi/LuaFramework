local pf_bosaixi_siwang = {
     CLASS = "composite.QSBSequence",
     ARGS = {
     	{
            CLASS = "composite.QSBParallel",
            ARGS = 
            { 
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_bosaixi02_dead_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return pf_bosaixi_siwang