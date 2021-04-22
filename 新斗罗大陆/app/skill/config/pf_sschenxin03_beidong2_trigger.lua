-- 技能 ss剑道尘心被动2触发
-- 技能ID 582
-- 施加破绽
--[[
	魂师 剑道尘心
	ID:1056
	psf 2020-4-21
]]--

local sschenxin_beidong2_trigger = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {random_enemy = true, buff_id = "pf_sschenxin03_beidong2_debuff1;y", no_cancel = true}
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return sschenxin_beidong2_trigger

