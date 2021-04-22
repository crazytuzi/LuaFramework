-- 技能 八宝如意软甲防御4
-- 技能ID 2020070

local sq_babaoruyiruanjia_fangyu4 = 
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
            OPTIONS = {buff_id = "sq_babaoruyiruanjia_fangyu4", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_babaoruyiruanjia_fangyu4
