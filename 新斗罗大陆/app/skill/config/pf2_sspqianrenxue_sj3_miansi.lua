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
                    OPTIONS = {percent = -0.5},
                }, 
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 1},
                -- },
                {
                    CLASS = "action.QSBSetHpPercent",
                    OPTIONS = {hp_percent = 1},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf2_sspqianrenxue_sj3_miansi", is_target = false},
                },
            },
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf2_sspqianrenxue_sj3_fuhuojianshang", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },        
    },
}

return ssqianshitangsan_pugong1