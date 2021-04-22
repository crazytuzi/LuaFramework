local pf_qianrenxue_zidong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlaySound",
                },
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
            ARGS = 
            {
               
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_qianrenxue_attack13_1", is_hit_effect = false},
                },               
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },               
                {
                    CLASS = "action.QSBHitTarget",
                },               
            },
        },
    },
}

return pf_qianrenxue_zidong1