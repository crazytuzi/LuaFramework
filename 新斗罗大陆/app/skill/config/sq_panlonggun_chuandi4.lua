-- 技能 盘龙棍机制传递4
-- 技能ID 2020101

local sq_panlonggun_chuandi4 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {highest_attack_teammate = true, buff_id = "sq_panlonggun_chuandi4"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_panlonggun_chuandi4

