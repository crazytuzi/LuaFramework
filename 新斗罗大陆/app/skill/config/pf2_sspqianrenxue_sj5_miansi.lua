local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBChangeRecoverHpLimit",
                    OPTIONS = {percent = -1},
                }, 
                {
                    CLASS = "action.QSBSetHpPercent",
                    OPTIONS = {hp_percent = 1},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf2_sspqianrenxue_sj5_miansi", is_target = false},
                },
            },
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf2_sspqianrenxue_sj5_fuhuojianshang", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },        
    },
}

return ssqianshitangsan_pugong1