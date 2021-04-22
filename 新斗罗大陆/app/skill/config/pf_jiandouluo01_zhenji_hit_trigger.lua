-- 技能 尘心真技剑痕暴击扣破绽及一层暴击
-- 技能ID 190082
--[[
	hero 尘心
	ID:1028 
	psf 2018-11-14
]]--

local chenxin_zhenji_hit_trigger = {
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {is_target = true,buff_id = "pf_jiandouluo01_pojia_debuff"},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "pf_jiandouluo01_jianhen_baoji_buff"},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {is_target = true,buff_id = "pf_jiandouluo01_pojia_debuff"},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "pf_jiandouluo01_jianhen_baoji_buff"},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},				
	},
}

return chenxin_zhenji_hit_trigger

