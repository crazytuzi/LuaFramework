local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="jiguan_jianyu"},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong