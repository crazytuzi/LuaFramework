--  创建人：刘悦璘
--  创建时间：2018.03.22
--  NPC：狼盗
--  类型：入场技能
local npc_langdao_ruchang = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_frame = 38},
                --         },
                --         {
                --             CLASS = "action.QSBPlayEffect",
                --             OPTIONS = {is_hit_effect = false, effect_id = "dragon_bellow_1"},
                --         },
                --     },
                -- }, 
                -- {
                --     CLASS = "action.QSBPlayAnimation",
                --     OPTIONS = {animation = "attack14"},
                -- },
                {
                    CLASS = "action.QSBJumpAppear",
                    OPTIONS = {jump_animation = "attack14"},
                },   
            },
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return npc_langdao_ruchang