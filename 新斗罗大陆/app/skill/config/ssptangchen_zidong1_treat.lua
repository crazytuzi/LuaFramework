local qiandaoliu_dazhao_zhiliao = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "ssptangchen_zidong1_treat", is_target = false},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "ssptangchen_zidong1_zj_treat", is_target = false},
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