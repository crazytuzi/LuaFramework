-- 技能 暗器 月蚀引爆
-- 技能ID 40661
-- 移除anqi_riyueshenzhen_yueshi_debuff结算伤害
--[[
	暗器 日月神针
	ID:1531
	psf 2020-6-2
]]--

local anqi_riyueshenzhen_yueshi_trigger = 
{
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBDecreaseHpByAbsorb",	
			OPTIONS = {buff_id = "anqi_riyueshenzhen_yueshi_debuff", is_by_save_damage = true, save_damage_percent = 0.1,is_single_buff = true},
		},
		{
			CLASS = "action.QSBClearBuffSaveValue",	
			OPTIONS = {buff_id = "anqi_riyueshenzhen_yueshi_debuff", is_save_damage = true},
		},
		{
			CLASS = "action.QSBRemoveBuff",	
			OPTIONS = {buff_id = "anqi_riyueshenzhen_yueshi_debuff", remove_all_same_buff_id = true},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_riyueshenzhen_yueshi_trigger

