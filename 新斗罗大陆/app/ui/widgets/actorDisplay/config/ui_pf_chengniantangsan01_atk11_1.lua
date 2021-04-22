
local ui_chengniantangsan_atk11_1 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack11_1"},
        },
        -- {
        --     CLASS = "action.QUIDBPlayLoopEffect",
        --     OPTIONS = {effect_id = "mahongjun_attack11_3_1", duration = 3.12, no_sound_loop = true},
        -- },
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
				{
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 25/30},
                },
				{
					CLASS = "composite.QUIDBParallel",
					ARGS = {
						{
							CLASS = "action.QUIDBPlayEffect",
							OPTIONS = {is_hit_effect = false, effect_id = "pf_chengniantangsan01_attack11_1_ui"},
						},
						{
							CLASS = "action.QUIDBPlayEffect",
							OPTIONS = {is_hit_effect = false, effect_id = "pf_chengniantangsan01_attack11_1_1_ui"},
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
                    OPTIONS = {delay_time = 65/30},
                },
				{
					CLASS = "composite.QUIDBParallel",
					ARGS = {
						{
							CLASS = "action.QUIDBPlayEffect",
							OPTIONS = {is_hit_effect = false, effect_id = "pf_chengniantangsan01_attack11_1_2_ui"},
						},
						{
							CLASS = "action.QUIDBPlayEffect",
							OPTIONS = {is_hit_effect = false, effect_id = "pf_chengniantangsan01_attack11_1_3_ui"},
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
                    OPTIONS = {delay_time = 3.12},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_chengniantangsan_atk11_1