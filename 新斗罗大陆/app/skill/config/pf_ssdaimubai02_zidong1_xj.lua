local pf_ssdaimubai01_zidong1_xj = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {  
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.15},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {  
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.3},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return pf_ssdaimubai01_zidong1_xj