
local mahongjun_shanxian = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBManualMode",
                    OPTIONS = {enter = true, revertable = true},
                },
                {
                    CLASS = "action.QSBActorStand",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id="mahongjun_attack12_3_1",is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.3, revertable = true},
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
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id="mahongjun_attack12_3_2",is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.3, revertable = true},
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

return mahongjun_shanxian