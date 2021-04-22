
local charge_3 = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBManualMode",     --进入手动模式
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBLockTarget",     --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        {
            CLASS = "action.QSBStopMove",
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack12_1", reload_on_cancel = true, revertable = true},       --对于会涉及隐身的animation，需要在QSBPlayAnimation中加入选项,reload_on_cancel = true,revertable = true
        },
        {
            CLASS = "action.QSBPlayEffect",                        
            OPTIONS = {effect_id = "chuandichongfeng1_y"},
        },
        {
            CLASS = "action.QSBApplyBuff",      --加速
            OPTIONS = {buff_id = "rush1"},
        }, 
        
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {is_target = true, buff_id = "stun_charge"},
        -- },        
        {
            CLASS = "action.QSBMoveToTarget",   --攻击者移动到目标前面
            OPTIONS = {is_position = true, effect_id = "anblk_chuanci_1", effect_interval = 150, scale_actor_face = -1},        -- 移动过程中在路径上产生的地面效果 ； 地面效果的距离间隔
        },
        {
            CLASS = "action.QSBRemoveBuff",     --去除加速
            OPTIONS = {buff_id = "rush1"},
        },
        {
            CLASS = "action.QSBPlayEffect",                        
            OPTIONS = {effect_id = "chuandichongfeng2_y"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack12_2", reload_on_cancel = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBReloadAnimation",
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",                        
                            OPTIONS = {is_hit_effect = false, effect_id = "anblk_chuanci_2"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_frame = 2},
                        -- },
                        {
                             CLASS = "action.QSBHitTarget",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBTriggerSkill",
                            OPTIONS = {skill_id = 104811},          --全体嘲讽
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
}

return charge_3