local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "zhaowuji_zhenji_plus_debuff",attacker_target = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "zhaowuji_zhenji_plus_buff"},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong