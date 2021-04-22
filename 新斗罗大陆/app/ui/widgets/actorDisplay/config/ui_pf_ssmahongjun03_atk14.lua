
local common_ssmahongjun_atk14 = {
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
					OPTIONS = {effect_id = "pf_ssmahongjun03_attack14_1_ui"},
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
					OPTIONS = {effect_id = "pf_ssmahongjun03_attack14_2_ui"},
				},
			},
		},
    },
}



return common_ssmahongjun_atk14