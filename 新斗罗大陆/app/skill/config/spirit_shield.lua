
local spirit_shield = {
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
	        CLASS = "composite.QSBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QSBPlayAnimation",
	                OPTIONS = {animation = "attack02"},
	            },
                {
                    CLASS = "action.QSBAttackFinish",
                },
	        },
	    },
	    {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false,effect_id="shadow_explosion_1"},
        },
        {
        	CLASS = "composite.QSBSequence",
	        ARGS = {
        		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 0.567},
	            },
			    {
		            CLASS = "action.QSBApplyBuff",
		            OPTIONS = {is_target = false, buff_id = "shadow_explosion_4"},
			    },
	        },
        },		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 5.8},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "shadow_explosion_3"},
	            },
                {
                    CLASS = "action.QSBHitTarget",
                },
	    	},
		},
	},
} 

return spirit_shield