
local fumo_yangwudi = {          -- 露娜觉醒技能触发的弹射子弹技能
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {is_teammate = true, just_hero = true, not_copy_hero = true, include_self = true},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 50,y = 50}, effect_id = "ningrongrong_attack13_2",
                        speed = 1200, hit_effect_id = "aosika_zhiliao_3", jump_info = {jump_number = 4, is_teammate = true,random_get_new_target=true},
                        rail_number = 3, rail_inter_frame = 1},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return fumo_yangwudi