local furou_mianyi = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTION = {is_target = false, buff_id = "shenglt_baolongzhiwang_carrion_mianyi"},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return furou_mianyi