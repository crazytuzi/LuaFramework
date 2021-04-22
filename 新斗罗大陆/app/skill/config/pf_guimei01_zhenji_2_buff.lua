local guimei_zhenji_2_buff = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_guimei01_zhenji_2_buff", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
    
return guimei_zhenji_2_buff