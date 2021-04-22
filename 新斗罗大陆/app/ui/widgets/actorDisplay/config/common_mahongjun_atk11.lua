
local common_mahongjun_atk11 = {
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
		            OPTIONS = {delay_time = 0.9},
		        },
	            {
	                CLASS = "action.QUIDBPlayEffect",	
	                OPTIONS = {is_hit_effect = false, effect_id = "zhanshi_mahongjun_attack11_3_2"},
	            },
	        },
	    },
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
		        {
		            CLASS = "action.QUIDBDelayTime",
		            OPTIONS = {delay_time = 0.9},
		        },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "zhanshi_mahongjun_attack11_3_1"},
	            },
	    	},
		},
    },
}

return common_mahongjun_atk11