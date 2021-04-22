
local ui_time_passes = {
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
	                OPTIONS = {delay_frame = 0},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "time_passes_1"},
	            },
	    	},
		},
	},
} 

return ui_time_passes