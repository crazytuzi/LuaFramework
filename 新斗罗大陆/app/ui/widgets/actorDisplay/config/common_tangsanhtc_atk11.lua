local common_zhaowuji_atk11 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 1},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {is_loop = false, animation = "attack11_2"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 1.5},
                },
                 {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {is_loop = false, animation = "attack11_3"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 2},
                },
                 {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {is_loop = false, animation = "attack11_1"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time =5.5},
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