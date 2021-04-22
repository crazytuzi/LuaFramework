
local ultra_crazy_wheel_1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "dianyuguan_dz_2_2", speed = 1700, hit_effect_id = "dianyuguan_dz_3_2",from_target = true, jump_number = 0, rail_number = 2, rail_inter_frame = 1},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return ultra_crazy_wheel_1