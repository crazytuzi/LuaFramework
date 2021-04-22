local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBDecreaseHpByAbsorb",
            OPTIONS = {is_max_hp_percent = true, hp_percent = 1.2},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "anqi_yonghengxingyu_cf5_jt3", is_target = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "anqi_yonghengxingyu_fuhuo_cd3", is_target = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },        
    },
}

return ssqianshitangsan_pugong1