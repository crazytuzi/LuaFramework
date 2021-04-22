local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "tangchen_xiuluozhiling_die", is_target = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong