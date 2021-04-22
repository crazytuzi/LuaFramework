
local liuerlong_jipao = {
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
                    OPTIONS = {is_hit_effect = false, effect_id = "tongyongyanwu_buff"},
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
			OPTIONS = {verify_flip = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
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

return liuerlong_jipao