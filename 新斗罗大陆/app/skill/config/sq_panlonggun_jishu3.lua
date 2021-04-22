-- 技能 盘龙棍大招计数3
-- 技能ID 2020079

local sq_panlonggun_jishu3 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sq_panlonggun_jishu3", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_panlonggun_jishu3

