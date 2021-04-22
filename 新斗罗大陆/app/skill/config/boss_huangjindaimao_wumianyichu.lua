local boss_huangjindaimao_wumianyichu = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "boss_huangjindaimao_wumian", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return boss_huangjindaimao_wumianyichu