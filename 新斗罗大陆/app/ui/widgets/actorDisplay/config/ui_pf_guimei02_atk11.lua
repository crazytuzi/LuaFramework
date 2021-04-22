
local ui_guimei_atk11 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 2/30},
                },
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "attack11"},
				},
            },
        },
        -- {
        --     CLASS = "action.QUIDBPlayLoopEffect",
        --     OPTIONS = {effect_id = "mahongjun_attack11_3_1", duration = 3.12, no_sound_loop = true},
        -- },
		{
			CLASS = "action.QUIDBPlayEffect",
			OPTIONS = {is_hit_effect = false, effect_id = "pf_guimei02_attack11_1_ui"},
		},
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 133/30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_guimei_atk11