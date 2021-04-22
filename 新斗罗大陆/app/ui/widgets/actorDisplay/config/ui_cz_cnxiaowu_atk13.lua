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
					OPTIONS = {animation = "attack13"},
				},
			},
		},
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 19},
                },
                {
                    CLASS = "composite.QUIDBParallel",            --自动1第一段
                    ARGS = {
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ui_pf_chengnianxiaowu_zidong1_1", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ui_pf_chengnianxiaowu_zidong1_4", is_hit_effect = false},
                        },
                    },
                }, 
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 22},
                },
                {
                    CLASS = "composite.QUIDBParallel",            --自动1第二段
                    ARGS = {
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ui_pf_chengnianxiaowu_zidong1_2", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ui_pf_chengnianxiaowu_zidong1_5", is_hit_effect = false},
                        },
                    },
                }, 
            },
        },
         {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 24},
                },
                {
                    CLASS = "composite.QUIDBParallel",            --自动1第三段
                    ARGS = {
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ui_pf_chengnianxiaowu_zidong1_3", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ui_pf_chengnianxiaowu_zidong1_6", is_hit_effect = false},
                        },
                    },
                }, 
            },
        },
	},
}

return common_ssmahongjun_atk11