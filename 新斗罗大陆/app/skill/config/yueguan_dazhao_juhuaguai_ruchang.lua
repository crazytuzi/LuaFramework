-- 技能 月关 大招菊花妖入场技
-- ID 268
-- 先加攻击属性BUFF, 再判断有没有觉醒
--[[
	hero 月关
	ID:1018
	psf 2018-7-24
]]--
local yueguan_dazhao_juhuaguai_ruchang = 
{
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "yueguan_dazhao_buff;y"},--技能成长加攻击
		},
		{
			CLASS = "action.QSBAttackByBuffNum",--临时标记判断月关是否觉醒
			OPTIONS = {buff_id = "fumo_yueguan_buff",num_pre_stack_count = 1,trigger_skill_id = 272,skill_level = 1,target_type = "teammate"},
		},
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attacker = true,status = "yueguan_full"},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = 
			{
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "fumo_yueguan_juhuaguai_buff"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "fumo_yueguan_juhuaguai_buff"},
				},
			},
		},
		{
			CLASS = "action.QSBAttackByBuffNum",--判断月关是否满级觉醒
			OPTIONS = {buff_id = "fumo_yueguan_buff_1",num_pre_stack_count = 1,trigger_skill_id = 272,skill_level = 1,target_type = "teammate"},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "yueguan_beidong2_full"},--清除临时标记
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return yueguan_dazhao_juhuaguai_ruchang 

