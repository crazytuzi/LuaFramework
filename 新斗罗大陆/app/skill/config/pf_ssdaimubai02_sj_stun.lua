local pf_ssdaimubai02_sj_stun = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBAttackFinish"
        },
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false,effect_id = "pf_ssdaimubai02_shenji_4s_1"},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false,effect_id = "pf_ssdaimubai02_shenji_4x_1"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 7 / 30},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false,effect_id = "pf_ssdaimubai02_shenji_3"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 8 / 30},
                        },
                        {
                          CLASS = "action.QSBHitTarget",
                        },
                    },
                },
            },
        },
    },
}

return pf_ssdaimubai02_sj_stun