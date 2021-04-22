
local common_qiandaoliu_atk11 = {
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
				                    OPTIONS = {delay_frame = 40},
				                },
								{
				                    CLASS = "action.QUIDBPlayEffect",
				                    OPTIONS = {effect_id = "qiandaoliu_wuhun"},
				                },
							},
						},
					},
				},
			},
		},
    },
}

return common_qiandaoliu_atk11