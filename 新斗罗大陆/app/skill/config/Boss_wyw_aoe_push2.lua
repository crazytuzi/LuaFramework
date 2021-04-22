
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
                    OPTIONS = {delay_frame = 63},
                }, 
                -- {
                --         CLASS = "action.QSBArgsGetHeroDamagePerSecond",
                --         OPTIONS = {coefficient = 0.05, set_black_board = {asd = "damage"}},
                -- },
                {
                    CLASS ="composite.QSBParallel",
                    ARGS = 
                    {
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "wyw_attack14_6", pos  = {x = 600 , y = 280}, ground_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "wyw_attack14_3", pos  = {x = 800 , y = 500}, ground_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "wyw_attack14_3", pos  = {x = 729 , y = 380}, ground_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "wyw_attack14_6", pos  = {x = 730 , y = 150}, front_layer = true},
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 5, duration = 0.4, count = 3, level = 5},
                        },
                        {

                            CLASS = "composite.QSBSequence",
                            ARGS ={
                                    {
                                        CLASS = "action.QSBArgsFindTargets", 
                                        OPTIONS = 
                                        { multiple_target_with_skill = true, set_black_board = {selectTargets = "selectTargets"}},
                                    },
                                    {
                                        CLASS = "action.QSBDecreaseAbsorbByProp",
                                        OPTIONS = {target_enemy_in_skill_range = true, current_absorb_percent = 1},
                                    }, 

                                    {
                                        CLASS = "action.QSBDecreaseHpWtihoutLog",
                                        OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true, value =0.6, get_black_board = {selectTargets = "selectTargets"}},
                                    },
                                    {
                                        CLASS = "action.QSBArgsGetHeroDamagePerSecond",
                                        OPTIONS = {coefficient = 0.01, set_black_board = {asd = "damage"}, dmg_limit_percent = 0.4},
                                    },
                                    

                                    {
                                        CLASS = "action.QSBHitTarget",
                                        OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.5}
                                    },



                            },

                        },
                        -- {
                        --     CLASS = "action.QSBHitTarget",
                        --     OPTIONS = {get_black_board = {damage_addition = "asd",ignore_absorb_percent = 0.4}}
                        -- },

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
                    OPTIONS = {delay_frame = 69},
                }, 
                {
                    CLASS ="composite.QSBParallel",
                    ARGS = 
                    {
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "wyw_attack14_7", pos  = {x = 440 , y = 160}, front_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "wyw_attack14_4", pos  = {x = 400 , y = 370}, ground_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "wyw_attack14_4", pos  = {x = 530 , y = 500}, ground_layer = true},
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
                    OPTIONS = {delay_frame = 75},
                }, 
                {
                    CLASS ="composite.QSBParallel",
                    ARGS = 
                    {
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "wyw_attack14_8", pos  = {x = 140 , y = 320}, ground_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "wyw_attack14_8", pos  = {x = 210 , y = 120}, front_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "wyw_attack14_5", pos  = {x = 280 , y = 540}, ground_layer = true},
                        },
 

                    },
                },                                         

            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 63},
                },
				{
					CLASS = "composite.QSBParallel",
					ARGS = { 
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "wyw_attack14_1", is_hit_effect = false},
                                }, 
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "wyw_attack14_2", is_hit_effect = false},
                                }, 

					},
				},
            },
        },	
    },
}

return jinzhan_tongyong