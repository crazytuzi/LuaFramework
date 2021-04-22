local qiandaoliu_zidong2_chufa = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "qiandaoliu_zidong2_buff", is_target = false},
        },
 
        {
            CLASS = "action.QSBHitTimer",
            OPTIONS = {duration_time = 1 ,interval_time = 0.5},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return qiandaoliu_zidong2_chufa