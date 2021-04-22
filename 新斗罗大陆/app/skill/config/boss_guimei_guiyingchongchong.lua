

local boss_guimei_guiyingchongchong = {

CLASS = "composite.QSBSequence",
    ARGS = {

        {
            CLASS = "composite.QSBParallel",
            ARGS = {

                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12_1"},
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.3, revertable = true},
                },
            },
        },
        {
            CLASS = "action.QSBTeleportToAbsolutePosition",
            OPTIONS = {pos = {x = 320, y = 150}},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12_2"},
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.3, revertable = true},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}


return boss_guimei_guiyingchongchong