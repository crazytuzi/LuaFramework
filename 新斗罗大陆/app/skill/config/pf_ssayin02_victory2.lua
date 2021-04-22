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
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "victory_2"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            { 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssayin02_victory2", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 120},
                },
                 {
                    CLASS = "action.QSBAttackFinish"
                 },
            },
        },
        
    },
}

return shifa_tongyong