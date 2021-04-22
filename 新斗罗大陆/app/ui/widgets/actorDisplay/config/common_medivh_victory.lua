
local common_medivh_victory = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
	        CLASS = "composite.QUIDBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QUIDBPlayAnimation",
	                OPTIONS = {animation = "victory"},
	            },
	        },
	    },
	    {
	    	CLASS = "composite.QUIDBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_time = 0.37},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "wuya_victory"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QUIDBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_time = 0.37},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "wuya_haunt_3"},
	            },
        	},
	    },
    },
}

return common_medivh_victory