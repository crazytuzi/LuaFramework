
local pf_chengniantangsan02_dazhao = {
   CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="pf_chengniantangsan02_skill"},
        },
		-- {
		-- 	CLASS = "composite.QSBSequence",
		-- 	ARGS = {
		-- 		{
  --                   CLASS = "action.QSBDelayTime",
  --                   OPTIONS = {delay_time = 0.2},
  --               },
		-- 		{
		-- 			CLASS = "action.QSBPlaySound",
		-- 			OPTIONS = {revertable = true,},
		-- 		},
		-- 	},
		-- },
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {forward_mode = true},
			ARGS = {
				{
				    CLASS = "composite.QSBParallel",
				    ARGS = {
						{
		                    CLASS = "action.QSBShowActor",				----黑屏时间开始
		                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
		                },
		                {
		                    CLASS = "action.QSBShowActorArena",				----黑屏时间开始
		                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
		                },
		            },
		        },
		        {
				    CLASS = "composite.QSBParallel",
				    ARGS = {
		                {
		                    CLASS = "action.QSBBulletTime",				----子弹时间开始
		                    OPTIONS = {turn_on = true, revertable = true},
		                },
		                {
		                    CLASS = "action.QSBBulletTimeArena",				----子弹时间开始
		                    OPTIONS = {turn_on = true, revertable = true},
		                },
		            },
		        },
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "tangsan_htc_dazhao_buff"},-- 上免疫控制buff
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
		            CLASS = "action.QSBStopMove",
		        },
		        {
		            CLASS = "action.QSBApplyBuff",      --加速
		            OPTIONS = {buff_id = "pf_chengniantangsan01_chongfeng_buff"},
		        },
		        {
		            CLASS = "action.QSBPlayAnimation",
		            OPTIONS = {animation = "attack11_2", is_loop = true, no_stand = true},       
		        }, 
		        {
		            CLASS = "action.QSBActorKeepAnimation",
		            OPTIONS = {is_keep_animation = true}
		        },
		        -- {
					-- CLASS = "action.QSBApplyBuff",
					-- OPTIONS = {buff_id = "pf_chengniantangsan02_chongfeng"},
				-- },
		        {
		            CLASS = "action.QSBChargeToTarget",
		            OPTIONS = {is_position = true,  scale_actor_face = 1, speed = 1500},
		        },
		        {
		            CLASS = "action.QSBRemoveBuff",     --去除加速
		            OPTIONS = {buff_id = "pf_chengniantangsan01_chongfeng_buff"},
		        },
		        {
		            CLASS = "action.QSBActorKeepAnimation",
		            OPTIONS = {is_keep_animation = false}
		        },
		        {
		            CLASS = "action.QSBForbidNormalAttack",    -- 让英雄不普攻
		            OPTIONS = {forbid = true, revertable = true}
		        },
		        -- {
		            -- CLASS = "action.QSBRemoveBuff",     
		            -- OPTIONS = {buff_id = "pf_chengniantangsan02_chongfeng"},
		        -- },
		        {
				    CLASS = "composite.QSBParallel",
				    ARGS = {
				        {
		                    CLASS = "action.QSBBulletTime",					---子弹时间结束
		                    OPTIONS = {turn_on = false},
		                },
		                {
		                    CLASS = "action.QSBBulletTimeArena",					---子弹时间结束
		                    OPTIONS = {turn_on = false},
		                },
		            },
		        },
		        {
				    CLASS = "composite.QSBParallel",
				    ARGS = {
		                {
		                    CLASS = "action.QSBShowActor",					----黑屏结束
		                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
		                },
		                {
		                    CLASS = "action.QSBShowActorArena",					----黑屏结束
		                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
		                },
		            },
		        },
		        {
		            CLASS = "composite.QSBParallel",
		            ARGS = {
		                {
				            CLASS = "action.QSBPlayAnimation",
				            OPTIONS = {animation = "attack11_3"},
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 6},
				                },
				                {
				                    CLASS = "action.QSBPlayEffect",
				                    OPTIONS = {effect_id = "pf_chengniantangsan01_attack11_3_1", is_hit_effect = false},
				                },         
				            },
				        },
                        {
				            CLASS = "action.QSBApplyBuff",      --眩晕
				            OPTIONS = {is_target = true, buff_id = "tangsan_htc_dazhao_debuff"},
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 3 / 24 * 30},
				                },
				                {
				                 	CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 10, duration = 0.2, count = 2,},
				                },
				            },
				        },
		            },
		        },
		        {
		            CLASS = "composite.QSBParallel",
		            ARGS = {
		            	{
							CLASS = "action.QSBPlayAnimation",
							OPTIONS = {animation = "attack11_1"},				            
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 17},
				                },
								{
									CLASS = "composite.QSBParallel",
									ARGS = {  
										{
											CLASS = "action.QSBPlayEffect",
											OPTIONS = {effect_id = "pf_chengniantangsan01_attack11_1", is_hit_effect = false},
										},   
										{
											CLASS = "action.QSBPlayEffect",
											OPTIONS = {effect_id = "pf_chengniantangsan01_attack11_1_1", is_hit_effect = false},
										}, 
									},
								},  
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 19},
				                },
				                {
				                    CLASS = "action.QSBPlayEffect",
				                    OPTIONS = {effect_id = "pf_chengniantangsan01_attack11_3", is_hit_effect = true},
				                }, 
				                 {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 11},
				                },
				                {
				                    CLASS = "action.QSBPlayEffect",
				                    OPTIONS = {effect_id = "pf_chengniantangsan01_attack11_3",is_hit_effect = true},
				                },   
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 19},
				                },
				                {
				                    CLASS = "action.QSBPlayEffect",
				                    OPTIONS = {effect_id = "pf_chengniantangsan01_attack11_3",is_hit_effect = true},
				                },           
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 19},
				                },               
				                {
				                    CLASS = "action.QSBHitTarget",
				                },  				              
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 11},
				                },               
				                {
				                    CLASS = "action.QSBHitTarget",
				                },  				                            
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 19},
				                },               
				                {
				                    CLASS = "action.QSBHitTarget",
				                },                                          
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 56},
				                },
				                {
									CLASS = "composite.QSBParallel",
									ARGS = {  
										{
											CLASS = "action.QSBPlayEffect",
											OPTIONS = {effect_id = "pf_chengniantangsan01_attack11_1_2", is_hit_effect = false},
										},   
										{
											CLASS = "action.QSBPlayEffect",
											OPTIONS = {effect_id = "pf_chengniantangsan01_attack11_1_3", is_hit_effect = false},
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
				                    OPTIONS = {delay_frame =19},
				                },
				                {
				                 	CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 10, duration = 0.15, count = 2,},
				                },
				            },
				        },
				        {
				            CLASS = "composite.QSBSequence",
				            ARGS = {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 35},
				                },
				                {
				                 	CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 10, duration = 0.15, count = 2,},
				                },
				            },
				        },
                        {
				            CLASS = "composite.QSBSequence",
				            ARGS = {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 44},
				                },
				                {
				                 	CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 25, duration = 0.2, count = 2,},
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.15},
				                },
				                {
				                 	CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 20, duration = 0.2, count = 2,},
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.15},
				                },
				                {
				                 	CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 15, duration = 0.1, count = 1,},
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
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "tangsan_htc_dazhao_buff"},-- 下免疫控制buff
				},
				{
		            CLASS = "action.QSBForbidNormalAttack",
		            OPTIONS = {forbid = false}
		        },
		        {
                    CLASS = "action.QSBAttackFinish"
                },
			},
		},
    },
}

return pf_chengniantangsan02_dazhao