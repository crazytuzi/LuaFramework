local tangchen_xiuluoxue_shanghai1 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {  
                {
                    CLASS = "action.QSBDecreaseHpWtihoutLog",
                    OPTIONS = {mode = "current_hp_percent", value = 0.03, ignore_absorb = true}
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return tangchen_xiuluoxue_shanghai1