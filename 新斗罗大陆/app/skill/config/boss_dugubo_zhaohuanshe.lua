--  创建人：刘悦璘
--  创建时间：2018.05.31
--  NPC：独孤博BOSS
--  类型：召唤技能
local boss_dugubo_zhaohuanshe = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        -- {
        --     CLASS = "action.QSBArgsPosition",
        -- },
        {
            CLASS = "action.QSBSummonGhosts",
            OPTIONS = {ignorePosition = true, actor_id = 3633, life_span = 10, number = 1, no_fog = false, use_render_texture = false},
        },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {is_target = true, buff_id = "boss_dugubo_shedu_dot"},
        -- },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {is_target = true, buff_id = "boss_dugubo_shedu_dot"},
        -- },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {is_target = true, buff_id = "boss_dugubo_shedu_dot"},
        -- },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return boss_dugubo_zhaohuanshe