local boss_bianyijinshu_fenlie = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "boss_bianyijinshu_pugong_buff", teammate = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return boss_bianyijinshu_fenlie