local boss_zhaowuji_zhonglijiya = {
    CLASS = 'composite.QSBParallel',
    ARGS = {
        {
            CLASS = 'action.QSBApplyBuff',
            OPTIONS = {is_target = false, buff_id = 'mianyi_suoyou_zhuangtai'}
        },
        {
            CLASS = 'composite.QSBSequence',
            ARGS = {
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 69 / 24}
                },
                {
                    CLASS = 'action.QSBShakeScreen',
                    OPTIONS = {amplitude = 5, duration = 0.35, count = 4}
                },
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 35 / 24}
                },
                {
                    CLASS = 'action.QSBShakeScreen',
                    OPTIONS = {amplitude = 15, duration = 0.35, count = 2}
                }
            }
        },
        {
            CLASS = 'composite.QSBSequence',
            ARGS = {
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 64 / 24}
                },
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 5 / 24}
                },
                {
                    CLASS = 'composite.QSBParallel',
                    ARGS = {
                        {
                            CLASS = 'action.QSBPlayAnimation',
                            OPTIONS = {animation = 'attack17'}
                        },
                        {
                            CLASS = 'composite.QSBSequence',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_time = 33 / 24}
                                },
                                {
                                    CLASS = 'action.QSBPlayEffect',
                                    OPTIONS = {effect_id = 'zhaowuji_attack17_1', is_hit_effect = false}
                                }
                            }
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
                    OPTIONS = {delay_time = 50 / 24}
                },
                {
                    CLASS = 'action.QSBMultipleTrap', --连续放置多个陷阱
                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = 'zhaowuji_heidongjifei'}
                },
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 52 / 24}
                },
                {
                    CLASS = 'composite.QSBParallel',
                    ARGS = {
                        {
                            CLASS = 'action.QSBDragActor',
                            OPTIONS = {
                                pos_type = 'self',
                                pos = {x = 200, y = 0},
                                duration = 0.5,
                                flip_with_actor = true
                            }
                        }
                    }
                },
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 8 / 24}
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
                    CLASS = 'composite.QSBParallel',
                    ARGS = {
                        {
                            CLASS = 'composite.QSBSequence',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_frame = 19 / 2}
                                },
                                {
                                    CLASS = 'action.QSBPlayEffect',
                                    OPTIONS = {effect_id = 'zhaowuji_attack14_1', is_hit_effect = false}
                                }
                            }
                        },
                        {
                            CLASS = 'composite.QSBSequence',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_frame = 13}
                                },
                                {
                                    CLASS = 'action.QSBPlayAnimation',
                                    OPTIONS = {animation = 'attack14'}
                                },
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_frame = 3}
                                },
                                {
                                    CLASS = 'action.QSBHitTarget'
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
                        },
                        {
                            CLASS = 'composite.QSBSequence',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_time = 28 / 24}
                                },
                                {
                                    CLASS = 'action.QSBCharge', --移动向目标位置（不打断动画）
                                    OPTIONS = {pos = {x = 640, y = 320}, move_time = 0.1}
                                }
                            }
                        },
                        {
                            CLASS = 'composite.QSBSequence',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBDelayTime',
                                    OPTIONS = {delay_time = 27 / 24}
                                },
                                {
                                    CLASS = 'action.QSBShakeScreen',
                                    OPTIONS = {amplitude = 15, duration = 0.3, count = 2}
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

return boss_zhaowuji_zhonglijiya
