
local ultra_spell_barrier = {         -- 真言术障，怀特迈恩

    CLASS = "composite.QSBParallel",
    ARGS = {
        {       -- 动作
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack11"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 20},
                                },
                                {
                                    CLASS = "action.QSBAttackFinish"
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 32},
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
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "huaitemaien_zhenyanshu_1_l"},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "huaitemaien_zhenyanshu_1_r"},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "huaitemaien_zhenyanshu_1_1"},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.08},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "huaitemaien_zhenyanshu_3", pos  = {x = 650 , y = 320}},
                },
            },
        },
        {   --黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 1.15, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.15},
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
        {                   --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 1.15, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.15},
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
    },
}

return ultra_spell_barrier
