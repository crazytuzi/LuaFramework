local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        
        {
            CLASS = "composite.QSBParallel",
            ARGS = {

                
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                         {
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 5},
                            },
                            {
                                CLASS = "action.QSBPlayAnimation",
                            },
                        },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                         {
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 6},
                            },
                            {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "yuxiaogang_atk13_1"},
                            }, 
                        },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                         {
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 12},
                            },
                            {
                                CLASS = "action.QSBPlayEffect",
                                OPTIONS = {is_hit_effect = true, effect_id = "yuxiaogang_atk13_2"},
                            }, 
                        },
                },
				
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                         {
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 15},
                            },
                            {
                                CLASS = "action.QSBPlayEffect",
                                OPTIONS = {is_hit_effect = true, effect_id = "yuxiaogang_atk13_2"},
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
                                OPTIONS = {delay_frame = 30},
                            },
                            {
                                CLASS = "action.QSBPlayEffect",
                                OPTIONS = {is_hit_effect = true, effect_id = "yuxiaogang_atk13_2"},
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
                                OPTIONS = {delay_frame = 45},
                            },
                            {
                                CLASS = "action.QSBPlayEffect",
                                OPTIONS = {is_hit_effect = true, effect_id = "yuxiaogang_atk13_2"},
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
                                OPTIONS = {delay_frame = 60},
                            },
                            {
                                CLASS = "action.QSBPlayEffect",
                                OPTIONS = {is_hit_effect = true, effect_id = "yuxiaogang_atk13_2"},
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
                                OPTIONS = {delay_frame = 75},
                            },
                            {
                                CLASS = "action.QSBPlayEffect",
                                OPTIONS = {is_hit_effect = true, effect_id = "yuxiaogang_atk13_2"},
                            }, 
                            {
                                CLASS = "action.QSBHitTarget",
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
                        OPTIONS = {delay_frame = 30},
                    },
                    {
                        CLASS = "action.QSBAttackFinish"
                    },
                },
        },
        
    },
}

return shifa_tongyong