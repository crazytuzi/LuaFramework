
local tangsan_pugong2 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
             CLASS = "composite.QUIDBSequence",
             ARGS = {
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack02"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 0.66},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "tangsan_attack02_1_ui"},
                },
            },
        },
    },
}

return tangsan_pugong2