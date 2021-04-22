
local common_victory = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {

    	{ 
    	 	CLASS = "composite.QUIDBSequence",
    	 	ARGS = {
    	 				{
    	 					CLASS = "action.QUIDBDelaytime",
    	 					OPTIONS = {delay_frame = 10}
    	 				},

    	 				{
    	 					CLASS = "action.QUIDBPlayLoopeffect",
    	 					OPTIONS = {is_hit_effect = false, effect_id = "qiandaoliu_fumo2_1"},
    	 				},
    	 				-- {
    	 				-- 	CLASS = "action.QUIDBDelaytime",
    	 				-- 	OPTIONS = {delay_frame = 10}
    	 				-- },
    	 				-- {
    	 				-- 	CLASS = "action.QUIDBStopLoopeffect",
    	 				-- 	OPTIONS = {is_hit_effect = false, effect_id = "qiandaoliu_fumo2_1"},
    	 				-- },

    	 	},

    	},

        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "victory"},

        },

    },
}

return common_victory