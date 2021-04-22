local common_xiaoqiang_victory = 
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
			                OPTIONS = {delay_time = 0 / 30},
			            },
			            {
			                CLASS = "action.QSBPlayEffect",
			                OPTIONS = {is_hit_effect = false, effect_id = "pf_ssdaimubai02_attack02"},
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
			                OPTIONS = {is_hit_effect = false, effect_id = "pf_ssdaimubai02_attack02_1_1"},
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

return common_xiaoqiang_victory