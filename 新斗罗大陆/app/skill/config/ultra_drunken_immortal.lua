

local ultra_drunken_immortal = {		--熊猫人醉拳
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		-- 上免疫控制buff
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_prepare_polymorph"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_polymorph_sheep_state"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_polymorph_sheep"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_stun"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_fear"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_silence"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_knockback"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_time_stop"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "immunize_winding_of_cane"},
                },
            },
        },
		-- 攻击动作，去除免疫特效
		{
			CLASS = "composite.QSBSequence",
			OPTIONS = {forward_mode = true},
			ARGS = 
			{
				{
					CLASS = "action.QSBEnableAnimationControlMove", -- 开启"让动画在x轴上位移控制角色在x轴上的位移"
					OPTIONS = {revertable = true},
				},
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack11", no_stand = true},
				},
		        {
					CLASS = "action.QSBDisableAnimationControlMove", -- 关闭"让动画在x轴上位移控制角色在x轴上的位移"
				},

		        {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_prepare_polymorph"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_polymorph_sheep_state"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_polymorph_sheep"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_stun"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_fear"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_silence"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_knockback"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_time_stop"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "immunize_winding_of_cane"},
                },
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
		{			--技能流程
			CLASS = "composite.QSBParallel",
			ARGS = 
			{	
				{		--起始
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.61},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_5"},
						}
					},
				},
				{		--连续挥棍
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1.3},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_1"},
						}
					},
				},
				{		--连续挥棍1音效
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1.3},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_y1"},
						}
					},
				},
				{		--连续挥棍2音效
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1.47},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_y2"},
						}
					},
				},
				{		--连续挥棍3音效
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1.61},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_y1"},
						}
					},
				},
				{		--挥棍旋风1
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1.36},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_2"},
						}
					},
				},
				{		--挥棍旋风2
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1.53},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_2"},
						}
					},
				},
				{		--挥棍旋风3
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1.67},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_2"},
						}
					},
				},
				{		--跳起武器旋转
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2.16},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_6"},
						}
					},
				},
				{		--连续转棍1音效
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2.16},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_y3"},
						}
					},
				},
				{		--跳起武器闪光
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2.6},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_3"},
						}
					},
				},
				{		--纵批刀光
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2.84},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_7"},
						}
					},
				},
				{		--砸地爆炸
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2.88},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_4"},
						}
					},
				},
				{		--砸地爆炸音效
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2.88},
                        },
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "drunken_immortal_y4"},
						}
					},
				},
			},
		},
		{			--技能伤害
			CLASS = "composite.QSBParallel",
			ARGS = 
			{	
				{		--第一次伤害
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_frame = 41},
		                },
			    		{
		                    CLASS = "action.QSBHitTarget",
		                },
					},
				},
				{		--第二次伤害
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_frame = 46},
		                },
			    		{
		                    CLASS = "action.QSBHitTarget",
		                },
					},
				},
				{		--第三次伤害
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_frame = 50},
		                },
			    		{
		                    CLASS = "action.QSBHitTarget",
		                },
					},
				},
				{		--第四次伤害
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_frame = 84},
		                },
			    		{
		                    CLASS = "action.QSBHitTarget",
		                },
					},
				},
			},
		},
		{	--黑屏
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	    			CLASS = "action.QSBShowActor",
	                OPTIONS = {is_attacker = true, turn_on = true, time = 0.8, revertable = true},
	    		},
	    		{
        			CLASS = "action.QSBBulletTime",
        			OPTIONS = {turn_on = true, revertable = true},
        		},
	    		{
	    			CLASS = "action.QSBDelayTime",
	    			OPTIONS = {delay_time = 1.23},
	    		},
	    		{
        			CLASS = "action.QSBBulletTime",
        			OPTIONS = {turn_on = false},
        		},
	    		{
	    			CLASS = "action.QSBShowActor",
	                OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
	    		},
	    	},
		},
		{					--竞技场黑屏
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	    			CLASS = "action.QSBShowActorArena",
	                OPTIONS = {is_attacker = true, turn_on = true, time = 0.8, revertable = true},
	    		},
	    		{
        			CLASS = "action.QSBBulletTimeArena",
        			OPTIONS = {turn_on = true, revertable = true},
        		},
	    		{
	    			CLASS = "action.QSBDelayTime",
	    			OPTIONS = {delay_time = 3.55},
	    		},
	    		{
        			CLASS = "action.QSBBulletTimeArena",
        			OPTIONS = {turn_on = false},
        		},
	    		{
	    			CLASS = "action.QSBShowActorArena",
	                OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
	    		},
	    	},
		},
		{		-- 震屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2.88},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 22, duration = 0.2, count = 1,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.17},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 16, duration = 0.18, count = 1,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.12},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 11, duration = 0.15, count = 1,},
                },
            },
        },
	},
}

return ultra_drunken_immortal