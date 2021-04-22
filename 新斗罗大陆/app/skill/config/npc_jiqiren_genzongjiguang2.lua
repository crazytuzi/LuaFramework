local boss_tielong_tiaoyue = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
		    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
            CLASS = "action.QSBBullet",
            OPTIONS = {start_pos = {x = 0,y = 80}},------第一束狐火-----
        },
        {
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 24 / 24 },
                },
				{
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
				        {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack13_1"},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 41 / 24 },
				                },
				                {
				                    CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 10, duration = 0.4, count = 10,},
				                },
			                },
		                },
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 41 / 24 },
				                },
				                {
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack13_2", no_stand = true,is_loop = true, is_keep_animation = true},
								},
								{
									CLASS = "action.QSBActorKeepAnimation",
									OPTIONS = {is_keep_animation = true} ,
								},
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 84 / 24 },
				                },
								{
									CLASS = "action.QSBActorKeepAnimation",
									OPTIONS = {is_keep_animation = false},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 131 / 24 },
				                },
				                {
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack13_3"},
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
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 43 / 24 },
				                },
				                {
				                    CLASS = "action.QSBArgsPosition",
				                    OPTIONS = {is_attackee = true }, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0 / 24 ,pass_key = {"pos"}},
				                },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "diliepo_yujing",count = 1, pass_key = {"pos"}},
						        },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing1",count = 1, pass_key = {"pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 4 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing2",count = 1, pass_key = {"pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 8/ 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_jiguang2",count = 1, pass_key = {"pos"}},
						        },				       
					        },
				        },
				        {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 49 / 24 },
				                },
				                {
				                    CLASS = "action.QSBArgsPosition",
				                    OPTIONS = {is_attackee = true }, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0 / 24 ,pass_key = {"pos"}},
				                },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "diliepo_yujing",count = 1, pass_key = {"pos"}},
						        },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing1",count = 1, pass_key = {"pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 4 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing2",count = 1, pass_key = {"pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 8 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_jiguang2",count = 1, pass_key = {"pos"}},
						        },				       
					        },
				        },
				        {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 54 / 24 },
				                },
				                {
				                    CLASS = "action.QSBArgsPosition",
				                    OPTIONS = {is_attackee = true }, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0 / 24 ,pass_key = {"pos"}},
				                },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "diliepo_yujing",count = 1, pass_key = {"pos"}},
						        },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing1",count = 1, pass_key = {"pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 4 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing2",count = 1, pass_key = {"pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 8 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_jiguang2",count = 1, pass_key = {"pos"}},
						        },				       
					        },
				        },
				        {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 60 / 24 },
				                },
				                {
				                    CLASS = "action.QSBArgsPosition",
				                    OPTIONS = {is_attackee = true , options_evaluate = {pos = "pos3"}}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0 / 24 ,pass_key = {"pos"}},
				                },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "diliepo_yujing",count = 1, pass_key = {"pos"}},
						        },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing1",count = 1, pass_key = {"pos"},  args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 4 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing2",count = 1, pass_key = {"pos"}, args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 8 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_jiguang2",count = 1, pass_key = {"pos"},args_translate = {pos3 = "pos"}},
						        },				       
					        },
				        },
				         {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 66 / 24 },
				                },
				                {
				                    CLASS = "action.QSBArgsPosition",
				                    OPTIONS = {is_attackee = true , options_evaluate = {pos = "pos3"}}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0 / 24 ,pass_key = {"pos"}},
				                },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "diliepo_yujing",count = 1, pass_key = {"pos"}},
						        },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing1",count = 1, pass_key = {"pos"},  args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 4 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing2",count = 1, pass_key = {"pos"}, args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 8 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_jiguang2",count = 1, pass_key = {"pos"},args_translate = {pos3 = "pos"}},
						        },				       
					        },
				        },
				        {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 72 / 24 },
				                },
				                {
				                    CLASS = "action.QSBArgsPosition",
				                    OPTIONS = {is_attackee = true , options_evaluate = {pos = "pos3"}}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0 / 24 ,pass_key = {"pos"}},
				                },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "diliepo_yujing",count = 1, pass_key = {"pos"}},
						        },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing1",count = 1, pass_key = {"pos"},  args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 4 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing2",count = 1, pass_key = {"pos"}, args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 8 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_jiguang2",count = 1, pass_key = {"pos"},args_translate = {pos3 = "pos"}},
						        },				       
					        },
				        },
				        {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 78 / 24 },
				                },
				                {
				                    CLASS = "action.QSBArgsPosition",
				                    OPTIONS = {is_attackee = true , options_evaluate = {pos = "pos3"}}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0 / 24 ,pass_key = {"pos"}},
				                },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "diliepo_yujing",count = 1, pass_key = {"pos"}},
						        },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing1",count = 1, pass_key = {"pos"},  args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 4 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing2",count = 1, pass_key = {"pos"}, args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 8 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_jiguang2",count = 1, pass_key = {"pos"},args_translate = {pos3 = "pos"}},
						        },				       
					        },
				        },
				        {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 84 / 24 },
				                },
				                {
				                    CLASS = "action.QSBArgsPosition",
				                    OPTIONS = {is_attackee = true , options_evaluate = {pos = "pos3"}}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0 / 24 ,pass_key = {"pos"}},
				                },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "diliepo_yujing",count = 1, pass_key = {"pos"}},
						        },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing1",count = 1, pass_key = {"pos"},  args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 4 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing2",count = 1, pass_key = {"pos"}, args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 8 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_jiguang2",count = 1, pass_key = {"pos"},args_translate = {pos3 = "pos"}},
						        },				       
					        },
				        },
				        {
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 90 / 24 },
				                },
				                {
				                    CLASS = "action.QSBArgsPosition",
				                    OPTIONS = {is_attackee = true , options_evaluate = {pos = "pos3"}}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0 / 24 ,pass_key = {"pos"}},
				                },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "diliepo_yujing",count = 1, pass_key = {"pos"}},
						        },
				                {
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing1",count = 1, pass_key = {"pos"},  args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 4 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_yujing2",count = 1, pass_key = {"pos"}, args_translate = {pos3 = "pos"}},
						        },
						        {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 8 / 24 ,pass_key = {"pos"}},
				                },
								{
						            CLASS = "action.QSBMultipleTrap",
						            OPTIONS = {trapId = "jiqiren_zhuizong_jiguang2",count = 1, pass_key = {"pos"},args_translate = {pos3 = "pos"}},
						        },				       
					        },
				        },
						{
				            CLASS = "composite.QSBSequence",
				            ARGS = 
				            {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 27 / 24 },
				                },                   
				                {
				                    CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 12, duration = 0.4, count = 2,},
				                },
				            },
				        },
			        },
		        },
			},
		},
	},
}
return boss_tielong_tiaoyue