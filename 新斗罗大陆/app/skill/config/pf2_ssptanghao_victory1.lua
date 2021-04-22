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
            OPTIONS = {animation = "victory"},
        },

        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                     CLASS = "action.QSBDelayTime",
                     OPTIONS = {delay_frame = 75},
                },  
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao02_victory_1"},
                },


            },
        },
    },
}

return ssniutian_victory