local tielong_wulianji = 
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
                    OPTIONS = {animation = "attack01"},
                },  
                -- {
                --     CLASS = "action.QSBHeroicalLeap",
                --     OPTIONS = {speed = 400 ,distance = 200 },
                -- --     -- OPTIONS = {speed = 800 ,move_time = 0.875 ,interval_time = 1 ,is_hit_target = true ,bound_height = 50},
                -- },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 15 / 24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBHeroicalLeap",
                                    -- OPTIONS = {speed = 400 ,distance = 100 },
                                    OPTIONS = {speed = 400 ,move_time = 0.2 ,interval_time = 1 ,is_hit_target = false ,bound_height = 50},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                }, 
            },
        },
        -- {
        --     CLASS = "action.QSBDelayTime",
        --     OPTIONS = {delay_time = 20 / 24 },
        -- },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack02", no_stand = true},
                },  
                -- {
                --     CLASS = "action.QSBHeroicalLeap",
                --     OPTIONS = {speed = 400 ,distance = 250 },
                -- },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 17 / 24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBHeroicalLeap",
                                    -- OPTIONS = {speed = 400 ,distance = 100 },
                                    OPTIONS = {speed = 400 ,move_time = 0.2 ,interval_time = 1 ,is_hit_target = false ,bound_height = 50},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                }, 
            },
        },
            --     {
            --         CLASS = "action.QSBDelayTime",
            --         OPTIONS = {delay_time = 33 / 24 },
            --     },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack02", no_stand = true},
                        },  
                        -- {
                        --     CLASS = "action.QSBHeroicalLeap",
                        --     OPTIONS = {speed = 400 ,distance = 200 },
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 17 / 24 },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBHeroicalLeap",
                                    -- OPTIONS = {speed = 400 ,distance = 100 },
                                            OPTIONS = {speed = 400 ,move_time = 0.2 ,interval_time = 1 ,is_hit_target = false ,bound_height = 50},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                        },
                                    },
                                },
                            },
                        }, 
                    },
                },
            --     {
            --         CLASS = "action.QSBDelayTime",
            --         OPTIONS = {delay_time = 33 / 24 },
            --     },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack01", no_stand = true},
                        },  
                        -- {
                        --     CLASS = "action.QSBHeroicalLeap",
                        --     OPTIONS = {speed = 400 ,distance = 200 },
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 15 / 24 },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBHeroicalLeap",
                                    -- OPTIONS = {speed = 400 ,distance = 100 },
                                            OPTIONS = {speed = 400 ,move_time = 0.2 ,interval_time = 1 ,is_hit_target = false ,bound_height = 50},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                        },
                                    },
                                },
                            },
                        }, 
                    },
                },
            --     {
            --         CLASS = "action.QSBDelayTime",
            --         OPTIONS = {delay_time = 33 / 24 },
            --     },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack02", no_stand = true},
                        },  
                        -- {
                        --     CLASS = "action.QSBHeroicalLeap",
                        --     OPTIONS = {speed = 400 ,distance = 200 },
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 17 / 24 },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBHeroicalLeap",
                                    -- OPTIONS = {speed = 400 ,distance = 100 },
                                            OPTIONS = {speed = 400 ,move_time = 0.2 ,interval_time = 1 ,is_hit_target = false ,bound_height = 50},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                        },
                                    },
                                },
                            },
                        }, 
                    },
                },
            -- },
                        -- {
                        --     CLASS = "action.QSBHeroicalLeap",
                            -- OPTIONS = {speed = 800 ,move_time = 0.875 ,interval_time = 1 ,is_hit_target = true ,bound_height = 50},
                        -- },
                --         {
                --             CLASS = "action.QSBHeroicalLeap",
                --             OPTIONS = {speed = 600 ,move_time = 2 ,interval_time = 1 ,is_hit_target = true ,bound_height = 40},
                --         },
                      
                --     },
                -- },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return tielong_wulianji