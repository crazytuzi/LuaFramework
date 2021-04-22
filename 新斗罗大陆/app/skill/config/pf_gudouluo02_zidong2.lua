local gudouluo_zidong2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "pf_gudouluo02_attack14_1", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "pf_gudouluo02_attack14_1_2", is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 55},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf_gudouluo02_zidong2;y", lowest_hp_teammate_and_self = true},
                },
            },
        },
        {
            CLASS = "action.QSBPlaySound"
        },
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
    },
}

return gudouluo_zidong2