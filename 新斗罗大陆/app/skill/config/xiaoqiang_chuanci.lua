
local xiaoqiang_chuanci = {			--小强穿刺1
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
	                OPTIONS = {delay_time = 0},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {effect_id = "dixuechuanci_y"},		--特效2
	            },
	    	},
		},		
	    {
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 0.53},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "dxlz_chuanci_1_1"},		--特效1
	            },
	            
    			},
		},
	    {
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 0.52},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "dxlz_chuanci_1"},		--特效2
	            },
	    	},
		},
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {forward_mode = true},
	    	ARGS = {
				{
	                CLASS = "action.QSBDelayTime",                     ---伤害延时-
	                OPTIONS = {delay_frame = 12},
	            },
	            { 
	    			CLASS = "action.QSBSelectTarget",
					OPTIONS = {furthest = true, always = true},
				},
	            {
	            	CLASS = "action.QSBHitTarget",
	            	OPTIONS = {is_current_target = true},
	        	},
	        	{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = true, effect_id = "dxlz_chuanci_3", is_current_target = true},       ---播放特效-
	        	},
	        	{
	        		CLASS = "action.QSBDeselectTarget",
	        	}
        	}, 	
		},
		-- {
		-- 	CLASS = "composite.QSBSequence",
	 --    	ARGS = {
		-- 		{
	 --                CLASS = "action.QSBDelayTime",                         ---延时-
	 --                OPTIONS = {delay_frame = 12},
	 --            },
	 --            {
	 --            	 CLASS = "action.QSBPlayEffect",
	 --            	 OPTIONS = {is_hit_effect = true, effect_id = "dxlz_chuanci_3"},       ---播放特效-
	 --        	},
  --       	},
		-- },
	},
} 

return xiaoqiang_chuanci