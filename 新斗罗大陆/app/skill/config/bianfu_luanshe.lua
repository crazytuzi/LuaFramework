--BOSS 月关菊花乱射
--NPC ID: 3313
--技能ID: 50406
--射射射
--创建人：樊科远
--创建时间:2018-4-6

local bianfu_luanshe = {
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
					OPTIONS = {delay_time = 1.3},
				},
				{
                 CLASS = "action.QSBPlayAnimation",
                  ARGS = {
                  {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                            },
                  },
                },
				{
					CLASS = "action.QSBPlaySound"
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.2},
				},
				{
					CLASS = "action.QSBPlayLoopEffect",
					OPTIONS = {effect_id = "shanxing_hongkuang_28", is_hit_effect = false},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 1.4},
				},
				{
                    CLASS = "action.QSBHitTarget",
                },
				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true},
                },
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.5},
				},
				{
					CLASS = "action.QSBStopLoopEffect",
					 OPTIONS = {effect_id = "shanxing_hongkuang_28"},
				},
				{
                    CLASS = "action.QSBAttackFinish"
                },
			},
		},
    },
}

return bianfu_luanshe

