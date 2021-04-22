--斗罗SKILL 宗门延爆
--宗门武魂争霸
--id 51344
--通用 主体
--[[
全员DEBUFF
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmwh_boss_shouwuhun_third2 = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
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
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBPlayAnimation",
											-- OPTIONS = {animation = "attack08"},
										},
										{
											CLASS = "action.QSBAttackFinish"
										},
									},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 1},
										},
										{
											CLASS = "composite.QSBParallel",
											ARGS =
											{
												{
													CLASS = "action.QSBApplyBuffMultiple",
													OPTIONS = {target_type = "teammate", buff_id = "zmwh_boss_qiwuhun_third2_debuff"},
												}, 
												{
													CLASS = "action.QSBApplyBuffMultiple",
													OPTIONS = {target_type = "enemy", buff_id = "zmwh_boss_qiwuhun_third2_debuff"},
												}, 
												{
													CLASS = "action.QSBApplyBuffMultiple",
													OPTIONS = {target_type = "teammate", buff_id = "zmwh_boss_qiwuhun_third2_yujing"},
												}, 
												{
													CLASS = "action.QSBApplyBuffMultiple",
													OPTIONS = {target_type = "enemy", buff_id = "zmwh_boss_qiwuhun_third2_yujing"},
												}, 
											},
										},
										{
											CLASS = "action.QSBApplyBuff",
											OPTIONS = {buff_id = "zmwh_boss_qiwuhun_second2_buff"},
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

return zmwh_boss_shouwuhun_third2