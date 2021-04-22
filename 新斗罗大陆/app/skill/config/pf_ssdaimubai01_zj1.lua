local pf_ssdaimubai01_zj1 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.7},
                        },
                        {
                          CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.25},
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
            },
        },
    },
}

return pf_ssdaimubai01_zj1