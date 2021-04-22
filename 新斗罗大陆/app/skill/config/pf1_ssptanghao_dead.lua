local ssptanghao_dead = 
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
                    OPTIONS = {delay_time = 38 / 30 },
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "dead",no_stand = true},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                     CLASS = "action.QSBDelayTime",
                     OPTIONS = {delay_frame = 30},
                },  
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao01_dead_1"},
                },

            },
        },

        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {enemy = true, buff_id = {"ssptanghao_shenji_debuff_1","ssptanghao_shenji_debuff_2",
            "ssptanghao_shenji_debuff_3","ssptanghao_shenji_debuff_4","ssptanghao_shenji_debuff_5"}},
        },
    },
}

return ssptanghao_dead