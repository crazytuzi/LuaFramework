-- 技能 瀚海乾坤罩入场4
-- 技能ID 2020044

local sq_hanhaiqiankunzhao_ruchang4 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "sq_hanhaiqiankunzhao_mianyi"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = true, buff_id = {"sq_hanhaiqiankunzhao_jinfei", "sq_hanhaiqiankunzhao_zengshang3", "sq_hanhaiqiankunzhao_jiannu1"}},
        },
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_target = true, is_always_lock = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_hanhaiqiankunzhao_ruchang4

