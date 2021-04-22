local gudouluo_beidong2_jihuo = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBHitTarget",
            OPTIONS = {target_enemy_lowest_hp_percent = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return gudouluo_beidong2_jihuo