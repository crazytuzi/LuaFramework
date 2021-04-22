-- 技能 瀚海乾坤罩五星移除buff
-- 技能ID 2020097

local sq_hanhaiqiankunzhao_yichu = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {teammate_and_self = true, buff_id = "sq_hanhaiqiankunzhao_fuchou5"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_hanhaiqiankunzhao_yichu

