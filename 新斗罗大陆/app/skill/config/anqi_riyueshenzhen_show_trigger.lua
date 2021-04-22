-- 技能 暗器 日月神针重置CD
-- 技能ID 40662
-- 根据anqi_riyueshenzhen_yue_buff判断添加anqi_riyueshenzhen_count1或2 (所持神针表现)
-- 移除anqi_riyueshenzhen_buff_1~5 (神针冷却BUFF)
--[[
	暗器 日月神针
	ID:1531
	psf 2020-6-2
]]--

local anqi_guijianchou_trigger1 = 
{
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBRemoveBuffByStatus",	
			OPTIONS = {status = "riyueshenzhen_cd"},
		},
		{
			CLASS = "action.QSBPlayMountSkillAnimation",
		},
		{
			CLASS = "action.QSBArgsConditionSelector",
			OPTIONS = {
				failed_select = 1,
				{expression = "self:has_buff:anqi_riyueshenzhen_yue_buff", select = 2},
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
}

return anqi_guijianchou_trigger1

