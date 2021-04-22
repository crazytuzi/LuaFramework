local ui_ultra_bampiric_embrace = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
                {
                	CLASS = "composite.QUIDBSequence",
                	ARGS = 
                	{
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
                            OPTIONS = {delay_frame = 7},
                        },
                        {
                            CLASS = "action.QUIDBPlayEffect",
                    		OPTIONS = {is_hit_effect = false, effect_id = "bampiric_embrace_1_1"},
                        },
                	},
            	},
            	{
                	CLASS = "composite.QUIDBSequence",
                	ARGS = {
                        {
                            CLASS = "action.QUIDBDelayTime",
                            OPTIONS = {delay_frame = 35},
                        },
                        {
                            CLASS = "action.QUIDBPlayEffect",
                    		OPTIONS = {is_hit_effect = false, effect_id = "bampiric_embrace_1_3"},
                        },
                	},
            	},
                {
                    CLASS = "composite.QUIDBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QUIDBDelayTime",
                            OPTIONS = {delay_frame = 41},
                        },
                        {
                            CLASS = "action.QUIDBPlayLoopEffect",
                            OPTIONS = {effect_id = "bampiric_embrace_4", duration = 2},
                        },
                    },
                },

            	{
                	CLASS = "composite.QUIDBSequence",
                	ARGS = {
                        {
                            CLASS = "action.QUIDBDelayTime",
                            OPTIONS = {delay_frame = 38},
                        },
                        {
                            CLASS = "action.QUIDBPlayEffect",
                    		OPTIONS = {is_hit_effect = false, effect_id = "bampiric_embrace_1_2"},
                        },
                	},
            	},
        	},
    	}
return ui_ultra_bampiric_embrace