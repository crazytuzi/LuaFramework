local hl_bianyijinshu_beiji = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "hl_bianyijinshu_pugong_buff1", teammate = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return hl_bianyijinshu_beiji