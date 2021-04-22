local ui_pf_sstianqingniumang02_atk11 = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack11"},
        },
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "pf_ssniutian02_attack11_1_ui", is_hit_effect = false},
        }, 
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "pf_ssniutian02_attack11_1_1_ui", is_hit_effect = false},
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 106 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_pf_sstianqingniumang02_atk11