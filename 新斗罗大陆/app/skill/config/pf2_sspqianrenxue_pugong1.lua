
local jinzhan_tongyong = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        -- {
        --     CLASS = "action.QSBPlaySound"
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBPlayAnimation",
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {          
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },                                          
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf2_sspqianrenxue_attack01_3", is_hit_effect = true},--普攻受击
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
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
            },
        },	
    },
}

return jinzhan_tongyong