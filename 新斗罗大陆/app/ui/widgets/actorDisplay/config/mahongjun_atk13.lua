
local tangsan_pugong2 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
             CLASS = "composite.QUIDBSequence",
             ARGS = {
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 0.8},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "mahongjun_attack13_1_ui"},
                },
            },
        },
    },
}

return tangsan_pugong2