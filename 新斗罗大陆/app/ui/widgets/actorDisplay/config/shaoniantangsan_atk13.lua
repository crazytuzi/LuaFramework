local tangsan_guitengjisheng = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "tangsan_attack13_1_ui"},
                },
            },
        },
        -- {
        --     CLASS = "composite.QUIDBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QUIDBDelayTime",
        --             OPTIONS = {delay_frame = 15},
        --         },
        --         {
        --             CLASS = "action.QUIDBPlayEffect",
        --             OPTIONS = {is_hit_effect = true},
        --         },
        --     },
        -- },
    },
}

return tangsan_guitengjisheng