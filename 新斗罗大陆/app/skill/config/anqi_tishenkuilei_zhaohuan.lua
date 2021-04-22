-- 技能 火种召唤
-- ID 190103
-- 召唤火种40006
--[[
	马红俊
	ID:1016
	psf 2018-11-20
]]--
local anqi_tishenkuilei_zhaohuan = {
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
						actor_id = 3840, life_span = 5,number = 1, no_fog = true, use_render_texture = false, 
						relative_pos = {x=400,y=0},appear_skill = 40265,
						is_attacked_ghost = true,
						enablehp = true,
						percents = {armor_physical = 1, armor_magic = 1},
						hp_percent = 0.4
					},
				},
				{
					CLASS = "action.QSBSummonGhosts",
					OPTIONS = {
						actor_id = 3840, life_span = 5,number = 1, no_fog = true, use_render_texture = false,
						relative_pos = {x=-400,y=0},appear_skill = 40265,
						is_attacked_ghost = true,
						enablehp = true,
						percents = {armor_physical = 1, armor_magic = 1},
						hp_percent = 0.4
					},
				},
			},
		},
		{
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return anqi_tishenkuilei_zhaohuan

