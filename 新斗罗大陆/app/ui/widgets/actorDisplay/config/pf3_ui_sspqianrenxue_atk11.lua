local common_ssmahongjun_atk11 = 
{
	CLASS = "composite.QUIDBParallel",
	ARGS = 
	{
		{
			CLASS = "composite.QUIDBSequence",
			ARGS = 
			{
				{
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 1},
	            },
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "attack11_1"},
				},
			},
		},
	    {
			CLASS = "composite.QUIDBSequence",
			ARGS = 
			{
				{
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 96},
	            },
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "attack11_2"},
				},
			},
		},
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 51 },
                },
                {
                    CLASS = "action.QUIDBActorFade",
                    OPTIONS = {fadeout = true, revertable = true, duration = 0.01 },
                },
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 45 },
                },
                {
                    CLASS = "action.QUIDBActorFade",
                    OPTIONS = {fadein = true, revertable = true,  duration = 0.01 },
                },
            },
        },
		{
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 14},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack11_1_ui"},--飞升特效
	            },
	        },
	    }, 
	    {
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 96},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack11_3_ui"},--下降特效
	            },
	        },
	    }, 
	    {
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 40},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack11_7_ui"},--预警特效
	            },
	        },
	    }, 
	    {
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 57},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack11_2_ui"},--激光特效
	            },
	        },
	    }, 
	    {
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 62},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack11_8_ui"},--地面前特效
	            },
	        },
	    }, 
	    {
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 62},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack11_9_ui"},--地面后特效
	            },
	        },
	    }, 
	},
}

return common_ssmahongjun_atk11