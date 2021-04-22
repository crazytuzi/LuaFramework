
local ui_chengniantangsan_atk14 = {
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
			CLASS = "action.QUIDBPlayAnimation",
			OPTIONS = {animation = "attack14"},
		},
		{
			CLASS = "action.QUIDBPlayEffect",
			OPTIONS = {is_hit_effect = false, effect_id = "tangsan_htc_attack14_1_ui"},
		},
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 53 / 30},
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