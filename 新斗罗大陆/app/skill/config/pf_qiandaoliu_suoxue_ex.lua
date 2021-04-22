
local pf_qiandaoliu_suoxue_ex = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_qiandaoliu_zhenji_suoxue", is_target = false},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_qiandaoliu_zhenji_dazhao_jishu", teammate_and_self = true},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "pf_qiandaoliu_zhenji_miansi_ex", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return pf_qiandaoliu_suoxue_ex