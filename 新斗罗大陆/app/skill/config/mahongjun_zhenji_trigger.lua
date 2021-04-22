-- 技能 火种召唤
-- ID 190103
-- 召唤火种40006
--[[
	马红俊
	ID:1016
	psf 2018-11-20
]]--
local mahongjun_zhenji_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "action.QSBArgsIsLeft",
			OPTIONS = {is_attacker = true},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {
				{
					CLASS = "action.QSBSummonGhosts",
					OPTIONS = {
						actor_id = 40006, life_span = 180,number = 1, no_fog = true, use_render_texture = false, 
						relative_pos = {x=150,y=0},appear_skill = 50181,
						is_attacked_ghost = false,trace_to_the_source = true,
						percents = {attack = 1,  magic_damage_percent_attack = 1},
					},
				},
				{
					CLASS = "action.QSBSummonGhosts",
					OPTIONS = {
						actor_id = 40006, life_span = 180,number = 1, no_fog = true, use_render_texture = false,
						relative_pos = {x=-150,y=0},appear_skill = 50181,
						is_attacked_ghost = false,trace_to_the_source = true,
						percents = {attack = 1,  magic_damage_percent_attack = 1},
					},
				},
			},
		},
		{
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return mahongjun_zhenji_trigger

