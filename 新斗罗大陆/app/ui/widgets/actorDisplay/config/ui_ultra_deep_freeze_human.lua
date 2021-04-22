
local ui_ultra_deep_freeze_human = {
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
                    OPTIONS = {delay_frame = 2},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "deep_freeze_1_1"},
                }, 
        	},
    	},
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "deep_freeze_1_2"},
                }, 
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "deep_freeze_2_1_1"},
                }, 
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "deep_freeze_3_1_1"},
                }, 
            },
        },
    },
}

return ui_ultra_deep_freeze_human
