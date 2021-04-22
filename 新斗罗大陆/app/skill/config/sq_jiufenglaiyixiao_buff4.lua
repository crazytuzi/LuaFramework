-- 技能 九凤来仪箫强化4
-- 技能ID 2020095

local sq_jiufenglaiyixiao_buff4 = 
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
            OPTIONS = {buff_id = "sq_jiufenglaiyixiao_buff4", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_jiufenglaiyixiao_buff4

