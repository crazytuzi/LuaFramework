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