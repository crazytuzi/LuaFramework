-- 技能 月关 悠悠花开被动触发技
-- ID 273
-- 再场上随机位置召唤菊花40001
--[[
	hero 月关
	ID:1018
	psf 2018-7-24
]]--
local yueguan_dazhao = 
{
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBArgsIsLeft",
			OPTIONS = {is_attacker = true},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = 
			{
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBArgsRandom",
							OPTIONS = {
								input = {
									datas = {
										{x = 200, y = 325},{x = 325, y = 325},{x = 200, y = 175},{x = 325, y = 175},
										{x = 450, y = 325},{x = 275, y = 250},{x = 450, y = 175},{x = 400, y = 250},
										{x = 500, y = 250},{x = 575, y = 350},{x = 575, y = 150},{x = 600, y = 325}
									},
								},
								output = {output_type = "data"},
								args_translate = { select = "absolute_pos"}
							},
						},
						{
							CLASS = "action.QSBSummonGhosts",
							OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false, use_render_texture = false,pass_key = {"absolute_pos"}},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 35,pass_key = {"absolute_pos"}},
						},
						{
							CLASS = "action.QSBSummonGhosts",
							OPTIONS = {
								actor_id = 40001, life_span = 10.5,number = 1, no_fog = true, use_render_texture = false,
								is_attacked_ghost = false,--[[不能被选中和攻击]] appear_skill = 268,--[[入场技能]] ai_name = "ghost_yueguan_juhuaguai1", dead_skill = 190078,
								percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
								extends_level_skills = {268}
							},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBArgsRandom",
							OPTIONS = {
								input = {
									datas = {
										{x = 1000, y = 325},{x = 875, y = 325},{x = 1000, y = 175},{x = 875, y = 175},
										{x = 750, y = 325},{x = 950, y = 250},{x = 750, y = 175},{x = 800, y = 250},
										{x = 700, y = 250},{x = 625, y = 350},{x = 625, y = 150},{x = 600, y = 175}
									},
								},
								output = {output_type = "data"},
								args_translate = { select = "absolute_pos"}
							},
						},
						{
							CLASS = "action.QSBSummonGhosts",
							OPTIONS = {
								actor_id = 9999, life_span = 0.001,number = 1, no_fog = false, use_render_texture = false,pass_key = {"absolute_pos"}
							},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 35,pass_key = {"absolute_pos"}},
						},
						{
							CLASS = "action.QSBSummonGhosts",
							OPTIONS = {
								actor_id = 40001, life_span = 10.5,number = 1, no_fog = true, use_render_texture = false,
								is_attacked_ghost = false,--[[不能被选中和攻击]] appear_skill = 268,--[[入场技能]] ai_name = "ghost_yueguan_juhuaguai1", dead_skill = 190078,
								percents = {attack = 0.67, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
								extends_level_skills = {268}
							},
						},
					},
				},
			},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "yueguan_dazhao_trigger_buff"},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return yueguan_dazhao 

