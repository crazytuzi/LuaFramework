
local common_ningrongrong_atk11 = {
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
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "stand"},
				},
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "stand"},
				},
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "stand"},
				},
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 52},
                },			
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {effect_id = "ningrongrong_attack11_3_zhanshi"},
				},
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 97},
                },			
				{
					CLASS = "action.QUIDBPlayLoopEffect",
					OPTIONS = {effect_id = "ningrongrong_attack11_4_zhanshi", duration = 3},
				},
			},
		},
    },
}



return common_ningrongrong_atk11