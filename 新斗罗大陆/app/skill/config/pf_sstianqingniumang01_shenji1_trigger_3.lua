-- 技能 牛天神技降龙
-- 技能ID 39052~39056
-- 随机友方范围护盾
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local pf_sstianqingniumang01_shenji1_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "action.QSBClearBuffSaveValue",
			OPTIONS = {buff_id = "pf_sstianqingniumang01_shenji1_buff_3", is_save_treat = true},
		},
		{
			CLASS = "action.QSBArgsSelectTarget", 
			OPTIONS = 
			{ is_teammate = true, include_self = true, just_hero = true, args_translate = {selectTarget = "options_target"}},
		},
		{
			CLASS = "action.QSBTrapMultiple", 
			OPTIONS = 
			{ 
				args = 
				{
					{trapId = "pf_sstianqingniumang01_shenji1_trap", relative_pos = { x = 0, y = 0}} ,
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
			CLASS = "action.QSBAddAbsorb",
			OPTIONS = {buff_id = "", hp_percent = 0.5, absorb_buff_id = "pf_sstianqingniumang01_shenji1_shield_buff_3", just_hero = true,single_max_percent = 0.5},
		},
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return pf_sstianqingniumang01_shenji1_trigger