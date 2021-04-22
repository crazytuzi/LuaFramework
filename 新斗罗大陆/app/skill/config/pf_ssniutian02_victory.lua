local pf_ssniutian02_victory = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        -- {
        --     CLASS = "action.QSBPlaySound",
        --     OPTIONS = {sound_id ="ssniutian_cheer"},
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 107 / 30 },
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "victory"},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "pf_ssniutian02_victory"},
        },
    },
}

return pf_ssniutian02_victory