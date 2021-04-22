--  创建人：刘悦璘
--  创建时间：2018.04.08
--  NPC：独孤博BOSS
--  类型：辅助
local jinshu_dugubo_jieyao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                { 
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {is_target = false, buff_id = "jinshu_dugubo_shedu_dot"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {is_target = false, buff_id = "jinshu_dugubo_shedu_dot"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {is_target = false, buff_id = "jinshu_dugubo_shedu_dot"},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return jinshu_dugubo_jieyao