
local ui_ultra_taunt = {
    CLASS = "composite.QUIDBParallel",
    ARGS = {
    	--[[ 
    		assembly line 1: 
    		1. play prepare animation
    		2. play skill animation
    		3. hit target, play hit effect and finish attack
    	--]]
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 8},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                },
            },
        },
        --[[
            assembly line 2:
            1. wait 0.1 (3 frame)
            2. play thunder effect
            3. wait 0.467 (14 frame)
            4. play attack effect
        --]]
    	{
    		CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 33},
                },
                {
                    CLASS = "composite.QUIDBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "taunt_2"},
                        },
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "taunt_3"},
                        },
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "taunt_1"},
                        },
                    },
                },
        	},
    	},
    },
}

return ui_ultra_taunt