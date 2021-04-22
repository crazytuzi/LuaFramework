
local pf_chengniantangsan02_zidong1 = {
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
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 34},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengniantangsan02_attack13_1", is_hit_effect = false},
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
                    OPTIONS = {delay_frame = 40},
                },
				{
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_chengniantangsan02_zidong1_buff"},
                },
				--技能生效及30帧的不可取消后摇
				{
					CLASS = "composite.QSBParallel",
					OPTIONS = {forward_mode = true,},
					ARGS = {
						{
							CLASS = "action.QSBHitTimer",
							OPTIONS = {duration_time = 6.3;interval_time = 0.5},
						},
						{
							CLASS = "composite.QSBSequence",
							OPTIONS = {forward_mode = true,},
							ARGS = {
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 40},
								},
								{
									CLASS = "action.QSBAttackFinish",
								},
							},
						},
					},
				},
            },
        },
    },
}
return pf_chengniantangsan02_zidong1