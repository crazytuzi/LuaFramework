-- 技能 霸王龙大招
-- 技能ID 52182
--[[
	hunling 霸王龙
	ID:3950
	psf 2019-11-11
]]--
local boss_bawanglong_dazhao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
		--跳
		{
			CLASS = "composite.QSBParallel",
			ARGS = {       
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "jump"},
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
							CLASS = "action.QSBCharge",
							OPTIONS = {pos = {x = 1000,y = 350},move_time = 0.8},
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
							},
						},
						{
							CLASS = "action.QSBRoledirection",
							OPTIONS = {direction = "left"},
						},
					},
				},
			},
		},
		--吼
		{
			 CLASS = "composite.QSBParallel",
			 ARGS = {
				{
					CLASS = "action.QSBPlaySound"
				},
				{
					CLASS = "action.QSBPlayAnimation",
				},
				{
					CLASS = "composite.QSBSequence",
					 ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 11 },
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "hl_bawanglong_attack11_1_1",is_hit_effect = false},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					 ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 30 },
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "hl_bawanglong_attack11_1",is_hit_effect = false},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					 ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 36 },
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBHitTarget",
								},
								{
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "hl_bawanglong_attack11_3", pos  = {x = 650 , y = 400}, ground_layer = false},
                                },
								{
									CLASS = "action.QSBShakeScreen",
									OPTIONS = {amplitude = 30, duration = 0.2, count = 10,},
								},
							},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					 ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 117 },
						},
						{
							CLASS = "action.QSBAttackFinish"
						},
					},
				},
			},
		},
	},
}

return boss_bawanglong_dazhao