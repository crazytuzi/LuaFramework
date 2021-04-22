local ssmahongjun_dazhao =
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBAttackFinish",
        },        
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "ssptangchen_sj2_hudun", no_cancel = true},
        },                                          
    },
}

return ssmahongjun_dazhao