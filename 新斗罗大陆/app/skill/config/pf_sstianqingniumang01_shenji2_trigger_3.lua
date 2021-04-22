-- 技能 牛天神技升龙
-- 技能ID 39057~39061
-- 随机敌方范围击飞
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local pf_sstianqingniumang01_shenji2_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "action.QSBClearBuffSaveValue",
			OPTIONS = {buff_id = "pf_sstianqingniumang01_shenji2_buff_3", is_save_damage = true},
		},
		{
			CLASS = "action.QSBArgsSelectTarget", 
			OPTIONS = 
			{ just_hero = true, args_translate = {selectTarget = "options_target"}},
		},
		{
			CLASS = "action.QSBTrapMultiple", 
			OPTIONS = 
			{ 
				args = 
				{
					{trapId = "pf_sstianqingniumang01_shenji2_trap", relative_pos = { x = 0, y = 0}} ,
				},
				pass_key = {"options_target"},
			},
		},
		{
			CLASS = "action.QSBArgsFindTargets", 
			OPTIONS = 
			{ multiple_target_with_skill = true, args_translate = {selectTargets = "targets"}},
		},
		{
			CLASS = "action.QSBDecreaseHpByAbsorb",
			OPTIONS = {buff_id = "",  is_max_hp_percent = true, coefficient = 0.3, single_max_percent = 0.5},
		},
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return pf_sstianqingniumang01_shenji2_trigger