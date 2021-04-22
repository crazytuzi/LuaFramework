
local fumo_yangwudi = {          -- 露娜觉醒技能触发的弹射子弹技能
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 50,y = 90}, effect_id = "yangwudi_atk13_2", speed = 1750, hit_effect_id = "typg_3", jump_info = {jump_number = 4}, rail_number = 3, rail_inter_frame = 1},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return fumo_yangwudi