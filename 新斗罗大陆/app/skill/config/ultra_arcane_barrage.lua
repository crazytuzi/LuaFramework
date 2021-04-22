
local ultra_arcane_barrage = {
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
		                    CLASS = "action.QSBPlayAnimation",
		                    OPTIONS = {animation = "attack13"},
		                },
		                {
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 1.133},
		                        },
		                        {
		                            CLASS = "action.QSBPlayEffect",
                            		OPTIONS = {is_hit_effect = false, effect_id = "arcane_barrage_4"},
		                        },
		                	},
		            	},
		            	-- first bullet
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 1.133},
		                        },
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "arcane_barrage_2", speed = 1100, hit_effect_id = "arcane_barrage_3"},
		                        },
		                	},
		            	},
		            	-- second bullet delay 8 frame
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 1.133},
		                        },
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 0.267},
		                        },
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "arcane_barrage_2", speed = 1100, hit_effect_id = "arcane_barrage_3", is_random_position = true},
		                        },
		                	},
		            	},
		            	-- third bullet delay 17 frame
		            	{
		                	CLASS = "composite.QSBSequence",
		                	ARGS = {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 1.133},
		                        },
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 0.567},
		                        },
		                        {
		                            CLASS = "action.QSBBullet",
                            		OPTIONS = {effect_id = "arcane_barrage_2", speed = 1100, hit_effect_id = "arcane_barrage_3", is_random_position = true},
		                        },
		                        {
				                    CLASS = "action.QSBAttackFinish"
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
        {
        	CLASS = "composite.QSBSequence",
        	ARGS = {
        		{
        			CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
        		},
        		{
        			CLASS = "action.QSBBulletTime",
        			OPTIONS = {turn_on = true, revertable = true},
        		},
        		{
        			CLASS = "action.QSBDelayTime",
        			OPTIONS = {delay_time = 0.767},
        		},
        		{
        			CLASS = "action.QSBBulletTime",
        			OPTIONS = {turn_on = false},
        		},
        		{
        			CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.267},
        		},
        	},
    	},
    },
} 

return ultra_arcane_barrage