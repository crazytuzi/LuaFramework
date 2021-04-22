local common_xiaoqiang_victory = 
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
                            CLASS = "action.QSBArgsIsUnderStatus",
                            OPTIONS = {is_attacker = true,status = "qianshitangsan_debuff1"},
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
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {is_target = false, buff_id = "ssqianshitangsan_shenji_debuff4"}
                                                },
                                                {
                                                    CLASS = "action.QSBAttackFinish",
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
                                            CLASS = "action.QSBAttackFinish",
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
}

return common_xiaoqiang_victory