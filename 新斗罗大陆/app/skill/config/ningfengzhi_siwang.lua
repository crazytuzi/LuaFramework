local tianqingniumang_siwang = {
    CLASS = "composite.QSBSequence",
    ARGS =
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 52},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ningfengzhi_dead_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },           
    },
}

return tianqingniumang_siwang