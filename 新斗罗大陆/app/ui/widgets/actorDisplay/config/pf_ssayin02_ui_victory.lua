local shifa_tongyong = 
{
     CLASS = "composite.QUIDBParallel",
     ARGS = 
     {
        -- {
        --     CLASS = "action.QUIDBPlaySound",
        --     OPTIONS = {sound_id ="yuxiaogang_cheer"},
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
        -- {
        --     CLASS = "composite.QUIDBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QUIDBDelayTime",
        --             OPTIONS = {delay_frame = 1},
        --         },
        --         {
        --             CLASS = "action.QUIDBPlayEffect",
        --             OPTIONS = {effect_id = "pf_ssayin02_ui_victory", is_hit_effect = false},
        --         },
        --     },
        -- },
        
    },
}

return shifa_tongyong