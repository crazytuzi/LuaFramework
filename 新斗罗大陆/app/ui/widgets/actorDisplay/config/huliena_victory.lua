
local huliena_victory = {
    CLASS = "composite.QUIDBParallel",
    ARGS = 
    {
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 10 },
                },
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "ui_huliena_shengli"},
				},
            },
        },
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "victory"},
        },
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 90},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}
return huliena_victory