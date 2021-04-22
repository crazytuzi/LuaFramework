
local pf_qiandaoliu_dazhao = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="pf_qiandaoliu03_skill"},
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true},
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBShowActor",              ----黑屏时间开始
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                        },
                        {
                            CLASS = "action.QSBShowActorArena",             ----黑屏时间开始
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBBulletTime",             ----子弹时间开始
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBBulletTimeArena",                ----子弹时间开始
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                    },
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},-- 上免疫控制buff
                },
                {
                    CLASS = "action.QSBLockTarget",     --锁定目标
                    OPTIONS = {is_lock_target = true, revertable = true},
                },
                {
                    CLASS = "action.QSBManualMode",     --进入手动模式
                    OPTIONS = {enter = true, revertable = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "2S_stun", is_target = true},--晕2s
                },
                {
                    CLASS = "action.QSBStopMove",
                },
                {
                    CLASS = "action.QSBApplyBuff",      --加速
                    OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12", is_loop = true, no_stand = true},       
                }, 
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = true}
                },
                {
                    CLASS = "action.QSBChargeToTarget",
                    OPTIONS = {is_position = true,scale_actor_face = 1, speed = 1500},
                },
                {
                    CLASS = "action.QSBRemoveBuff",     --去除加速
                    OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false},
                },
                {
                    CLASS = "action.QSBForbidNormalAttack",    -- 让英雄不普攻
                    OPTIONS = {forbid = true, revertable = true},
                },
                {
                    CLASS = "composite.QSBParallel",
                     ARGS = {
                        {
                            CLASS = "action.QSBBulletTime",                 ---子弹时间结束
                            OPTIONS = {turn_on = false},
                        },
                        {
                            CLASS = "action.QSBBulletTimeArena",                    ---子弹时间结束
                            OPTIONS = {turn_on = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBShowActor",                  ----黑屏结束
                            OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                        },
                        {
                            CLASS = "action.QSBShowActorArena",                 ----黑屏结束
                            OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                        },
                    },
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = {"qiandaoliu_dazhao_buff2"}, is_target = false},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = { 
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "pf_qiandaoliu03_whzs_3", is_hit_effect = false},
                                },         
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 2.6},
                                },
								{
									CLASS = "composite.QSBParallel",
									ARGS = { 
										{
											CLASS = "action.QSBPlayEffect",
											OPTIONS = {effect_id = "pf_qiandaoliu03_attack11_2_1",is_hit_effect = false},
										},
										{
											CLASS = "action.QSBPlayEffect",
											OPTIONS = {effect_id = "pf_qiandaoliu03_attack11_2_2",is_hit_effect = false},
										},
										{
											CLASS = "composite.QSBSequence",
											ARGS = {
												{
													CLASS = "action.QSBArgsIsDirectionLeft",
													OPTIONS = {is_attacker = true},
												},
												{
													CLASS = "composite.QSBSelector",
													ARGS = 
													{
														{
															CLASS = "action.QSBTrap",
															OPTIONS = 
															{ 
																trapId = "pf_qiandaoliu3_dazhao_trap1",
																args = 
																{
																	{delay_time = 0.1 , relative_pos = { x = -240, y = 0}} ,
																	{delay_time = 0.2 , relative_pos = { x = -360, y = 0}} ,
																	{delay_time = 0.3 , relative_pos = { x = -480, y = 0}} ,
																},
															},
														},
														{
															CLASS = "action.QSBTrap",
															OPTIONS = 
															{ 
																trapId = "pf_qiandaoliu3_dazhao_trap2",
																args = 
																{
																	{delay_time = 0.1 , relative_pos = { x = 240, y = 0}} ,
																	{delay_time = 0.2 , relative_pos = { x = 360, y = 0}} ,
																	{delay_time = 0.3 , relative_pos = { x = 480, y = 0}} ,
																},
															},
														},
													},
												},
											},
										},	
										{
											CLASS = "action.QSBShakeScreen",
											OPTIONS = {amplitude = 20, duration = 0.1, count = 3,},
										},										
									},
								},
                            },
                        },
						--扇翅膀
						{
							CLASS = "composite.QSBSequence",
							ARGS = { 
								{
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 12},
                                },
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "pf_qiandaoliu03_attack11_1_2", is_hit_effect = false, haste = true},
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
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "pf_qiandaoliu03_attack11_1_1", is_hit_effect = false, haste = true},
								},
							},
						}, 
						{
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 72},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "pf_qiandaoliu03_attack11_1_3", is_hit_effect = false},
                                },         
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 2.6},
                                },               
                                {
                                    CLASS = "action.QSBHitTarget",
                                },    
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "qiandaoliu_dazhao_buff2", is_target = false},
                                }, 
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },          
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                },                               
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBLockTarget",
                    OPTIONS = {is_lock_target = false},
                },
                {
                    CLASS = "action.QSBManualMode",
                    OPTIONS = {exit = true},
                },
                {
                    CLASS = "action.QSBForbidNormalAttack",
                    OPTIONS = {forbid = false}
                },
                {
                    CLASS = "action.QSBRemoveBuff",     --去除免控
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
            },
        },
    },
}

return pf_qiandaoliu_dazhao