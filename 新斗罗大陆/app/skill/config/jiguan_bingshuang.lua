local boss_bosaixi_leiji = {
CLASS = "composite.QSBParallel",
    ARGS = {
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --            CLASS = "action.QSBApplyBuff",
        --            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --            CLASS = "action.QSBTeleportToAbsolutePosition",
        --            OPTIONS = {pos = {x = 580, y = 300}},
        --         },
        --     },
        -- },
        -- {   
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 10},
        --         },
        --         {
        --             CLASS = "action.QSBPlayAnimation",
        --         },
        --         {
        --             CLASS = "action.QSBAttackFinish"
        --         },
        --     },
        -- },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 64},
                -- },
                -- {
                --     CLASS = "action.QSBHitTarget",
                -- },
                -- {
                --     CLASS = "action.QSBAttackFinish"
                -- },
                -- {
                --   CLASS = "action.QSBPlaySceneEffect",
                --   OPTIONS = {effect_id = "fenhongniangniang_attack16_3", pos  = {x = 270 , y = 230}, ground_layer = true},
                -- },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="jiguan_bingdong"},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
                -- {
                --     CLASS = "action.QSBRemoveBuff",
                --     OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                -- },
            },
        },
    },
}
--         {
--             CLASS = "action.QSBPlaySound",
--             OPTIONS = {sound_id ="guimei_walk"},
--         },
--     },
-- }

return boss_bosaixi_leiji