local gudouluo_beidong1_chufa = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {lowest_hp = true},
        },
        {
            CLASS = "action.QSBBullet",
            OPTIONS = {target_random = true},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return gudouluo_beidong1_chufa