-- 技能 暗器 煞影索命 配件伤害
-- 技能ID 40550~40554
-- 造成debuff储存量X%的伤害,并附带伤势,有上限; 若伤害低于Y%,触发一次主力效果
--[[
	暗器 鬼见愁
	ID:1528
	psf 2020-1-17
]]--

local anqi_guijianchou_damage = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBPlayMountSkillAnimation",
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "anqi_guijianchou_peijian_trigger_deubff_3"},
		},
		{
			CLASS = "action.QSBGuiJianChou",
			OPTIONS = {buff_id = "anqi_guijianchou_debuff",damage_percent = 0.2,limit_percent = 3,base_attack_percent = 0.2,
			recover_hp_limit_percent = 1, percent = 0.365,--[[伤害低于伤害上限的50%则触发技能]] trigger_skill_id = 40547, clear_save_treat = false}
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = true},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_guijianchou_damage
