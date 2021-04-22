
local common_ssmahongjun_atk14 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
    	{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
				{
					CLASS = "composite.QUIDBParallel",
					ARGS = {
						{
							CLASS = "composite.QUIDBSequence",
							ARGS = {
								{
									CLASS = "action.QUIDBPlayAnimation",
									OPTIONS = {animation = "attack14"},
								},
							},
						},
						{
				            CLASS = "composite.QUIDBSequence",
				            ARGS = {
				                {
				                    CLASS = "action.QUIDBDelayTime",
				                    OPTIONS = {delay_frame = 0},
				                },
				                {
									CLASS = "action.QUIDBPlayEffect",
									OPTIONS = {effect_id = "ssmahongjun_attack14_1_1"},
								},
				            },
				        },
				        {
				            CLASS = "composite.QUIDBSequence",
				            ARGS = {
				                {
				                    CLASS = "action.QUIDBDelayTime",
				                    OPTIONS = {delay_frame = 5},
				                },
				                {
				                    CLASS = "action.QUIDBPlayEffect",
				                    OPTIONS = {effect_id = "ssmahongjun_attack14_2_1"},
				                },
				            },
				        },
					},
				},
			},
		},
    },
}



return common_ssmahongjun_atk14