
local ultra_powershot = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
                
            },
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 29},
                -- },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "powershot_2_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 29},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {is_range_hit = true},
                },
            },
        },
    },
}

return ultra_powershot