local pf_qiandaoliu_zhenji_qianghua = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "pf_qiandaoliu03_zhenji_buff", is_target = false},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_qiandaoliu03_zhenji_miansi_ex", teammate_and_self = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return pf_qiandaoliu_zhenji_qianghua