local qiandaoliu_dazhao_zhiliao = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "pf2_sspqianrenxue_dazhao_treat", is_target = false},
        },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {buff_id = "qiandaoliu_dazhao_jianshe_zhiliao", is_target = false},
        -- },
        -- {
        --     CLASS = "action.QSBPlaySound"
        -- },
        {
            CLASS = "action.QSBAverageTreat",
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return qiandaoliu_dazhao_zhiliao