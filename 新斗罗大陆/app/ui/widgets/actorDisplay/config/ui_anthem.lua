
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
	                OPTIONS = {delay_frame = 17},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = true, effect_id = "anthem_3"},
	            },
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 19},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = true, effect_id = "anthem_3"},
	            },
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 19},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = true, effect_id = "anthem_3"},
	            },
	    	},
		},
	},
} 

return ui_anthem