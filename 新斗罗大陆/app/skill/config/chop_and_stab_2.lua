
local chop_and_stab = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.53},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {is_range_hit = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.43},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {is_range_hit = true},
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_time = 0.95},
                -- },
                -- {
                --     CLASS = "action.QSBHitTarget",
                --     OPTIONS = {is_range_hit = true},
                -- },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return chop_and_stab