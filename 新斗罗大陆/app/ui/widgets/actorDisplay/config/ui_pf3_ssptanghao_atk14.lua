local ui_ssptanghao_atk14 = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack14"},
        },
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "ssptanghao_attack14_1_ui", is_hit_effect = false},
        }, 
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "ssptanghao_attack14_1_1_ui", is_hit_effect = false},
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 50 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_ssptanghao_atk14