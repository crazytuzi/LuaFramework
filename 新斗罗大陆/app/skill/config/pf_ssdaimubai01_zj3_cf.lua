local pf_ssdaimubai01_zj3_cf = 
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
                                            CLASS = "composite.QSBParallel",
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
                                                            CLASS = "action.QSBMultipleTrap",
                                                            OPTIONS = {trapId = "pf_ssdaimubai01_liuxing2a_1",count = 1},
                                                        },
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 3 / 30 ,pass_key = {"pos"}},
                                                        },
                                                        {
                                                            CLASS = "action.QSBMultipleTrap",
                                                            OPTIONS = {trapId = "pf_ssdaimubai01_liuxing2a_2",count = 1},
                                                        },
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 6 / 30 ,pass_key = {"pos"}},
                                                        },
                                                        {
                                                            CLASS = "action.QSBMultipleTrap",
                                                            OPTIONS = {trapId = "pf_ssdaimubai01_liuxing2a_3",count = 1},
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 6 / 30 },
                                                        },
                                                        {
                                                          CLASS = "action.QSBHitTarget",
                                                          OPTIONS = {damage_scale = 1.3 },
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
                                                            CLASS = "action.QSBMultipleTrap",
                                                            OPTIONS = {trapId = "pf_ssdaimubai01_liuxing2b_1",count = 1},
                                                        },
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 3 / 30 ,pass_key = {"pos"}},
                                                        },
                                                        {
                                                            CLASS = "action.QSBMultipleTrap",
                                                            OPTIONS = {trapId = "pf_ssdaimubai01_liuxing2b_2",count = 1},
                                                        },
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 6 / 30 ,pass_key = {"pos"}},
                                                        },
                                                        {
                                                            CLASS = "action.QSBMultipleTrap",
                                                            OPTIONS = {trapId = "pf_ssdaimubai01_liuxing2b_3",count = 1},
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 6 / 30 },
                                                        },
                                                        {
                                                          CLASS = "action.QSBHitTarget",
                                                          OPTIONS = {damage_scale = 1.3 },
                                                        },
                                                    },
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

return pf_ssdaimubai01_zj3_cf