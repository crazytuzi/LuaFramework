local gudouluo_fumo1_chufa = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_gudouluo01_fumo1_p_x", lowest_hp_enemies = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return gudouluo_fumo1_chufa