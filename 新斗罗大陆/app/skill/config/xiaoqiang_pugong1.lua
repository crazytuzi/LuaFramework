
local xiaoqiang_pugong1 = {			--小强普攻1
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
	        CLASS = "composite.QSBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QSBPlayAnimation",
	                OPTIONS = {animation = "attack01"},				---动作
	            },
                {
                    CLASS = "action.QSBAttackFinish"				--技能结束，才可以执行下一个技能。
                },
	        },
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 0.45},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "dxlz_pugong_1_1"},		--特效1
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 0.73},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "dxlz_pugong_1_1-1"},		--特效1
	            },
	    	},
		},
		{
			CLASS = "composite.QSBSequence",
	    	ARGS = {
				{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 12},
	            },
	            {
	            	 CLASS = "action.QSBHitTarget",
	        	},
	        	{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 7},
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
	                CLASS = "action.QSBDelayTime",       ---延时-
	                OPTIONS = {delay_frame = 12},
	            },
	            {
	            	 CLASS = "action.QSBPlayEffect",
	            	 OPTIONS = {is_hit_effect = true, effect_id = "melee_hit"},       ---播放特效-
	        	},
	        	{
	                 CLASS = "action.QSBDelayTime",       ---延时-
	                 OPTIONS = {delay_frame = 7},
	            },
	            {
	            	 CLASS = "action.QSBPlayEffect",
	            	 OPTIONS = {is_hit_effect = true, effect_id = "melee_hit"},      ---播放特效-
	        	},
        	},
		},
	},
} 

return xiaoqiang_pugong1