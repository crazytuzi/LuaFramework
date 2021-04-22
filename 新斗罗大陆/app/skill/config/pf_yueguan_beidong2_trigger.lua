-- 技能 月关 满地伤被动触发技
-- ID 274
-- 在目标位置召唤花苞40003
--[[
	hero 月关
	ID:1018
	psf 2018-7-24
]]--
local yueguan_beidong2_trigger = 
{
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBAttackByBuffNum",--同时最多两个花苞
			OPTIONS = {buff_id = "yueguan_beidong2_count",num_pre_stack_count = 2,trigger_skill_id = 272,skill_level = 1,target_type = "teammate"}
		},
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attacker = true,status = "yueguan_full",reverse_result = true}
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = 
			{
				{
					CLASS = "action.QSBSummonGhosts",
					OPTIONS = {
						actor_id = 40003,skin_id = 22, life_span = 4.0,number = 1, no_fog = true, use_render_texture = false,
						relative_pos = {x=0,y=0},appear_skill = 200275,
						is_attacked_ghost = false,--[[不能被选中和攻击]]
						extends_level_skills = {200275}
					},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return yueguan_beidong2_trigger 

