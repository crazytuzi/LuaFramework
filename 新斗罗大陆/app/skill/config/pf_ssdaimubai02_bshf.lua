
local pf_ssdaimubai02_bshf = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "pf_ssdaimubai02_bsjs"},
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
                            OPTIONS = {buff_id = "pf_ssdaimubai02_bianshen", is_target = false},
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

return pf_ssdaimubai02_bshf

