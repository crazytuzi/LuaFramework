local pf_ssdaimubai02_zj2_cf = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "zsdaimubai_zj"},
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
                            CLASS = "action.QSBAttackFinish"
                        },
                        -- {
                        --     CLASS = "action.QSBApplyBuff",
                        --     OPTIONS = {is_target = false, buff_id = "zsdaimubai_zj_bd2"},
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsIsDirectionLeft",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = 
                                    {   
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBArgsPosition",
                                                    OPTIONS = {is_attackee = true},
                                                },
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 0 / 30 ,pass_key = {"pos"}},
                                                },
                                                {
                                                    CLASS = "composite.QSBParallel",
                                                    ARGS =
                                                    {
                                                        {
                                                            CLASS = "action.QSBMultipleTrap",
                                                            OPTIONS = {trapId = "pf_ssdaimubai02_liuxing1",count = 1},
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 6 / 30 },
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
                                                    CLASS = "action.QSBArgsPosition",
                                                    OPTIONS = {is_attackee = true},
                                                },
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 0 / 30 ,pass_key = {"pos"}},
                                                },
                                                {
                                                    CLASS = "composite.QSBParallel",
                                                    ARGS =
                                                    {
                                                        {
                                                            CLASS = "action.QSBMultipleTrap",
                                                            OPTIONS = {trapId = "pf_ssdaimubai02_liuxing1_1",count = 1},
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 6 / 30 },
                                                },
                                                {
                                                  CLASS = "action.QSBHitTarget",
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
            },
        },
    },
}

return pf_ssdaimubai02_zj2_cf