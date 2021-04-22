-- 技能 盘龙棍机制传递5
-- 技能ID 2020102

local sq_panlonggun_chuandi5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {highest_attack_teammate = true, buff_id = "sq_panlonggun_chuandi5"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_panlonggun_chuandi5

