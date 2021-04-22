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
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 75 / 30 },
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
                    OPTIONS = {delay_time = 23 / 30 },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao03_victory_1"},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao03_victory_1_1"},
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "victory"},
        },
    },
}

return ssniutian_victory