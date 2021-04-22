
local tangsan_htc_zidong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
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
		            OPTIONS = {is_hit_effect = false, effect_id = "sspqianrenxue_attack13_1"},
		        }, 	
                {
                    CLASS = "action.QSBHitTimer",
                    OPTIONS = {duration_time = 6;interval_time = 1.5},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				--技能抬手40帧
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 41},
                },
				{
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "sspqianrenxue_zidong1_buff"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "sspqianrenxue_zidong1_buff2"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "sspqianrenxue_zidong1_gedang"},
                },
            },
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
            {
				{
                    CLASS = "action.QSBPlayAnimation",
                },
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
    },
}
return tangsan_htc_zidong1