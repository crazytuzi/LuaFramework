
local ultra_aimed_fire = {      --瞄准射击
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
                
            },
        },

        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "aimed_fire_1", is_hit_effect = false, haste = true},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "aimed_fire_3", is_hit_effect = false, haste = true},
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "aimed_fire_y"},
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 47},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "aimed_fire_2", speed = 2400, hit_effect_id = "melee_hit"},
                },
            },
        },
    },
}

return ultra_aimed_fire