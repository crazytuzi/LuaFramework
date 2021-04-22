
local ultra_barrage = {     --弹幕箭雨
    CLASS = "composite.QSBParallel",
    ARGS = {
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
                        
                    },
                },                
                {
                    CLASS = "action.QSBAttackFinish",
                },
                
            },
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1},
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
            OPTIONS = {forward_mode = true,},   --
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1},
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
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "barrage_y"},
                },
            },
        },

        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "barrage_1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "barrage_1_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 33},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "barrage_2", speed = 3000, hit_effect_id = "arrow_3_2", start_pos = {x = 0, y = 25}, end_pos = {x = 0, y = 25},},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 4},        --37帧
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "barrage_2", speed = 3000, hit_effect_id = "arrow_3_4", start_pos = {x = 0, y = -25}, end_pos = {x = 0, y = -25},},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 4},        --41帧
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "barrage_2", speed = 3000, hit_effect_id = "arrow_3_3"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 4},        --45帧
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "barrage_2", speed = 3000, hit_effect_id = "arrow_3_4", start_pos = {x = 0, y = -25}, end_pos = {x = 0, y = -25},},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 4},        --49帧
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "barrage_2", speed = 3000, hit_effect_id = "arrow_3_2", start_pos = {x = 0, y = 25}, end_pos = {x = 0, y = 25},},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 4},        --53帧
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "barrage_2", speed = 3000, hit_effect_id = "arrow_3_3"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 4},        --57帧
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "barrage_2", speed = 3000, hit_effect_id = "arrow_3_2", start_pos = {x = 0, y = 25}, end_pos = {x = 0, y = 25},},
                },

            },
        },
    },
}

return ultra_barrage