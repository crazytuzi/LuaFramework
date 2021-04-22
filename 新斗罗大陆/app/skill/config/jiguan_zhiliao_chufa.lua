local boss_bosaixi_leiji = 
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
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "jiguan_zhiliao_chufa", lowest_hp_teammate= true},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
                -- {
                --     CLASS = "action.QSBRemoveBuff",
                --     OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                -- },
            },
        }
--         {
--             CLASS = "action.QSBPlaySound",
--             OPTIONS = {sound_id ="guimei_walk"},
--         },
--     },
-- }

return boss_bosaixi_leiji