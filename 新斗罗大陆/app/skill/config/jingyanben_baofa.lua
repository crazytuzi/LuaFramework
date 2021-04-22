
local jingyanben_baofa = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        -- {
            -- CLASS = "composite.QSBSequence",
            -- ARGS = {
                -- {
                    -- CLASS = "action.QSBPlayAnimation",
                -- },
                -- {
                    -- CLASS = "action.QSBAttackFinish"
                -- },
            -- },
        -- },
        -- {
        --     CLASS = "action.QSBPlayEffect",
        --     OPTIONS = {is_hit_effect = false},
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayByAttack",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.45},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {is_hit_effect = true},
                        -- },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
				{
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return jingyanben_baofa