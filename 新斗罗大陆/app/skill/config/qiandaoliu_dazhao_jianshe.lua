local qiandaoliu_dazhao_jianshe = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {buff_id = "qiandaoliu_dazhao_jianshe_zhiliao", is_target = false},
        -- },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "qiandaoliu_dazhao_buff1", is_target = false},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return qiandaoliu_dazhao_jianshe