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
            OPTIONS = {delay_frame = 2},
        },
				{
					CLASS = "action.QUIDBPlayAnimation",
					OPTIONS = {animation = "attack14"},
				},
			},
		},
		{
        CLASS = "composite.QUIDBSequence",
        ARGS = 
        {
            {
                CLASS = "action.QUIDBDelayTime",
                OPTIONS = {delay_frame = 16},
            },
            {
                CLASS = "action.QUIDBPlayEffect",
                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack14_3_ui"},--头顶剑特效
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
                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack14_4_ui"},--施法特效
            },
        },
    },  
    {
        CLASS = "composite.QUIDBSequence",
        ARGS = 
        {
            {
                CLASS = "action.QUIDBDelayTime",
                OPTIONS = {delay_frame = 46},
            },
            {
                CLASS = "action.QUIDBPlayEffect",
                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack14_1_ui"},--前层特效
            },
        },
    },  
    {
        CLASS = "composite.QUIDBSequence",
        ARGS = 
        {
            {
                CLASS = "action.QUIDBDelayTime",
                OPTIONS = {delay_frame = 46},
            },
            {
                CLASS = "action.QUIDBPlayEffect",
                OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack14_2_ui"},--后层特效
            },
        },
    },    
	},
}

return common_ssmahongjun_atk11