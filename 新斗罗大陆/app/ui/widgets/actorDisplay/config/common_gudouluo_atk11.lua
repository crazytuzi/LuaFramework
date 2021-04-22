
local common_gudouluo_atk11 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
    	{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "attack11_1"},
				},
				{
					CLASS = "composite.QUIDBParallel",
				    ARGS = {
						{
							CLASS = "action.QUIDBPlayAnimation",
							OPTIONS = {animation = "attack11_2"},
						},
						{
							CLASS = "composite.QUIDBSequence",
							ARGS = {
								{
				                    CLASS = "action.QUIDBDelayTime",
				                    OPTIONS = {delay_frame = 10 / 24 * 30},
				                },
								{
									CLASS = "action.QUIDBPlayEffect",
									OPTIONS = {effect_id = "gudouluo_attack11_3"},
								},
							},
						},
					},
				},
			},
		},
    },
}

return common_gudouluo_atk11