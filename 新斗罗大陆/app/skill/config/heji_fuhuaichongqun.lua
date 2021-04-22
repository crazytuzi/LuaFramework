
local heji_fuhuaichongqun = {			--腐坏虫群
	CLASS = "composite.QSBParallel",
	ARGS = {
        {
			CLASS = "composite.QSBSequence",
	    	ARGS = {
				{
		            CLASS = "action.QSBPlayAnimation",
		            OPTIONS = {animation = "attack11", reload_on_cancel = true},
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
	                CLASS = "action.QSBDelayTime",        ---延时-
	                OPTIONS = {delay_frame = 40},
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
	                CLASS = "action.QSBDelayTime",        ---延时-
	                OPTIONS = {delay_frame = 15},
	            },
	            {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "anblk_dazhao_1"},
                }, 
        	},
		},
                                 {
                                    CLASS = "composite.QSBSequence",
                                    ARGS =
                                    {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_target = false, buff_id = "fuhuaichongqun_heji"},
                                        },
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 17},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                        },
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 38},
                                        },
                                        {
                                            CLASS = "action.QSBAttackFinish"
                                        },
                                    },
                                },       
		{   --黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.8, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.38},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        },
        {                    --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.8, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.38},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        },
	},
} 

return heji_fuhuaichongqun