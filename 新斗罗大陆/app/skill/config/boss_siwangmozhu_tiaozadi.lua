-- 技能 BOSS死亡魔蛛 召唤
-- 技能ID 50870
-- 召唤小蜘蛛
--[[
	boss 死亡魔蛛
	ID:3698
	psf 2018-7-19
]]--

local boss_siwangmozhu_tiaozadi = 
{
	CLASS = "composite.QSBParallel",
	ARGS =
	{
		{
			CLASS = "action.QSBPlayAnimation",
			ARGS = {
				{
					CLASS = "action.QSBHitTarget",
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1},
                },
				{
                    CLASS = "action.QSBChangeRage",
                    OPTIONS = {is_target = true, rage_value = 250,rage_value_max = 250},
                },
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}
return boss_siwangmozhu_tiaozadi