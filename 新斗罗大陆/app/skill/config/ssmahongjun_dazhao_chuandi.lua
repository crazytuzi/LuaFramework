local ssmahongjun_dazhao_chuandi = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "ssmahongjun_zhuoshao", is_target = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "ssmahongjun_zhuoshao", is_target = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "ssmahongjun_zhuoshao", is_target = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssmahongjun_dazhao_chuandi