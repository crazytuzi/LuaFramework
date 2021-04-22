
local ui_blade_storm = {
    CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {is_loop = true,animation = "attack11"},
        },
        {
            CLASS = "action.QUIDBPlayLoopEffect",
            OPTIONS = {effect_id = "bladestorm_1", duration = 3.12},
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

return ui_blade_storm