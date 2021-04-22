local zibao_mianyi = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTION = {is_target = false, buff_id = "zibao_mianyi"},
        }
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return zibao_mianyi