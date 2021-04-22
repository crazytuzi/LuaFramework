-- 技能 暴龙之王普攻
-- 技能ID 53323
--[[
	暴龙之王 4127
	升灵台"巨兽沼泽"
]]--
--psf 2020-6-22

local shenglt_baolongzhiwang_pugong = 
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
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 3,
						{expression = "target:distance>275", select = 1},
						{expression = "self:shenglt_hunt", select = 2},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {  
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "stand" },
								},
								{
									CLASS = "action.QSBAttackFinish"
								},
							},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {  
								{
									CLASS = "action.QSBTriggerSkill",
									OPTIONS = {skill_id = 53325 },
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = 
									{
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 30 },
										},
										{
											CLASS = "action.QSBAttackFinish"
										},
									},
								},
							},
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
									CLASS = "composite.QSBSequence",
									ARGS = 
									{
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 30 },
										},
										{
											CLASS = "action.QSBAttackFinish"
										},
									},
								},
							},
						},
					},
				},
			},
		},
	},
}
return shenglt_baolongzhiwang_pugong