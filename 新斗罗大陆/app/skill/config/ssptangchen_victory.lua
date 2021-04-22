local shifa_tongyong = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
     {
        -- {
        --     CLASS = "action.QSBPlaySound"
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "victory"},
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
                    OPTIONS = {delay_frame = 40},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ssptangchen_victory", is_hit_effect = false},--转刀特效
                },
            },
        },
    },
}

return shifa_tongyong