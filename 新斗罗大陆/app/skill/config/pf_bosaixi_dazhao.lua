
local pf_bosaixi_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},--不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 71},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        }, 
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="pf_bosaixi01_skill"},
        },
        {                           --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},--不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 71},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack11"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 61},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_bosaixi01_attack11_1", is_hit_effect = false},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_bosaixi01_attack11_1_1", is_hit_effect = false},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_bosaixi01_attack11_1_2", is_hit_effect = false},
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
                                            CLASS = "action.QSBPlaySceneEffect",
                                            OPTIONS = {effect_id = "pf_bosaixi01_attack11_2", pos  = {x = 640 , y = 360}, scale_actor_face = -1, front_layer = true},
                                        }, 
                                        {
                                            CLASS = "action.QSBPlaySceneEffect",
                                            OPTIONS = {effect_id = "pf_bosaixi01_attack11_3", pos  = {x = 640 , y = 360}, scale_actor_face = -1, front_layer = true},
                                        }, 
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 2},
                                                },
                                                {
                                                    CLASS = "action.QSBPlaySceneEffect",
                                                    OPTIONS = {effect_id = "pf_bosaixi01_attack11_5", pos  = {x = 640 , y = 360}, scale_actor_face = -1, front_layer = true},
                                                }, 
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 21},
                                                },
                                                {
                                                    CLASS = "action.QSBHitTarget",
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
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return pf_bosaixi_dazhao