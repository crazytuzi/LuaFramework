local xunlian_elite_qianrenxue_shenfa03_1 = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
		    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
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
							OPTIONS = {animation = "victory"},
						},
					},
				},
				{
					CLASS = "action.QSBApplyBuff",
				    OPTIONS = {is_target = true, buff_id = "lockon_4s"},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_time = 100 / 24 },
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
		                    OPTIONS = {delay_time = 12 / 24 },
		                },
		                {
		                    CLASS = "action.QSBArgsPosition",
		                    OPTIONS = {is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
		                },
		                {
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_time = 1 / 24, pass_key = {"pos"}},
		                },
		                {
				            CLASS = "action.QSBMultipleTrap",
				            OPTIONS = {trapId = "xunlian_elite_qianrenxue_shenfayujing03",count = 1, pass_key = {"pos"}},
				        },
				        {
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_time = 14 / 24, pass_key = {"pos"}},
		                },
						{
				            CLASS = "action.QSBMultipleTrap",
				            OPTIONS = {trapId = "poshui_qianrenxue_shenfa03",count = 1, pass_key = {"pos"}},
				        },
	      	            {
				            CLASS = "action.QSBMultipleTrap",
				            OPTIONS = {trapId = "xunlian_qianrenxue_xiaotianshi_xianjing03_1",count = 1, pass_key = {"pos"}},
				        },

			        },
		        },
		        {
		            CLASS = "composite.QSBSequence",
		            ARGS = 
		            {
		                {
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_time = 36 / 24 },
		                },                   
        		        {
		                    CLASS = "action.QSBTriggerSkill",
		                    OPTIONS = {skill_id = 54218, wait_finish = true}, --放置另一个trap
		                },
		            },
		        },
		        {
		            CLASS = "composite.QSBSequence",
		            ARGS = 
		            {
		                {
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_time = 48 / 24 },
		                },                   
        		        {
		                    CLASS = "action.QSBTriggerSkill",
		                    OPTIONS = {skill_id = 54218, wait_finish = true}, --放置另一个trap
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
		                    CLASS = "action.QSBTriggerSkill",
		                    OPTIONS = {skill_id = 54218, wait_finish = true}, --放置另一个trap
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
		                    CLASS = "action.QSBTriggerSkill",
		                    OPTIONS = {skill_id = 54218, wait_finish = true}, --放置另一个trap
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
		                    CLASS = "action.QSBTriggerSkill",
		                    OPTIONS = {skill_id = 54218, wait_finish = true}, --放置另一个trap
		                },
		            },
		        },								
				{
		            CLASS = "composite.QSBSequence",
		            ARGS = 
		            {
		                {
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_time = 44 / 24 },
		                },                   
		                {
		                    CLASS = "action.QSBShakeScreen",
		                    OPTIONS = {amplitude = 6, duration = 0.35, count = 1,},
		                },
		            },
		        },
			},
		},
	},
}
return xunlian_elite_qianrenxue_shenfa03_1