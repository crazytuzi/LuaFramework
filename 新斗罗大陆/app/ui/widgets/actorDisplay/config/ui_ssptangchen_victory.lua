local shifa_tongyong = 
{
     CLASS = "composite.QUIDBParallel",
     ARGS = 
     {
        -- {
        --     CLASS = "action.QUIDBPlaySound"
        -- },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "victory"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            { 
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 40},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "ui_ssptangchen_victory", is_hit_effect = false},--转刀特效
                },
            },
        },
    },
}

return shifa_tongyong