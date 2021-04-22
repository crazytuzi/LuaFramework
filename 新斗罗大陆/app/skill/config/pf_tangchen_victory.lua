local pf_tangchen_victory = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    { 
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 6},
                -- },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pl_tangcheng_victory_1", is_hit_effect = false},
                },
            },
        },
    },
}

return pf_tangchen_victory