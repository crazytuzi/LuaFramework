
local teleport = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBActorStand",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.05, revertable = true},
                },
            },
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 0.05},
        },
        {
            CLASS = "action.QSBTeleportToTargetBehind",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBActorFadeIn", revertable = true,
                    OPTIONS = {duration = 0.05},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return teleport