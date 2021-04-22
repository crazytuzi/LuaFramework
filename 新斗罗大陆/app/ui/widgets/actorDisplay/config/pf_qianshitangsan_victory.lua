local common_victory = 
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
				            OPTIONS = {animation = "victory"},
				        },
					},
				},
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
		                 OPTIONS = {effect_id = "ui_pf_ssqianshitangsan_victory"},
		                },
		            },
		        },
			},
		},
    },
}

return common_victory