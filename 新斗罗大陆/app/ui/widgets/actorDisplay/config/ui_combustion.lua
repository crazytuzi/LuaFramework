
local ui_combustion = {
    CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "composite.QUIDBParallel",
                    ARGS = {
                         {
                            CLASS = "action.QUIDBPlayAnimation",
                            OPTIONS = {animation = "attack14"},
                        },
                    },
                },
            },
        },
    	{
    		CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 0},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "combustion_4_1"},
                }, 
        	},
    	},
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QUIDBPlayLoopEffect",
                    OPTIONS = {effect_id = "combustion_buff", duration = 4},
                },
            },
        },
    },
}

return ui_combustion
