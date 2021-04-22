local ssmahongjun03_dazhao_chuandi = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_ssmahongjun03_zhuoshao", is_target = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_ssmahongjun03_zhuoshao", is_target = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_ssmahongjun03_zhuoshao", is_target = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssmahongjun03_dazhao_chuandi