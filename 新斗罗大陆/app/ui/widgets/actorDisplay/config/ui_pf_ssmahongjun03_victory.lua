
local common_pf_ssmahongjun03_victory = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QUIDBPlaySound"
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "victory"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssmahongjun03_victory_1_1"},
                },
            },
        },
        -- {
        --     CLASS = "composite.QUIDBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QUIDBDelayTime",
        --             OPTIONS = {delay_frame = 32},
        --         },
        --         {
        --             CLASS = "action.QUIDBPlayEffect",
        --             OPTIONS = {effect_id = "pf_ssmahongjun03_victory_2_1"},
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 71},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssmahongjun03_victory_3_1"},
                },
            },
        },
    },
}

return common_pf_ssmahongjun03_victory