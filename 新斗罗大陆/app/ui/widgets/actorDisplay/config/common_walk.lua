
local common_walk = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "walk"},
        },
        {
        	CLASS = "composite.QUIDBSequence",
        	ARGS = {
        		{
        			CLASS = "action.QUIDBDelayTime",
        			OPTIONS = {delay_time = 4.0},
        		},
        		{
		            CLASS = "action.QUIDBPlayAnimation",
		            OPTIONS = {animation = "stand"},
		        },
        	},
    	},
    },
}

return common_walk