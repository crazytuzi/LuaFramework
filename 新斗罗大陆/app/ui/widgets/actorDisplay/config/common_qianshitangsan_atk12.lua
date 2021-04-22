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
				                    OPTIONS = {delay_frame = 0},
				                },
				                {
				                 CLASS = "action.QUIDBPlayEffect",
				                 OPTIONS = {effect_id = "ui_ssqianshitangsan_attack12_1"},
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