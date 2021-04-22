-- 技能 BOSS死亡魔蛛 召唤
-- 技能ID 50870
-- 召唤小蜘蛛
--[[
	boss 死亡魔蛛
	ID:3698
	psf 2018-7-19
]]--

local boss_siwangmozhu_zhaohuan = 
{
	CLASS = "composite.QSBSequence",
	ARGS =
	{
		{
			CLASS = "action.QSBAttackByBuffNum",
			OPTIONS = { buff_id = "boss_siwangmozhu_beidong_buff",min_num = 2,num_pre_stack_count = 3, trigger_skill_id = 50095,target_type = "self" }
		},
        {
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return boss_siwangmozhu_zhaohuan