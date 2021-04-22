local guimei_zhenji_1_atk_max = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = {"guimei_zhenji_kj_max", "guimei_zhenji_atk_max"}, random_enemy = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return guimei_zhenji_1_atk_max