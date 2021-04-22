--  创建人：刘悦璘
--  创建时间：2018.03.22
--  NPC：鬼虎
--  类型：攻击
local npc_guihu_zhanzhengjianta = {
    CLASS = "composite.QSBSequence",
    ARGS = {      
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDragActor",
                            OPTIONS = {pos_type = "self", pos  = {x = 130 , y = 0}, duration = 0.1, flip_with_actor = true},
                        }, 
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {effect_id = "qiangqibing_attack12_3_1", is_hit_effect = false},
                        -- },
                    },
                },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_frame = 30},
                --         },
                --         {
                --             CLASS = "composite.QSBParallel",
                --             ARGS = {
                --                 {
                --                     CLASS = "action.QSBPlayEffect",
                --                     OPTIONS = {is_hit_effect = false},
                --                 },
                --                 {
                --                     CLASS = "action.QSBPlayEffect",
                --                     OPTIONS = {effect_id = "qiangqibing_attack12_3_2", is_hit_effect = false},
                --                 },
                --             },
                --         },
                --     },
                -- },
            },
        },       
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return npc_guihu_zhanzhengjianta