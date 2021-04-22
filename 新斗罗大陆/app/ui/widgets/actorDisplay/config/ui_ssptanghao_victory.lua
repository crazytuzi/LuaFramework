local ui_ssptanghao_victory = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "victory"},
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 5 / 30},
                },
                {
                    CLASS = "composite.QUIDBParallel",
                    ARGS =
                    {
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ssptanghao_victory_1_ui", is_hit_effect = false},
                        }, 
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ssptanghao_victory_1_1_ui", is_hit_effect = false},
                        },
                    },
                },
            },
        },
    },
}

return ui_ssptanghao_victory