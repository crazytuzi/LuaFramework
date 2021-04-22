
local ui_blade_fury = {
    CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {is_loop = true,animation = "attack11"},
        },
        {
            CLASS = "action.QUIDBPlayLoopEffect",
            OPTIONS = {effect_id = "ui_xiaowu_attack11_1_1", duration = 3.12, no_sound_loop = true},
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 3.12},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_blade_fury