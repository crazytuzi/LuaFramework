--斗罗SKILL 器武魂宗门冲击波
--宗门武魂争霸
--id 51347
--通用 上下头
--[[
根据上下头决定上下屏
概率有所偏移
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmwh_boss_qiwuhun_first0 = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
    {  
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false},
		},
		{
			CLASS = "action.QSBPlaySound"
		},
		------根据上下头决定激光上下屏
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
					----上头射上面
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 0.8},
										},
										{
											CLASS = "action.QSBPlayAnimation",
											OPTIONS = {animation = "attack06",no_stand = true},
										},
									},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 26},
										},
										{
											CLASS = "action.QSBTrap",  
											OPTIONS = 
											{ 
												trapId = "zmwh_boss_tongyong_hongkuang",
												args = 
												{
													{delay_time = 0 , pos = { x = 1000, y = 425}} ,
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
											OPTIONS = {delay_time = 2.8},
										},
										{
											CLASS = "action.QSBBullet",
											OPTIONS = {effect_id = "zmwh_boss_qiuwuhun_attack06_2_2",is_tornado = true, tornado_size = {width = 100, height = 220}, 
											start_pos = {x = 1000, y = 450, global = true}, speed = 1200, 
											sort_layer_with_actor = true},
										},
									},
								},					
								{
									 CLASS = "composite.QSBSequence",
									 ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 3.5},
										},
										{
											CLASS = "action.QSBPlayAnimation",
											OPTIONS = {animation = "attack06_2",no_stand = true},
										},
										{
											CLASS = "action.QSBAttackFinish"
										},
									},
								},
							},
						},
						----下头射下面
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 0.8},
										},
										{
											CLASS = "action.QSBPlayAnimation",
											OPTIONS = {animation = "attack06",no_stand = true},
										},
									},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_frame = 26},
										},
										{
											CLASS = "action.QSBTrap",  
											OPTIONS = 
											{ 
												trapId = "zmwh_boss_tongyong_hongkuang",
												args = 
												{
													{delay_time = 0 , pos = { x = 1000, y = 250}} ,
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
											OPTIONS = {delay_time = 2.8},
										},
										{
											CLASS = "action.QSBBullet",
											OPTIONS = {effect_id = "zmwh_boss_qiuwuhun_attack06_2_1",is_tornado = true, tornado_size = {width = 100, height = 190}, 
											start_pos = {x = 1000, y = 265, global = true}, speed = 1200, 
											sort_layer_with_actor = true},
										},
									},
								},					
								{
									 CLASS = "composite.QSBSequence",
									 ARGS = {
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 3.5},
										},
										{
											CLASS = "action.QSBPlayAnimation",
											OPTIONS = {animation = "attack06_2",no_stand = true},
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

return zmwh_boss_qiwuhun_first0