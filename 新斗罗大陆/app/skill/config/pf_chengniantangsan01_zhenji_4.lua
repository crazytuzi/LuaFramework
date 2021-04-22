
local tangsan_zhenji_4 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
            CLASS = "action.QSBPlaySound",
            OPTIONS = {revertable = true,},
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 43/30},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_chengniantangsan01_attack13_1"},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 44/30},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_chengniantangsan01_attack13_1_1"},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
				--技能抬手40帧
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 51},
                },
				{
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_chengniantangsan01_zidong1_max"},
                },
				{
					CLASS = "action.QSBHitTimer",
					OPTIONS = {duration_time = 8.3;interval_time = 0.5},
				},
            },
        },
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {forward_mode = true,},
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 96},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
    },
}
return tangsan_zhenji_4