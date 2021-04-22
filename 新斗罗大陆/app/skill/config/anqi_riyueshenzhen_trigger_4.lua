-- 技能 暗器 日月交辉触发
-- 技能ID 40651~40655
-- 目标交替增加日月debuff (根据anqi_riyueshenzhen_yue_buff判断),自身增加一层count,
-- 计数达到5时,触发引爆并加上anqi_riyueshenzhen_peijian_buff_5和anqi_riyueshenzhen_buff_5
--[[
	暗器 日月神针
	ID:1531
	psf 2020-6-2
]]--

local anqi_riyueshenzhen_trigger = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 2,
						{expression = "self:has_buff:anqi_riyueshenzhen_yue_buff", select = 1},
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
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "anqi_riyueshenzhen_yue_buff"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "anqi_riyueshenzhen_yue_debuff", is_target = true},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "anqi_riyueshenzhen_yue_buff"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "anqi_riyueshenzhen_ri_debuff", is_target = true},
								},
							},
						},
					},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 3,
						{expression = "self:has_buff:anqi_riyueshenzhen_count1", select = 1},
						{expression = "self:has_buff:anqi_riyueshenzhen_count2", select = 2},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "anqi_riyueshenzhen_count1"},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "anqi_riyueshenzhen_count2"},
						},
					},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return anqi_riyueshenzhen_trigger

