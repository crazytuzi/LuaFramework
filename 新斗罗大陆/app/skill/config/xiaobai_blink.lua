local xiaobai_blink = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBActorStand",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12_1"},
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id = "xiaobai_attack12_sf"},
                },
            },
        },
        {
            CLASS = "action.QSBTeleportToPosition",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12_2"},
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id = "xiaobai_attack12_sf"},
                },
            },
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return xiaobai_blink