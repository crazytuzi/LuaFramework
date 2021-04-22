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
                            OPTIONS = {delay_frame = 28},

                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "pf1_sspqianrenxue_victory_1", is_hit_effect = false},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "pf1_sspqianrenxue_victory_2", is_hit_effect = false},
                                },
                            },
                        },
                    },    
         },   
        
    },
}

return pf_bosaixi_shengli