
-- 技能 八宝如意软甲防御1
-- 技能ID 2020067

local sq_babaoruyiruanjia_fangyu1 = 
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
            OPTIONS = {buff_id = "sq_babaoruyiruanjia_fangyu1", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_babaoruyiruanjia_fangyu1

