
local ui_ultra_circle_of_healing = {
	CLASS = "composite.QUIDBParallel",
	ARGS = {
		{
	        CLASS = "composite.QUIDBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QUIDBPlayAnimation",
	                OPTIONS = {animation = "attack11"},
	            },
	        },
	    },
	    {
	    	CLASS = "composite.QUIDBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 43},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "circle_of_healing_1_2"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QUIDBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 18},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "circle_of_healing_1_3"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QUIDBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 43},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "circle_of_healing_1_1"},
	            },
        	},
	    },
	},
} 

return ui_ultra_circle_of_healing