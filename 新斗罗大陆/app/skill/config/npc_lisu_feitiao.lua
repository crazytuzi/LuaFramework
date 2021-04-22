local npc_lisu_feitiao = 
{
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
					CLASS = "composite.QSBParallel",
					ARGS =
					{ 
						{
							CLASS = "action.QSBPlayAnimation",
							OPTIONS = {animation = "attack01"},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								-- {
								-- 	CLASS = "action.QSBSelectTarget",
								-- 	OPTIONS = {range_max = true},
								-- },
						        {
						            CLASS = "action.QSBArgsPosition",
						            OPTIONS = {is_attackee = true},
						        },
								-- {
						            -- CLASS = "action.QSBMultipleTrap",
						            -- OPTIONS = {trapId = "boss_tielong_chuidi_trap",count = 1, pass_key = {"pos"}},
						        -- },
								{
						            CLASS = "action.QSBDelayTime",
						            OPTIONS = {delay_frame = 10, pass_key = {"pos"}},
						        },
								{
									CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
									OPTIONS = {move_time = 0.5},
								},
								-- {
								-- 	CLASS = "action.QSBShakeScreen", 
								-- },
								{
						            CLASS = "action.QSBDelayTime",
						            OPTIONS = {delay_frame = 20,},
						        },
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
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
						            CLASS = "action.QSBDelayTime",
						            OPTIONS = {delay_frame = 23},
						        },
								{
									 CLASS = "action.QSBHitTarget",
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true},
								},
							},
						},	
					},
				},
			},
		},
	},
}
return npc_lisu_feitiao