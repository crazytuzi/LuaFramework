
local jinzhan_tongyong = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBUncancellable"
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack11_1",no_stand = true},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS ={
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 70},
                        },


                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                        {
                                            CLASS = "action.QSBSummonGhosts",
                                            OPTIONS = { actor_id = 4191, life_span = 20,number = 1, no_fog = true, absolute_pos = {x=300,y=500}, appear_skill = 56012, trace_to_the_source = true},
                                         },
                                         {
                                            CLASS = "action.QSBSummonGhosts",
                                            OPTIONS = { actor_id = 4193, life_span = 20,number = 1, no_fog = true, absolute_pos = {x=720,y=470}, appear_skill = 56009, trace_to_the_source = true},
                                         },
                                         {
                                            CLASS = "action.QSBSummonGhosts", 
                                            OPTIONS = { actor_id = 4189, life_span = 20,number = 1, no_fog = true, absolute_pos = {x=650,y=220}, appear_skill = 56010, trace_to_the_source = true},
                                         },
                                         {
                                            CLASS = "action.QSBSummonGhosts",
                                            OPTIONS = { actor_id = 4190, life_span = 20,number = 1, no_fog = true, absolute_pos = {x=150,y=190}, appear_skill = 56011, trace_to_the_source = true},
                                         },
                                        {
                                            CLASS = "action.QSBSummonGhosts",
                                            OPTIONS = { actor_id = 4194, life_span = 20,number = 1, no_fog = true, absolute_pos = {x=500,y=300}, appear_skill = 56024, trace_to_the_source = true, direction = "left",useAttackerHatred=true},
                                         },
                                                -- {
                                                --     CLASS = "action.QSBSummonGhosts",
                                                --     OPTIONS = {
                                                --         actor_id = 3011, life_span = 20,number = 1, no_fog = true,
                                                --         absolute_pos = {x=250,y=150}, appear_skill = 50180, trace_to_the_source = true,
                                                --     },
                                                -- },
                                                -- {
                                                --     CLASS = "action.QSBSummonGhosts",
                                                --     OPTIONS = {
                                                --         actor_id = 3011, life_span = 20,number = 1, no_fog = true,
                                                --         absolute_pos = {x=750,y=150}, appear_skill = 50179, trace_to_the_source = true,
                                                --     },
                                                -- },
                                                -- {
                                                --     CLASS = "action.QSBSummonGhosts",
                                                --     OPTIONS = {
                                                --         actor_id = 3011, life_span = 20,number = 1, no_fog = true,
                                                --         absolute_pos = {x=250,y=450}, appear_skill = 50180, trace_to_the_source = true,
                                                --     },
                                                -- },
                                                -- {
                                                --     CLASS = "action.QSBSummonGhosts",
                                                --     OPTIONS = {
                                                --         actor_id = 3011, life_span = 20,number = 1, no_fog = true,
                                                --         absolute_pos = {x=750,y=450}, appear_skill = 50180, trace_to_the_source = true,
                                                --     },
                                                -- },

                                    },
                        },
                },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 70},
                            },

                            {
                                CLASS = "action.QSBPlayAnimation",
                                OPTIONS = {animation = "attack11_2", is_loop = true},
                            },
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 8.3},
                            },

                            {
                                CLASS = "action.QSBPlayAnimation",
                                OPTIONS = {animation = "attack11_3",no_stand = true},
                            },
 

                            {
                                CLASS = "action.QSBPlayAnimation",
                                OPTIONS = {animation = "attack11_4", is_loop = true},
                            }, 
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 10.1},
                            },
                            {
                                CLASS = "action.QSBPlayAnimation",
                                OPTIONS = {animation = "attack11_5"},
                            }, 
                            {
                                CLASS = "action.QSBAttackFinish",
                            },


                       

                    },
         },
          {
            CLASS = "composite.QSBSequence",
            ARGS = {
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 58},
                            },
                            {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_1", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_2", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 7, duration = 0.4, count = 3, level = 5},
                                            },
                                            


                                        },

                       

                             },
                              {
                                CLASS = "composite.QSBParallel",
                                ARGS = {

                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_1_1", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_1_2", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_2_1", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_2_2", is_hit_effect = false, ground_layer = true},
                                            },
                                           {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_2_3", is_hit_effect = false, ground_layer = true},
                                            },                                              


                                        },

                       

                             },
                             {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 9},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_1_1"},
                                            }, 
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_1_2"},
                                            },
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_2_2"},
                                            },  
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_4", is_hit_effect = false},
                                            },                                             


                                        },

                             },
                              {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 11.5},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_2_1"},
                                            }, 
                                            {
                                                CLASS = "action.QSBStopLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_2_3"},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_5", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_6", is_hit_effect = false},
                                            },                                             


                                        },

                             },                             






                    },

        },
     
         {
            CLASS = "composite.QSBSequence",
            ARGS = {
                            {
                                CLASS = "action.QSBArgsFindTargets", 
                                OPTIONS = 
                                { my_enemies = true , set_black_board = {selectTargets = "selectTargets"}},
                            },
                            {
                                CLASS = "action.QSBArgsGetHeroDamagePerSecond",
                                OPTIONS = {coefficient = 0.003, set_black_board = {asd = "damage"}},
                            },
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 4.5},

                            },

                            {
                                CLASS = "action.QSBDecreaseHpWtihoutLog",
                                OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true, value = 0.25, get_black_board = {selectTargets = "selectTargets"}},
                            },

                           {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.5,dmg_limit_percent = 0.2}--1
                            },
                             {
                                CLASS = "action.QSBDecreaseAbsorbByProp",
                                OPTIONS = {target_enemy_in_skill_range = true, current_absorb_percent = 0.95},
                            }, 
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.2},
                            }, 

                            {
                                CLASS = "action.QSBDecreaseHpWtihoutLog",
                                OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true, value = 0.25, get_black_board = {selectTargets = "selectTargets"}},
                            },
                           {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.5,dmg_limit_percent = 0.15}--2
                            },
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.2},
                            }, 

                            {
                                CLASS = "action.QSBDecreaseHpWtihoutLog",
                                OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true,value = 0.35,get_black_board = {selectTargets = "selectTargets"}},
                            }, 
                           {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.5,dmg_limit_percent = 0.15}--3
                            },
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.35},
                            },

                            {
                                CLASS = "action.QSBDecreaseHpWtihoutLog",
                                OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true,value = 0.35,get_black_board = {selectTargets = "selectTargets"}},
                            }, 
                           {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.5,dmg_limit_percent = 0.15}--4
                            },
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.2},
                            },

                            {
                                CLASS = "action.QSBDecreaseHpWtihoutLog",
                                OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true,value = 0.3, get_black_board = {selectTargets = "selectTargets"}},
                            }, 
                           {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.5,dmg_limit_percent = 0.15}--5
                            },
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.25},
                            },

                            {
                                CLASS = "action.QSBDecreaseHpWtihoutLog",
                                OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true, value = 0.3,get_black_board = {selectTargets = "selectTargets"}},
                            }, 
                           {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.5,dmg_limit_percent = 0.15}--6
                            },


                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.2},
                            }, 
 
                           {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.5,dmg_limit_percent = 0.15}--7
                            },

                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.25},
                            }, 
                           {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.5,dmg_limit_percent = 0.15}--8
                            },
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.2},
                            }, 

                            {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.5,dmg_limit_percent = 0.1}--9
                            }, 
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.25},
                            }, 

                            {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.5,dmg_limit_percent = 0.1}--10
                            },
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.2},
                            }, 


                            {
                                CLASS = "action.QSBDecreaseHpWtihoutLog",
                                OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true,  value = 0.3, get_black_board = {selectTargets = "selectTargets"}},
                            },
                            {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.2}--11
                            }, 
                               
                           {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.25},
                            }, 


                            {
                                CLASS = "action.QSBDecreaseHpWtihoutLog",
                                OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true, value = 0.3,  get_black_board = {selectTargets = "selectTargets"}},
                            },
                            {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.2}--12
                            },
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.2},
                            }, 

                            {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.2}--13
                            }, 

                            {
                                CLASS = "action.QSBExpression",
                                OPTIONS = {expStr = "value = {0.3 * (1 - 0.5 * (target:block_f > random))}"}

                            },
                            {
                                CLASS = "action.QSBDecreaseHpWtihoutLog",
                                OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true,  get_black_board = {selectTargets = "selectTargets"}},
                            },
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_time = 0.25},
                            }, 

                            {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.2}--14
                            }, 
                            {
                                CLASS = "action.QSBExpression",
                                OPTIONS = {expStr = "value = {0.3 * (1 - 0.5 * (target:block_f > random))}"}

                            },
                            {
                                CLASS = "action.QSBDecreaseHpWtihoutLog",
                                OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true,  get_black_board = {selectTargets = "selectTargets"}},
                            },                      

                    },
         },

      

       
    --     {
    --         CLASS = "composite.QSBSequence",
    --         ARGS = {
				-- {
    --                 CLASS = "action.QSBDelayTime",
    --                 OPTIONS = {delay_frame = 63},
    --             },
				-- {
				-- 	CLASS = "composite.QSBParallel",
				-- 	ARGS = { 
    --                             {
    --                                 CLASS = "action.QSBPlayEffect",
    --                                 OPTIONS = {effect_id = "wyw_attack14_1", is_hit_effect = false},
    --                             }, 
    --                             {
    --                                 CLASS = "action.QSBPlayEffect",
    --                                 OPTIONS = {effect_id = "wyw_attack14_2", is_hit_effect = false},
    --                             }, 

				-- 	},
				-- },
    --         },
    --     },	
    },
}

return jinzhan_tongyong