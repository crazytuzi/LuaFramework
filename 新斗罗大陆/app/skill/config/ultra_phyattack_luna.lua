
local ultra_phyattack_luna = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack01"},
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
                    OPTIONS = {effect_id = "lunar_crescent_2", speed = 2300, hit_effect_id = "melee_hit", rail_number = 3, rail_inter_frame = 1},
                },
            },
        },
    },
}

return ultra_phyattack_luna