-- 技能 BOSS死亡魔蛛 召唤
-- 技能ID 50870
-- 召唤小蜘蛛
--[[
	boss 死亡魔蛛
	ID:3698
	psf 2018-7-19
]]--

local liuerlong_zhenji_trigger = 
{
	CLASS = "composite.QSBSequence",
	ARGS =
	{
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
				{"target:has_buff!=yuxiaogang_zhenji_diecen_buff1", "trigger_skill:190155"}, 
			}
		},
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "yuxiaogang_zhenji_diecen_buff1",is_target = true},
        },
        {
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return liuerlong_zhenji_trigger