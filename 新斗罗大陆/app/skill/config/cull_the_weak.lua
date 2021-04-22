local first_move = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
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
                            OPTIONS = {is_hit_effect = false, effect_id = "shadow_step_1"},
                        },
                        {
                            CLASS = "action.QSBActorFadeOut",
                            OPTIONS = {duration = 0.10, revertable = true},
                        },
                    },
                },
                {
                    CLASS = "action.QSBSelectTarget",
                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 11}},
                },
                {
                    CLASS = "action.QSBTeleportToTargetBehind",
                    OPTIONS = {verify_flip = true},
                },
                -- {
                --     CLASS = "action.QSBPlayAnimation",
                --     OPTIONS = {animation = "attack01"},
                -- },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effeci_id = "shadow_step_1_nosound"},
                        },
                        {
                            CLASS = "action.QSBActorFadeIn", revertable = true,
                            OPTIONS = {duration = 0.10},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack01"},
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 7},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.1},
                },
                {
                    CLASS = "action.QSBDelayByAttack",
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {current_target = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 7},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.1},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "heroic_strike_weapon"},
                },
            },
        },
    },
}

local killing_spree = {
   	CLASS = "composite.QSBSequence",
    ARGS = 
    {
        first_move,
        first_move,
        first_move,
        first_move,
        first_move,
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return killing_spree