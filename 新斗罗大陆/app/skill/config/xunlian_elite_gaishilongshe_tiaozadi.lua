-- 技能 BOSS盖世龙蛇跳砸地
-- 跳目标造成AOE伤害
--[[
	boss 盖世龙蛇
	ID:3246 副本2-4
	psf 2018-3-22
]]--

local boss_gaishilongshe_tiaozadi = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBPlaySound",
		}, 
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{		
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack16"},
					ARGS = 
					{
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
									CLASS = "action.QSBShakeScreen",
									OPTIONS = {amplitude = 35, duration = 0.2, count = 1,},
								},
							},
						},
					},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},	
		},
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {revertable = true},
			ARGS = 
			{
                {
                    CLASS = "action.QSBArgsPosition",
                    OPTIONS = {is_attackee = true},
                },
				{
                    CLASS = "action.QSBMultipleTrap",
                    OPTIONS = {trapId = "boss_gaishilongshe_tiaozadi_circle",count = 1, pass_key = {"pos"}},
                },
				{
                    CLASS = "action.QSBDelayTime", 
                    OPTIONS = {delay_frame = 55, pass_key = {"pos"}},
                },
				{
					CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
					OPTIONS = {move_time = 1.25},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				},
			},
		},
	},
}

return boss_gaishilongshe_tiaozadi
