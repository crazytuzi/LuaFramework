
local fulande_bianshen = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {is_loop = false,animation = "stand_1"},
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
                    OPTIONS = {animation = "stand"},
                },
				{
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 2},
                },
            },
        },
    },
}

return fulande_bianshen