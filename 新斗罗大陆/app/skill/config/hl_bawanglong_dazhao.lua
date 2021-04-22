-- 技能 霸王龙大招
-- 技能ID 35113~35117
--[[
	hunling 霸王龙
	ID:2011
	psf 2019-11-11
]]--
local hl_bawanglong_dazhao = 
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
							CLASS = "action.QSBArgsPosition",
							OPTIONS = {is_attacker = true ,enter_stop_position = true},
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
							},
						},
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
			},
		},
		--吼
		{
			 CLASS = "composite.QSBParallel",
			 ARGS = {
				{
					CLASS = "composite.QSBSequence",
					OPTIONS = {forward_mode = true,},   --不会打断特效
					ARGS = 
					{
						{
							CLASS = "action.QSBShowActor",
							OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
						},
						{
							CLASS = "action.QSBBulletTime",
							OPTIONS = {turn_on = true, revertable = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 38},
						},
						{
							CLASS = "action.QSBBulletTime",
							OPTIONS = {turn_on = false},
						},
						{
							CLASS = "action.QSBShowActor",
							OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
						},

					},
				},
				{               --竞技场黑屏
					CLASS = "composite.QSBSequence",
					OPTIONS = {forward_mode = true,},   --不会打断特效
					ARGS = 
					{
						{
							CLASS = "action.QSBShowActorArena",
							OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
						},
						{
							CLASS = "action.QSBBulletTimeArena",
							OPTIONS = {turn_on = true, revertable = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 38},
						},
						{
							CLASS = "action.QSBBulletTimeArena",
							OPTIONS = {turn_on = false},
						},
						{
							CLASS = "action.QSBShowActorArena",
							OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
						},

					},
				},
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
									CLASS = "composite.QSBSequence",
									 ARGS = {
										{
											CLASS = "action.QSBHitTarget",
										},
										{
											CLASS = "action.QSBRemoveBuff",
											OPTIONS = {buff_id = "hl_bawanglong_dazhao_buff"},
										},
									},
								},
								{
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "hl_bawanglong_attack11_3", pos  = {x = 650 , y = 400}, ground_layer = false},
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

return hl_bawanglong_dazhao