
local common_ultra_victory = {
	CLASS = "composite.QUIDBSequence",
    ARGS = {
    	{
    		CLASS = "action.QUIDBActorFade",
    		OPTIONS = {fadeout = true, duration = 0,},
		},
        {
            CLASS = "action.QUIDBDelayTime",
            OPTIONS = {delay_time = 1.0},
        },
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "flash_out_1", async = true},
        },
        {
        	CLASS = "action.QUIDBDelayTime", 
        	OPTIONS = {delay_time = 0.5},
    	},
    	{
    		CLASS = "action.QUIDBActorFade",
    		OPTIONS = {fadein = true, duration = 0.1},
		},
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "victory", async = true},
        },
    },
}

return common_ultra_victory