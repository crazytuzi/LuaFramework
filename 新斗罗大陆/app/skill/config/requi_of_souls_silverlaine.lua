
local requi_of_souls_silverlaine = {
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 2},
        },
		{
	        CLASS = "composite.QSBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack07", revertable = true, reload_on_cancel = true},
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
	                OPTIONS = {delay_time = 0.8},
	            },
	            {
		            CLASS = "composite.QSBSequence",
			        ARGS = {
			        	{
			                CLASS = "action.QSBPlayLoopEffect",
			                OPTIONS = {effect_id = "requi_of_souls_1_1"},
	            		},
	            		{
			                CLASS = "action.QSBPlayLoopEffect",
			                OPTIONS = {effect_id = "requi_of_souls_1_3"},
	            		},
            		},
		        },
		        {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 3.2},
	            },
	            {
		            CLASS = "composite.QSBSequence",
			        ARGS = {
			        	{
			                CLASS = "action.QSBStopLoopEffect",
			                OPTIONS = {effect_id = "requi_of_souls_1_1"},
	            		},
	            		{
			                CLASS = "action.QSBStopLoopEffect",
			                OPTIONS = {effect_id = "requi_of_souls_1_3"},
	            		},
            		},
		        },
        	},
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	            {
	                CLASS = "action.QSBPlayWarningZone",
	                OPTIONS = {duration = 4, effect_id = "The_flame_tip_ring_3",is_hit_effect = false},
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 4},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "requi_of_souls_1_2"},
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 4},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "requi_of_souls_1"},
	            },
	    	},
		},
		{
			CLASS = "composite.QSBSequence",
	    	ARGS = {
				{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 4.1},
	            },
	            {
	            	 CLASS = "action.QSBHitTarget",
	        	},
        	},
		},
	},
} 

return requi_of_souls_silverlaine