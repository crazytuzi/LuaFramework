
local common_xiaoqiang_victory = {
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
	                OPTIONS = {delay_time = 0.3},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "dxlz_shifa_1_2"},
	            },
	            
        	},
	    },
	    {
	    	CLASS = "composite.QUIDBSequence",
	        ARGS = {
	    		
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_time = 1},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "dxlz_shifa_1_1"},
	            },
        	},
	    },
    },
}

return common_xiaoqiang_victory