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
            OPTIONS = {is_target = false, buff_id = "mianyi_chongfeng_zhuangtai"},
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
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBActorFadeOut",
                                    OPTIONS = {duration = 0.1, revertable = true},
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
                            OPTIONS = {delay_time = 6/24 },
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="duguyan_attack11"},
                        },    
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 6/24 },
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="duguyan_attack14"},
                        },    
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 16/24 },
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="duguyan_attack01"},
                        },    
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2/24 },
                        },
                        {
                            CLASS = "action.QSBTeleportToAbsolutePosition",
                            OPTIONS = {pos = {x = 1000, y = 300}},
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
                            CLASS = "action.QSBHitTarget",
                        },  
                    },
                },
                {
                    CLASS = "composite.QSBSequence",    -- 入场魂环
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 48/24 },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "tongyongzihunhuan_soul_2" , is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 5/24 },
                        },
                        {
                             CLASS = "composite.QSBSequence",
                             ARGS = 
                             {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack11", reload_on_cancel = true, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {is_target = false, buff_id = "mianyi_chongfeng_zhuangtai"},
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
                            OPTIONS = {delay_time = 15/24 },
                        },
                        {
                            CLASS = "action.QSBActorFadeIn",
                            OPTIONS = {duration = 1, revertable = true},
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
}

return tank_chongfeng