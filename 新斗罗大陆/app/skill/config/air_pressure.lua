
local air_pressure = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "long_fenya_3", pos  = {x = 640 , y = 340}, ground_layer = false},
                },
            },
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 12},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "long_pugong_3",is_hit_effect = true},
                },
            },
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 11},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {is_range_hit = true},
                },
            },
        },

    },
}

return air_pressure