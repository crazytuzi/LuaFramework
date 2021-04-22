
local jinzhan_tongyong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 37 / 24  },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "renmianmozhu3_dead_3" , is_hit_effect = false },
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 27 / 24  },
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id = "clashatk03"},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return jinzhan_tongyong