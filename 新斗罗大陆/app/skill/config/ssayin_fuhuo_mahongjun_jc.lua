local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBAttackFinish",
        },
        {
            CLASS = "composite.QSBSequence",           
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsUnderStatus",
                    OPTIONS = {is_attacker = true,status = "ssmahongjun_zhenji_jc"},
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
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "ssayin_dazhao_mahongjun_jt", is_target = true, no_cancel = true},
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
        },
    },
}

return ssqianshitangsan_pugong1