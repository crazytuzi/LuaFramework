--序章比比东AI
--创建人：张义
--创建时间：2018年4月9日22:45:11
--修改时间：



local prologue_xiaozhizhu_ruchang = {
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

return prologue_xiaozhizhu_ruchang