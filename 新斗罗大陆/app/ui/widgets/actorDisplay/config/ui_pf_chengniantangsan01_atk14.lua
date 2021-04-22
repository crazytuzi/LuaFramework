
local ui_chengniantangsan_atk14 = {
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
			CLASS = "action.QUIDBPlayAnimation",
			OPTIONS = {animation = "attack14"},
		},
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
				{
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 13/30},
                },
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_chengniantangsan01attack14_1_1_ui"},
				},
            },
        },
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
				{
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 27/30},
                },
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_chengniantangsan01attack14_1_ui"},
				},
            },
        },
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 60 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_chengniantangsan_atk14