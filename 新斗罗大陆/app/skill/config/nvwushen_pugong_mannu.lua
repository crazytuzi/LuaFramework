
local nvwushen_pugong_mannu = {			--女武神普攻2满怒
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
	        CLASS = "composite.QSBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QSBPlayAnimation",
	                OPTIONS = {animation = "attack02"},				---动作
	            },
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 0.46},
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
	                OPTIONS = {delay_time = 0.46},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "dln_pg_2_1"},		--特效1
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.1},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "dln_pg_2_1_2"},		--特效2
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 2.1},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "dln_pg_2_2"},		--特效3
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 2.2},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "dln_pg_2_3"},		--特效4
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.8},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "dln_pg_2_4"},		--特效5
	            },
	    	},
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.66},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {is_range_hit = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.2},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {is_range_hit = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.6},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {is_range_hit = true},
                },                                                                                              
            },    
        },		
		{
			CLASS = "composite.QSBSequence",
	    	ARGS = {
				{
	                CLASS = "action.QSBDelayTime",       ---延时-
	                OPTIONS = {delay_frame = 18},
	            },
	            {
	            	 CLASS = "action.QSBPlayEffect",
	            	 OPTIONS = {is_hit_effect = true, effect_id = "melee_hit"},       ---播放特效-
	        	},
	        	{
	                 CLASS = "action.QSBDelayTime",       ---延时-
	                 OPTIONS = {delay_frame = 17},
	            },
	            {
	            	 CLASS = "action.QSBPlayEffect",
	            	 OPTIONS = {is_hit_effect = true, effect_id = "melee_hit"},      ---播放特效-
	        	},
	        	{
	                 CLASS = "action.QSBDelayTime",       ---延时-
	                 OPTIONS = {delay_frame = 18},
	            },
	            {
	            	 CLASS = "action.QSBPlayEffect",
	            	 OPTIONS = {is_hit_effect = true, effect_id = "melee_hit"},      ---播放特效-
	        	},	        	
        	},
		},
	},
} 

return nvwushen_pugong_mannu