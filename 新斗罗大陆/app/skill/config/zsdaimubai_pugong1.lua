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
			                OPTIONS = {animation = "attack01"},
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
			                OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack01"},
			            },		            
		        	},
			    },
			    {
			    	CLASS = "composite.QSBSequence",
			        ARGS = 
			        {
			    		{
			                CLASS = "action.QSBDelayTime",
			                OPTIONS = {delay_time = 10/ 30 },
			            },
			            {
							CLASS = "composite.QSBParallel",
						    ARGS = 
					    	{
					            {
					                CLASS = "action.QSBPlayEffect",
					                OPTIONS = {is_hit_effect = true, effect_id = "shaoniandaimubai_atk02_3"},
					            },
					            {
					              CLASS = "action.QSBHitTarget",
					            },
				            },
			            },
		        	},
			    },
			    {
			    	CLASS = "composite.QSBSequence",
			        ARGS = 
			        {
			    		
			            {
			                CLASS = "action.QSBDelayTime",
			                OPTIONS = {delay_time = 22/ 30 },
			            },
			            {
							CLASS = "composite.QSBParallel",
						    ARGS = 
					    	{
					            {
					                CLASS = "action.QSBPlayEffect",
					                OPTIONS = {is_hit_effect = true, effect_id = "shaoniandaimubai_atk02_3"},
					            },
					            {
					              CLASS = "action.QSBHitTarget",
					            },
				            },
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