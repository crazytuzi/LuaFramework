-- 技能 比比东真技自动2回复能量
-- 技能ID 190256
-- 回50能量
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_zidong2_plus_trigger = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        -- {
			-- CLASS = "action.QSBApplyBuff",
			-- OPTIONS = {buff_id = "bibidong_zidong2_plus_buff"},
		-- },
		{
			CLASS = "action.QSBChangeRage",
			OPTIONS = {rage_value = 50,rage_value_max = 100},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return bibidong_zidong2_plus_trigger

