local pf_tangchen_dead = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    { 
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBPlayAnimation",
        --         },
        --         {
        --             CLASS = "action.QSBSuicide", 
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 6},
                -- },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pl_tangcheng_dead_1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return pf_tangchen_dead