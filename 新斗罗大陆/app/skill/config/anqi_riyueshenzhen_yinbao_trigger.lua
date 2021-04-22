-- 技能 暗器 日月交辉引爆
-- 技能ID 40679~40683
-- 叠满五次count后触发的效果, 引爆所有伤害40656~60
--[[
	暗器 日月神针
	ID:1531
	psf 2020-6-2
]]--

local anqi_riyueshenzhen_yinbao_trigger = 
{
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBPlayMountSkillAnimation",
		},
		{
			CLASS = "action.QSBArgsConditionSelector",
			OPTIONS = {
				failed_select = 1,
				{expression = "self:has_buff:anqi_riyueshenzhen_1", select = 1},
				{expression = "self:has_buff:anqi_riyueshenzhen_2", select = 2},
				{expression = "self:has_buff:anqi_riyueshenzhen_3", select = 3},
				{expression = "self:has_buff:anqi_riyueshenzhen_4", select = 4},
				{expression = "self:has_buff:anqi_riyueshenzhen_5", select = 5},
			}
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBArgsFindTargets",
							OPTIONS = {is_under_status = "riyueshenzhen_riyue", my_enemies = true},
						},
						{
							CLASS = "action.QSBTriggerSkillIgnoreCD",	
							OPTIONS = {skill_id = 40656},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBArgsFindTargets",
							OPTIONS = {is_under_status = "riyueshenzhen_riyue", my_enemies = true},
						},
						{
							CLASS = "action.QSBTriggerSkillIgnoreCD",	
							OPTIONS = {skill_id = 40657},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBArgsFindTargets",
							OPTIONS = {is_under_status = "riyueshenzhen_riyue", my_enemies = true},
						},
						{
							CLASS = "action.QSBTriggerSkillIgnoreCD",	
							OPTIONS = {skill_id = 40658},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBArgsFindTargets",
							OPTIONS = {is_under_status = "riyueshenzhen_riyue", my_enemies = true},
						},
						{
							CLASS = "action.QSBTriggerSkillIgnoreCD",	
							OPTIONS = {skill_id = 40659},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBArgsFindTargets",
							OPTIONS = {is_under_status = "riyueshenzhen_riyue", my_enemies = true},
						},
						{
							CLASS = "action.QSBTriggerSkillIgnoreCD",	
							OPTIONS = {skill_id = 40660},
						},
					},
				},
			},
		},
		{
			CLASS = "action.QSBDelayTime",
			OPTIONS = {delay_frame = 20},
		},
		{
			CLASS = "action.QSBArgsConditionSelector",
			OPTIONS = {
				failed_select = 6,
				{expression = "self:has_buff:anqi_riyueshenzhen_peijian_buff_5", select = 5},
				{expression = "self:has_buff:anqi_riyueshenzhen_peijian_buff_4", select = 4},
				{expression = "self:has_buff:anqi_riyueshenzhen_peijian_buff_3", select = 3},
				{expression = "self:has_buff:anqi_riyueshenzhen_peijian_buff_2", select = 2},
				{expression = "self:has_buff:anqi_riyueshenzhen_peijian_buff_1", select = 1},
			}
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "anqi_riyueshenzhen_shouhu_buff_1"},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "anqi_riyueshenzhen_shouhu_buff_2"},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "anqi_riyueshenzhen_shouhu_buff_3"},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "anqi_riyueshenzhen_shouhu_buff_4"},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "anqi_riyueshenzhen_shouhu_buff_5"},
				},
			},
		},
		{
			CLASS = "action.QSBRemoveBuff",	
			OPTIONS = {buff_id = {"anqi_riyueshenzhen_ri_debuff","anqi_riyueshenzhen_yue_debuff"}, 
			remove_all_same_buff_id = true, enemy = true},
		},
		{
			CLASS = "action.QSBRemoveBuffByStatus",	
			OPTIONS = {status = "riyueshenzhen_count"},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "anqi_riyueshenzhen_cd_buff"},
		},
		{
			CLASS = "composite.QSBParallel",
			ARGS = 
			{
				{
					CLASS = "action.QSBClearSkillCD",
					OPTIONS = {skill_id = 40683},
				},
				{
					CLASS = "action.QSBClearSkillCD",
					OPTIONS = {skill_id = 40662},
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_riyueshenzhen_yinbao_trigger

