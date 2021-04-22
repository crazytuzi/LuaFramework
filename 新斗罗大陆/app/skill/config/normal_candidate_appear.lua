local normal_candidate_appear = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBUncancellable"
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsPosition",
                    OPTIONS = {is_attacker = true , enter_stop_position = true},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {pass_key = {"pos"}, effect_id = "chuxian_huangse", front_layer = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1 ,pass_key = {"pos"}},
                },
                {
                    CLASS = "action.QSBTeleportToAbsolutePosition",
                    -- OPTIONS = {pos = {x = 500, y = 320}},
                },
            },
        },  
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 0.3},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}
return normal_candidate_appear