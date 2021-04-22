--  创建人：刘悦璘
--  创建时间：2018.04.07
--  NPC：大地之王
--  类型：攻击
local changqiangbing_chongfeng = {
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
            OPTIONS = {buff_id = "tongyongchongfeng_buff"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack16", is_loop = true},       
                }, 
                -- {
                --     CLASS = "action.QSBPlayLoopEffect",
                --     OPTIONS = {effect_id = "qiangbing_attack13_1_1"},
                -- },
            },
        },
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = true}
        },
        {
            CLASS = "action.QSBMoveToTarget",
            OPTIONS = {is_position = true},
        },
        {
            CLASS = "action.QSBRemoveBuff",     --去除加速
            OPTIONS = {buff_id = "tongyongchongfeng_buff"},
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
                            CLASS = "action.QSBActorKeepAnimation",
                            OPTIONS = {is_keep_animation = false}
                        },
                        -- {
                        --     CLASS = "action.QSBStopLoopEffect",
                        --     OPTIONS = {effect_id = "qiangbing_attack13_1_1"},
                        -- },
                        {
                            CLASS = "action.QSBActorStand",
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
                {
                     CLASS = "action.QSBHitTarget",
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
}

return changqiangbing_chongfeng