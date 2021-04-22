local boss_huangjindaimao_shuidun = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "boss_huangjindaimao_shuidun", lowest_hp_teammate = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return boss_huangjindaimao_shuidun