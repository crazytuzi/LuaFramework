local hl_bianyijinshu_fenlie2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "hl_bianyijinshu_pugong_buff2", teammate = true, no_cancel = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return hl_bianyijinshu_fenlie2