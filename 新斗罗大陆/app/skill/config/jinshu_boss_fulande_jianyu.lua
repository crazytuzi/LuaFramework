local fulande_misharuodian = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {flip_follow_y =  true},
                        },
                    },
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true, effect_id = "fulande_atk13_3_2"},
                },
            },
        },
    },
}

return fulande_misharuodian
