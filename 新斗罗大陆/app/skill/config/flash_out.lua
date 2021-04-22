
local flash_out = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "flash_out_1"},
                },
                {
                    CLASS = "action.QSBFlashAppear",
                    OPTIONS = {color = ccc3(255, 255, 255), wait_time = 18 / 30, fade_in_time = 4 / 30},
                },
            },
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 6},
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

return flash_out