
local jinzhan_tongyong = {
        CLASS = "composite.QSBParallel",
        ARGS = {
        {
            CLASS = "composite.QSBSequence",

            ARGS = {
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 1},
                            },
                            {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_19", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_20", is_hit_effect = false, ground_layer = true},
                                            },
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_1", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_2", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_3_3", is_hit_effect = false, ground_layer = true},
                                            },
  


                                        },

                       

                             },
                             {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 65},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {

                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_31", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_32", is_hit_effect = false},
                                            }, 
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 4, duration = 0.2, count = 2, level = 5},
                                            },  
                                           


                                        },

                             },
                              {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 44},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {

                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_31", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_32", is_hit_effect = false},
                                            }, 
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 4, duration = 0.2, count = 2, level = 5},
                                            },                                              


                                        },

                             },  

                              {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 42},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_31", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_32", is_hit_effect = false},
                                            },
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 4, duration = 0.2, count = 2, level =5},
                                            },                                               

 
                                        },

                             },
                                {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 42},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
 
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_31", is_hit_effect = false},
                                            },                                             
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_32", is_hit_effect = false},
                                            },
                                            {
                                                CLASS = "action.QSBShakeScreen",
                                                OPTIONS = {amplitude = 4, duration = 0.2, count = 2, level = 5},
                                            },    
                                         


                                        },

                             },

                             {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 30},
                             },
                             {
                                CLASS = "composite.QSBParallel",
                                ARGS = {
                                            -- {
                                            --     CLASS = "action.QSBStopLoopEffect",
                                            --     OPTIONS = {effect_id = "wyw_attack11_5_1"},
                                            -- }, 
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_23", is_hit_effect = false, ground_layer = true},
                                            }, 
                                            {
                                                CLASS = "action.QSBPlayLoopEffect",
                                                OPTIONS = {effect_id = "wyw_attack11_24", is_hit_effect = false, ground_layer = true},
                                            }, 
   
                                            -- {
                                            --     CLASS = "action.QSBPlayEffect",
                                            --     OPTIONS = {effect_id = "wyw_attack11_11", is_hit_effect = false},
                                            -- },                                             
                                            -- {
                                            --     CLASS = "action.QSBPlayEffect",
                                            --     OPTIONS = {effect_id = "wyw_attack11_12", is_hit_effect = false},
                                            -- },                                             


                                        },

                             }, 
                            -- {
                            --     CLASS = "action.QSBDelayTime",
                            --     OPTIONS = {delay_time = 10},
                            --  },
                            --  {
                            --     CLASS = "composite.QSBParallel",
                            --     ARGS = {
                            --                 -- {
                            --                 --     CLASS = "action.QSBStopLoopEffect",
                            --                 --     OPTIONS = {effect_id = "wyw_attack11_5_1"},
                            --                 -- }, 
                            --                {
                            --                     CLASS = "action.QSBStopLoopEffect",
                            --                     OPTIONS = {effect_id = "wyw_attack11_3_1"},
                            --                 }, 
                            --                 {
                            --                     CLASS = "action.QSBStopLoopEffect",
                            --                     OPTIONS = {effect_id = "wyw_attack11_3_2"},
                            --                 }, 
                            --                 {
                            --                     CLASS = "action.QSBStopLoopEffect",
                            --                     OPTIONS = {effect_id = "wyw_attack11_3_3"},
                            --                 },
                            --                 -- {
                            --                 --     CLASS = "action.QSBPlayEffect",
                            --                 --     OPTIONS = {effect_id = "wyw_attack11_11", is_hit_effect = false},
                            --                 -- },                                             
                            --                 -- {
                            --                 --     CLASS = "action.QSBPlayEffect",
                            --                 --     OPTIONS = {effect_id = "wyw_attack11_12", is_hit_effect = false},
                            --                 -- },  
   
                                          


                            --             },

                            --  }, 
                             -- {
                             --    CLASS = "action.QSBDelayTime",
                             --    OPTIONS = {delay_frame = 50 },
                             -- },
                             -- {
                             --    CLASS = "composite.QSBParallel",
                             --    ARGS = {
                             --                {
                             --                    CLASS = "action.QSBStopLoopEffect",
                             --                    OPTIONS = {effect_id = "wyw_attack11_5_1"},
                             --                }, 

   
                             --                {
                             --                    CLASS = "action.QSBPlayEffect",
                             --                    OPTIONS = {effect_id = "wyw_attack11_23", delay_per_hit=-1},
                             --                },                                             
                             --                {
                             --                    CLASS = "action.QSBPlayEffect",
                             --                    OPTIONS = {effect_id = "wyw_attack11_24", delay_per_hit=-1},
                             --                },                                             


                             --            },

                             -- },                          













                    },

        },




        {
             CLASS = "composite.QSBSequence",
             OPTIONS = {forward_mode = true},
             ARGS = {
                {
                    CLASS = "action.QSBUncancellable",
                },
                {
                    CLASS = "action.QSBSetCannotBeLocked",
                },
                -- {
                --     CLASS = "action.QSBPlayAnimation",
                --     OPTIONS = {animation = "attack21", no_stand = true },
                -- },

         {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 38},
                                },
                            },
                        }, 
                        {
                            CLASS = "action.QSBJumpAppear",
                            OPTIONS = {jump_animation = "attack21"},
                        },
                        -- {
                        --     CLASS = "action.QSBPlayAnimation",
                        --     OPTIONS = { animation = "attack21"},
                        -- },    
                    },
                },               


                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 2},
                },

                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack01_1"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 2},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack01_1"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 2},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack01_1"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 2},
                },
                {
                     CLASS = "action.QSBPlayAnimation",
                     OPTIONS = {animation = "attack01_1"},
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = { delay_frame = 2},
                -- },
                -- {
                --      CLASS = "action.QSBPlayAnimation",
                --      OPTIONS = {animation = "attack01_1"},
                -- },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 1},
                },
    },
    },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                                {
                                    CLASS = "action.QSBSetCannotBeLocked",
                                    OPTIONS = { isCan = true },
                                },
                                -- {
                                --     CLASS = "action.QSBUncancellable",
                                -- },
                                {
                                    CLASS = "action.QSBSetHpGroup",
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = { buff_id = "chanrao_yishang"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = { buff_id = "weakness_mark"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = { buff_id = "zudui_mianyi_suoyou_zhuangtai"},
                                },



                    },
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "dead2_1", no_stand = true },
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "dead2_2", is_loop = true },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_time = 10.5},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_time = 2},
                },

                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "dead2_3" },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 1},
                },

                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = { delay_frame = 30},
                -- },



                {
                    CLASS = "action.QSBSuicide",
                    OPTIONS = { use_dead_skill = true},
                  
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 15},
                },

                {
                    CLASS = "action.QSBAttackFinish",
                },



            },
        },
    },
}
return jinzhan_tongyong