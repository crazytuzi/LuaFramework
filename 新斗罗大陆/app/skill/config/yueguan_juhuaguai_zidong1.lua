-- 技能 菊花怪 菊花分株
-- ID 270
-- 召唤两个40002
--[[
	hero 月关的菊花怪
	ID:1019
	psf 2018-7-24
]]--
local yueguan_juhuaguai_zidong1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBPlayAnimation",
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
		{
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 31},
				},
				{
					CLASS = "action.QSBSummonGhosts",
					OPTIONS = {
						actor_id = 40002, life_span = 10,number = 1, no_fog = true, use_render_texture = false, --入场动作1.7+0.3秒,持续8秒,共10秒
						relative_pos = {x=50,y=75},
						is_attacked_ghost = false,trace_to_the_source = true, appear_skill = 271, dead_skill = 190078,
						percents = {attack = 0.5, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1},
						extends_level_skills = {271}
					},
				},
				{
					CLASS = "action.QSBSummonGhosts",
					OPTIONS = {
						actor_id = 40002, life_span = 10,number = 1, no_fog = true, use_render_texture = false,
						relative_pos = {x=-50,y=-75},
						is_attacked_ghost = false,trace_to_the_source = true,  appear_skill = 271, dead_skill = 190078,
						percents = {attack = 0.5, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1},
						extends_level_skills = {271}
					},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "yueguan_zidong1_direct"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "yueguan_zidong1_direct"},
				},
			},
		},
    },
}

return yueguan_juhuaguai_zidong1

