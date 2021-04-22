local boss_zhaowuji_dalijingangzhang = {
    CLASS = 'composite.QSBSequence',
    ARGS = {
        {
            CLASS = 'action.QSBPlaySound'
        },
        {
            CLASS = 'composite.QSBParallel',
            ARGS = {
                {
                    CLASS = 'action.QSBPlayEffect',
                    OPTIONS = {effect_id = 'zhaowuji_attack13_1', is_hit_effect = false}
                },
                {
                    CLASS = 'action.QSBPlayAnimation',
                    ARGS = {
                        {
                            CLASS = 'composite.QSBParallel',
                            ARGS = {
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
                        },
                        {
                            CLASS = 'action.QSBHitTarget'
                        },
                        {
                            CLASS = 'action.QSBDelayTime',
                            OPTIONS = {delay_frame = 8}
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
                            OPTIONS = {delay_time = 41 / 24}
                        },
                        {
                            CLASS = 'action.QSBShakeScreen',
                            OPTIONS = {amplitude = 15, duration = 0.25, count = 1}
                        }
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_time = 0.18},
                        -- },
                        -- {
                        --     CLASS = "action.QSBShakeScreen",
                        --     OPTIONS = {amplitude = 25, duration = 0.1, count = 1,},
                        -- },
                    }
                },
                {
                    CLASS = 'composite.QSBSequence',
                    ARGS = {
                        {
                            CLASS = 'action.QSBDelayTime',
                            OPTIONS = {delay_time = 22 / 24}
                        },
                        {
                            CLASS = 'action.QSBArgsPosition',
                            OPTIONS = {is_attacker = true}
                        },
                        {
                            CLASS = 'action.QSBDelayTime',
                            OPTIONS = {delay_frame = 1, pass_key = {'pos'}}
                        },
                        {
                            CLASS = 'action.QSBMultipleTrap', --连续放置多个陷阱
                            OPTIONS = {
                                interval_time = 0.5,
                                attacker_face = false,
                                attacker_underfoot = true,
                                count = 1,
                                distance = 150,
                                trapId = 'jingangzhang_jifei'
                            }
                        }
                    }
                }
            }
        },
        {
            CLASS = 'action.QSBAttackFinish'
        }
    }
}

return boss_zhaowuji_dalijingangzhang
