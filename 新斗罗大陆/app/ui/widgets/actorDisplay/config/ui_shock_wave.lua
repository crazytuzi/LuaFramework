
local ui_shock_wave = {
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
                    OPTIONS = {is_hit_effect = false, effect_id = "shock_wave_1_1"},
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
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "shock_wave_1_2"},
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
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "shock_wave_1_3"},
                }, 
            },
        },
    },
}

return ui_shock_wave
