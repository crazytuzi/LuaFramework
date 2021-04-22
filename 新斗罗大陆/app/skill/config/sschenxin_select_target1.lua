-- 技能 ss剑道尘心选目标1
-- 技能ID 583
-- 施加破绽
--[[
	魂师 剑道尘心
	ID:1056
	psf 2020-4-21
]]--

local sschenxin_select_target1 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {highest_attack_teammate = true,prior_role = "health",not_copy_hero = true,
            buff_id = "sschenxin_select_health_buff"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sschenxin_select_target1

