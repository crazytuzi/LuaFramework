local ui_niugao_attack13 = 
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
            OPTIONS = {effect_id = "niugao_attack13_1_ui"},
        },
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "niugao_attack13_1_1_ui"},
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 92},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_niugao_attack13