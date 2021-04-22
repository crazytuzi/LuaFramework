local shifa_tongyong = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            { 
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "hl_bingbidihuangxie_attack12_1_3"},
                        },   
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "hl_bingbidihuangxie_attack12_1_4"},
                        },             
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 34},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack13"},
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
                            OPTIONS = {delay_frame = 46},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "hl_bingbidihuangxie_attack12_1_1"},
                        }, 
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 46},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "hl_bingbidihuangxie_attack12_1_2"},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "hl_bingbidihuangxie_attack01_3"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 54},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "hl_bingbidihuangxie_attack01_3", is_hit_effect = true},
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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 54},
                        },
                        {
                            CLASS = "action.QSBArgsConditionSelector",
                            OPTIONS = {
                                failed_select = 1,
                                {expression = "target:has_buff:hl_bingbidihuangxie_debuff_1=1", select = 1},
                                {expression = "target:has_buff:hl_bingbidihuangxie_debuff_2=1", select = 2},
                                {expression = "target:has_buff:hl_bingbidihuangxie_debuff_3=1", select = 3},
                                {expression = "target:has_buff:hl_bingbidihuangxie_debuff_4=1", select = 4},
                                {expression = "target:has_buff:hl_bingbidihuangxie_debuff_5=1", select = 5},
                                {expression = "target:has_buff:hl_bingbidihuangxie_debuff_6=1", select = 6},
                            }
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = 
                            {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_1"}, multiple_target_with_skill=true},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_7"}, multiple_target_with_skill=true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_2"}, multiple_target_with_skill=true},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_8"}, multiple_target_with_skill=true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_3"}, multiple_target_with_skill=true},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_9"}, multiple_target_with_skill=true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_4"}, multiple_target_with_skill=true},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_10"}, multiple_target_with_skill=true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_5"}, multiple_target_with_skill=true},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_11"}, multiple_target_with_skill=true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_6"}, multiple_target_with_skill=true},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_bingbidihuangxie_debuff_12"}, multiple_target_with_skill=true},
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_frame = 56},
                --         },
                --         {
                --             CLASS = "action.QSBChangeBuffStackNumber",
                --             OPTIONS = {status = "bingbidihuangxie", is_target = true},
                --         }, 
                --     },
                -- },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 58},
                        },
                        {
                            CLASS = "action.QSBTransmitBuff",
                            OPTIONS = {status = "bingbidihuangxie", from_multiple_target_with_skill = true,to_multiple_target_with_skill=true,is_max_stack = true},
                        }, 
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 26},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {forward_mode = true},
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
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBArgsSelectTarget",
                                                            OPTIONS = {max_distance = true}
                                                        },
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_frame = 1 ,  pass_key = {"selectTarget"}},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            OPTIONS = {pass_key = {"selectTarget"}},
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {is_hit_effect = true, effect_id = "hl_bingbidihuangxie_attack12_3_1", pass_key = {"selectTarget"}},
                                                                }, 
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {is_hit_effect = true, effect_id = "hl_bingbidihuangxie_attack12_3_2", pass_key = {"selectTarget"}},
                                                                }, 
                                                            },
                                                        },
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_frame = 1 ,  pass_key = {"selectTarget"}},
                                                        },         
                                                        {
                                                            CLASS = "action.QSBDragActor",
                                                            OPTIONS = {pos_type = "self" , pos = {x = 100,y = 0} , duration = 0.35, flip_with_actor = true },
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
                },
            },
        },
    },
}

return shifa_tongyong