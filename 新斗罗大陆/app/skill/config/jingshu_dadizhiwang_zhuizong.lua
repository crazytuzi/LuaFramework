local jingshu_dadizhiwang_zhuizong = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
		    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
		-- {
		-- 	CLASS = "action.QSBPlaySound",
		-- }, 
		{
			CLASS = "composite.QSBParallel",
			ARGS = 
			{
				{
		            CLASS = "action.QSBMultipleTrap",
		            OPTIONS = {trapId = "jinshu_lieyanzhuizong_yujing",count = 1, pass_key = {"pos"}},
		        },
		        {
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "action.QSBPlayAnimation",
							OPTIONS = {animation = "attack11"},
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
		                    CLASS = "action.QSBArgsPosition",
		                    OPTIONS = {is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
		                },
						{
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_time = 24 / 24, pass_key = {"pos"}},
		                },
						{
				            CLASS = "action.QSBMultipleTrap",
				            OPTIONS = {trapId = "jinshu_lieyanzhuizong_baozha",count = 1, pass_key = {"pos"}},
				        },
				        {
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_time = 35 / 24, pass_key = {"pos"}},
		                },
		                {
				            CLASS = "action.QSBMultipleTrap",
				            OPTIONS = {trapId = "jinshu_lieyanzhuizong_chixu",count = 1, pass_key = {"pos"}},
				        },
			        },
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
		                    CLASS = "action.QSBShakeScreen",
		                    OPTIONS = {amplitude = 8, duration = 0.25, count = 2,},
		                },
		            },
		        },
			},
		},
	},
}

return jingshu_dadizhiwang_zhuizong