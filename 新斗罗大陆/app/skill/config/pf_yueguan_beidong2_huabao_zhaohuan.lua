-- 技能 月关 满地伤花苞召唤
-- ID 275
-- 再自己位置召唤40002,然后自杀
--[[
	hero 月关花苞
	ID:40003
	psf 2018-7-24
]]--
local yueguan_beidong2_huabao_zhaohuan = 
{
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "yueguan_beidong2_count"},
		},
		{
			CLASS = "action.QSBDelayTime",
			OPTIONS = {delay_frame = 3},
		},
		{
			CLASS = "action.QSBSummonGhosts",
			OPTIONS = {
				actor_id = 40002,skin_id = 21, life_span = 9.5,number = 1, no_fog = true, use_render_texture = false, --入场动作1.2+0.3秒,数值持续8秒,共9.5秒
				relative_pos = {x=0,y=0},
				is_attacked_ghost = false,trace_to_the_source = true,--[[Ghost召唤的Ghost从属于最初召唤者]] appear_skill = 200276, dead_skill = 290078,
				percents = {attack = 0.5, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1},
				extends_level_skills = {200276}
			},
		},
		{
			CLASS = "action.QSBSuicide",
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return yueguan_beidong2_huabao_zhaohuan 

