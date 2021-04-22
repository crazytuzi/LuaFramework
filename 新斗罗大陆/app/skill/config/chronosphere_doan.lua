
local chronosphere_doan = {
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
	        CLASS = "composite.QSBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QSBPlayAnimation",
	                OPTIONS = {animation = "attack14"},
	            },
                {
                    CLASS = "action.QSBAttackFinish"
                },
	        },
	    },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "chronosphere_doan_6_1"},
        },
        {
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 2},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "chronosphere_doan_6_2"},
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 32},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "chronosphere_doan_6_3"},
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
					CLASS = "composite.QSBParallel",
					ARGS = {
			            {
			                CLASS = "action.QSBApplyBuff",
			                OPTIONS = {is_target = false, buff_id = "chronosphere_doan_7_2"},
			            },
			            {
			                CLASS = "action.QSBApplyBuff",
			                OPTIONS = {is_target = false, buff_id = "chronosphere_doan_7_1"},
			            },
			        },
		        },
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 200},
	            },
	            {
					CLASS = "composite.QSBParallel",
					ARGS = {
			            {
			                CLASS = "action.QSBRemoveBuff",
			                OPTIONS = {is_target = false, buff_id = "chronosphere_doan_7_2"},
			            },
			            {
			                CLASS = "action.QSBRemoveBuff",
			                OPTIONS = {is_target = false, buff_id = "chronosphere_doan_7_1"},
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
        	},
		},
	},
} 

return chronosphere_doan