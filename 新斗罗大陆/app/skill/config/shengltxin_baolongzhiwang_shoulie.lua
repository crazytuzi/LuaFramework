-- 技能 暴龙之王进入狩猎状态
-- 技能ID 53324
--[[
	暴龙之王 4127
	升灵台"巨兽沼泽"
]]--
--psf 2020-6-22

local shenglt_baolongzhiwang_shoulie = 
{
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "action.QSBUncancellable",
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = {"shenglt_baolongzhiwang_hunt_buff","shenglt_baolongzhiwang_hungry_debuff","shenglt_baolongzhiwang_carrion_debuff"}},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
	},
}
return shenglt_baolongzhiwang_shoulie