-- 技能 比比东真技强化
-- 技能ID 190258
-- 魔法杀魂师上BUFF
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
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "pf_bibidong01_zhenji_plus_buff"},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return bibidong_zidong1_trigger

