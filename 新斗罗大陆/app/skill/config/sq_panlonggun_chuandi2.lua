-- 技能 盘龙棍机制传递2
-- 技能ID 2020099

local sq_panlonggun_chuandi2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {highest_attack_teammate = true, buff_id = "sq_panlonggun_chuandi2"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_panlonggun_chuandi2

