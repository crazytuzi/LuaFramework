
local phyattack_yeshouxingtai = {			--野兽形态
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
	        CLASS = "composite.QSBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QSBPlayAnimation",
	                OPTIONS = {animation = "attack11"},				---动作
	            },
                {
                    CLASS = "action.QSBAttackFinish"				--技能结束，才可以执行下一个技能。
                },
	        },
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		-- {
	      --           CLASS = "action.QSBDelayTime",
	      --           OPTIONS = {delay_time = 0},
	      --       },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "huomao_dazhao_1"},		--特效1
	            },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		-- {
	      --           CLASS = "action.QSBDelayTime",
	      --           OPTIONS = {delay_time = 0.6},
	      --       },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "fdr_pugong1_2"},		--特效2
	            },
	    	},
		},

	},
} 

return phyattack_yeshouxingtai