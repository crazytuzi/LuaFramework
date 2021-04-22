-- 技能 尘心自动2 杀气毕露 额外伤害
-- 技能ID 222
-- 打伤害
--[[
	hero 尘心
	ID:1028 
	psf 2018-5-4
]]--

local chenxin_zidong2_plus_trigger = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBBullet",
		},
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "hp_percent<0.4","increase_hp:self:maxHp*0.01"},
			}
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return chenxin_zidong2_plus_trigger

