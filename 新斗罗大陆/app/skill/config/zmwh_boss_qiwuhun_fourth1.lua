--斗罗SKILL 回字封锁
--宗门武魂争霸
--id 51402
--通用 主体/上下头
--[[
主体简单动作和实际释放
上下头长动作
]]--
--创建人：庞圣峰
--创建时间：2019-1-24

local zmwh_boss_qiwuhun_fourth1 = 
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
											OPTIONS = {animation = "attack07"},
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
											OPTIONS = {delay_frame = 10},
										},
										{
											CLASS = "action.QSBTrap",  
											OPTIONS = 
											{ 
												trapId = "zmwh_boss_tongyong_huizikuang",
												args = 
												{
													{pos = { x = 800, y = 300}} ,
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
											OPTIONS = {delay_time = 7},
										},
										{
											CLASS = "action.QSBTriggerSkill",
											OPTIONS = {skill_id = 51403, wait_finish = false},
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
									OPTIONS = {is_attacker = true,status = "zmwh_boss_up"},
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
															OPTIONS = {animation = "attack07"},
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
															OPTIONS = {delay_frame = 80},
														},
														{
															CLASS = "composite.QSBParallel",
															ARGS = {
																{
																	CLASS = "action.QSBTrap",  
																	OPTIONS = 
																	{ 
																		trapId = "zmwh_boss_tongyong_second1_trap1",
																		args = 
																		{
																			{delay_time = 3 / 24 , pos = { x = 910, y = 500}} ,
																			{delay_time = 6 / 24 , pos = { x = 720, y = 500}} ,
																			{delay_time = 9 / 24 , pos = { x = 530, y = 500}} ,
																			{delay_time = 12 / 24 , pos = { x = 340, y = 500}},
																			{delay_time = 15 / 24 , pos = { x = 150, y = 500}} ,
																			{delay_time = 0 , pos = { x = 1100, y = 500}} ,
																			{delay_time = 0 , pos = { x = 1100, y = 200}} ,
																		},
																	},
																},
																{
																	CLASS = "action.QSBTrap",  
																	OPTIONS = 
																	{ 
																		trapId = "zmwh_boss_tongyong_second1_trap2",
																		args = 
																		{
																			{delay_time = 3 / 24 , pos = { x = 910, y = 500}} ,
																			{delay_time = 6 / 24 , pos = { x = 720, y = 500}} ,
																			{delay_time = 9 / 24 , pos = { x = 530, y = 500}} ,
																			{delay_time = 12 / 24 , pos = { x = 340, y = 500}},
																			{delay_time = 15 / 24 , pos = { x = 150, y = 500}} ,
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
															CLASS = "action.QSBDelayTime",
															OPTIONS = {delay_frame = 108},
														},
														{
															CLASS = "composite.QSBParallel",
															ARGS = {
																{
																	CLASS = "action.QSBTrap",  
																	OPTIONS = 
																	{ 
																		trapId = "zmwh_boss_tongyong_second1_trap3",
																		args = 
																		{
																			{delay_time = 8 / 24 , pos = { x = 110, y = 228}} ,
																			{delay_time = 11 / 24 , pos = { x = 110, y = 310}} ,
																			{delay_time = 11 / 24 , pos = { x = 110, y = 392}} ,
																		},
																	},
																},
																{
																	CLASS = "action.QSBTrap",  
																	OPTIONS = 
																	{ 
																		trapId = "zmwh_boss_tongyong_second1_trap4",
																		args = 
																		{
																			{delay_time = 8 / 24 , pos = { x = 110, y = 228}} ,
																			{delay_time = 11 / 24 , pos = { x = 110, y = 310}} ,
																			{delay_time = 11 / 24 , pos = { x = 110, y = 392}} ,
																		},
																	},
																},
															},
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
															OPTIONS = {animation = "attack07"},
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
															OPTIONS = {delay_frame = 80},
														},
														{
															CLASS = "composite.QSBParallel",
															ARGS = {
																{
																	CLASS = "action.QSBTrap",  
																	OPTIONS = 
																	{ 
																		trapId = "zmwh_boss_tongyong_second1_trap1",
																		args = 
																		{
																			{delay_time = 3 / 24 , pos = { x = 910, y = 140}} ,
																			{delay_time = 6 / 24 , pos = { x = 720, y = 140}} ,
																			{delay_time = 9 / 24 , pos = { x = 530, y = 140}} ,
																			{delay_time = 12 / 24 , pos = { x = 340, y = 140}},
																			{delay_time = 15 / 24 , pos = { x = 150, y = 140}} ,
																		},
																	},
																},
																{
																	CLASS = "action.QSBTrap",  
																	OPTIONS = 
																	{ 
																		trapId = "zmwh_boss_tongyong_second1_trap2",
																		args = 
																		{
																			{delay_time = 3 / 24 , pos = { x = 910, y = 140}} ,
																			{delay_time = 6 / 24 , pos = { x = 720, y = 140}} ,
																			{delay_time = 9 / 24 , pos = { x = 530, y = 140}} ,
																			{delay_time = 12 / 24 , pos = { x = 340, y = 140}},
																			{delay_time = 15 / 24 , pos = { x = 150, y = 140}} ,
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
															CLASS = "action.QSBDelayTime",
															OPTIONS = {delay_frame = 108},
														},
														{
															CLASS = "composite.QSBParallel",
															ARGS = {
																{
																	CLASS = "action.QSBTrap",  
																	OPTIONS = 
																	{ 
																		trapId = "zmwh_boss_tongyong_second1_trap3",
																		args = 
																		{
																			{delay_time = 8 / 24 , pos = { x = 870, y = 228}} ,
																			{delay_time = 11 / 24 , pos = { x = 870, y = 310}} ,
																			{delay_time = 14 / 24 , pos = { x = 870, y = 392}} ,
																			{delay_time = 8 / 24 , pos = { x = 1070, y = 228}} ,
																			{delay_time = 11 / 24 , pos = { x = 1070, y = 310}} ,
																			{delay_time = 14 / 24 , pos = { x = 1070, y = 392}} ,
																		},
																	},
																},
																{
																	CLASS = "action.QSBTrap",  
																	OPTIONS = 
																	{ 
																		trapId = "zmwh_boss_tongyong_second1_trap4",
																		args = 
																		{
																			{delay_time = 8 / 24 , pos = { x = 870, y = 228}} ,
																			{delay_time = 11 / 24 , pos = { x = 870, y = 310}} ,
																			{delay_time = 14 / 24 , pos = { x = 870, y = 392}} ,
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

return zmwh_boss_qiwuhun_fourth1