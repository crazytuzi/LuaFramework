
local thunder_prison_shanghai = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {is_hit_effect = true, effect_id = "maidiwen_aoshunengliu_3_1"},
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true, effect_id = "maidiwen_aoshunengliu_3_2"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                     CLASS = "action.QSBHitTarget",
                }
            },
        },                        
    },
}

return thunder_prison_shanghai