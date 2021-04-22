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
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "attack11"},
				},
			},
		},
		{
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 59},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack11_1_ui"},--挥剑特效
	            },
	        },
	    }, 
	    {
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 54},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack11_3_ui"},--后层翅膀特效
	            },
	        },
	    }, 
	    {
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 18},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack11_4_ui"},--前层特效
	            },
	        },
	    }, 
	    {
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 18},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack11_5_ui"},--后层特效
	            },
	        },
	    },
	    {
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_frame = 10},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack11_6_ui"},--脚底法阵特效
	            },
	        },
	    },  
	},
}

return common_ssmahongjun_atk11