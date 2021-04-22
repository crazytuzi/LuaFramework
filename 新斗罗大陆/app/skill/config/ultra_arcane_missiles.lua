local MISSILE_START_TIME = 0.47
local MISSILE_END_TIME = 1.76
local MISSILE_NUMBER = 5
local MISSILE_INTERVAL = (MISSILE_END_TIME - MISSILE_START_TIME) / (MISSILE_NUMBER - 1)
local MISSILE_SPEED = 1100 * 1.0
local MISSILE_SCISSOR = {x = 0, y = -100, width = 110, height = 200, grad1x1 = -25, grad1x2 = 25, grad2x1 = -25, grad2x2 = 25}
local RENDER_TEXTURE_SIZE = CCSize(500, 100)
-- local MISSILE_SCISSOR = {x = 0, y = -100, width = 110, height = 200, grad1x1 = 0, grad1x2 = 0, grad2x1 = 0, grad2x2 = 0}

local ultra_arcane_missiles = {
	CLASS = "composite.QSBParallel",
    ARGS = {
    	--[[ 
    		assembly line 1: 
    		1. play prepare animation
    		2. play skill animation
    		3. play hit effect, create 3 bullet and finish attack
    	--]]
    	{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
		                {
		                	CLASS = "composite.QSBSequence",
		                	ARGS = 
		                	{
		                    	{
				                    CLASS = "action.QSBPlayAnimation",
				                    OPTIONS = {animation = "attack13"},
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
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = MISSILE_START_TIME},
		                        },
		                        {
		                            CLASS = "action.QSBPlayEffect",
                            		OPTIONS = {is_hit_effect = false, effect_id = "arcane_missiles_1"},
		                        },
		                	},
		            	},
		            	-- first bullet
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = MISSILE_START_TIME + MISSILE_INTERVAL * 0},
		                        },
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "arcane_missiles_2", speed = MISSILE_SPEED, hit_effect_id = "arcane_missiles_3", is_random_position = true, is_not_loop = true, 
                            		scissor = MISSILE_SCISSOR,
	                            	size_render_texture = RENDER_TEXTURE_SIZE,}
		                        },
		                	},
		            	},
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = MISSILE_START_TIME + MISSILE_INTERVAL * 1},
		                        },
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "arcane_missiles_2", speed = MISSILE_SPEED, hit_effect_id = "arcane_missiles_3", is_random_position = true, is_not_loop = true, 
                            		scissor = MISSILE_SCISSOR,
	                            	size_render_texture = RENDER_TEXTURE_SIZE,}
		                        },
		                	},
		            	},
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = MISSILE_START_TIME + MISSILE_INTERVAL * 2},
		                        },
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "arcane_missiles_2", speed = MISSILE_SPEED, hit_effect_id = "arcane_missiles_3", is_random_position = true, is_not_loop = true, 
                            		scissor = MISSILE_SCISSOR,
	                            	size_render_texture = RENDER_TEXTURE_SIZE,}
		                        },
		                	},
		            	},
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = MISSILE_START_TIME + MISSILE_INTERVAL * 3},
		                        },
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "arcane_missiles_2", speed = MISSILE_SPEED, hit_effect_id = "arcane_missiles_3", is_random_position = true, is_not_loop = true, 
                            		scissor = MISSILE_SCISSOR,
	                            	size_render_texture = RENDER_TEXTURE_SIZE,}
		                        },
		                	},
		            	},
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = MISSILE_START_TIME + MISSILE_INTERVAL * 4},
		                        },
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "arcane_missiles_2", speed = MISSILE_SPEED, hit_effect_id = "arcane_missiles_3", is_random_position = true, is_not_loop = true, 
                            		scissor = MISSILE_SCISSOR,
	                            	size_render_texture = RENDER_TEXTURE_SIZE,}
		                        },
		                	},
		            	},
                    },
                },
            },
        },
        --[[
        	assembly line 2:
        	1. fade in black area and display attacker
        	2. fade out 
        --]]
     --    {
     --    	CLASS = "composite.QSBSequence",
     --    	ARGS = {
     --    		{
     --    			CLASS = "action.QSBShowActor",
     --                OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
     --    		},
     --    		{
     --    			CLASS = "action.QSBBulletTime",
     --    			OPTIONS = {turn_on = true, revertable = true},
     --    		},
     --    		{
     --    			CLASS = "action.QSBDelayTime",
     --    			OPTIONS = {delay_time = 0.767},
     --    		},
     --    		{
     --    			CLASS = "action.QSBBulletTime",
     --    			OPTIONS = {turn_on = false},
     --    		},
     --    		{
     --    			CLASS = "action.QSBShowActor",
     --                OPTIONS = {is_attacker = true, turn_on = false, time = 0.267},
     --    		},
     --    	},
    	-- },
    },
} 

return ultra_arcane_missiles