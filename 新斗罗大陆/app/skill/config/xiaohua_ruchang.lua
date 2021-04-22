--  创建人：刘悦璘
--  创建时间：2018.03.22
--  NPC：狼盗
--  类型：入场技能
local xiaohua_ruchang = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack21"},
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

return xiaohua_ruchang