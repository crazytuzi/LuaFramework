-- 技能 霸王龙跳跃
-- 技能ID 31005
--[[
	hunling 霸王龙
	ID:2011
	psf 2019-11-11
]]--
local hl_bawanglong_jump = 
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
		            CLASS = "action.QSBChargeToTarget",
		            OPTIONS = {is_position = true,  scale_actor_face = 1, move_time = 0.8},
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
							OPTIONS = {buff_id = "hl_bawanglong_highest_rage_mark",enemy = true},
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

return hl_bawanglong_jump