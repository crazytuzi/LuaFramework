
local wugui_xuanzhuan = {


--     CLASS = "composite.QSBSequence",
--     ARGS = {
--             CLASS = "composite.QSBParallel",
--             ARGS = {
--                 {
--                     CLASS = "action.QSBApplyBuff",
--                     OPTIONS = {buff_id = "speedup_wugui"},
--                 },
--                 {
--                     CLASS = "action.QSBPlayAnimation",
--                     OPTIONS = {animation = "attack11", is_loop = true},
--                 },
--                 {
--                     CLASS = "action.QSBActorKeepAnimation",
--                     OPTIONS = {is_keep_animation = true},
--                 },
--                 {
--                     CLASS = "action.QSBHitTimer",
--                 },             
--         },
--         {
--             CLASS = "composite.QSBSequence",
--             ARGS = {
--                 {
--                     CLASS = "action.QSBActorKeepAnimation",
--                     OPTIONS = {is_keep_animation = false},
--                 },
--                 {
--                     CLASS = "action.QSBActorStand",
--                 },
--             },
--         },
--         {
--             CLASS = "composite.QSBParallel",
--             ARGS = {
--                 {
--                     CLASS = "action.QSBAttackFinish"
--                 },
--                 {
--                     CLASS = "action.QSBRemoveBuff",
--                     OPTIONS = {buff_id = "speedup_wugui"},
--                 },
--             },
--         },
--     },
-- }
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack11", no_stand = true},
                        },
                        -- {
                        --     CLASS = "action.QSBActorKeepAnimation",
                        --     OPTIONS = {is_keep_animation = true},
                        -- },
                    },
                },
                -- {
                --     CLASS = "action.QSBActorKeepAnimation",
                --     OPTIONS = {is_keep_animation = false},
                -- },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_time = 0.2},
                -- },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "speedup_wugui"},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack13", is_loop = true},
                        },
                        {
                            CLASS = "action.QSBActorKeepAnimation",
                            OPTIONS = {is_keep_animation = true},
                        },
                        {
                            CLASS = "action.QSBHitTimer",
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_time = 5},
                -- },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false},
                },
                {
                    CLASS = "action.QSBActorStand",
                },
            },
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBAttackFinish"
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "speedup_wugui"},
                },
            },
        },
    },
}

return wugui_xuanzhuan