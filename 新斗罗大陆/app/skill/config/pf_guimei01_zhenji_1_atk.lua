local guimei_zhenji_1_atk = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "pf_guimei01_zhenji_atk", is_target = false, remove_all_same_buff_id = true},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "pf_guimei01_zhenji_atk_max", is_target = false, remove_all_same_buff_id = true},
        },
        {   
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return guimei_zhenji_1_atk