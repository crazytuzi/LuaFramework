
local pf_ssdaimubai01_bshf = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "zsdaimubai_bsjs"},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "pf_ssdaimubai01_bianshen", is_target = false},
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            }, 
        },
    },
}

return pf_ssdaimubai01_bshf

