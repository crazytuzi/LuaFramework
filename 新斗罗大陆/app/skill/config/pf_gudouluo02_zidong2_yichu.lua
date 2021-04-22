local gudouluo_zidong2_yichu = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "pf_gudouluo02_zidong2", is_target = false},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "pf_gudouluo02_zhenji_zidong2", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return gudouluo_zidong2_yichu