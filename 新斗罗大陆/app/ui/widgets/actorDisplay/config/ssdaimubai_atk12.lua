local boss_niumang_shuilao = 
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
                    OPTIONS = {animation = "attack12"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS =
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 3 / 30 },
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack12_1_ui"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS =
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 8 / 30 },
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack12_1_1_ui"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS =
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 2 / 30 },
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "zsdaimubai_attack12_2_ui"},
                },
            },
        },
        -- {
        --     CLASS = "composite.QUIDBSequence",
        --     ARGS =
        --     {
        --         {
        --             CLASS = "action.QUIDBDelayTime",
        --             OPTIONS = {delay_time = 20 / 30 },
        --         },
        --         {
        --             CLASS = "action.QUIDBPlayEffect",
        --             OPTIONS = {effect_id = "zsdaimubai_attack12_3_ui"},
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QUIDBSequence",
        --     ARGS =
        --     {
        --         {
        --             CLASS = "action.QUIDBDelayTime",
        --             OPTIONS = {delay_time = 46 / 30 },
        --         },
        --         {
        --             CLASS = "composite.QUIDBParallel",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QUIDBPlayAnimation",
        --                     OPTIONS = {animation = "attack11_3"},
        --                 },                                        
        --                 {
        --                     CLASS = "action.QUIDBPlayEffect",
        --                     OPTIONS = {effect_id = "zsdaimubai2_attack11_3_ui"},
        --                 }, 
        --                 {
        --                     CLASS = "action.QUIDBPlayEffect",
        --                     OPTIONS = {effect_id = "zsdaimubai2_attack11_3_1_ui"},
        --                 },   
        --             },
        --         },
        --     },
        -- },
    },
}

return boss_niumang_shuilao