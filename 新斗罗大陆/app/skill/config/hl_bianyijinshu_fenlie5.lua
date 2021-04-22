local hl_bianyijinshu_fenlie5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "hl_bianyijinshu_pugong_buff5", teammate = true, no_cancel = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return hl_bianyijinshu_fenlie5