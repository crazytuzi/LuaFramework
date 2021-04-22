local pf_ssdaimubai01_sj_stun2 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "zsdmb_ms"},
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
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "2.5S_stun", is_target = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            },
        },
    },
}

return pf_ssdaimubai01_sj_stun2