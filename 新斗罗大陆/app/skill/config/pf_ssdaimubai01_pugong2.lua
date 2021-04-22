local pf_ssdaimubai01_pugong2 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
    	{
			CLASS = "composite.QSBParallel",
		    ARGS = 
		    {
		        {
			        CLASS = "composite.QSBSequence",
			        ARGS = 
			        {
			            {
			                CLASS = "action.QSBPlayAnimation",
			                OPTIONS = {animation = "attack02"},
			            },
			        },
			    },
			    {
			    	CLASS = "composite.QSBSequence",
			        ARGS = 
			        {
			    		{
			                CLASS = "action.QSBDelayTime",
			                OPTIONS = {delay_time = 7 / 30},
			            },
			            {
			                CLASS = "action.QSBPlayEffect",
			                OPTIONS = {is_hit_effect = false, effect_id = "pf_ssdaimubai01_attack02_1"},
			            },
		        	},
			    },
			    {
			    	CLASS = "composite.QSBSequence",
			        ARGS = {
			    		
			            {
			                CLASS = "action.QSBDelayTime",
			                OPTIONS = {delay_time = 26/ 30 },
			            },
			            {
			                CLASS = "action.QSBPlayEffect",
			                OPTIONS = {is_hit_effect = false, effect_id = "pf_ssdaimubai01_attack01_3"},
			            },
		        	},
			    },
			    {
			    	CLASS = "composite.QSBSequence",
			        ARGS = 
			        {
			    		
			            {
			                CLASS = "action.QSBDelayTime",
			                OPTIONS = {delay_time = 30/ 30 },
			            },
			            {
			              CLASS = "action.QSBHitTarget",
			            },
		        	},
			    },
		    },
	    },
	    {
		  CLASS = "action.QSBAttackFinish",
		},
    },
}

return pf_ssdaimubai01_pugong2