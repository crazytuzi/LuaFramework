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
	        CLASS = "action.QUIDBPlayEffect",
	        OPTIONS = {effect_id = "ui_ssayin_attack13_1"},
        },
        {
	        CLASS = "action.QUIDBPlayEffect",
	        OPTIONS = {effect_id = "ui_ssayin_attack13_2"},
        },		
    },
}

return common_ssmahongjun_atk11