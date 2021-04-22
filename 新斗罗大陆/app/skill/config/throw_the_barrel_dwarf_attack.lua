local MISSILE_START_TIME = 0.47
local MISSILE_END_TIME = 1.76
local MISSILE_NUMBER = 5
local MISSILE_INTERVAL = (MISSILE_END_TIME - MISSILE_START_TIME) / (MISSILE_NUMBER - 1)
local MISSILE_SPEED = 1100 * 1.0

local throw_the_barrel_dwarf_attack = {
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
                    		OPTIONS = {delay_frame = 20},
                        },
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "throw_the_barrel", is_not_loop = true, is_throw = true, hit_duration = -1, height_ratio = 7, at_position = {x = 20 , y = -100},throw_speed = 900}
		                        }
		                	},
		            	},
                    },
                },
            },
        },
    },
} 

return throw_the_barrel_dwarf_attack