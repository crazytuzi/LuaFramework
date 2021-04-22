-- 英雄特殊普攻动作
local common_atk02 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
	        {
	            CLASS = "action.QUIDBPlayAnimation",
	            OPTIONS = {animation = "attack13"},
	        },
	        {
	        	CLASS = "composite.QUIDBSequence",
	        	ARGS = {
			                {
			                    CLASS = "action.QUIDBDelayTime",
			                    OPTIONS = {delay_frame = 15},
			                },

			              	{
			              		CLASS = "composite.QUIDBParallel",
			              		ARGS = {
					                {
					                    CLASS = "action.QUIDBPlayEffect",
					                    OPTIONS = {effect_id = "pf_ssptanghao02_attack13_1_ui", is_hit_effect = false},
					                }, 
					            	{
					                    CLASS = "action.QUIDBPlayEffect",
					                    OPTIONS = {effect_id = "pf_ssptanghao02_attack13_1_1_ui", is_hit_effect = false},
					                }, 
					            },
			                },  
	        	},
	        },
	        {
	        	CLASS = "composite.QUIDBSequence",
	        	ARGS = {
			                {
			                    CLASS = "action.QUIDBDelayTime",
			                    OPTIONS = {delay_frame = 25},
			                },
			                {
			                    CLASS = "action.QUIDBPlayEffect",
			                    OPTIONS = {effect_id = "pf_ssptanghao02_attack13_1_2_ui", is_hit_effect = false},
			                },  
    			            -- {
			                --     CLASS = "action.QUIDBPlayEffect",
			                --     OPTIONS = {effect_id = "pf_ssptanghao02_attack13_1_3_ui", is_hit_effect = false},
			                -- }, 
	        	},
	        },

    },
}

return common_atk02