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
									OPTIONS = {animation = "attack12"},
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
				                 OPTIONS = {effect_id = "pf01_ssqianshitangsan_attack12_1_ui"},
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