
local common_victory = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {

    		-- {
    		-- 	CLASS = "action.QUIDBPlayEffect",
    		-- 	OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao01_victory_1_2"},
    		-- },

	        {
	            CLASS = "action.QUIDBPlayAnimation",
	            OPTIONS = {animation = "victory"},
	        },

	        -- {
	        -- 	CLASS = "composite.QUIDBSequence",
	        -- 	ARGS = {
		       --              {
         --                        CLASS = "action.QUIDBDelayTime",
         --                        OPTIONS = {delay_frame = 75},
         --                    },  
         --                    {
         --                         CLASS = "action.QUIDBPlayEffect",
         --                         OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao02_victory_1_ui"},
         --                    },
         --                    -- {
         --                    --     CLASS = "action.QUIDBPlayEffect",
         --                    --      OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao01_victory_1_1_ui"},
         --                    -- },
	        -- 	},
	        -- },
    },
}

return common_victory