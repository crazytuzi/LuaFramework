local npc_daimubai_tiaopi = {
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {effect_id = "xiliangqibing_attack11_1", is_hit_effect = false},
                        -- },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 12 / 24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 43 / 24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "daimubai_tiaopi"},
                                },
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, count = 1, distance = 50, trapId = "daimubai_liuxingyu"},
                                },
                                -- {
                                --     CLASS = "action.QSBHitTarget",
                                -- },
                            },
                        },
                    },
                },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 15/24 },
                --         },
                --         -- {
                --         --  CLASS = "action.QSBSelectTarget",
                --         --  OPTIONS = {range_max = true},
                --         -- },
                --         {
                --             CLASS = "action.QSBArgsPosition",
                --             OPTIONS = {is_attackee = true},
                --         },
                --         -- {
                --             -- CLASS = "action.QSBMultipleTrap",
                --             -- OPTIONS = {trapId = "boss_tielong_chuidi_trap",count = 1, pass_key = {"pos"}},
                --         -- },
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 25/24 , pass_key = {"pos"}},
                --         },
                --         {
                --             CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                --             OPTIONS = {move_time = 0.75},
                --         },
                --         -- {
                --         --  CLASS = "action.QSBShakeScreen", 
                --         -- },
                --         -- {
                --         --     CLASS = "action.QSBDelayTime",
                --         --     OPTIONS = {delay_frame = 20,},
                --         -- },
                --         -- {
                --         --     CLASS = "action.QSBRemoveBuff",
                --         --     OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                --         -- },
                --     },
                -- },  
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 43 / 24 },
                --         },
                --         {
                --             CLASS = "composite.QSBParallel",
                --             ARGS = 
                --             {
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
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 25 / 24 },
                        },   
                        -- {
                        --     CLASS = "action.QSBHeroicalLeap",
                        --     OPTIONS = {speed = 200 ,move_time = 1 ,interval_time = 1 ,is_hit_target = true ,bound_height = 40},
                        -- },
                        {
                            CLASS = "action.QSBHeroicalLeap",
                            OPTIONS = {speed = 350 ,distance = 275 },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return npc_daimubai_tiaopi