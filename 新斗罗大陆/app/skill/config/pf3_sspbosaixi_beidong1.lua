local cnxiaowu_jipao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false,effect_id = "pf3_sspbosaixi_shanxian01"},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false,effect_id = "pf3_sspbosaixi_shanxian04"},
                        },
                        {
                            CLASS = "action.QSBActorFadeOut",
                            OPTIONS = {duration = 0.25, revertable = true},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false ,buff_id = "pf3_sspbosaixi_beidong1_cf"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.25},
                        },
                        {
                            CLASS = "action.QSBTeleportToPosition",
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false,effect_id = "pf3_sspbosaixi_shanxian01"},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false,effect_id = "pf3_sspbosaixi_shanxian04"},
                                },
                                {
                                    CLASS = "action.QSBActorFadeIn",
                                    OPTIONS = {duration = 0.25, revertable = true},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
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

return cnxiaowu_jipao