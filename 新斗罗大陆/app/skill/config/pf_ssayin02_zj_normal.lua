local zidan_tongyong = 
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
                        {expression = "target:hp/target:max_hp>0.75", select = 1},
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
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsIsUnderStatus",
                                    OPTIONS = {is_attacker = true,status = "ssayin_zj_normal_chufa"},
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBAttackFinish",
                                        }, 
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {is_target = false, buff_id = "ssayin_zj_normal"},
                                                }, 
                                                {
                                                    CLASS = "action.QSBApplyBuff",
                                                    OPTIONS = {is_target = false, buff_id = "ssayin_zj_normal_chufa"},
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
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return zidan_tongyong