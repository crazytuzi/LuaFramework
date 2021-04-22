local sspbosaixi_zj_cf3 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {   
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false ,buff_id = "ssptangchen_zj1_jt1"},      --真技1监听1？？？？？
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false ,buff_id = "ssptangchen_zj2_jt1"},      --真技2监听1？？？？？
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false ,buff_id = "ssptangchen_zj1_buff1"},      --真技2监听1？？？？？
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false ,buff_id = "ssptangchen_zj2_buff1"},      --真技2监听1？？？？？
        },
        {
            CLASS = "action.QSBAttackFinish",
        },                                                         
    },
}

return sspbosaixi_zj_cf3