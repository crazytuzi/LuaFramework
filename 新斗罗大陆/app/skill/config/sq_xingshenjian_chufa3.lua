-- 技能 星神剑触发3
-- 技能ID 2020054

local sq_xingshenjian_chufa3 = 
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
            OPTIONS = {is_target = false, buff_id = "sq_xingshenjian_chufa3"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_xingshenjian_chufa3

