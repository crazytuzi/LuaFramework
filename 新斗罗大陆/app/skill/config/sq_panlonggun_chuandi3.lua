-- 技能 盘龙棍机制传递3
-- 技能ID 2020100

local sq_panlonggun_chuandi3 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {highest_attack_teammate = true, buff_id = "sq_panlonggun_chuandi3"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_panlonggun_chuandi3

