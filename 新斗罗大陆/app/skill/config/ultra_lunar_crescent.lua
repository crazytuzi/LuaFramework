
local ultra_lunar_crescent = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
                
            },
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 21},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "lunar_crescent_2", speed = 1750, hit_effect_id = "melee_hit", jump_number = 4, rail_number = 3, rail_inter_frame = 1},
                },
            },
        },
    },
}

return ultra_lunar_crescent