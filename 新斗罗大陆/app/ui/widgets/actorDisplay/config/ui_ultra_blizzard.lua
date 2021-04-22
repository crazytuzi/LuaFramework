
local ui_ultra_blizzard = {
    CLASS = "composite.QUIDBParallel",
    ARGS = {
    	--[[ 
    		assembly line 1: 
    		1. play prepare animation while wait 0.367 (11 frame) and play thunder effect
    		2. play skill animation
    		3. wait and play attack effect
    	--]]
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
                                            OPTIONS = {is_hit_effect = false, effect_id = "blizzard_1"},
                                        },
                                        {
                                            CLASS = "action.QUIDBPlayEffect",
                                            OPTIONS = {is_hit_effect = false, effect_id = "blizzard_4"},
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
        --[[
        	assembly line 2:
        	1. fade in black area (8 frame) and display attacker
            2. wait 78 frame
        	2. fade out (12 frame)
        --]]
        --[[
            assembly line 3:
            1. wait 3.1 (93 frame)
            2. play hit effect for three times
        --]]
    	{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
               
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 2.933},
                },
                {
                    CLASS = "composite.QUIDBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QUIDBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QUIDBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "blizzard_3", is_random_position = true, is_range_effect = true},
                                },
                                {
                                    CLASS = "action.QUIDBDelayTime",
                                    OPTIONS = {delay_time = 0.15},
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return ui_ultra_blizzard