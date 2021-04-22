
local common_bosaixi_atk11 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
    	{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
				{
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 30 / 24 * 30},
                },
				{
					CLASS = "composite.QUIDBParallel",
					ARGS = {
						{
							CLASS = "composite.QUIDBSequence",
							ARGS = {
								{
									CLASS = "action.QUIDBPlayAnimation",
									OPTIONS = {animation = "attack11"},
								},
							},
						},
						{
							CLASS = "composite.QUIDBSequence",
							ARGS = {
								{
				                    CLASS = "action.QUIDBDelayTime",
				                    OPTIONS = {delay_frame = 90},
				                },
								{
				                    CLASS = "action.QUIDBPlayEffect",
				                    OPTIONS = {effect_id = "bosaixiyx_attack11_3_1"},
				                },
							},
						},
					},
				},
			},
		},
    },
}

return common_bosaixi_atk11