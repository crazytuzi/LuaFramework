local gudouluo_beidong2_chufa = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "gudouluo_beidong2_jiance", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return gudouluo_beidong2_chufa