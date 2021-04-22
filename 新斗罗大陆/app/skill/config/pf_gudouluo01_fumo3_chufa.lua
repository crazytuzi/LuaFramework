local gudouluo_fumo3_chufa = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_gudouluo01_fumo3_p_x", lowest_hp_enemies = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return gudouluo_fumo3_chufa