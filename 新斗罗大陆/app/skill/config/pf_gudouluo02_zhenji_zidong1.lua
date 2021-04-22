local gudouluo_zidong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
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
					OPTIONS = {delay_frame = 36},
				},
				{
				    CLASS = "action.QSBArgsSelectTarget",
				    OPTIONS = {lowest_hp = true},
				},
				{
					CLASS = "composite.QSBParallel",
					OPTIONS = {pass_key = {"selectTarget"}},
					ARGS = 
					{
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {start_pos = {x = 150,y = 150}},
						},
						{
							CLASS = "action.QSBPlunderRage",
							OPTIONS = {plunder_rage_percent = 0.1, plunder_rage_max = 0.4},
						},
						{
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "pf_gudouluo02_attack13_2", is_hit_effect = true},
		                },
					},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 36},
				},
				{
				    CLASS = "action.QSBArgsSelectTarget",
				    OPTIONS = {lowest_hp = true},
				},
				{
					CLASS = "composite.QSBParallel",
					OPTIONS = {pass_key = {"selectTarget"}},
					ARGS = 
					{
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {start_pos = {x = 150,y = 150}},
						},
						{
							CLASS = "action.QSBPlunderRage",
							OPTIONS = {plunder_rage_percent = 0.1, plunder_rage_max = 0.4},
						},
						{
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "pf_gudouluo02_attack13_2", is_hit_effect = true},
		                },
					},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 36},
				},
				{
				    CLASS = "action.QSBArgsSelectTarget",
				    OPTIONS = {lowest_hp = true},
				},
				{
					CLASS = "composite.QSBParallel",
					OPTIONS = {pass_key = {"selectTarget"}},
					ARGS = 
					{
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {start_pos = {x = 150,y = 150}},
						},
						{
							CLASS = "action.QSBPlunderRage",
							OPTIONS = {plunder_rage_percent = 0.1, plunder_rage_max = 0.4},
						},
						{
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "pf_gudouluo02_attack13_2", is_hit_effect = true},
		                },
					},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 36},
				},
				{
				    CLASS = "action.QSBArgsSelectTarget",
				    OPTIONS = {lowest_hp = true},
				},
				{
					CLASS = "composite.QSBParallel",
					OPTIONS = {pass_key = {"selectTarget"}},
					ARGS = 
					{
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {start_pos = {x = 150,y = 150}},
						},
						{
							CLASS = "action.QSBPlunderRage",
							OPTIONS = {plunder_rage_percent = 0.1, plunder_rage_max = 0.4},
						},
						{
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "pf_gudouluo02_attack13_2", is_hit_effect = true},
		                },
					},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 36},
				},
				{
				    CLASS = "action.QSBArgsSelectTarget",
				    OPTIONS = {lowest_hp = true},
				},
				{
					CLASS = "composite.QSBParallel",
					OPTIONS = {pass_key = {"selectTarget"}},
					ARGS = 
					{
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {start_pos = {x = 150,y = 150}},
						},
						{
							CLASS = "action.QSBPlunderRage",
							OPTIONS = {plunder_rage_percent = 0.1,  plunder_rage_max = 0.4},
						},
						{
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "pf_gudouluo02_attack13_2", is_hit_effect = true},
		                },
					},
				},
			},
		},
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "pf_gudouluo02_attack13_1", is_hit_effect = false},
        },
    },
}

return gudouluo_zidong1
