-- 技能 盘龙棍大招计数1
-- 技能ID 2020077

local sq_panlonggun_jishu1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sq_panlonggun_jishu1", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_panlonggun_jishu1

