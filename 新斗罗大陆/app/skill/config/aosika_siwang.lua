local aosika_siwang = {
    CLASS = "composite.QSBSequence",
    ARGS =
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 37},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "aosika_dead_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },           
    },
}

return aosika_siwang