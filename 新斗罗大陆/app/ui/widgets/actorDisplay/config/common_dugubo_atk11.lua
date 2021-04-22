
local common_dugubo_atk11 = 
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
                    OPTIONS = {animation = "attack11"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QUIDBDelayTime",
                --     OPTIONS = {delay_frame = 14},
                -- },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "ui_dugubo_attack11_1"},
                },
            },
        },
        -- -- {
        -- --     CLASS = "composite.QUIDBSequence",
        -- --     ARGS = {
        -- --         {
        -- --             CLASS = "action.QUIDBDelayTime",
        -- --             OPTIONS = {delay_frame = 32},
        -- --         },
        -- --         {
        -- --             CLASS = "action.QUIDBPlayEffect",
        -- --             OPTIONS = {effect_id = "ssmahongjun_victory_2_1"},
        -- --         },
        -- --     },
        -- -- },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QUIDBDelayTime",
                --     OPTIONS = {delay_frame = 71},
                -- },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "ui_dugubo_attack11_1_1"},
                },
            },
        },
    },
}

return common_dugubo_atk11