local common_ssmahongjun_victory = 
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
                    OPTIONS = {delay_time = 16 / 30 },
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack13_5_1_ui"},
                },
            },
        },
        -- {
        --     CLASS = "composite.QUIDBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QUIDBDelayTime",
        --             OPTIONS = {delay_time = 24 / 30 },
        --         },
        --         {
        --             CLASS = "action.QUIDBPlaySound",
        --             OPTIONS = {sound_id ="zsdaimubai_cheer"},
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 36 / 30 },
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "ssdaimubai_victory_ui"},
                },
            },
        },
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "victory"},
        },
    },
}

return common_ssmahongjun_victory