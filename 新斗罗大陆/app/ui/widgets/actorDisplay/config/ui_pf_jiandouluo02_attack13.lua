
local ui_chenxin_attack13 = {
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
                    OPTIONS = {delay_time = 21 / 30},
                },
                {
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_jiandouluo02_attack13_1_ui"},
				},
            },
        },
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 83 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_chenxin_attack13