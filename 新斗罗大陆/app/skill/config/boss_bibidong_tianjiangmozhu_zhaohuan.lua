-- 技能 BOSS比比东 召唤天降魔蛛
-- 技能ID 50839
-- 召唤-2
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_bibidong_tianjiangmozhu_zhaohuan = {
    CLASS = "composite.QSBParallel",
    ARGS = {
	    {
			CLASS = "action.QSBSummonMonsters",
			OPTIONS = {wave = -2},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
    },
}

return boss_bibidong_tianjiangmozhu_zhaohuan