local zidan_tongyong = 
{
    CLASS = "composite.QSBParallel",
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
                            CLASS = "action.QSBArgsConditionSelector",
                            OPTIONS = 
                            {
                                failed_select = 1,                                
                                {expression = "target:hp/target:max_hp>0.5", select = 1},
                                {expression = "target:hp/target:max_hp>0", select = 2},
                            }
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ss_wfhg_haishenzhiyu_huifu2"},
                                },                          
                            },
                        },
                    },
                }, 
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return zidan_tongyong