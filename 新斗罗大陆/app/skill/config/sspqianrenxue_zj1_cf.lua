local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "sspqianrenxue_zj1_jt", is_target = false},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sspqianrenxue_zj1_buff", is_target = false},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sspqianrenxue_zj1_jt2", is_target = false},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "sspqianrenxue_zhenji_2"},
        }, 
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "sspqianrenxue_zhenji_3"},
        },  
        {
            CLASS = "action.QSBAttackFinish",
        },        
    },
}

return ssqianshitangsan_pugong1