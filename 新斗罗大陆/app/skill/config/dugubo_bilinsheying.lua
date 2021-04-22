
local dugubo_bilinsheying = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
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
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 27},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "dugubo_attack14_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 61},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 61},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true},
                },
            },
        },
    },
}

return dugubo_bilinsheying

