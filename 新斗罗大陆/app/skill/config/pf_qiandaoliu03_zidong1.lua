
local pf_qiandaoliu_zidong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
			CLASS = "action.QSBPlaySound",
		},
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 70},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_qiandaoliu03_attack13_1", is_hit_effect = false,haste = true},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_qiandaoliu03_attack13_3",is_hit_effect = false},
				},
				-- {
					-- CLASS = "action.QSBPlayEffect",
					-- OPTIONS = {effect_id = "pf_qiandaoliu03_attack13_2_1",is_hit_effect = false},
				-- },
				-- {
					-- CLASS = "action.QSBPlayEffect",
					-- OPTIONS = {effect_id = "pf_qiandaoliu03_attack13_2_2",is_hit_effect = false},
				-- },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_qiandaoliu03_attack13_2_3",is_hit_effect = false},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_qiandaoliu03_attack13_2_4",is_hit_effect = false},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_qiandaoliu03_attack13_2_5",is_hit_effect = false},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_qiandaoliu03_attack13_2_6",is_hit_effect = false},
				},      
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },              
                {
                    CLASS = "action.QSBHitTarget",
                },               
            },
        },
    },
}

return pf_qiandaoliu_zidong1