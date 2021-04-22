local gudouluo_fumo2_chufa = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_gudouluo01_fumo2_p_x", lowest_hp_enemies = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return gudouluo_fumo2_chufa