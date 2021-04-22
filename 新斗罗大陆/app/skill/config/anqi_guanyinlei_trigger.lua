-- 技能 暗器 观音泪触发技
-- 技能ID 40358~40362
-- 放子弹
--[[
	暗器 观音泪
	ID:1522
	psf 2019-4-29
]]--

local anqi_guanyinlei_trigger = 
{
	 CLASS = "composite.QSBSequence",
	 ARGS = 
	 {
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false},
		},
		{
			CLASS = "action.QSBBullet",
			OPTIONS = {flip_follow_y = true,start_pos = {x = 100,y = 100},},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "anqi_guanyinlei_count_cd", all_enemy = true},
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "guanyinlei_attack01_4_3", is_hit_effect = true},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "anqi_guanyinlei_count_buff", enemy = true, remove_all_same_buff_id = true},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_guanyinlei_trigger

