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
					CLASS = "composite.QUIDBParallel",
					ARGS = 
					{
						{
							CLASS = "composite.QUIDBSequence",
							ARGS = 
							{
								{
									CLASS = "action.QUIDBPlayAnimation",
									OPTIONS = {animation = "attack11"},
								},
							},
						},
						{
				            CLASS = "composite.QUIDBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QUIDBDelayTime",
				                    OPTIONS = {delay_frame = 10},
				                },
				                {
				                 CLASS = "action.QUIDBPlayEffect",
				                 OPTIONS = {effect_id = "pf01_ssqianshitangsan_attack11_1_1_ui"},
				                },
				            },
				        },
				        {
				            CLASS = "composite.QUIDBSequence",
				            ARGS = {
				                {
				                    CLASS = "action.QUIDBDelayTime",
				                    OPTIONS = {delay_frame = 10},
				                },
				                {
				                 CLASS = "action.QUIDBPlayEffect",
				                 OPTIONS = {effect_id = "pf01_ssqianshitangsan_attack11_1_2_ui"},
				                },
				            },
				        },
					},
				},
			},
		},
    },
}

return common_ssmahongjun_atk11