local boss_shenhaimojing_shuilao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS =
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    -- ARGS = {
                },
                {
                    CLASS = "action.QSBPlaySound"
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS =
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 15 / 24 },
                        },
                        {
                            CLASS = "action.QSBSelectTarget",
                            OPTIONS = {range_max = true},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shenhaimojing_shuiyux"} ,
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shenhaimojing_shuizhux"} ,
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shuilao_hongquan"} ,
                                },
                            },
                        },
                    }, 
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         -- {
        --         --     CLASS = "action.QSBDelayTime",
        --         --     OPTIONS = {delay_time = 0.1},
        --         -- },
        --         {
        --             CLASS = "composite.QSBParallel",
        --             ARGS = {
        --                 {
        --                     CLASS = "action.QSBPlayEffect",
        --                     OPTIONS = {is_hit_effect = true},
        --                 },
        --                 {
        --                     CLASS = "action.QSBHitTarget",
        --                 },
        --             },
        --         },
        --     },
        -- },
        --     },
        -- },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_shenhaimojing_shuilao