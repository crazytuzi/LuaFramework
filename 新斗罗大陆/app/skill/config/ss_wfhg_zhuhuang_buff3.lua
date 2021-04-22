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
                                {expression = "self:hp/self:max_hp=1", select = 1},
                                {expression = "self:hp/self:max_hp>0.9", select = 2},
                                {expression = "self:hp/self:max_hp>0.8", select = 3},
                                {expression = "self:hp/self:max_hp>0", select = 4},
                            }
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "ss_wfhg_zhuhuang_buff3"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "ss_wfhg_zhuhuang_buff4"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "ss_wfhg_zhuhuang_buff5"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "ss_wfhg_zhuhuang_buff6"},
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