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
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "sspbosaixi_sj2_debuff1"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "sspbosaixi_sj2_debuff2"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                }, 
                {
                  CLASS = "action.QSBHitTarget",
                },                                                                                
            },
        },
    },
}

return common_xiaoqiang_victory