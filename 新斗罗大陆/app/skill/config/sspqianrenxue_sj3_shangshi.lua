local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sspqianrenxue_sj3_buff3",is_target = false},
        },
        {
            CLASS = "action.QSBChangeRecoverHpLimitResistance",
            OPTIONS = {is_attacker = true, percent = 0.36},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },   
    },
}

return ssqianshitangsan_pugong1