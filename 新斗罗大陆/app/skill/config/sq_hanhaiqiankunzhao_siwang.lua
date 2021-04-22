-- 技能 瀚海乾坤罩破碎死亡技能
-- 技能ID 2020046

local sq_hanhaiqiankunzhao_siwang = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = true, buff_id = "sq_hanhaiqiankunzhao_jinfei"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = true, buff_id = "sq_hanhaiqiankunzhao_zengshang1"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = true, buff_id = "sq_hanhaiqiankunzhao_zengshang2"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = true, buff_id = "sq_hanhaiqiankunzhao_zengshang3"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = true, buff_id = "sq_hanhaiqiankunzhao_zengshang4"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = true, buff_id = "sq_hanhaiqiankunzhao_jiannu1"},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = true, buff_id = "sq_hanhaiqiankunzhao_jiannu2"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_hanhaiqiankunzhao_siwang

