
local jinzhan_tongyong = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
     {
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {          
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 24},
                },                                          
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf3_sspqianrenxue_attack01_3", is_hit_effect = true},--普攻受击
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {          
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 39},
                },                                          
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf3_sspqianrenxue_attack01_3", is_hit_effect = true},--普攻受击
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
				{
					CLASS = "composite.QSBParallel",
					ARGS = {  
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = false},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
					},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 6},
                },
                {
					CLASS = "action.QSBHitTarget",
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
                    CLASS = "action.QSBPlayAnimation",
                },
				{
					CLASS = "action.QSBAttackFinish"
				},
            },
        },
    },
}

return jinzhan_tongyong