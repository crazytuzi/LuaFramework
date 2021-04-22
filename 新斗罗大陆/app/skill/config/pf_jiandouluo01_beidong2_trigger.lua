-- 技能 尘心被动2 七杀领域 上BUFF
-- 技能ID 222
-- 给场上随机一人上标记
--[[
	hero 尘心
	ID:1028 
	psf 2018-5-4
]]--

local chenxin_beidong2_trigger = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {random_enemy = true, buff_id = "pf_jiandouluo01_pojia_debuff", no_cancel = true}
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return chenxin_beidong2_trigger

