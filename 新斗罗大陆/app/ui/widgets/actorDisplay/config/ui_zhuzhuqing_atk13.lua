local ui_zhuzhuqing_atk13 = 
    {
        CLASS = "composite.QUIDBParallel",
        ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack13"},
        },
        {
            CLASS = "action.QUIDBPlaySound"
        },
        {
            CLASS = "composite.QUIDBSequence", 
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 12},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "ui_zhuzhuqing_attack13_1"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence", 
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 23},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "ui_zhuzhuqing_attack13_2"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence", 
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 45},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "ui_zhuzhuqing_attack13_3"},
                },
            },
        },
    },
}
return ui_zhuzhuqing_atk13
