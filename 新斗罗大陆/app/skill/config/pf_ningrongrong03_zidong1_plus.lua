local pf_ningrongrong03_zidong1_plus = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
                    OPTIONS = {delay_frame = 32},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ningrongrong03_attack13_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ningrongrong03_attack13_1_1", is_hit_effect = false},
                },
            },
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 32 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 37 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}, target_teammate_lowest_hp_percent = true, is_hit_effect = true},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 42 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}, target_teammate_lowest_hp_percent = true, is_hit_effect = true},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 47 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}, target_teammate_lowest_hp_percent = true, is_hit_effect = true},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 52 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}, target_teammate_lowest_hp_percent = true, is_hit_effect = true},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 57 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 140,y = 200}, target_teammate_lowest_hp_percent = true, is_hit_effect = true},
				},
			},
		},
    },
}

return pf_ningrongrong03_zidong1_plus
