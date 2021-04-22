local tank_chongfeng = 
{
    CLASS = "composite.QSBSequence",
    -- OPTIONS = {forward_mode = true},
    ARGS = 
    {
        {
            CLASS = "action.QSBManualMode",     --进入手动模式
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBStopMove",
        },
        -- {
        --     CLASS = "composite.QSBParallel",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBPlayAnimation",
        --             OPTIONS = {animation = "attack14"}, 
        --         },
        --         -- {
        --         --     CLASS = "action.QSBPlayEffect",
        --         --     OPTIONS = {effect_id = "fulande_atk13_3_2" , is_hit_effect = true},
        --         -- },
        --     },
        -- },
        {
            CLASS = "action.QSBLockTarget",     --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack14"}, 
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "fulande_atk13_3_2" , is_hit_effect = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 60/24 },
                        },
                        -- {
                        --     CLASS = "action.QSBManualMode",     --进入手动模式
                        --     OPTIONS = {enter = true, revertable = true},
                        -- },
                        -- {
                        --     CLASS = "action.QSBStopMove",
                        -- },
                        {
                            CLASS = "action.QSBApplyBuff",      --加速
                            OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack12", is_loop = true},       
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
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "chongfeng_tongyong_xuanyun", is_target = true},
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
                },
            },
        },
    },
}

return tank_chongfeng