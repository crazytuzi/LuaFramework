local MISSILE_START_TIME = 0.47
local MISSILE_END_TIME = 1.76
local MISSILE_NUMBER = 5
local MISSILE_INTERVAL = (MISSILE_END_TIME - MISSILE_START_TIME) / (MISSILE_NUMBER - 1)
local MISSILE_SPEED = 1100 * 1.0

local multi_vampiric = {
	CLASS = "composite.QSBParallel",
    ARGS = {
    	{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                    		OPTIONS = {is_target_effect = true, effect_id = "vampiric_1"},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                    		OPTIONS = {delay_frame = 7},
                        },
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "vampiric_3", is_not_loop = true, is_throw = true, from_target = true}
		                        }
		                	},
		            	},
                    },
                },
            },
        },
    },
} 

return multi_vampiric