-- 技能 象甲宗冲锋跳跃
-- 技能ID 50352
-- 跳向目标造成AOE伤害
--[[
	boss 象甲宗
	ID:3282 副本6-4
	psf 2018-3-30
]]--

local boss_xiangjiazong_jump = {
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attacker = true, reverse_result = true, status = "berserk"},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = 
			{
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBPlaySound",
								},        
								{
									CLASS = "action.QSBPlayAnimation",
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
											OPTIONS = {move_time = 0.6},
										},
										{
											 CLASS = "action.QSBHitTarget",
										},
										{
											CLASS = "action.QSBAttackFinish",
										},
									},
								},
							},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
			},
		},
	},
}

return boss_xiangjiazong_jump