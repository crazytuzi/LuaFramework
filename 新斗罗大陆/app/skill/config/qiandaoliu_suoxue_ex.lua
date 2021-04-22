
local qiandaoliu_suoxue_ex = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "qiandaoliu_zhenji_suoxue", is_target = false},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "qiandaoliu_whzs_3_1", is_hit_effect = false},
        }, 
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "qiandaoliu_zhenji_dazhao_jishu", teammate_and_self = true},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "qiandaoliu_zhenji_miansi_ex", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return qiandaoliu_suoxue_ex