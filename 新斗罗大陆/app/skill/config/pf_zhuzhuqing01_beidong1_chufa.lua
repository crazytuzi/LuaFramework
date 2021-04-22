local zhuzhuqing_beidong1_chufa = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "zhuzhuqing_beidong1_baoji", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return zhuzhuqing_beidong1_chufa