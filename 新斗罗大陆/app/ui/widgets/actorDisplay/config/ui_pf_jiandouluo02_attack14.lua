
local ui_chenxin_attack13 = {
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
			CLASS = "action.QUIDBPlayAnimation",
			OPTIONS = {animation = "attack14"},
		},
		{
			CLASS = "action.QUIDBPlayEffect",
			OPTIONS = {is_hit_effect = false, effect_id = "pf_jiandouluo02_attack14_1_ui"},
		},
		{
			CLASS = "action.QUIDBPlayEffect",
			OPTIONS = {is_hit_effect = false, effect_id = "pf_jiandouluo02_attack14_1_2_ui"},
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