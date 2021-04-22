

local landianbawang_fanfutuci = {
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
                    OPTIONS = {effect_id = "landianbawang_attack12"},
                },
                --{
                    --CLASS = "action.QSBPlayEffect",
                    --OPTIONS = {effect_id = "qiangbing_attack12_1_1", is_hit_effect = false},
                --},
            },
        },       
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return landianbawang_fanfutuci