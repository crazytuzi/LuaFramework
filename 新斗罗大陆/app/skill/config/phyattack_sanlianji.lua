
local phyattack_sanlianji = {			--火猫三连击
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
	        CLASS = "composite.QSBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QSBPlayAnimation",
	                OPTIONS = {animation = "attack13"},				---动作
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
	                OPTIONS = {delay_time = 0.32},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "fdr_3lianji_1"},		--特效1
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 0.62},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "fdr_3lianji_1_2"},		--特效2
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.2},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "fdr_3lianji_1_3"},		--特效3
	            },
	    	},
		},
		{
			CLASS = "composite.QSBSequence",
	    	ARGS = {
				{
	                CLASS = "action.QSBDelayTime",        ---延时-
	                OPTIONS = {delay_frame = 12},
	            },
	            {
	            	CLASS = "action.QSBHitTarget",        ---伤害-
	        	},
	        	{
	                CLASS = "action.QSBDelayTime",        ---延时-
	                OPTIONS = {delay_frame = 7},
	            },
	            {
	            	CLASS = "action.QSBHitTarget",        ---伤害-
	        	},
	            {
	                CLASS = "action.QSBDelayTime",        ---延时-
	                OPTIONS = {delay_frame = 6},
	            },
	            {
	            	CLASS = "action.QSBHitTarget",        ---伤害-
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
	        	{
	                 CLASS = "action.QSBDelayTime",       ---延时-
	                 OPTIONS = {delay_frame = 6},
	            },
	            {
	            	 CLASS = "action.QSBPlayEffect",
	            	 OPTIONS = {is_hit_effect = true, effect_id = "melee_hit"},      ---播放特效-
	        	},
        	},
		},
	},
} 

------------------------------------------变身后脚本------------------------------------------------------------
local phyattack_bianshen_sanlianji = {			--火猫变身三连击
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
	        CLASS = "composite.QSBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QSBPlayAnimation",
	                OPTIONS = {animation = "attack13"},				---动作
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
	                OPTIONS = {delay_time = 0.26},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "huomao_3lianji_1"},		--特效1
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 0.63},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "huomao_3lianji_1_2"},		--特效2
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.33},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "huomao_3lianji_1_3_1"},		--特效3
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.33},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "huomao_3lianji_1_3_2"},		--特效4
	            },
	    	},
		},
		{
			CLASS = "composite.QSBSequence",
	    	ARGS = {
				{
	                CLASS = "action.QSBDelayTime",        ---延时-
	                OPTIONS = {delay_frame = 10},
	            },
	            {
	            	CLASS = "action.QSBHitTarget",        ---伤害-
	        	},
	        	{
	                CLASS = "action.QSBDelayTime",        ---延时-
	                OPTIONS = {delay_frame = 6},
	            },
	            {
	            	CLASS = "action.QSBHitTarget",        ---伤害-
	        	},
	            {
	                CLASS = "action.QSBDelayTime",        ---延时-
	                OPTIONS = {delay_frame = 7},
	            },
	            {
	            	CLASS = "action.QSBHitTarget",        ---伤害-
	        	},
        	},
		},
		{
			CLASS = "composite.QSBSequence",
	    	ARGS = {
				{
	                CLASS = "action.QSBDelayTime",       ---延时-
	                OPTIONS = {delay_frame = 10},
	            },
	            {
	            	 CLASS = "action.QSBPlayEffect",
	            	 OPTIONS = {is_hit_effect = true, effect_id = "melee_hit"},       ---播放特效-
	        	},
	        	{
	                 CLASS = "action.QSBDelayTime",       ---延时-
	                 OPTIONS = {delay_frame = 6},
	            },
	            {
	            	 CLASS = "action.QSBPlayEffect",
	            	 OPTIONS = {is_hit_effect = true, effect_id = "melee_hit"},      ---播放特效-
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


-- return phyattack_sanlianji
return {phyattack_sanlianji,phyattack_bianshen_sanlianji}