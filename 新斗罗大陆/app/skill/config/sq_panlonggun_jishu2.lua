-- 技能 盘龙棍大招计数2
-- 技能ID 2020078

local sq_panlonggun_jishu2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sq_panlonggun_jishu2", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_panlonggun_jishu2

