-- 技能 BOSS比比东 召唤魔蛛
-- 技能ID 50836
-- 召唤-1
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_bibidong_zhaohuanmozhu = {
    CLASS = "composite.QSBParallel",
    ARGS = {
	    {
			CLASS = "action.QSBSummonMonsters",
			OPTIONS = {wave = -1,attacker_level = true},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
    },
}

return boss_bibidong_zhaohuanmozhu