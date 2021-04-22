-- 技能 月关召唤菊花怪变紫色
-- 技能ID 50419
-- 变紫色
--[[
	boss 月关的菊花怪
	ID:3337 副本7--4
	psf 2018-4-6
]]--

local boss_yueguan_juhuaguai_bianzise = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "boss_yueguan_juhuaguai_zise_buff"},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return boss_yueguan_juhuaguai_bianzise

