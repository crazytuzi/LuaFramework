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
            CLASS = "action.QSBBullet",
            OPTIONS = {start_pos = {x = 125,y = 115}, effect_id = "pf_gudouluo01_attack1_2", speed = 1500, hit_effect_id = "pf_gudouluo01_attack1_3"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return gudouluo_beidong1_chufa