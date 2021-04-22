local ui_pf_sstianqingniumang02_victory = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 0 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "victory"},
                },
            },
        },
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "pf_ssniutian02_victory_ui", is_hit_effect = false},
        }, 
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 107 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_pf_sstianqingniumang02_victory