local daimubai_baihuhushengzhang = 
{
     CLASS = "composite.QUIDBParallel",
     ARGS = 
     {
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                },
            },
        },
        -- {
        --     CLASS = "composite.QUIDBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QUIDBDelayTime",
        --             OPTIONS = {delay_time = 0.15},
        --         },
        --         {
        --             CLASS = "action.QUIDBPlaySound",
        --             OPTIONS = {sound_id ="daimubai_skill"},
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 0.73},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "shaoniandaimubai_attack11_1_1_ui"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 0.73},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "shaoniandaimubai_attack11_1_2_ui"},
                },
            },
        },
    },
}

return daimubai_baihuhushengzhang