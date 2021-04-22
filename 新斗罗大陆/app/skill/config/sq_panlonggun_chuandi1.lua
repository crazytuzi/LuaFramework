-- 技能 盘龙棍机制传递1
-- 技能ID 2020098

local sq_panlonggun_chuandi1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {highest_attack_teammate = true, buff_id = "sq_panlonggun_chuandi1"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_panlonggun_chuandi1

