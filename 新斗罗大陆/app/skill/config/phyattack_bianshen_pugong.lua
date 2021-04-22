
local phyattack_bianshen_pugong = {			--火猫变身普攻
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
	                OPTIONS = {delay_time = 0.22},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "huomao_pugong_1_1"},		--特效1
	            },
	    	},
		},
		-- {
	 --    	CLASS = "composite.QSBSequence",
	 --    	ARGS = {
	 --    		{
	 --                CLASS = "action.QSBDelayTime",
	 --                OPTIONS = {delay_time = 0.38},
	 --            },
	 --            {
	 --                CLASS = "action.QSBPlayEffect",
	 --                OPTIONS = {is_hit_effect = false, effect_id = "huomao_pugong_1_1"},		--特效2
	 --            },
	 --    	},
		-- },
		{
			CLASS = "composite.QSBSequence",
	    	ARGS = {
				{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 7},
	            },
	            {
	            	 CLASS = "action.QSBHitTarget",
	        	},
	        	{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 6},
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
	                OPTIONS = {delay_frame = 7},
	            },
	            {
	            	 CLASS = "action.QSBPlayEffect",
	            	 OPTIONS = {is_hit_effect = true, effect_id = "melee_hit"},
	        	},
	        	{
	                 CLASS = "action.QSBDelayTime",
	                 OPTIONS = {delay_frame = 6},
	            },
	            {
	            	 CLASS = "action.QSBPlayEffect",
	            	 OPTIONS = {is_hit_effect = true, effect_id = "melee_hit"},
	        	},
        	},
		},

	},
} 

return phyattack_bianshen_pugong