local ui_ssniutian_atk13 = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack13"},
        },
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "pf_sstianqingniumang01_attack13_1_ui", is_hit_effect = false},
        }, 
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 71 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_ssniutian_atk13