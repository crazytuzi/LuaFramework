-- 技能 BOSS火无双 十字火焰伤害(暂弃)
-- 技能ID 50372
-- 等程序实现多个伤害区拼接
--[[
	boss 火无双
	ID:3287 副本6-16
	psf 2018-3-30
]]--

local boss_huowushuang_crossfire_damage_1 = {
	CLASS = "composite.QSBParallel",
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
	},
}

return boss_huowushuang_crossfire_damage_1