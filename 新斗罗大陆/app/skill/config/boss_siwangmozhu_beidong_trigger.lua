-- 技能 BOSS死亡魔蛛 召唤
-- 技能ID 50870
-- 召唤小蜘蛛
--[[
	boss 死亡魔蛛
	ID:3698
	psf 2018-7-19
]]--

local boss_siwangmozhu_beidong_trigger = 
{
	CLASS = "composite.QSBParallel",
	ARGS =
	{
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {
				random_enemy = true,
				buff_id = "boss_bibidong_duye_debuff"
			},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return boss_siwangmozhu_beidong_trigger