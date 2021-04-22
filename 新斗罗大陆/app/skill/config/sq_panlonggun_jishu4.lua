-- 技能 盘龙棍大招计数4
-- 技能ID 2020080

local sq_panlonggun_jishu4 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sq_panlonggun_jishu4", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_panlonggun_jishu4

