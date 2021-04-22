local bosaixi_zidong1_chufa = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "bosaixi_zidong1_buff", is_target = false,  remove_all_same_buff_id = true},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return bosaixi_zidong1_chufa