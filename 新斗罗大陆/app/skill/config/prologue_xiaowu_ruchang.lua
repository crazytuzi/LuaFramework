--序章成年小舞入场
--创建人：张义
--创建时间：2018年5月30日18:22:55
--修改时间：



local prologue_xiaowu_ruchang = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayAnimation"
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return prologue_xiaowu_ruchang