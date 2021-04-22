local pf_chengniantangsan02_siwang = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 25},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengniantangsan02_dead_1", is_hit_effect = false},
                },
            },
            {
                CLASS = "action.QSBAttackFinish",
            },
        },
    },
}

return pf_chengniantangsan02_siwang