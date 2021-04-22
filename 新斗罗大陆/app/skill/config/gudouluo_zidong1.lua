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
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 28},
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
							OPTIONS = {start_pos = {x = 50,y = 300}},
						},
						{
							CLASS = "action.QSBPlunderRage",
							OPTIONS = {plunder_rage_percent = 0.1, plunder_rage_max = 0.3},
						},
						{
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "gudouluo_attack13_3_1", is_hit_effect = true},
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
					OPTIONS = {delay_frame = 28},
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
							OPTIONS = {start_pos = {x = 50,y = 100}},
						},
						{
							CLASS = "action.QSBPlunderRage",
							OPTIONS = {plunder_rage_percent = 0.1, plunder_rage_max = 0.3},
						},
						{
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "gudouluo_attack13_3_2", is_hit_effect = true},
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
					OPTIONS = {delay_frame = 28},
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
							OPTIONS = {start_pos = {x = 50,y = -100}},
						},
						{
							CLASS = "action.QSBPlunderRage",
							OPTIONS = {plunder_rage_percent = 0.1, plunder_rage_max = 0.3},
						},
						{
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "gudouluo_attack13_3_3", is_hit_effect = true},
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
					OPTIONS = {delay_frame = 28},
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
							OPTIONS = {start_pos = {x = 50,y = -300}},
						},
						{
							CLASS = "action.QSBPlunderRage",
							OPTIONS = {plunder_rage_percent = 0.1, plunder_rage_max = 0.3},
						},
						{
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "gudouluo_attack13_3_4", is_hit_effect = true},
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
		            CLASS = "composite.QSBParallel",
		            ARGS = {
		                {
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "gudouluo_attack13_1_1", is_hit_effect = false},
		                },
		                {
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "gudouluo_attack13_1_2", is_hit_effect = false},
		                },
		                {
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "gudouluo_attack13_1_3", is_hit_effect = false},
		                },
		                {
		                    CLASS = "action.QSBPlayEffect",
		                    OPTIONS = {effect_id = "gudouluo_attack13_1_4", is_hit_effect = false},
		                },
		                {
		                    CLASS = "action.QSBPlayAnimation",
		                },
		            },
		        },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return gudouluo_zidong1
