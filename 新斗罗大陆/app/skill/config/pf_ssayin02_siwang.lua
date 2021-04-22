local tianqingniumang_siwang = {
    CLASS = "composite.QSBSequence",
    ARGS =
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 32},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssayin02_dead", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },           
    },
}

return tianqingniumang_siwang