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
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBArgsConditionSelector",
                                                            OPTIONS = 
                                                            {
                                                                failed_select = 1,
                                                                {expression = "target:buff_num:ssqianshitangsan_putixue1=0", select = 1},
                                                                {expression = "target:buff_num:ssqianshitangsan_putixue1=1", select = 1},
                                                                {expression = "target:buff_num:ssqianshitangsan_putixue1=2", select = 2},
                                                                {expression = "target:buff_num:ssqianshitangsan_putixue1=3", select = 2},                                                                                                            
                                                            },
                                                        },
                                                        {
                                                            CLASS = "composite.QSBSelector",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBDelayTime",
                                                                    OPTIONS = {delay_time = 1},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBHitTarget",
                                                                    OPTIONS = {property_promotion = {critical_damage = 3}},
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