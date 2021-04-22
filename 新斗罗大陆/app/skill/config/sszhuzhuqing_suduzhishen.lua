local sszhuzhuqing_suduzhishen = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "sszhuzhuqing_zj_qx1",no_cancel = true},
        },
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "sszhuzhuqing_wuhun_jt"},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = 
            {
                --变身后
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "sszhuzhuqing_zj_qx1",no_cancel = true},
                        },
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
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            },
        },
    },
}
return sszhuzhuqing_suduzhishen