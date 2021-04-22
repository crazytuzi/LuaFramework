
local npc_shaluzhe_ruchang = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 3},
                        },
                    },
                }, 
                {
                    CLASS = "action.QSBJumpAppear",
                    OPTIONS = {jump_animation = "attack15"},
                },   
            },
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return npc_shaluzhe_ruchang