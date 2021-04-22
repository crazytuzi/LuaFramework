
local tangsan_htc_zidong1 = {
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
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false},
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
                    OPTIONS = {buff_id = "tangsan_htc_zidong1_buff"},
                },
				{
					CLASS = "action.QSBHitTimer",
					OPTIONS = {duration_time = 6.3;interval_time = 0.5},
				},
            },
        },
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {forward_mode = true,},
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 90},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
    },
}
return tangsan_htc_zidong1