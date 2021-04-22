local hl_bianyijinshu_fenlie1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "hl_bianyijinshu_pugong_buff1", teammate = true, no_cancel = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return hl_bianyijinshu_fenlie1