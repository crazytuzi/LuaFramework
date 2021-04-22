-- 技能 暴龙之王咆哮
-- 技能ID 53328
--[[
	暴龙之王 4127
	升灵台"巨兽沼泽"
]]--
--psf 2020-6-22

local shenglt_baolongzhiwang_paoxiao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "action.QSBUncancellable",
		},
		--朝向
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
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "shenglt_baolongzhiwang_hungry_debuff"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "shenglt_baolongzhiwang_carrion_debuff",remove_all_same_buff_id = true},
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
							OPTIONS = {delay_frame = 115 },
						},
						{
							CLASS = "action.QSBArgsConditionSelector",
							OPTIONS = {
								failed_select = 2,
								{expression = "self:shenglt_hunt", select = 1},
							}
						},
						{
							CLASS = "composite.QSBSelector",
							ARGS = {
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "shenglt_baolongzhiwang_hunt_buff"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = {"shenglt_baolongzhiwang_hunt_buff","shenglt_baolongzhiwang_hungry_debuff","shenglt_baolongzhiwang_carrion_debuff"}},
								},
							},
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

return shenglt_baolongzhiwang_paoxiao