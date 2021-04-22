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
					OPTIONS = {animation = "attack14"},
				},
			},
		},
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 16},
                },
                {
                    CLASS = "composite.QUIDBParallel",            --自动2
                    ARGS = {
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ui_pf_chengnianxiaowu_zidong2_1", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ui_pf_chengnianxiaowu_zidong2_2", is_hit_effect = false},
                        },
                    },
                }, 
            },
        }, 
	},
}

return common_ssmahongjun_atk11