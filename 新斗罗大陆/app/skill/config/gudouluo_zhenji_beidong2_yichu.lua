local gudouluo_zhenji_beidong2_yichu = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "gudouluo_zhenji_beidong2", is_target = false},
        },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {buff_id = "dugubo_zhenji_die", remove_all_same_buff_id = true},
        -- },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return gudouluo_zhenji_beidong2_yichu