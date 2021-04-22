-- 技能 ss剑道尘心选目标1
-- 技能ID 584
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
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {not_copy_hero = true,under_status = "sschenxin_enemy",default_select = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sschenxin_select_target1

