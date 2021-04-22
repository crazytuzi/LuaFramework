local npc_yuanshao_dazhao = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
		{	
			CLASS = "composite.QSBSequence",
			-- OPTIONS = {forward_mode = true}, --不会打断特效
			ARGS = 
			{	
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animaion = "attack13"},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true},
            ARGS = 
            {
                {
                    CLASS = "action.QSBSelectTarget",
                },
                {
                    CLASS = "action.QSBUncancellable",
                },
                {
                    CLASS = "action.QSBArgsIsDirectionLeft",
                    OPTIONS = {is_attacker = true},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {   
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBPlaySceneEffect",
                                            OPTIONS = {effect_id = "tishi_kuangfx_w15_l1002", pos  = {x = 1150 , y = 260}, ground_layer = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlaySceneEffect",
                                            OPTIONS = {effect_id = "tishi_kuangfx_w15_l1002", pos  = {x = 1150 , y = 425}, ground_layer = true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 33},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBBullet",
                                            OPTIONS = {effect_id = "fulande2_attack13_2", sort_layer_with_actor = true, speed = 325, is_tornado = true, tornado_size = {width = 150, height = 122},
                                            start_pos = {x = 1480,y = 280, global = true}, dead_ok = false, single = true},
                                        },
                                        {
                                            CLASS = "action.QSBBullet",
                                            OPTIONS = {effect_id = "fulande2_attack13_2", sort_layer_with_actor = true, speed = 325, is_tornado = true, tornado_size = {width = 150, height = 122},
                                            start_pos = {x = 1480,y = 455, global = true}, dead_ok = false, single = true},          
                                        },
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
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
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlaySceneEffect",
                                            OPTIONS = {effect_id = "tishi_kuangfx_w15_l100", pos  = {x = 0 , y = 260}, ground_layer = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlaySceneEffect",
                                            OPTIONS = {effect_id = "tishi_kuangfx_w15_l100", pos  = {x = 0 , y = 425}, ground_layer = true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 33},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBBullet",
                                            OPTIONS = {effect_id = "fulande2_attack13_2", sort_layer_with_actor = true, speed = 325, is_tornado = true, tornado_size = {width = 135, height = 122},
                                            start_pos = {x = -300,y = 280, global = true}, dead_ok = false, single = true},
                                        },
                                        {
                                            CLASS = "action.QSBBullet",
                                            OPTIONS = {effect_id = "fulande2_attack13_2", sort_layer_with_actor = true, speed = 325, is_tornado = true, tornado_size = {width = 135, height = 122},
                                            start_pos = {x = -300,y = 455, global = true}, dead_ok = false, single = true},          
                                        },
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
			},
		},
	},
}		

return npc_yuanshao_dazhao