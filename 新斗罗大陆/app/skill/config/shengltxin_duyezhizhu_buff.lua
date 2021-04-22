
local duyezhizhu_buff = {
 
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = { all_enemy = true, buff_id = "duyezhizhu_fushidebuff"},

        },  
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}


return duyezhizhu_buff