
local boss_mahongjun_shanxian = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        -- {
        --     CLASS = "action.QSBImmuneCharge",
        --     OPTIONS = {enter = true, revertable = true},
        -- },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                -- {
                --     CLASS = "action.QSBManualMode",
                --     OPTIONS = {enter = true, revertable = true},
                -- },
                -- {
                --     CLASS = "action.QSBActorStand",
                -- },
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
            CLASS = "action.QSBTeleportToAbsolutePosition",
            OPTIONS = {pos = {x = 320, y = 150}},
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
        -- {
        --     CLASS = "action.QSBImmuneCharge",
        --     OPTIONS = {enter = false},
        -- },
        -- {
        --     CLASS = "action.QSBManualMode",
        --     OPTIONS = {exit = true},
        -- },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_mahongjun_shanxian