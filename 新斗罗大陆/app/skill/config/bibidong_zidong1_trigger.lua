-- 技能 比比东自动1触发反击
-- 技能ID 399
-- 反击
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_zidong1_trigger = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
			CLASS = "action.QSBHitTarget",
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return bibidong_zidong1_trigger

