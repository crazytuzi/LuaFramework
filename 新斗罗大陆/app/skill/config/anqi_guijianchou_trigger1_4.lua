-- 技能 暗器 释放飞弹
-- 技能ID 40520~40524
-- 开始放飞弹
--[[
	暗器 鬼见愁
	ID:1528
	psf 2020-1-17
]]--


local anqi_guijianchou_trigger1 = 
{
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBRemoveBuff",	
			OPTIONS = {buff_id = "anqi_guijianchou_plus_count", remove_all_same_buff_id = true, enemy = true},
		},
		{
			CLASS = "action.QSBApplyBuff",	
			OPTIONS = {buff_id = "anqi_guijianchou_buff1"},
		},
		{
			CLASS = "action.QSBPlayMountSkillAnimation",
		},
		{
			CLASS = "action.QSBTriggerSkill",	
			OPTIONS = {skill_id = 40533, wait_finish = false},
		},
		{
			CLASS = "action.QSBDelayTime",
			OPTIONS = {delay_time = 0.1},
		},
		{
			CLASS = "action.QSBTriggerSkill",	
			OPTIONS = {skill_id = 40533, wait_finish = false},
		},
		{
			CLASS = "action.QSBDelayTime",
			OPTIONS = {delay_time = 0.2},
		},
		{
			CLASS = "action.QSBTriggerSkill",	
			OPTIONS = {skill_id = 40533, wait_finish = false},
		},
		{
			CLASS = "action.QSBDelayTime",
			OPTIONS = {delay_time = 0.1},
		},
		{
			CLASS = "action.QSBTriggerSkill",	
			OPTIONS = {skill_id = 40533, wait_finish = false},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_guijianchou_trigger1

