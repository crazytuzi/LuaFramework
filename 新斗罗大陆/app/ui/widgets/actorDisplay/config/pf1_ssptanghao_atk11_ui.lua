-- 英雄特殊普攻动作
local common_atk02 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
	        {
	            CLASS = "action.QUIDBPlayAnimation",
	            OPTIONS = {animation = "attack11"},
	        },
	        {
	        	CLASS = "composite.QUIDBSequence",
	        	ARGS = {
			                {
			                    CLASS = "action.QUIDBDelayTime",
			                    OPTIONS = {delay_frame = 22},
			                },
			                {
			                    CLASS = "action.QUIDBPlayEffect",
			                    OPTIONS = {effect_id = "pf_ssptanghao01_attack11_1_1_ui", is_hit_effect = false},
			                },  
	        	},
	        },
	        {
	        	CLASS = "composite.QUIDBSequence",
	        	ARGS = {
			                {
			                    CLASS = "action.QUIDBDelayTime",
			                    OPTIONS = {delay_frame = 34},
			                },
			                {
			                    CLASS = "action.QUIDBPlayEffect",
			                    OPTIONS = {effect_id = "pf_ssptanghao01_attack11_1_2_ui", is_hit_effect = false},
			                },
        			        -- {
			                --     CLASS = "action.QUIDBPlayEffect",
			                --     OPTIONS = {effect_id = "pf_ssptanghao01_attack11_1_2_1_ui", is_hit_effect = false},
			                -- },    
	        	},
	        },

	        {
	        	CLASS = "composite.QUIDBSequence",
	        	ARGS = {
			                {
			                    CLASS = "action.QUIDBDelayTime",
			                    OPTIONS = {delay_frame = 51},
			                },
			                {
			                    CLASS = "action.QUIDBPlayEffect",
			                    OPTIONS = {effect_id = "pf_ssptanghao01_attack11_1_3_ui", is_hit_effect = false},
			                },
			                -- {
			                --     CLASS = "action.QUIDBPlayEffect",
			                --     OPTIONS = {effect_id = "pf_ssptanghao01_attack11_1_3_1_ui", is_hit_effect = false},
			                -- },    
	        	},
	        },

    },
}

return common_atk02