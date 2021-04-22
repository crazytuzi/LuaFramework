local boss_fulande_bianshen = {
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBUncancellable",    
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
            	{
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack15"},
                },
                {
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 41/24},
				        },
				        {
				            CLASS = "action.QSBActorFadeOut",
				            OPTIONS = {is_target = false, duration = 0.1},
				        },
				    },
				},
				{
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 42/24},
				        },
	        			{
				            CLASS = "action.QSBTeleportToAbsolutePosition",
				            OPTIONS = {pos = {x = 1100, y = 160}},
				        },
				    },
				},
				{
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 43/24},
				        },
						{
		                    CLASS = "action.QSBPlayAnimation",
		                    OPTIONS = {animation = "attack21"},
		                },
					},
				},
				{
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 42/24},
				        },
						{
			            	CLASS = "action.QSBSummonMonsters",
			            	OPTIONS = {wave = -3},
			            },
					},
				},
				{
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 43/24},
				        },
				        {
				            CLASS = "action.QSBActorFadeIn",
				            OPTIONS = {is_target = false, duration = 0.1},
				        },
				    },
				},
		    },
		},
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return boss_fulande_bianshen