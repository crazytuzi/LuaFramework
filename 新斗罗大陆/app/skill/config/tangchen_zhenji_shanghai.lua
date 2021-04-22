local tangchen_zhenji_shanghai = 
{
     CLASS = "composite.QSBSequence",
     ARGS = { 
        {
            CLASS = "composite.QSBParallel",
            ARGS = { 
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return tangchen_zhenji_shanghai