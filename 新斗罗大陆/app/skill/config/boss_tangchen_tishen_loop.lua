-- 技能 BOSS唐晨替身日常
-- 技能ID 50827
-- 检查身上的BUFF数量,三层触发召唤
-- 三层debuff自杀
--[[
	boss 唐晨 
	ID:3676 副本14-8
	psf 2018-7-4
]]--

local boss_tangchen_tishen_loop = 
{
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_shanghai"},
		},
		-- {
			-- CLASS = "action.QSBAttackByBuffNum", --三只蝙蝠死后自杀
			-- OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_debuff",num_pre_stack_count = 3,trigger_skill_id = 200115,target_type = "self"},
		-- },
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "boss_tangchen_bianfu_zhaohuan_buff"},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "boss_tangchen_bianfu_zhaohuan_debuff"},
		},
		{
			CLASS = "action.QSBAttackByBuffNum", --召唤唐晨
			OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_buff",min_num = 0,num_pre_stack_count = 3,trigger_skill_id = 50824,target_type = "self"},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return boss_tangchen_tishen_loop