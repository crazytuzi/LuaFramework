
local tangsan_pugong2 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
             CLASS = "composite.QUIDBSequence",
             ARGS = {
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 1.53},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "mahongjun_attack11_3_11_ui"},
                },
            },
        },
    },
}

return tangsan_pugong2