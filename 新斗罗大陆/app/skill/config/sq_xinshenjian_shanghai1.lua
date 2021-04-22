-- 技能 星神剑伤害1
-- 技能ID 2020057

local sq_xinshenjian_shanghai1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "sq_xsj_attack1", is_hit_effect = true},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_xinshenjian_shanghai1

