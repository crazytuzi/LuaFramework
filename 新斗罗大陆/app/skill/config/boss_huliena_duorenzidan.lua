

local boss_huliena_duorenzidan = {
	CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayEffect"
        },
        {
           CLASS = "composite.QSBSequence",
           ARGS = {
                    {
                      CLASS = "action.QSBPlayAnimation",
                      ARGS = {
                                CLASS = "action.QSBBullet",
                                OPTIONS = {effect_id = "huliena_attack14_2",speed = 2500,hit_effect_id = "huliena_attack14_3"},
                             },
                    },
                    {
                      CLASS = "action.QSBAttackFinish",
                    },
                  },
        },
    },
}
return boss_huliena_duorenzidan    