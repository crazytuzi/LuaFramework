
local anthem_1 = {
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
	                CLASS = "composite.QSBParallel",
	                ARGS = {
	                    {
	                        CLASS = "action.QSBAttackFinish"
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
	                OPTIONS = {delay_frame = 25},
	            },
	            {
	                CLASS = "action.QSBHitTarget",
	            },
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 45},
	            },
	            {
	                CLASS = "action.QSBHitTarget",
	            },
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 45},
	            },
	            {
	                CLASS = "action.QSBHitTarget",
	            },
        	},
	    },
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 25},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = true, effect_id = "anthem_3"},
	            },
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 45},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = true, effect_id = "anthem_3"},
	            },
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 45},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = true, effect_id = "anthem_3"},
	            },
	    	},
		},
	},
} 

return anthem_1