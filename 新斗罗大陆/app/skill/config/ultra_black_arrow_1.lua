
local ultra_black_arrow = {     --黑箭
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
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
                    OPTIONS = {delay_time = 1.5},
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
        {               --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
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
                    OPTIONS = {delay_time = 1.5},
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

        -- animation
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        -- effect
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "darkness_meteor_fletch_1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "darkness_meteor_fletch_1_2", is_hit_effect = false},
                },
            },
        },
        -- bullet
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5},
                },
                {
                    CLASS = "action.QSBUncancellable",
                },
                {
                    CLASS = "action.QSBArgsIsLeft",
                    OPTIONS = {is_attackee = true},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, hit_effect_id = "gaze_of_fear_boom", shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 1280 - 400, y = 600 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 1280 - 800, y = 680 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 1280 - 400, y = 600 + 50, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, hit_effect_id = "gaze_of_fear_boom", shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 1280 - 480, y = 630 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 1280 - 640, y = 660 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 433},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 1280 - 800, y = 680 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, hit_effect_id = "gaze_of_fear_boom", shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 1280 - 400, y = 600 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 1280 - 480, y = 630 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 1280 - 800, y = 680 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, hit_effect_id = "gaze_of_fear_boom", shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 400, y = 600 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 800, y = 680 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 400, y = 600 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, hit_effect_id = "gaze_of_fear_boom", shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 480, y = 630 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 640, y = 660 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 800, y = 680 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, hit_effect_id = "gaze_of_fear_boom", shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 400, y = 600 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 480, y = 630 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.1 / 4},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "darkness_meteor_fletch_2", speed = 2360, time = 0.266 / 2, shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 800, y = 680 + 80, global = true}, dead_ok = true, single = true, end_pos = {x = 0, y = 0}, hit_dummy = "dummy_body"},
                                },
                            },
                        },
                    },
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "darkness_meteor_fletch_1_y"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.73},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "darkness_meteor_fletch_y"},
                },
            },
        },












        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "composite.QSBSequence",
        --             OPTIONS = {forward_mode = true,}, -- 因为以下很多行为只是用于计算，所以开启forward_mode模式，消除不必要的等待帧数
        --             ARGS = {
        --                 {
        --                     CLASS = "action.QSBArgsIsLeft", -- 根据目标是否在屏幕左半侧选择
        --                     OPTIONS = {is_attackee = true},
        --                 },
        --                 {
        --                     CLASS = "composite.QSBSelector",
        --                     OPTIONS = {pass_args = true}, -- 把选择的子行为的传递参数传递下去
        --                     ARGS = {
        --                         {
        --                             CLASS = "action.QSBArgsPosition",
        --                             OPTIONS = {x = 800, is_attackee = true}, -- 生成传递参数 pos = {x = 800, y = 目标的y轴}
        --                         },
        --                         {
        --                             CLASS = "action.QSBArgsPosition",
        --                             OPTIONS = {x = 100, is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
        --                         },
        --                     },
        --                 },
        --                 {
        --                     CLASS = "action.QSBShuttle",
        --                     OPTIONS = {cancel_if_not_found = true, in_range = true, is_flip_x = true, shuttle_frame_count = 12, shuttle_shade_count = 4, shuttle_shade_interval_frame = 2},
        --                     -- 把角色传送到传递下来的pos处，并生成拖影
        --                     -- 不指定拖影的effect_id，通过角色本体的渲染结果生成拖影
        --                 },
        --                 -- 剩余部分为动作之类的，略
        --             },
        --         },
        --         {
        --             CLASS = "composite.QSBParallel",
        --             ARGS = {
        --                 {
        --                     CLASS = "composite.QSBSequence",
        --                     ARGS = {
        --                         {
        --                             CLASS = "action.QSBPlayAnimation",
        --                             OPTIONS = {animation = "attack11"},
        --                         },
        --                         {
        --                             CLASS = "action.QSBAttackFinish",
        --                         },
                                
        --                     },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = {
        --                         {
        --                             CLASS = "action.QSBPlayEffect",
        --                             OPTIONS = {effect_id = "black_arrow_1_1", is_hit_effect = false},
        --                         },
        --                         {
        --                             CLASS = "action.QSBPlayEffect",
        --                             OPTIONS = {effect_id = "black_arrow_1_2", is_hit_effect = false},
        --                         },
        --                     },
        --                 },
        --                 {
        --                     CLASS = "composite.QSBSequence",
        --                     OPTIONS = {forward_mode = true,},
        --                     ARGS = {
        --                         {
        --                             CLASS = "action.QSBDelayTime",
        --                             OPTIONS = {delay_frame = 45},
        --                         },
        --                         {
        --                             CLASS = "action.QSBBullet",
        --                             OPTIONS = {effect_id = "black_arrow_2", speed = 1900, hit_effect_id = "black_arrow_3"},
        --                         },
        --                     },
        --                 },
        --             },
        --         },

        --     },
        -- },
    },
}

return ultra_black_arrow