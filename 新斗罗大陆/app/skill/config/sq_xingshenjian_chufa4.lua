-- 技能 星神剑触发4
-- 技能ID 2020055

local sq_xingshenjian_chufa4 = 
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
            OPTIONS = {is_target = false, buff_id = "sq_xingshenjian_chufa4"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_xingshenjian_chufa4

