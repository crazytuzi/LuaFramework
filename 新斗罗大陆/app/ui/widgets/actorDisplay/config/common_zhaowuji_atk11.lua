
local common_zhaowuji_atk11 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {is_loop = false, animation = "attack11"},
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 1.1},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "zhanshi_zhaowuji_attack11_3"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 2.5},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return common_zhaowuji_atk11