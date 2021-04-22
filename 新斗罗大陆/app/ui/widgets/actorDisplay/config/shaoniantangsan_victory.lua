local shaoniantangsan_shengli = {
    CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlaySound",
            OPTIONS = {sound_id = "tangsan_cheer"},
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "victory"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "tangsan_victory_1_ui"},
                },
            },
        },
    },
}

return shaoniantangsan_shengli