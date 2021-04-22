
local ui_chengniantangsan_atk13 = {
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
			CLASS = "action.QUIDBPlayAnimation",
			OPTIONS = {animation = "attack13"},
		},
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
				{
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 43/30},
                },
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_chengniantangsan01_attack13_1_ui"},
				},
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
				{
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 44/30},
                },
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_chengniantangsan01_attack13_1_1_ui"},
				},
            },
        },
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 91 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_chengniantangsan_atk13