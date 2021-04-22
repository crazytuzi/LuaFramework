
local ui_pf_ssmahongjun01_atk11 = {
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
					OPTIONS = {effect_id = "pf_ssmahongjun_attack11_2_ui"},
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
					OPTIONS = {effect_id = "pf_ssmahongjun_attack11_3_ui"},
				},
			},
		},
    },
}



return ui_pf_ssmahongjun01_atk11