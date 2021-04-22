-- 技能 霸王龙跳
-- 技能ID 52181
--[[
	hunling 霸王龙
	ID:3950
	psf 2019-11-11
]]--
local boss_bawanglong_jump = 
{
	CLASS = "composite.QSBParallel",
	ARGS = {       
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "hl_bawanglong_attack12_1", is_hit_effect = false},
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "hl_bawanglong_attack12_1_1", is_hit_effect = false},
		},
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{
				{
					CLASS = "action.QSBArgsPosition",
					OPTIONS = {is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 1, pass_key = {"pos"}},
				},
				{
					CLASS = "action.QSBCharge",
					OPTIONS = {move_time = 0.8},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {       
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "hl_bawanglong_attack12_3", is_hit_effect = false},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "hl_bawanglong_attack12_3_1", is_hit_effect = false},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "boss_hl_bawanglong_highest_rage_mark",enemy = true},
						},
						{
							 CLASS = "action.QSBHitTarget",
						},
					},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return boss_bawanglong_jump