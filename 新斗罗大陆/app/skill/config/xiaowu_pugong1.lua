
local xiaowu_pugong1 = {
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "xiaowu_attack01_1_1", is_hit_effect = false, haste = true},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
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
        --         -- {
        --         --     CLASS = "action.QSBDelayTime",
        --         --     OPTIONS = {delay_time = 0.2},
        --         -- },
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {effect_id = "xiaowu_attack01_1_1", is_hit_effect = false},
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },               
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 6},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return xiaowu_pugong1