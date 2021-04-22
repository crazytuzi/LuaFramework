
local naocankao_gangtiexinxing2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {   
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- 第一轮技能
                {
                    CLASS = "composite.QSBParallel",
                     ARGS = {
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "iron_star_3_1", pos  = {x = 670 , y = 480}, scale_actor_face = -1, ground_layer = true},
                        }, 
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "iron_star_3_2", pos  = {x = 640 , y = 300}, scale_actor_face = -1, front_layer = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.33},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 10, duration = 0.13, count = 2,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.17},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 10, duration = 0.13, count = 2,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.12},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 10, duration = 0.13, count = 2,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.12},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 8, duration = 0.13, count = 2,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.12},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 8, duration = 0.13, count = 2,},
                                },
                            },
                        },
                    },
                },
                -- 第二轮技能
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.5},
                },

                {
                    CLASS = "composite.QSBParallel",
                     ARGS = {
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "iron_star_3_1", pos  = {x = 670 , y = 480}, scale_actor_face = -1, ground_layer = true},
                        }, 
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "iron_star_3_2", pos  = {x = 640 , y = 300}, scale_actor_face = -1, front_layer = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.33},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 10, duration = 0.13, count = 2,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.17},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 10, duration = 0.13, count = 2,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.12},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 10, duration = 0.13, count = 2,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.12},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 8, duration = 0.13, count = 2,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.12},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 8, duration = 0.13, count = 2,},
                                },
                            },
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
                    OPTIONS = {delay_time = 0.2},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.5},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return naocankao_gangtiexinxing2