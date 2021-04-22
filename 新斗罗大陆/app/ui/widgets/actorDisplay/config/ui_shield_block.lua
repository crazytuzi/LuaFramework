
local ui_anthem = {
	CLASS = "composite.QUIDBParallel",
	ARGS = {
		{
	        CLASS = "composite.QUIDBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QUIDBPlayAnimation",
	                OPTIONS = {animation = "attack14"},
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
                    CLASS = "action.QUIDBPlayLoopEffect",
                    OPTIONS = {effect_id = "shield_block_buff", duration = 4},
                },
            },
        },
	},
} 

return ui_anthem