local MISSILE_START_TIME = 0.47
local MISSILE_END_TIME = 1.76
local MISSILE_NUMBER = 5
local MISSILE_INTERVAL = (MISSILE_END_TIME - MISSILE_START_TIME) / (MISSILE_NUMBER - 1)
local MISSILE_SPEED = 1100 * 1.0

local castthrow = {
	CLASS = "composite.QSBParallel",
    ARGS = {
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    	{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                    		OPTIONS = {delay_frame = 25},
                        },
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "castthrow_2", is_not_loop = true, is_throw = true, hit_duration = -1,height_ratio=2000,throw_speed = 600,at_position = {x = 0 , y = 0}}
		                        }
		                	},
		            	},
                    },
                },
            },
        },
    },
} 

return castthrow