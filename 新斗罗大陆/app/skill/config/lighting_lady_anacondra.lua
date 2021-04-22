
local lighting_lady_anacondra = {
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
	        CLASS = "composite.QSBSequence",
	        ARGS = {
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
	                OPTIONS = {delay_frame = 1},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "groups_lightning_1"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	        	{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 2},
	            },
	        	{
	        		CLASS = "composite.QSBParallel",
	        		ARGS = {
	        			{
			                CLASS = "action.QSBPlayEffect",
			                OPTIONS = {is_hit_effect = false, effect_id = "lighting_1_4"},
			            },
			            {
			                CLASS = "action.QSBBullet",
			        		OPTIONS = {effect_id = "lighting_lady_anacondra_2", speed = 1900, hit_effect_id = "lighting_lady_anacondra_3"},
			            },
	        		},
	        	},
        	},
	    },
	},
} 

return lighting_lady_anacondra