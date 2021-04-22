-- 技能 盘龙棍大招计数5
-- 技能ID 2020081

local sq_panlonggun_jishu5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sq_panlonggun_jishu5", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_panlonggun_jishu5

