
local common_ningrongrong_long_atk14 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack14"},
        },
        {
        	CLASS = "composite.QUIDBSequence",
        	ARGS = {
        		{
        			CLASS = "action.QUIDBDelayTime",
        			OPTIONS = {delay_frame = 2},
        		},
        		{
		            CLASS = "action.QUIDBPlayEffect",
		            OPTIONS = {effect_id = "nignrongrong_ui_attack14"},
		        },
        	},
    	},
    },
}

return common_ningrongrong_long_atk14