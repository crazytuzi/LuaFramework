local zidan_tongyong = 
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
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mingyueye_buff_tk"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mingyueye_buff_yueye5"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {lowest_hp_teammate = true , just_hero = true,is_target = false, buff_id = "mingyueye_buff_yueye5"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return zidan_tongyong