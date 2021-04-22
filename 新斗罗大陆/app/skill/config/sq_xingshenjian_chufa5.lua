-- 技能 星神剑触发5
-- 技能ID 2020056

local sq_xingshenjian_chufa5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
            OPTIONS = {is_god_arm = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "sq_xingshenjian_chufa5"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_xingshenjian_chufa5

