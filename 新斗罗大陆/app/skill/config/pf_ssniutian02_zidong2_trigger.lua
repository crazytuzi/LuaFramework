-- 技能 牛天自动1反击伤害、护盾
-- 技能ID 550
-- 伤害敌方，护盾友方，根据BUFF储量加成，同时触发551
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local pf_ssniutian02_zidong2_trigger = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "pf_ssniutian02_attack14_1", is_hit_effect = false},
		},
		{
			CLASS = "action.QSBDecreaseHpByAbsorb",
			OPTIONS = {buff_id = "pf_sstianqingniumang02_zidong2_buff", is_by_save_damage = true, save_damage_percent = 1, target_enemy = true, single_max_percent = 0.25},
		},
		{
			CLASS = "action.QSBAddAbsorb",
			OPTIONS = {buff_id = "pf_sstianqingniumang02_zidong2_buff", save_damage_percent = 1, absorb_buff_id = "pf_sstianqingniumang02_zidong2_shield_buff;y", just_hero = true, single_max_percent = 0.25,multiple_target_with_skill = true},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "pf_sstianqingniumang02_zidong2_buff"},
		},
		-- {
		-- 	CLASS = "action.QSBRemoveBuff",
		-- 	OPTIONS = {buff_id = "pf_sstianqingniumang02_zidong2_buff1"},
		-- },
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return pf_ssniutian02_zidong2_trigger

