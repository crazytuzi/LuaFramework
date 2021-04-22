--BOSS 月关菊花乱射
--NPC ID: 3313
--技能ID: 50406
--射射射
--创建人：庞圣峰
--创建时间:2018-4-6

local zudui_boss_yueguan_zidong2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			 CLASS = "composite.QSBSequence",
			 ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.5},
				},
				{
					CLASS = "action.QSBPlaySound"
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 10},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "xunlian_yueguan_shanxingkuang_buff", is_target = false},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 20},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "xunlian_yueguan_shanxingkuang_buff", is_target = false},
				},
			},
		},
		{
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                	CLASS = "action.QSBDelayTime",
                	OPTIONS = {delay_time = 12/30},
                },
				{
		            CLASS = "action.QSBPlayAnimation",
		            OPTIONS = {animation = "attack13"},
		     	},
		    },
		},
     	{
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                	CLASS = "action.QSBDelayTime",
                	OPTIONS = {delay_time = 35/30},
                },
		     	{
		            CLASS = "action.QSBPlayEffect",
		            OPTIONS = {effect_id = "yueguancz_attack13_1"},
		        },
		    },
		},
		{
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                	CLASS = "action.QSBDelayTime",
                	OPTIONS = {delay_time = 45/30},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
            },
        },
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return zudui_boss_yueguan_zidong2

