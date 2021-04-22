
local baichenxiang_zidong2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBSelectTarget",
                    OPTIONS = {max_haste_coefficient = true},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "action.QSBLaser",      -- 特殊子弹，激光形式的子弹
                            OPTIONS = {effect_id = "baichengxiang_attack14_2", effect_width = 200, Zoder = "isGroundEffect",start_pos = {x = 0, y = 145}, use_clip = true, duration = 1, is_loop = true, switch_target = false, hit_dummy = "dummy_center", cancel_skill = true},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return baichenxiang_zidong2

