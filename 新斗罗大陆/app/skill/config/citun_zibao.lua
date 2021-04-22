
local citun_zibao = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true},
            ARGS = {
                {
                    CLASS = "action.QSBLockTarget",     --锁定目标
                    OPTIONS = {is_lock_target = true, revertable = true},
                },
                {
                    CLASS = "action.QSBManualMode",     --进入手动模式
                    OPTIONS = {enter = true, revertable = true},
                },
                {
                    CLASS = "action.QSBStopMove",
                },
                {
                    CLASS = "action.QSBApplyBuff",      --加速
                    OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
                },
                {
                    CLASS = "action.QSBApplyBuff",      --免控
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },

                {
                    CLASS = "action.QSBMoveToTarget",
                    OPTIONS = {is_position = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",     --去除加速
                    OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                             CLASS = "composite.QSBSequence",
                             ARGS = {
                                {
                                    CLASS = "action.QSBReloadAnimation",
                                },
                                {
                                    CLASS = "action.QSBActorStand",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBLockTarget",
                    OPTIONS = {is_lock_target = false},
                },
                {
                    CLASS = "action.QSBManualMode",
                    OPTIONS = {exit = true},
                },
            },
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack11"},
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
            CLASS = "action.QSBSuicide", -- 这个action会让刺豚自杀，并且不播放初始设定的死亡动画
        },
        {
            CLASS = "action.QSBRemoveBuff",     --去除免控
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        },
    },
}
return citun_zibao
