local ui_niugao_attack21 = 
{
     CLASS = "composite.QUIDBParallel",
     ARGS = 
     {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack21"},
        },
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "niugao_attack21_1_ui"},
        },
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "niugao_attack21_1_1_ui"},
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 70},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_niugao_attack21