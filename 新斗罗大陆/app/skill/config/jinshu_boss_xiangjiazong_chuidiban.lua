-- 技能 象甲宗锤地板
-- 技能ID 50354
-- AOE,狂暴时不使用
--[[
	boss 象甲宗
	ID:3282 副本6-4
	psf 2018-3-30
]]--

local boss_xiangjiazong_chuidiban = 
  --   CLASS = "composite.QSBSequence",
  --   ARGS = {
  --       {
		-- 	CLASS = "action.QSBArgsIsUnderStatus",
		-- 	OPTIONS = {is_attacker = true, reverse_result = true, status = "berserk"},
		-- },
		-- {
		-- 	CLASS = "composite.QSBSelector",
		-- 	ARGS = 
		-- 	{
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBPlaySound"
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 17/24},
										},
										{
											CLASS = "action.QSBPlayEffect",
											OPTIONS = {is_hit_effect = false},
										},
									},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 17/24},
										},
										{
											CLASS = "action.QSBShakeScreen",
										},
									},
								},
								{
									CLASS = "action.QSBPlayAnimation",
									ARGS = {
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
											},
										},
									},
								},
							},
						},
						{
							CLASS = "action.QSBAttackFinish"
						},
					},
				}
-- 				{
-- 					CLASS = "composite.QSBSequence",
-- 					ARGS = {
-- 						{
-- 							CLASS = "action.QSBAttackFinish",
-- 						},
-- 					},
-- 				},
-- 			},
-- 		},
--     },
-- }

return boss_xiangjiazong_chuidiban