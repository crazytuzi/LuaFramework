local MISSILE_START_TIME = 0.47
local MISSILE_END_TIME = 1.76
local MISSILE_NUMBER = 5
local MISSILE_INTERVAL = (MISSILE_END_TIME - MISSILE_START_TIME) / (MISSILE_NUMBER - 1)
local MISSILE_SPEED = 1100 * 1.0

local gas_bomb = {
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
                    		OPTIONS = {delay_frame = 15},
                        },
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "cast_glass_2", is_not_loop = true, is_throw = true, hit_duration = -1,height_ratio=10,throw_speed = 1100,at_position = {x = 65 , y = -100}}
		                        }
		                	},
		            	},
                    },
                },
            },
        },
    },
} 

return gas_bomb