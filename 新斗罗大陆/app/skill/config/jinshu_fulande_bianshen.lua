local boss_fulande_bianshen = 
{
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
        -- {
        --     CLASS = "action.QSBImmuneCharge",
        --     OPTIONS = {enter = true, revertable = true},
        -- },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
            	{
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "victory"},
                },
                {
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 30/24},
				        },
				        {
				            CLASS = "action.QSBActorFadeOut",
				            OPTIONS = {is_target = false, duration = 0.5},
				        },
				    },
				},
				-- {
				--     CLASS = "composite.QSBSequence",
				--     ARGS = 
				--     {
				--     	{
				--             CLASS = "action.QSBDelayTime",
				--             OPTIONS = {delay_time = 42/24},
				--         },
				--         {
				--             CLASS = "action.QSBReplaceBGTransformBoss",
				--         },
			 --        },
		  --       },
				{
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 42/24},
				        },
				        {
				            CLASS = "composite.QSBParallel",
				            ARGS = 
				            {
			        			{
						            CLASS = "action.QSBTeleportToAbsolutePosition",
						            OPTIONS = {pos = {x = 630, y = 320}},
						        },
					        },
				        },
				    },
				},
				{
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 10/24},
				        },
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
								            OPTIONS = {delay_time = 43/24},
								        },
										{
						                    CLASS = "action.QSBPlayAnimation",
						                    OPTIONS = {animation = "stand_1"},
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
								            OPTIONS = {is_target = false, duration = 0.15},
								        },
								    },
								},
								{
								    CLASS = "composite.QSBSequence",
								    ARGS = 
								    {
								    	{
								            CLASS = "action.QSBDelayTime",
								            OPTIONS = {delay_time = 71/24},
								        },
								        {
								            CLASS = "action.QSBApplyBuff",
								            OPTIONS = {buff_id = "fulande_bianshen_buff"},
								        },  
								        {
								            CLASS = "action.QSBRetainBuff",
								            OPTIONS = {buff_id = "fulande_bianshen_buff"},
								        },
								    },
								},
							},
						},
				    },
				},
			},
		},
		{
            CLASS = "action.QSBReleaseBuff",
            OPTIONS = {buff_id = "fulande_bianshen_buff"},
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