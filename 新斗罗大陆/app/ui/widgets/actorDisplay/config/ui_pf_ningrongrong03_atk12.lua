
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
					OPTIONS = {effect_id = "pf_ningrongrong03_attack11_1_ui"},
				},
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 45},
                },			
				{
					CLASS = "action.QUIDBPlayLoopEffect",
					OPTIONS = {effect_id = "pf_ningrongrong03_attack11_1_1_ui"},
				},
			},
		},
    },
}



return common_ningrongrong_atk11