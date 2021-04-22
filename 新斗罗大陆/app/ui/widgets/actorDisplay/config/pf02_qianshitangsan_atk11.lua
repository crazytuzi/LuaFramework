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
				                 CLASS = "action.QUIDBPlayEffect",
				                 OPTIONS = {effect_id = "pf02_ssqianshitangsan_attack11_1_1_ui"},
				                },
				            },
				        },
				        {
				            CLASS = "composite.QUIDBSequence",
				            ARGS = {

				                {
				                 CLASS = "action.QUIDBPlayEffect",
				                 OPTIONS = {effect_id = "pf02_ssqianshitangsan_attack11_1_2_ui"},
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