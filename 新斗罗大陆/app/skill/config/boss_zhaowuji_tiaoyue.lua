local boss_zhaowuji_tiaoyue = {
    CLASS = 'composite.QSBParallel',
    ARGS = {
        {
            CLASS = 'action.QSBApplyBuff',
            OPTIONS = {is_target = false, buff_id = 'mianyi_suoyou_zhuangtai'}
        },
        {
            CLASS = 'action.QSBPlaySound'
        },
        {
            CLASS = 'composite.QSBSequence',
            OPTIONS = {revertable = true},
            ARGS = {
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
                                    OPTIONS = {effect_id = 'zhaowuji_attack16_1', is_hit_effect = false}
                                }
                            }
                        },
                        {
                            CLASS = 'composite.QSBSequence',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_frame = 0}
                                },
                                {
                                    CLASS = 'action.QSBPlayAnimation'
                                }
                            }
                        },
                        {
                            CLASS = 'action.QSBMultipleTrap', --连续放置多个陷阱
                            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = 'zhaowujitiaoyue_hongquan'}
                        },
                        {
                            CLASS = 'composite.QSBSequence',
                            ARGS = {
                                -- {
                                -- 	CLASS = "action.QSBSelectTarget",
                                -- 	OPTIONS = {range_max = true},
                                -- },
                                {
                                    CLASS = 'action.QSBArgsPosition',
                                    OPTIONS = {is_attackee = true}
                                },
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_frame = 50, pass_key = {'pos'}}
                                },
                                {
                                    CLASS = 'action.QSBCharge', --移动向目标位置（不打断动画）
                                    OPTIONS = {move_time = 0.5}
                                },
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_frame = 48}
                                },
                                {
                                    CLASS = 'action.QSBRemoveBuff',
                                    OPTIONS = {is_target = false, buff_id = 'mianyi_suoyou_zhuangtai'}
                                },
                                {
                                    CLASS = 'action.QSBAttackFinish'
                                }
                            }
                        },
                        {
                            CLASS = 'composite.QSBSequence',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_time = 57 / 24}
                                },
                                {
                                    CLASS = 'action.QSBShakeScreen',
                                    OPTIONS = {amplitude = 40, duration = 0.75, count = 1}
                                }
                            }
                        },
                        {
                            CLASS = 'composite.QSBSequence',
                            OPTIONS = {revertable = true},
                            ARGS = {
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_time = 57 / 24}
                                },
                                {
                                    CLASS = 'composite.QSBSequence',
                                    ARGS = {
                                        {
                                            CLASS = 'action.QSBDelayTime',
                                            OPTIONS = {delay_frame = 0}
                                        },
                                        {
                                            CLASS = 'composite.QSBParallel',
                                            ARGS = {
                                                {
                                                    CLASS = 'action.QSBPlayEffect',
                                                    OPTIONS = {
                                                        effect_id = 'zhaowuji_attack16_1_1',
                                                        is_hit_effect = false
                                                    }
                                                },
                                                {
                                                    CLASS = 'action.QSBPlayEffect',
                                                    OPTIONS = {is_hit_effect = true}
                                                }
                                            }
                                        },
                                        {
                                            CLASS = 'action.QSBHitTarget'
                                        }
                                    }
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
        }
    }
}
return boss_zhaowuji_tiaoyue
