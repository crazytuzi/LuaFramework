local daimubai_baihulieguangbo = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
                },
            },
        },
        -- {
        --     CLASS = "action.QUIDBPlaySound",
        -- },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 0.57},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "shaoniandaimubai_attack14_1_ui"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 0.58},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "shaoniandaimubai_atk02_3_ui"},
                },
            },
        },
    },
}

return daimubai_baihulieguangbo