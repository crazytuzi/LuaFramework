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
		            OPTIONS = {delay_frame = 3 },
		        },
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "attack13"},
				},
			},
		},
        {
			CLASS = "composite.QUIDBSequence",
			ARGS = 
			{
				{
		            CLASS = "action.QUIDBDelayTime",
		            OPTIONS = {delay_frame = 18 },
		        },
		        {
			        CLASS = "action.QUIDBPlayEffect",
			        OPTIONS = {effect_id = "ui_pf_ssayin03_attack13_1"},
		        },
		    },		
        },
        {
		            CLASS = "action.QUIDBDelayTime",
		            OPTIONS = {delay_frame = 20 },
		},	
    },
}

return common_ssmahongjun_atk11