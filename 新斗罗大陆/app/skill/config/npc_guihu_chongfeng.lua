--  创建人：刘悦璘
--  创建时间：2018.03.22
--  NPC：鬼虎
--  类型：攻击
local npc_guihu_chongfeng = {
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
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack18", is_loop = true},       
                }, 
                -- {
                --     CLASS = "action.QSBPlayLoopEffect",
                --     OPTIONS = {effect_id = "qiangqibing_attack14_1"},
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
                            CLASS = "action.QSBActorKeepAnimation",
                            OPTIONS = {is_keep_animation = false}
                        },
                        -- {
                        --     CLASS = "action.QSBStopLoopEffect",
                        --     OPTIONS = {effect_id = "qiangqibing_attack14_1"},
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

return npc_guihu_chongfeng