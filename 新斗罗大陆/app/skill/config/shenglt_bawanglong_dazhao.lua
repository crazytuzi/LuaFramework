-- 技能 霸王龙大招
-- 技能ID 53308
--[[
	霸王龙 4120
	升灵台
	psf 2020-4-13
]]--
local shenglt_bawanglong_dazhao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
		--跳
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{
				{
					CLASS = "action.QSBArgsIsLeft",
					OPTIONS = {is_attacker = true},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "action.QSBRoledirection",
							OPTIONS = {direction = "right"},
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
							OPTIONS = {effect_id = "shenglt_bawanglong_attack11_1_1",is_hit_effect = false},
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
							OPTIONS = {effect_id = "shenglt_bawanglong_attack11_1",is_hit_effect = false},
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
									CLASS = "composite.QSBSequence",
										ARGS = {
										{
											CLASS = "action.QSBHitTarget",
										},
										{
											CLASS = "action.QSBRemoveBuff",
											OPTIONS = {buff_id = "shenglt_bawanglong_dazhao_buff"},
										},
									},
								},
								{
									CLASS = "action.QSBPlaySceneEffect",
									OPTIONS = {effect_id = "shenglt_bawanglong_attack11_3", pos  = {x = 650 , y = 400}, ground_layer = false},
								},
								{
									CLASS = "action.QSBShakeScreen",
									OPTIONS = {amplitude = 12, duration = 0.2, count = 10,},
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

return shenglt_bawanglong_dazhao