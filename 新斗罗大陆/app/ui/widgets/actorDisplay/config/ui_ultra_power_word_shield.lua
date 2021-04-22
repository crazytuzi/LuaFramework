
local ui_ultra_power_word_shield = {
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
                            OPTIONS = {animation = "attack11"},
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
                    OPTIONS = {delay_frame = 34},
                },
				{
					CLASS = "composite.QUIDBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "power_word_shield_1"},
                        },
					},
				},
        	},
    	},
    },
}

return ui_ultra_power_word_shield