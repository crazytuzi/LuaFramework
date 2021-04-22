local zidan_tongyong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 45 / 30},
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
                    OPTIONS = {delay_time = 16/30},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "yueguancz_attack01_2",hit_effect_id = "yueguancz_attack01_3",start_pos = {x = 0,y = 100}},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false,effect_id = "yueguancz_attack01_1"},
                },
            },
        },
    },
}

return zidan_tongyong