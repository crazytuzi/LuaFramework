local ui_sschenxin_atk13 = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack13"},
        },
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "pf_sschenxin03_attack13_1_ui", is_hit_effect = false},
        }, 
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 44 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_sschenxin_atk13