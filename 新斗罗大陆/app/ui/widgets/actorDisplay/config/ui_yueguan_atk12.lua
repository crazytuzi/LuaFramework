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
                    OPTIONS = {delay_time = 45 / 30 },
                },
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "ui_yueguancz_atk12"},
				},
            },
        },
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack12"},
        },
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 95 / 30},
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