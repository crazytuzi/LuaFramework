local zhaowuji_dingweizhuizong = {
    CLASS = 'composite.QSBSequence',
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = 'action.QSBLockTarget', --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true}
        },
        {
            CLASS = 'action.QSBManualMode', --进入手动模式
            OPTIONS = {enter = true, revertable = true}
        },
        {
            CLASS = 'action.QSBStopMove'
        },
        {
            CLASS = 'action.QSBPlayAnimation',
            OPTIONS = {animation = 'attack12_1'}
        },
        {
            CLASS = 'action.QSBApplyBuff', --加速
            OPTIONS = {buff_id = 'tongyongchongfeng_buff1'}
        },
        {
            CLASS = 'composite.QSBParallel',
            ARGS = {
                {
                    CLASS = 'action.QSBPlayAnimation',
                    OPTIONS = {animation = 'attack12_2', is_loop = true}
                },
                {
                    CLASS = 'action.QSBPlayEffect',
                    OPTIONS = {effect_id = 'zhaowuji_attack12_2', is_hit_effect = false}
                }
            }
        },
        {
            CLASS = 'action.QSBActorKeepAnimation',
            OPTIONS = {is_keep_animation = true}
        },
        {
            CLASS = 'action.QSBMoveToTarget',
            OPTIONS = {is_position = true}
        },
        {
            CLASS = 'action.QSBRemoveBuff', --去除加速
            OPTIONS = {buff_id = 'tongyongchongfeng_buff1'}
        },
        {
            CLASS = 'action.QSBActorKeepAnimation',
            OPTIONS = {is_keep_animation = false}
        },
        {
            CLASS = 'composite.QSBParallel',
            ARGS = {
                {
                    CLASS = 'action.QSBPlayEffect',
                    OPTIONS = {effect_id = 'zhaowuji_attack12_3', is_hit_effect = false}
                },
                {
                    CLASS = 'composite.QSBSequence',
                    ARGS = {
                        {
                            CLASS = 'action.QSBPlayAnimation',
                            OPTIONS = {animation = 'attack12_3'}
                        },
                        {
                            CLASS = 'action.QSBReloadAnimation'
                        },
                        {
                            CLASS = 'action.QSBAttackFinish'
                        }
                    }
                },
                {
                    CLASS = 'action.QSBHitTarget'
                }
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

return zhaowuji_dingweizhuizong
