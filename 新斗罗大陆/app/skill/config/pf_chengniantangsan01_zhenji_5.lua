
local pf_chengniantangsan02_zhenji_5 =   
{
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "tangsan_zhenji_1_die", is_target = false, probability=0.5},
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 13/30},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengniantangsan01_attack14_1_1", is_hit_effect = false},
                },               
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 27/30},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengniantangsan01_attack14_1", is_hit_effect = false},
                },               
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 32},
                },
				{
					CLASS = "composite.QSBParallel",
					ARGS = {  
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "pf_chengniantangsan01_attack14_3", is_hit_effect = false},
						}, 
						{
							CLASS = "action.QSBHitTarget",
						},
					},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
				{
					CLASS = "action.QSBAttackFinish"
				},
            },
        },
    },
}

return pf_chengniantangsan02_zhenji_5