local shewangxianjing = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {effect_id="hongquan_1" , is_hit_effect = false},
                -- },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shewangxianjing