local ssmahongjun_dazhao =
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
		{
			CLASS = "action.QSBRemoveBuff",	
			OPTIONS = {buff_id = "pf01_ssqianshitangsan_zhenji_jt1"},
		},
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssmahongjun_dazhao