-- 技能 八宝如意软甲防御3
-- 技能ID 2020069

local sq_babaoruyiruanjia_fangyu3 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
            OPTIONS = {is_god_arm = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sq_babaoruyiruanjia_fangyu3", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_babaoruyiruanjia_fangyu3
