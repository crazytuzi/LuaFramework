
local scramble_appear = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "loose_soil_1"},
        },
        {
            CLASS = "action.QSBScrambleAppear",
            OPTIONS = {scramble_animation = "attack21", mask = {x = -100, y = -200, width = 200, height = 190},},
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

return scramble_appear