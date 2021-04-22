
local yuxiaogang_huangjingshenglongpao = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="yuxiaogang_skill"},
        },
        {
            CLASS = "composite.QSBSequence",
             ARGS = {
                -- {
                --     CLASS = "action.QSBSelectTarget",
                --     OPTIONS = {},
                -- },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {  
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {forward_mode = true,}, -- 因为以下很多行为只是用于计算，所以开启forward_mode模式，消除不必要的等待帧数
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsIsLeft", -- 根据目标是否在屏幕左半侧选择
                                    OPTIONS = {is_attackee = true},
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    OPTIONS = {pass_args = true}, -- 把选择的子行为的传递参数传递下去
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBArgsPosition",
                                            OPTIONS = {x = 1000, is_attackee = true}, -- 生成传递参数 pos = {x = 800, y = 目标的y轴}
                                        },
                                        {
                                            CLASS = "action.QSBArgsPosition",
                                            OPTIONS = {x = 200, is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBCharge",
                                    OPTIONS = {move_time = 0.375, fcae_target = true},
                                },
                                -- {
                                --     CLASS = "action.QSBShuttle",
                                --     -- OPTIONS = {cancel_if_not_found = false, in_range = true, is_flip_x = true, shuttle_frame_count = 12, shuttle_shade_count = 4, shuttle_shade_interval_frame = 2},
                                --     -- 把角色传送到传递下来的pos处，并生成拖影
                                --     -- 不指定拖影的effect_id，通过角色本体的渲染结果生成拖影
                                -- },
                                -- 剩余部分为动作之类的，略
                            },         
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack15"},
                        },
                    },
                },
                {  
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            ARGS = {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {is_hit_effect = true},
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
                                    OPTIONS = {delay_time = 50 / 30},
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
                                    OPTIONS = {delay_time = 50 / 30},
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
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return yuxiaogang_huangjingshenglongpao