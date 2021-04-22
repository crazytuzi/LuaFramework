
local common_chenxin_atk11 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 9},
                },			
				{
					CLASS = "action.QUIDBPlaySound",
					OPTIONS = {sound_id = "chenxin_qszs_sf"},
				},
			},
		},
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
                    OPTIONS = {delay_frame = 40},
                },			
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {effect_id = "zhanshi_jiandouluo_attack11_3"},
				},
			},
		},
    },
}



return common_chenxin_atk11