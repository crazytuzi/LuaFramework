
local arcane_explosion_doan = {
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
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "arcane_explosion_doan_1_3"},
        },
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 31},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "arcane_explosion_doan_1_1"},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "arcane_explosion_doan_1_2"},
	            },
	    	},
		},
		{
			CLASS = "composite.QSBSequence",
	    	ARGS = {
				{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 40},
	            },
	            {
	            	 CLASS = "action.QSBHitTarget",
	        	},
        	},
		},
	},
} 

return arcane_explosion_doan