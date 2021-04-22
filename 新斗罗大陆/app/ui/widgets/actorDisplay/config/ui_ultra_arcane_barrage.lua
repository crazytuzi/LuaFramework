
local ui_ultra_arcane_barrage = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
    	--[[ 
    		assembly line 1: 
    		1. play prepare animation
    		2. play skill animation
    		3. play hit effect, create 3 bullet and finish attack
    	--]]
    	{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "composite.QUIDBParallel",
                    ARGS = {
                    	{
		                    CLASS = "action.QUIDBPlayAnimation",
		                    OPTIONS = {animation = "attack13"},
		                },
		                {
		                	CLASS = "composite.QUIDBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QUIDBDelayTime",
		                            OPTIONS = {delay_time = 1.133},
		                        },
		                        {
		                            CLASS = "action.QUIDBPlayEffect",
                            		OPTIONS = {is_hit_effect = false, effect_id = "arcane_barrage_4"},
		                        },
		                	},
		            	},
                    },
                },
            },
        },
    },
} 

return ui_ultra_arcane_barrage