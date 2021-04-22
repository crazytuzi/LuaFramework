--斗罗SKILL 宗门禁锢
--宗门武魂争霸
--id 51350
--通用 主体
--[[
牢笼
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmwh_boss_qiwuhun_third1 = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
        {
            CLASS = "action.QSBLockTarget",     --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true},
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBArgsIsUnderStatus",
					OPTIONS = {is_attacker = true,status = "zmwh_boss"},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						----主体
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBPlayAnimation",
									-- OPTIONS = {animation = "attack08"},
								},
								{
									CLASS = "action.QSBPlaySound"
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = 
									{
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 1 },
										},
										{
											CLASS = "action.QSBApplyBuff",
											OPTIONS = {is_target = true, buff_id = "zmwh_boss_qiwuhun_third1_debuff"},
										}, 
										{
											CLASS = "action.QSBSummonGhosts",
											OPTIONS = {actor_id = 61032 , life_span = 4.2,number = 1, appear_skill = 51369 ,dead_skill = 51370, enablehp = true,hp_percent = 0.0001 , relative_pos = {x = 0, y = -25}, no_fog = false,is_attacked_ghost = true},
										},
										{
											CLASS = "action.QSBHitTarget",
										},
										{
											CLASS = "action.QSBLockTarget",
											OPTIONS = {is_lock_target = false},
										},
										{
											CLASS = "action.QSBAttackFinish"
										},
									},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = 
									{
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 1.2 },
										},
										{
											CLASS = "action.QSBShakeScreen",
											OPTIONS = {amplitude = 3, duration = 0.15, count = 1,},
										},
									},
								},
							},
						},
						------
						----上下头
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBArgsIsUnderStatus",
									OPTIONS = {is_attacker = true,status = "zmwh_boss_right"},
								},
								{
									CLASS = "composite.QSBSelector",
									ARGS = {
										--上头
										{
											CLASS = "composite.QSBParallel",
											ARGS = {
												{
													CLASS = "composite.QSBSequence",
													ARGS = {
														{
															CLASS = "action.QSBPlayAnimation",
															-- OPTIONS = {animation = "attack07"},
														},
														{
															CLASS = "action.QSBAttackFinish"
														},
													},
												},
											},
										},
										--下头
										{
											CLASS = "composite.QSBParallel",
											ARGS = {
												{
													CLASS = "composite.QSBSequence",
													ARGS = {
														{
															CLASS = "action.QSBPlayAnimation",
															-- OPTIONS = {animation = "attack07"},
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
						------
					},
				},
			},
		},
        
    },
}

return zmwh_boss_qiwuhun_third1