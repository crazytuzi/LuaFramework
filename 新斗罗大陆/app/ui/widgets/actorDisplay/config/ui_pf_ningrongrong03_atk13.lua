
local common_ningrongrong_atk11 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "attack13"},
				},
				
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {		
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {effect_id = "pf_ningrongrong03_attack13_1_ui"},
				},
			},
		},
    },
}



return common_ningrongrong_atk11