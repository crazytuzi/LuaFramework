-- 技能 比比东真技
-- 技能ID 190257
-- 物理杀敌放蜘蛛子弹
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_zhenji_trigger = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
		-- {
			-- CLASS = "action.QSBBullet",	
			-- OPTIONS = {attack_dummy = "dummy_foot",target_random =true,speed = 300}
		-- },
		{
			CLASS = "action.QSBSummonGhosts",
			OPTIONS = {
				actor_id = 40010, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 5, y = 0}, 
				appear_skill = 190259,--[[direction = "left",]]
				percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
				clean_new_wave = true, is_no_deadAnimation = true
			},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return bibidong_zhenji_trigger

