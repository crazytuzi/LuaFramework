local zhuzhuqing_beidong2_chufa = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "zhuzhuqing_shanbi", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return zhuzhuqing_beidong2_chufa