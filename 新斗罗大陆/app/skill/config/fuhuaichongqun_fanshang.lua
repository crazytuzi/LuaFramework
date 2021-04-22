
local fuhuaichongqun_fanshang = {			--腐坏虫群反伤
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
            CLASS = "action.QSBUFO",
            OPTIONS = {effect_id = "anblk_dazhao_2_1", speed = 1000, hit_effect_id = "anblk_dazhao_3"}, -- effect_id填小苍蝇特效，speed填小苍蝇的飞行速度
        },
		{
			CLASS = "composite.QSBSequence",
	    	ARGS = {
				{
	                CLASS = "action.QSBDelayTime",        ---延时-
	                OPTIONS = {delay_frame = 5},
	            },
	            {
	            	CLASS = "action.QSBHitTarget",        ---伤害-
	        	},
	        	{
                    CLASS = "action.QSBAttackFinish"				--技能结束，才可以执行下一个技能。
                },
        	},
		},
	},
} 

return fuhuaichongqun_fanshang