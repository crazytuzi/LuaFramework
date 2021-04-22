local tank_chongfeng = 
{
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = 
    {
        {
            CLASS = "action.QSBManualMode",     --进入手动模式
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBLockTarget",     --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = true, buff_id = "lockon_4s"},
        },
        {
            CLASS = "action.QSBStopMove",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
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
                                            OPTIONS = {animation = "attack05_1", reload_on_cancel = true, revertable = true},       --对于会涉及隐身的animation，需要在QSBPlayAnimation中加入选项,reload_on_cancel = true,revertable = true
                                        },
                                        -- {
                                        --     CLASS = "composite.QSBSequence",
                                        --     ARGS = 
                                        --     {
                                        --         {
                                        --             CLASS = "action.QSBPlayEffect",
                                        --             OPTIONS = {effect_id = "fulande_atk13_3_2" , is_hit_effect = true},
                                        --         },
                                        --     },
                                        -- },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 36/24 },
                                                },
                                                {
                                                    CLASS = "action.QSBActorFadeOut",
                                                    OPTIONS = {duration = 0.01, revertable = true},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 2 / 24 },
                                                        },
                                                        {
                                                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                                            OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 0, trapId = "diliepo_yujing3"},
                                                        },
                                                    },
                                                }, 
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 15 / 24 },
                                                        },
                                                        {
                                                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                                            OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 0, trapId = "diliepo_yujing4"},
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 19 / 24 },
                                                        },
                                                        {
                                                            CLASS = "action.QSBShakeScreen",
                                                            OPTIONS = {amplitude = 10, duration = 0.35, count = 1},
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 29 / 24 },
                                                        },
                                                        {
                                                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                                            OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 0, trapId = "diliepo_yujing5"},
                                                        },
                                                    },
                                                }, 
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 29 / 24 },
                                                        },
                                                        {
                                                            CLASS = "action.QSBShakeScreen",
                                                            OPTIONS = {amplitude = 15, duration = 0.35, count = 1},
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 40/24 },
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBMoveToTarget",   --攻击者移动到目标前面
                                                    -- OPTIONS = {is_position = true, effect_id = "langhunshi_xingluo", effect_interval = 60, scale_actor_face = 1}, 
                                                    OPTIONS = {is_position = true},       -- 移动过程中在路径上产生的地面效果 ； 地面效果的距离间隔
                                                },
                                                {
                                                    CLASS = "action.QSBApplyBuff",      --加速
                                                    OPTIONS = {buff_id = "langhunshi_xingluo"},
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 48/24 },
                                                        },
                                                        {
                                                            CLASS = "action.QSBStopMove",
                                                        },
                                                        {
                                                             CLASS = "composite.QSBSequence",
                                                             ARGS = 
                                                             {
                                                                {
                                                                    CLASS = "composite.QSBParallel",
                                                                    ARGS = 
                                                                    {
                                                                        {
                                                                            CLASS = "action.QSBPlayAnimation",
                                                                            OPTIONS = {animation = "attack05_2", reload_on_cancel = true, revertable = true},
                                                                        },
                                                                        {
                                                                            CLASS = "action.QSBActorFadeIn",
                                                                            OPTIONS = {duration = 0.01, revertable = true},
                                                                        },
                                                                    },
                                                                },
                                                                {
                                                                    CLASS = "action.QSBReloadAnimation",
                                                                },
                                                                {
                                                                    CLASS = "action.QSBActorStand",
                                                                },
                                                                {
                                                                    CLASS = "action.QSBLockTarget",
                                                                    OPTIONS = {is_lock_target = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBAttackFinish"
                                                                },
                                                            },
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 62/24 },
                                                        },
                                                        {
                                                             CLASS = "action.QSBHitTarget",
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
                                                        {
                                                            CLASS = "action.QSBShakeScreen",
                                                            OPTIONS = {amplitude = 10, duration = 0.35, count = 2},
                                                        },
                                                    },
                                                },
                                            },
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
                },
            },
        },
    },
}

return tank_chongfeng