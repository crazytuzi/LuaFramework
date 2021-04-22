-- 技能 冰天雪女召唤冰晶
-- 技能ID 53318
-- 召唤放置陷阱的NPC
--[[
	冰天雪女
	升灵台
	ID:4125 
	psf 2020-4-13
]]--

local shenglt_bingtianxuenv_zhaohuan = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "action.QSBArgsRandom",
			OPTIONS = {
				input = {
					datas = {
						{x = 350, y = 325},{x = 350, y = 250},{x = 350, y = 175},{x = 350, y = 250},
						{x = 650, y = 250},{x = 650, y = 350},{x = 650, y = 150},{x = 650, y = 175}
					},
				},
				output = {output_type = "data"},
				args_translate = { select = "absolute_pos"}
			},
		},
		{
			CLASS = "action.QSBSummonGhosts",
			OPTIONS = {actor_id = 4126, life_span = 6,number = 1, no_fog = true, use_render_texture = false, 
			percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return shenglt_bingtianxuenv_zhaohuan