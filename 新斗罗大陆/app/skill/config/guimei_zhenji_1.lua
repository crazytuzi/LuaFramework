local guimei_zhenji_1 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = {"guimei_zhenji_kj","guimei_zhenji_atk"}, random_enemy = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return guimei_zhenji_1