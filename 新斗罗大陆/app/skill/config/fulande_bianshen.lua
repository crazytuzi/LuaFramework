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
                    OPTIONS = {animation = "attack22"},
                },
                {
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 47/24},
				        },
				        {
				            CLASS = "action.QSBActorFadeOut",
				            OPTIONS = {is_target = false, duration = 0.2},
				        },
				    },
				},
				{
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 48/24},
				        },
				        {
				            CLASS = "action.QSBPlayVideo",
				            OPTIONS = {video = "res/video/1_12video.mp4"},
				        },
				    },
				},
				{
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 50/24},
				        },
				        {
		                    CLASS = "composite.QSBParallel",
		                    ARGS = 
		                    {
		                        {
		                            CLASS = "action.QSBTrap",  
		                            OPTIONS = 
		                            { 
		                                trapId = "fulande_liuxingyu1",
		                                args = 
		                                {
		                                    {delay_time = 1 / 24 , pos = { x = 760, y = 120}} ,
		                                    {delay_time = 3 / 24 , pos = { x = 920, y = 200}} ,
		                                    {delay_time = 5 / 24 , pos = { x = 1200, y = 320}} ,
		                                    {delay_time = 7 / 24 , pos = { x = 920, y = 400}},
		                                    {delay_time = 9 / 24 , pos = { x = 760, y = 480}} ,
		                                },
		                            },
		                        },                       
		                        {
		                            CLASS = "action.QSBTrap",  
		                            OPTIONS = 
		                            { 
		                                trapId = "fulande_liuxingyu2",
		                                args = 
		                                {
		                                    {delay_time = 1 / 24 , pos = { x = 560, y = 120}} ,
		                                    {delay_time = 3 / 24 , pos = { x = 320, y = 200}} ,
		                                    {delay_time = 5 / 24 , pos = { x = 120, y = 320}} ,
		                                    {delay_time = 7 / 24 , pos = { x = 320, y = 400}},
		                                    {delay_time = 9 / 24 , pos = { x = 560, y = 480}} ,
		                                },
		                            },
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
				            OPTIONS = {delay_time = 55/24},
				        },
				        {
				            CLASS = "action.QSBReplaceBGTransformBoss",
				        },
			        },
		        },
				{
				    CLASS = "composite.QSBSequence",
				    ARGS = 
				    {
				    	{
				            CLASS = "action.QSBDelayTime",
				            OPTIONS = {delay_time = 56/24},
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
				            OPTIONS = {delay_time = 20/24},
				        },
				        {
				            CLASS = "composite.QSBParallel",
				            ARGS = 
				            {
								-- {
								--     CLASS = "composite.QSBSequence",
								--     ARGS = 
								--     {
								--     	{
								--             CLASS = "action.QSBDelayTime",
								--             OPTIONS = {delay_time = 43/24},
								--         },
								-- 		{
						  --                   CLASS = "action.QSBPlayAnimation",
						  --                   OPTIONS = {animation = "stand_1"},
						  --               },
								-- 	},
								-- },
								-- {
								--     CLASS = "composite.QSBSequence",
								--     ARGS = 
								--     {
								--     	{
								--             CLASS = "action.QSBDelayTime",
								--             OPTIONS = {delay_time = 43/24},
								--         },
								--         {
								--             CLASS = "action.QSBActorFadeIn",
								--             OPTIONS = {is_target = false, duration = 0.15},
								--         },
								--     },
								-- },
								{
								    CLASS = "composite.QSBSequence",
								    ARGS = 
								    {
								    	{
								            CLASS = "action.QSBDelayTime",
								            OPTIONS = {delay_time = 41/24},
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
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 105 / 24},
                },
              	{
		            CLASS = "action.QSBAttackFinish"
		        },
            },
        },
        -- {
        --     CLASS = "action.QSBAttackFinish"
        -- },
    },
}
return boss_fulande_bianshen