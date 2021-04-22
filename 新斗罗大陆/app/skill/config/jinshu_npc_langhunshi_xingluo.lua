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
            CLASS = "action.QSBStopMove",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_2" },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 7/24 },
                        }, 
                        {
                            CLASS = "action.QSBHeroicalLeap",
                            OPTIONS = {speed = 800 ,move_time = 10/24}
                        }, 
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 25/24 },
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
                                            OPTIONS = {animation = "attack12_1", reload_on_cancel = true, revertable = true},       --对于会涉及隐身的animation，需要在QSBPlayAnimation中加入选项,reload_on_cancel = true,revertable = true
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
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
                                                    OPTIONS = {delay_time = 19/24 },
                                                },
                                                {
                                                    CLASS = "action.QSBActorFadeOut",
                                                    OPTIONS = {duration = 0.01, revertable = true},
                                                },
                                            },
                                        },
                                        -- {
                                        --     CLASS = "composite.QSBSequence",
                                        --     ARGS = 
                                        --     {
                                        --         {
                                        --             CLASS = "action.QSBDelayTime",
                                        --             OPTIONS = {delay_time = 2/24 },
                                        --         },
                                        --         {
                                        --             CLASS = "action.QSBMoveToTarget",   --攻击者移动到目标前面
                                        --             OPTIONS = {is_position = true},       -- 移动过程中在路径上产生的地面效果 ； 地面效果的距离间隔
                                        --         },
                                        --     },
                                        -- },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 20/24 },
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
                                                             CLASS = "composite.QSBSequence",
                                                             ARGS = 
                                                             {
                                                                {
                                                                    CLASS = "composite.QSBParallel",
                                                                    ARGS = 
                                                                    {
                                                                        {
                                                                            CLASS = "action.QSBPlayAnimation",
                                                                            OPTIONS = {animation = "attack12_2", reload_on_cancel = true, revertable = true},
                                                                        },
                                                                        {
                                                                            CLASS = "action.QSBActorFadeIn",
                                                                            OPTIONS = {duration = 0.01, revertable = true},
                                                                        },
                                                                    },
                                                                },
                                                                {
                                                                    CLASS = "action.QSBRemoveBuff",
                                                                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBReloadAnimation",
                                                                },
                                                                {
                                                                    CLASS = "action.QSBActorStand",
                                                                },
                                                                {
                                                                    CLASS = "action.QSBAttackFinish"
                                                                },
                                                            },
                                                        },
                                                    },
                                                },
                                                -- {
                                                --     CLASS = "composite.QSBSequence",
                                                --     ARGS = 
                                                --     {
                                                --         {
                                                --             CLASS = "action.QSBDelayTime",
                                                --             OPTIONS = {delay_time = 120/24 },
                                                --         },
                                                --         {
                                                --             CLASS = "action.QSBRemoveBuff",     --去除加速
                                                --             OPTIONS = {buff_id = "qiandigongji"},
                                                --         },
                                                --     },
                                                -- },
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
                },
            },
        },
    },
}

return tank_chongfeng