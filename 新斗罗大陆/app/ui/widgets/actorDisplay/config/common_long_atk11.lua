
local common_long_atk11 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {is_loop = true,animation = "attack11"},
        },
        -- {
        --     CLASS = "action.QUIDBPlayLoopEffect",
        --     OPTIONS = {effect_id = "mahongjun_attack11_3_1", duration = 3.12, no_sound_loop = true},
        -- },
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

return common_long_atk11