
local youminlang_fanfu = {
    CLASS = "composite.QSBSequence",
    ARGS = {      
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBPlayEffect",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    --OPTIONS = {effect_id = "qiangbing_attack12_1_1", is_hit_effect = false},
                },
            },
        },       
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return youminlang_fanfu