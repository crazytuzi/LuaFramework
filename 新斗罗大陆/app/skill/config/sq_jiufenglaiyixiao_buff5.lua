-- 技能 九凤来仪箫强化5
-- 技能ID 2020096

local sq_jiufenglaiyixiao_buff5 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
            OPTIONS = {is_god_arm = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sq_jiufenglaiyixiao_buff5", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_jiufenglaiyixiao_buff5

