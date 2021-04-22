
local pf_cnxiaowu03_pugong2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "pf_chengnianxiaowu03_attack02_1", is_hit_effect = false, haste = true},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 1},
                -- },
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 0},
        --         },
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {effect_id = "pf_chengnianxiaowu03_attack02_1", is_hit_effect = false, haste = true},
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return pf_cnxiaowu03_pugong2