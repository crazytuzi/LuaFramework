local ui_ssptanghao_atk13 = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack13"},
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 13 / 30},
                },
                {
                    CLASS = "composite.QUIDBParallel",
                    ARGS =
                    {
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ssptanghao_attack13_1_ui", is_hit_effect = false},
                        }, 
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ssptanghao_attack13_1_1_ui", is_hit_effect = false},
                        },
                    },
                },
            },
        },
        -- {
        --     CLASS = "composite.QUIDBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QUIDBDelayTime",
        --             OPTIONS = {delay_time = 32 / 30},
        --         },
        --         {
        --             CLASS = "composite.QUIDBParallel",
        --             ARGS =
        --             {
        --                 {
        --                     CLASS = "action.QUIDBPlayEffect",
        --                     OPTIONS = {effect_id = "ssptanghao_attack13_2_ui", is_hit_effect = false},
        --                 }, 

        --             },
        --         },
        --     },
        -- },---弃用
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 57/ 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_ssptanghao_atk13