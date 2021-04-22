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
            ARGS = 
            {          
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },                                          
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "cz_cnxiaowu_shengli", is_hit_effect = false},--桃心特效
                },
            },
        },
    },
}

return pf_bosaixi_shengli