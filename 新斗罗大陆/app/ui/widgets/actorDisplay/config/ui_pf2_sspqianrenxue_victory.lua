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
					OPTIONS = {animation = "victory"},
				},
			},
		},
		{
	        CLASS = "composite.QUIDBSequence",
	        ARGS = 
	        {
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_victory_3_ui"},--蓄力特效
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
	                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_victory_1_ui"},--前层特效
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
	                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_victory_2_ui"},--前层特效
	            },
	        },
	    }, 
	},
}

return common_ssmahongjun_atk11