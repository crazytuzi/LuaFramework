
local ui_lianzhu_fireball = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
       	{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "composite.QUIDBParallel",
                    ARGS = {
                     	{
                            CLASS = "action.QUIDBPlayAnimation",
                            OPTIONS = {animation = "attack13"},
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
                    OPTIONS = {delay_frame = 9},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false,effect_id = "lianzhu_fireball_1_1"},
                },
            },
        },     
    },
}

return ui_lianzhu_fireball