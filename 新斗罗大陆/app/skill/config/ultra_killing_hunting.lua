
local ultra_killing_hunting = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
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
                    OPTIONS = {delay_frame = 25},
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
        {                       --竞技场黑屏
            CLASS = "composite.QSBSequence",
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
                    OPTIONS = {delay_frame = 25},
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
                            OPTIONS = {animation = "attack11", reload_on_cancel = true, revertable = true},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.70},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "duomingliesha_1"},
                                }, 
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 52},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "duomingliesha_1_1", is_rotate_to_target = true},
                                }, 
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {forward_mode = true,},
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 24},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "duomingliesha_2", speed = 2500, hit_effect_id = "duomingliesha_3"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 4},        --34帧
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "duomingliesha_2", speed = 2500, hit_effect_id = "duomingliesha_3_2", start_pos = {x = 0, y = -40}, end_pos = {x = 0, y = -40},},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 4},        --38帧
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "duomingliesha_2", speed = 2500, hit_effect_id = "duomingliesha_3", start_pos = {x = 0, y = 40}, end_pos = {x = 0, y = 40},},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 4},        --42帧
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "duomingliesha_2", speed = 2500, hit_effect_id = "duomingliesha_3_2"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 4},        --45帧
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "duomingliesha_2", speed = 2500, hit_effect_id = "duomingliesha_3", start_pos = {x = 0, y = 40}, end_pos = {x = 0, y = 40},},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 4},        --48帧
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "duomingliesha_2", speed = 2500, hit_effect_id = "duomingliesha_3_2", start_pos = {x = 0, y = -40}, end_pos = {x = 0, y = -40},},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 6},        --55帧
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "duomingliesha_2_1", speed = 3500, hit_effect_id = "fire_blade_storm_3_1", shake = {amplitude = 20, duration = 0.17, count = 2}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 2},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 12, duration = 0.15, count = 1,},
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

return ultra_killing_hunting