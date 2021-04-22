
local common_qianrenxue_atk11 = {
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
					OPTIONS = {animation = "attack11_2_1"},
				},
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "attack14_3"},
				},
			},
		},
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = {
		        {
		            CLASS = "action.QUIDBDelayTime",
		            OPTIONS = {delay_time = 3.3},
		        },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "qianrenxue_attack11_4_for_ui"},
	            },
	    	},
		},
    },
}



return common_qianrenxue_atk11