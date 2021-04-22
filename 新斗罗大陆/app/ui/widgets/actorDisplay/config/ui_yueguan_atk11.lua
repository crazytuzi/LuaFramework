local ui_pf_ssdaimubai01_victory = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS = 
    {
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 14 / 30 },
                },
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "ui_yueguancz_attack11_2"},
				},
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 22 / 30 },
                },
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "ui_yueguancz_attack11_1"},
				},
            },
        },
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack11"},
        },
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 116 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_pf_ssdaimubai01_victory