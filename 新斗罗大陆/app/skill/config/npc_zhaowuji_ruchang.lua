local jump_appear = {
    CLASS = 'composite.QSBSequence',
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = 'action.QSBManualMode',
            OPTIONS = {enter = true, revertable = true}
        },
        {
            CLASS = 'composite.QSBParallel',
            ARGS = {
                {
                    CLASS = 'composite.QSBSequence', -- 入场魂环
                    ARGS = {
                        {
                            CLASS = 'action.QSBDelayTime',
                            OPTIONS = {delay_time = 25 / 24}
                        },
                        {
                            CLASS = 'action.QSBPlayEffect',
                            OPTIONS = {effect_id = 'zhaowuji_soul_2', is_hit_effect = false}
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
                                    CLASS = 'action.QSBShakeScreen',
                                    OPTIONS = {amplitude = 8, duration = 0.3, count = 2}
                                },
                                {
                                    CLASS = 'action.QSBPlayEffect',
                                    OPTIONS = {effect_id = 'zhaowuji_attack21_1', is_hit_effect = false}
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
                                                        effect_id = 'zhaowuji_attack21_1_1',
                                                        is_hit_effect = false
                                                    }
                                                }
                                            }
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
                            OPTIONS = {delay_time = 12 / 24}
                        },
                        {
                            CLASS = 'composite.QSBParallel',
                            ARGS = {
                                {
                                    CLASS = 'action.QSBShakeScreen',
                                    OPTIONS = {amplitude = 12, duration = 0.35, count = 3}
                                },
                                {
                                    CLASS = 'action.QSBPlayEffect',
                                    OPTIONS = {effect_id = 'zhaowuji_attack11_1', is_hit_effect = false}
                                }
                            }
                        }
                    }
                },
                {
                    CLASS = 'action.QSBCharge', --移动向目标位置（不打断动画）
                    OPTIONS = {pos = {x = 840, y = 320}, move_time = 0.1}
                },
                {
                    CLASS = 'action.QSBJumpAppear',
                    OPTIONS = {jump_animation = 'attack21'}
                },
                {
                    CLASS = 'composite.QSBSequence',
                    ARGS = {
                        {
                            CLASS = 'action.QSBDelayTime',
                            OPTIONS = {delay_time = 0 / 24}
                        },
                        {
                            CLASS = 'action.QSBPlaySound',
                            OPTIONS = {sound_id = 'zhaowuji_attack21'}
                        }
                    }
                },
                {
                    CLASS = 'action.QSBPlaySound',
                    OPTIONS = {sound_id = 'zhaowuji_ready'}
                }
            }
        },
        {
            CLASS = 'action.QSBManualMode',
            OPTIONS = {exit = true}
        },
        {
            CLASS = 'action.QSBAttackFinish'
        }
    }
}

return jump_appear
