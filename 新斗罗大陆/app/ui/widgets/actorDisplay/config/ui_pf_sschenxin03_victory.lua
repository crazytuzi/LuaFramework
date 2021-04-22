
local common_victory = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "victory"},
        },
        {
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 58},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf_sschenxin03_victory_ui"},--剑消散特效
	            },
	        },
	    }, 

    },
}

return common_victory