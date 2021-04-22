
local anqi_mifengnaiping_chufa5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "anqi_mifengnaiping_chufa5", is_target = false},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = {"anqi_mifengnaiping_death", "anqi_mifengnaiping_xiaonaiping5", "anqi_mifengnaiping_jiance5", "anqi_mifengnaiping_biaoxian5_1"}, teammate_and_self = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return anqi_mifengnaiping_chufa5
