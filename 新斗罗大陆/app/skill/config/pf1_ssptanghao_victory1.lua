local ssniutian_victory = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        -- {
        --     CLASS = "action.QSBPlaySound",
        --     OPTIONS = {sound_id ="ssniutian_cheer"},
        -- },
        {    
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "victory1"},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao01_victory_1_2"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                     CLASS = "action.QSBDelayTime",
                     OPTIONS = {delay_frame = 25},
                },  
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao01_victory_1"},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao01_victory_1_1"},
                },

            },
        },
    },
}

return ssniutian_victory