-- 技能 BOSS死亡魔蛛 召唤
-- 技能ID 50870
-- 召唤小蜘蛛
--[[
	boss 死亡魔蛛
	ID:3698
	psf 2018-7-19
]]--

local liuerlong_zhenji_plus_trigger = 
{
	CLASS = "composite.QSBSequence",
	ARGS =
	{
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
				{"target:has_buff!=liuerlong_zhenji_plus_diecen_buff1", "trigger_skill:190152"}, 
			}
		},
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "liuerlong_zhenji_plus_diecen_buff1",attacker_target = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "liuerlong_zhenji_plus_jishu_buff1"},
        },
        {
			CLASS = "action.QSBAttackByBuffNum",
			OPTIONS = { buff_id = "liuerlong_zhenji_plus_diecen_buff1",num_pre_stack_count = 4, trigger_skill_id = 190153,target_type = "actor_target" }
		},
        {
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return liuerlong_zhenji_plus_trigger