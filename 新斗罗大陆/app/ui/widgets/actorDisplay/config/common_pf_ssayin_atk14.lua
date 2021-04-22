local common_ssmahongjun_atk11 = 
{
	CLASS = "composite.QUIDBParallel",
    ARGS = 
    {
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = 
			{
				{
		            CLASS = "action.QUIDBDelayTime",
		            OPTIONS = {delay_frame = 1 },
		        },
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "attack14"},
				},
			},
		},
		{
            CLASS = "composite.QUIDBParallel",
            ARGS = 
            {
            	{
			CLASS = "composite.QUIDBSequence",
			ARGS = 
			{
            	{
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
            	{
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "ui_pf_ssayin_attack14_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 28},
                },
                {
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {effect_id = "ui_pf_ssayin_attack14_2", is_hit_effect = false},
				},
			},
		},
             
              
            },
        },
    },
}

return common_ssmahongjun_atk11