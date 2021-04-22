-- 技能 死前强化
-- 技能ID 50875
-- 加双抗
--[[
	boss 魔鲸王
	ID:3699 3700
	psf 2018-7-19
]]--

local boss_mojingwang_qianghua =                                       
{
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {teammate = true, buff_id = "boss_mojingwang_qianghua",no_cancel = true},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
	},
}

return boss_mojingwang_qianghua