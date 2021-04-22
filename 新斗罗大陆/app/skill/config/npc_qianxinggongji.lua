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
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBStopMove",
        },
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
                            OPTIONS = {animation = "attack15_1", reload_on_cancel = true, revertable = true},       --对于会涉及隐身的animation，需要在QSBPlayAnimation中加入选项,reload_on_cancel = true,revertable = true
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
                                    OPTIONS = {delay_time = 14/24 },
                                },
                                {
                                    CLASS = "action.QSBActorFadeOut",
                                    OPTIONS = {duration = 0.2, revertable = true},
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
                            OPTIONS = {delay_time = 10/24 },
                        },
                        {
                            CLASS = "action.QSBApplyBuff",      --加速
                            OPTIONS = {buff_id = "qiandigongji"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 13/24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 3, duration = 0.2, count = 10},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 130/24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 10, duration = 0.25, count = 1},
                        },
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
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBMoveToTarget",   --攻击者移动到目标前面
                                            OPTIONS = {is_position = true, effect_id = "qianxinggongji", effect_interval = 60, scale_actor_face = 1},        -- 移动过程中在路径上产生的地面效果 ； 地面效果的距离间隔
                                        },
                                        -- {
                                        --     CLASS = "composite.QSBParallel",
                                        --     ARGS = 
                                        --     {                                        
                                        --         {
                                        --             CLASS = "action.QSBStopMove",
                                        --         },
                                        --         {
                                        --             CLASS = "action.QSBApplyBuff",      --加速
                                        --             OPTIONS = {buff_id = "qiandigongji2"},
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
                                            OPTIONS = {delay_time = 48/24 },
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {                                        
                                                {
                                                    CLASS = "action.QSBStopMove",
                                                },
                                                {
                                                    CLASS = "action.QSBApplyBuff",      --加速
                                                    OPTIONS = {buff_id = "qiandigongji2"},
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
                                            OPTIONS = {delay_time = 49/24 },
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {                                        
                                                {
                                                    CLASS = "action.QSBApplyBuff",      --加速
                                                    OPTIONS = {buff_id = "qiandigongji3"},
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
                                            OPTIONS = {delay_time = 103/24 },
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
                                                            OPTIONS = {animation = "attack15", reload_on_cancel = true, revertable = true},
                                                        },
                                                        {
                                                            CLASS = "action.QSBActorFadeIn",
                                                            OPTIONS = {duration = 0.1, revertable = true},
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
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 120/24 },
                                        },
                                        {
                                            CLASS = "action.QSBRemoveBuff",     --去除加速
                                            OPTIONS = {buff_id = "qiandigongji"},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 109/24 },
                                        },
                                        {
                                             CLASS = "action.QSBHitTarget",
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
}

return tank_chongfeng