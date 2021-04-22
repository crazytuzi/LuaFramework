
local ui_ultra_gaze_of_fear = {
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
                            OPTIONS = {animation = "attack11"},
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
                    OPTIONS = {delay_frame = 32},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "gaze_of_fear_1_1"},
                }, 
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 7},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "gaze_of_fear_1_2"},
                }, 
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 35},
        --         },
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {is_hit_effect = true, effect_id = "gaze_of_fear_3"},
        --         }, 
        --     },
        -- },
    },
}

return ui_ultra_gaze_of_fear
