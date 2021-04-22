local pf_cnxiaowu03_siwang = {
    CLASS = "composite.QSBSequence",
    ARGS =
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 25},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengnianxiaowu03_dead_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },           
    },
}

return pf_cnxiaowu03_siwang