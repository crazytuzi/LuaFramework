
local common_zhuzhuqing_atk11 = {
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
								{
	                                CLASS = "action.QUIDBSummonGhosts",
	                                OPTIONS = {ghostId = 1040, scale = 0.5,number = 1, action = "attack11_4", pos = {x = 200, y = 55}, direction="RIGHT"},
	                            },
	                            {
	                                CLASS = "action.QUIDBSummonGhosts",
	                                OPTIONS = {ghostId = 1040, scale = 0.5,number = 1, action = "attack11_5", pos = {x = 250, y = 55}, direction="LEFT"},
	                            },
	                            {
	                                CLASS = "action.QUIDBSummonGhosts",
	                                OPTIONS = {ghostId = 1040, scale = 0.5,number = 1, action = "attack11_6", pos = {x = 200, y = 55}, direction="RIGHT"},
	                            },
	                            {
	                                CLASS = "action.QUIDBSummonGhosts",
	                                OPTIONS = {ghostId = 1041, scale = 0.5,number = 1, action = "attack11_7", pos = {x = 250, y = 55}, direction="LEFT"},
	                            },
							},
						},
					},
				}, 
			},
		},
    },
}

return common_zhuzhuqing_atk11