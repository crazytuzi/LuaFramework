local tank_chongfeng = {
    CLASS = 'composite.QSBSequence',
    -- OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = 'action.QSBManualMode', --进入手动模式
            OPTIONS = {enter = true, revertable = true}
        },
        {
            CLASS = 'action.QSBStopMove'
        },
        {
            CLASS = 'composite.QSBParallel',
            ARGS = {
                {
                    CLASS = 'composite.QSBSequence',
                    ARGS = {
                        {
                            CLASS = 'action.QSBDelayTime',
                            OPTIONS = {delay_frame = 0}
                        },
                        {
                            CLASS = 'action.QSBPlayEffect',
                            OPTIONS = {effect_id = 'zhaowuji_attack18_1', is_hit_effect = false}
                        }
                    }
                },
                {
                    CLASS = 'composite.QSBParallel',
                    ARGS = {
                        {
                            CLASS = 'action.QSBDelayTime',
                            OPTIONS = {delay_frame = 0}
                        },
                        {
                            CLASS = 'composite.QSBSequence',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_frame = 60}
                                },
                                {
                                    CLASS = 'action.QSBCharge', --移动向目标位置（不打断动画）
                                    OPTIONS = {move_time = 0.1}
                                },
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_frame = 10}
                                },
                                {
                                    CLASS = 'action.QSBHitTarget'
                                }
                            }
                        },
                        {
                            CLASS = 'action.QSBPlayAnimation',
                            OPTIONS = {animation = 'attack18_1'}
                        }
                    }
                },
                {
                    CLASS = 'composite.QSBSequence',
                    ARGS = {
                        {
                            CLASS = 'action.QSBDelayTime',
                            OPTIONS = {delay_frame = 30}
                        },
                        {
                            CLASS = 'composite.QSBParallel',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBPlayEffect',
                                    OPTIONS = {effect_id = 'zhaowuji_attack13_1_1', is_hit_effect = false}
                                },
                                {
                                    CLASS = 'action.QSBPlayEffect',
                                    OPTIONS = {is_hit_effect = true}
                                }
                            }
                        }
                    }
                }
            }
        },
        -- {
        --     CLASS = "composite.QSBParallel",
        --     ARGS =
        --     {
        --         {
        --             CLASS = "action.QSBPlayAnimation",
        --             OPTIONS = {animation = "attack14"},
        --         },
        --         -- {
        --         --     CLASS = "action.QSBPlayEffect",
        --         --     OPTIONS = {effect_id = "fulande_atk13_3_2" , is_hit_effect = true},
        --         -- },
        --     },
        -- },
        {
            CLASS = 'action.QSBLockTarget', --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true}
        },
        {
            CLASS = 'composite.QSBParallel',
            ARGS = {
                {
                    CLASS = 'composite.QSBParallel',
                    ARGS = {
                        {
                            CLASS = 'action.QSBPlayAnimation',
                            OPTIONS = {animation = 'attack18_2'}
                        },
                        {
                            CLASS = 'composite.QSBSequence',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_time = 0 / 24}
                                },
                                {
                                    CLASS = 'action.QSBPlayEffect',
                                    OPTIONS = {effect_id = 'zhaowuji_attack18_2', is_hit_effect = false}
                                }
                            }
                        }
                    }
                },
                {
                    CLASS = 'composite.QSBSequence',
                    ARGS = {
                        {
                            CLASS = 'action.QSBDelayTime',
                            OPTIONS = {delay_time = 26 / 24}
                        },
                        -- {
                        --     CLASS = "action.QSBManualMode",     --进入手动模式
                        --     OPTIONS = {enter = true, revertable = true},
                        -- },
                        -- {
                        --     CLASS = "action.QSBStopMove",
                        -- },
                        {
                            CLASS = 'action.QSBApplyBuff', --加速
                            OPTIONS = {buff_id = 'tongyongchongfeng_buff1'}
                        },
                        {
                            CLASS = 'action.QSBPlayAnimation',
                            OPTIONS = {animation = 'attack18_3', is_loop = true}
                        },
                        {
                            CLASS = 'action.QSBActorKeepAnimation',
                            OPTIONS = {is_keep_animation = true}
                        },
                        {
                            CLASS = 'composite.QSBParallel',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBMoveToTarget',
                                    OPTIONS = {is_position = true}
                                },
                                {
                                    CLASS = 'action.QSBPlayEffect',
                                    OPTIONS = {effect_id = 'zhaowuji_attack18_3', is_hit_effect = false}
                                },
                                {
                                    CLASS = 'composite.QSBSequence',
                                    ARGS = {
                                        {
                                            CLASS = 'action.QSBDelayTime',
                                            OPTIONS = {delay_time = 2 / 24}
                                        },
                                        {
                                            CLASS = 'action.QSBHitTarget'
                                        }
                                    }
                                }
                            }
                        },
                        {
                            CLASS = 'action.QSBApplyBuff',
                            OPTIONS = {buff_id = 'chongfeng_tongyong_xuanyun', is_target = true}
                        },
                        {
                            CLASS = 'action.QSBRemoveBuff', --去除加速
                            OPTIONS = {buff_id = 'tongyongchongfeng_buff1'}
                        },
                        {
                            CLASS = 'composite.QSBParallel',
                            ARGS = {
                                {
                                    CLASS = 'composite.QSBSequence',
                                    ARGS = {
                                        {
                                            CLASS = 'action.QSBReloadAnimation'
                                        },
                                        {
                                            CLASS = 'action.QSBActorKeepAnimation',
                                            OPTIONS = {is_keep_animation = false}
                                        },
                                        {
                                            CLASS = 'action.QSBActorStand'
                                        },
                                        {
                                            CLASS = 'action.QSBAttackFinish'
                                        }
                                    }
                                }
                                -- {
                                --      CLASS = "action.QSBHitTarget",
                                -- },
                            }
                        },
                        {
                            CLASS = 'action.QSBLockTarget',
                            OPTIONS = {is_lock_target = false}
                        },
                        {
                            CLASS = 'action.QSBManualMode',
                            OPTIONS = {exit = true}
                        }
                    }
                }
            }
        }
    }
}

return tank_chongfeng
