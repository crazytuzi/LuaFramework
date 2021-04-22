local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBDecreaseHpByAbsorb",
            OPTIONS = {is_attack_percent = true, attack_percent = 10},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "ssayin_dazhao_buff2_5", is_target = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "ssayin_dazhao_buff2_7", is_target = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },        
    },
}

return ssqianshitangsan_pugong1