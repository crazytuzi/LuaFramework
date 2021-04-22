-- 技能 霸王龙大招
-- 技能ID 30015~30019
--[[
	hunling 霸王龙
	ID:2011
	psf 2019-11-11
]]--
local hl_bawanglong_pugong = 
{
	 CLASS = "composite.QSBParallel",
	 ARGS = {
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 12 },
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 15 },
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {  
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBPlunderRage",
							OPTIONS = {plunder_rage_percent = 0.14, plunder_rage_max = 16},
						},
					},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 45 },
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "boss_hl_bawanglong_highest_rage_mark",enemy = true},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_hl_bawanglong_highest_rage_mark",highest_rage_enemy = true},
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
		},
	},
}
return hl_bawanglong_pugong