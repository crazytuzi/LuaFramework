
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
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_ssaosika02_attack11_1_ui"},
				}, 
				-- {
				-- 	CLASS = "action.QUIDBPlayEffect",
				-- 	OPTIONS = {is_hit_effect = false, effect_id = "pf_ssaosika02_attack11_5_ui"},
				-- },   
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_ssaosika02_attack11_4_ui"},
				},  
			},
		},
    },
}



return common_ningrongrong_atk11