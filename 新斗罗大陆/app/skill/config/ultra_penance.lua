local MISSILE_START_TIME = 0.367
local MISSILE_END_TIME = 1.167
local MISSILE_NUMBER = 3
local MISSILE_INTERVAL = (MISSILE_END_TIME - MISSILE_START_TIME) / (MISSILE_NUMBER - 1)
local MISSILE_SPEED = 1000
local START_POSITION = -110
local END_POSITION = 50
local DISAPPEAR_POSITION = -200 - END_POSITION
local SCISSOR = {x = 0 - START_POSITION, y = -100, width = -15 - START_POSITION, height = 200, grad1x1 = -25, grad1x2 = 25, grad2x1 = -25, grad2x2 = 25}
local RENDER_TEXTURE_SIZE = CCSize(500, 150)
-- local SCISSOR = {x = 0 - START_POSITION, y = -100, width = -15 - START_POSITION, height = 200, grad1x1 = 0, grad1x2 = 0, grad2x1 = 0, grad2x2 = 0}
-- local SCISSOR = nil

local ultra_penance = {			-- 苦修
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
				                    CLASS = "action.QSBAttackFinish",
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
		                        -- {
		                        --     CLASS = "action.QSBPlayEffect",
                          --   		OPTIONS = {is_hit_effect = false, effect_id = "arcane_missiles_1"},
		                        -- },
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
                            		OPTIONS = {effect_id = "penance_3", speed = MISSILE_SPEED, is_not_loop = false, 
	                            		scissor = SCISSOR,
	                            		start_position = START_POSITION,
	                            		end_position = END_POSITION,
	                            		disappear_position = DISAPPEAR_POSITION,
	                            		size_render_texture = RENDER_TEXTURE_SIZE,
                            		},
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
                            		OPTIONS = {effect_id = "penance_2", speed = MISSILE_SPEED, is_not_loop = false, 
	                            		scissor = SCISSOR,
	                            		start_position = START_POSITION,
	                            		end_position = END_POSITION,
	                            		disappear_position = DISAPPEAR_POSITION,
	                            		size_render_texture = RENDER_TEXTURE_SIZE,
                            		},
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
                            		OPTIONS = {effect_id = "penance_2", speed = MISSILE_SPEED, is_not_loop = false, 
	                            		scissor = SCISSOR,
	                            		start_position = START_POSITION,
	                            		end_position = END_POSITION,
	                            		disappear_position = DISAPPEAR_POSITION,
	                            		size_render_texture = RENDER_TEXTURE_SIZE,
                            		},
		                        },
		                	},
		            	},
                    },
                },
            },
        },
        {
        	CLASS = "composite.QSBSequence",
        	ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QSBPlayEffect",
            		OPTIONS = {is_hit_effect = false, effect_id = "tld_pugong_1"},
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

return ultra_penance
