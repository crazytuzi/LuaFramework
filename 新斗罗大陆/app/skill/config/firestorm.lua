
local firestorm = {
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
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "firestorm_1"},
	            },
	            {
	                CLASS = "action.QSBDelayByAttack",
	            },
	            {
                    CLASS = "action.QSBUncancellable",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true, effect_id = "firestorm_3",is_range_effect = true},
                },
            },
        },
	    {
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	            {
	                CLASS = "action.QSBPlayWarningZone",
	                OPTIONS = {duration = 3, effect_id = "The_flame_tip_ring_2",is_hit_effect = true,is_range_effect = true},
	            },
	    	},
		},
		{
			CLASS = "composite.QSBSequence",
	    	ARGS = {
				{
	                CLASS = "action.QSBDelayByAttack",
	            },
	            {
	            	 CLASS = "action.QSBHitTarget",
	            	 OPTIONS = {is_range_hit = true},
	        	},
        	},
		},
	},
} 

return firestorm