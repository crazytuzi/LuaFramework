-- 技能 BOSS火无双 十字火焰伤害
-- 技能ID 50371
-- 十字AOE
--[[
	boss 火无双
	ID:3287 副本6-16
	psf 2018-3-30
]]--

local boss_huowushuang_crossfire_damage = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBPlaySound",
		},        
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false},
		},
		{
			CLASS = "action.QSBHitTarget",
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return boss_huowushuang_crossfire_damage