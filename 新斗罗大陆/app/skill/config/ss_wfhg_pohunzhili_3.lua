local zidan_tongyong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "ss_wfhg_pohunzhili_baoji"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "ss_wfhg_pohunzhili_baoji_cd"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return zidan_tongyong