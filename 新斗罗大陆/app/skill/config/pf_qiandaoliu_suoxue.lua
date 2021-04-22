
local pf_qiandaoliu_suoxue = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_qiandaoliu_zhenji_suoxue", is_target = false},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "pf_qiandaoliu_zhenji_miansi", teammate_and_self = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return pf_qiandaoliu_suoxue