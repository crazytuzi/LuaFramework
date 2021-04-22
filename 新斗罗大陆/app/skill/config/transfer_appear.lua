
local transfer_appear = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true},
        },
        {
            CLASS = "action.QSBTransferAppear",
            OPTIONS = {effect_id = "transfer_matrix_1", color = ccc3(128, 128, 128)},
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

return transfer_appear