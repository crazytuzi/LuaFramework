
local anqi_mifengnaiping_zhong4 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "anqi_mifengnaiping_biaoxian4_1", is_target = false},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "anqi_mifengnaiping_biaoxian4_2", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return anqi_mifengnaiping_zhong4

