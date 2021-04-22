
local ayin_pugong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="ningrongrong_attack01_sf"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 21},
                },               
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = { is_hit_effect = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                        CLASS = "composite.QSBParallel",            
                        ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "ayin_attack01_1", is_hit_effect = false},
                        },
                    },
                },
            },
        },
    },
}

return ayin_pugong