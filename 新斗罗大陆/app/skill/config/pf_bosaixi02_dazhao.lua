
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
                    OPTIONS = {delay_frame = 83},
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
                    OPTIONS = {delay_frame = 83},
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
                                    OPTIONS = {delay_frame = 6},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_bosaixi02_attack11_1", is_hit_effect = false},
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
                                    OPTIONS = {delay_frame = 80},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                     ARGS = {
                                        -- {
                                        --     CLASS = "action.QSBPlaySceneEffect",
                                        --     OPTIONS = {effect_id = "siwangziyitx_2", pos  = {x = 640 , y = 330}, scale_actor_face = -1},
                                        -- }, 
                                        {
                                            CLASS = "action.QSBPlaySceneEffect",
                                            OPTIONS = {effect_id = "bosaixiyx_attack11_3", pos  = {x = 640 , y = 410}, scale_actor_face = -1, front_layer = true},
                                        }, 
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 0.75},
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