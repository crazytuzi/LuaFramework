
local common_ningrongrong_long_atk13 = {
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
        			OPTIONS = {delay_frame = 29},
        		},
        		{
		            CLASS = "action.QUIDBPlayEffect",
		            OPTIONS = {effect_id = "nignrongrong_ui_attack13"},
		        },
        	},
    	},
    },
}

return common_ningrongrong_long_atk13