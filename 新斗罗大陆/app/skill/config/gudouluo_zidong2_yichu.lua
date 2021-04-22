local gudouluo_zidong2_yichu = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "gudouluo_zidong2", is_target = false},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "gudouluo_zhenji_zidong2", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return gudouluo_zidong2_yichu