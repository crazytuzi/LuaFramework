local boss_zhaowuji_dalijinganghou = {
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
                    OPTIONS = {delay_frame = 4}
                },
                {
                    CLASS = 'action.QSBPlayEffect',
                    OPTIONS = {effect_id = 'zhaowuji_attack15_1', is_hit_effect = false}
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
                    CLASS = 'action.QSBPlayAnimation',
                    OPTIONS = {animation = 'attack15'},
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
                    OPTIONS = {delay_time = 66 / 24}
                }
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {effect_id = "npc_zhaowujidazhao" , is_hit_effect = false},
                -- },
            }
        },
        {
            CLASS = 'composite.QSBSequence',
            ARGS = {
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 44 / 24}
                },
                {
                    CLASS = 'action.QSBPlaySound'
                }
            }
        },
        {
            CLASS = 'composite.QSBSequence',
            ARGS = {
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 66 / 24}
                },
                {
                    CLASS = 'action.QSBHitTarget'
                },
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 4 / 24}
                },
                {
                    CLASS = 'action.QSBHitTarget'
                },
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 4 / 24}
                },
                {
                    CLASS = 'action.QSBHitTarget'
                },
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 4 / 24}
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
                    CLASS = 'action.QSBPlaySound',
                    OPTIONS = {sound_id = 'zhaowuji_ready'}
                }
            }
        },
        {
            CLASS = 'action.QSBApplyBuff',
            OPTIONS = {buff_id = 'dalijinganghou_debuff_boss_3', is_target = false}
        }
    }
}

return boss_zhaowuji_dalijinganghou
