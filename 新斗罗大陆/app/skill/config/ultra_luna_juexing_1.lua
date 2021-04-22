
local ultra_luna_juexing_1 = {          -- 露娜觉醒技能触发的弹射子弹技能
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "lunar_crescent_2", speed = 1750, hit_effect_id = "melee_hit", jump_number = 4, rail_number = 3, rail_inter_frame = 1},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return ultra_luna_juexing_1