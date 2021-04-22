local tank_chongfeng = 
{
    CLASS = "composite.QSBSequence",
    -- OPTIONS = {forward_mode = true},
    ARGS = 
    {
        -- {
        --     CLASS = "action.QSBManualMode",     --进入手动模式
        --     OPTIONS = {enter = true, revertable = true},
        -- },
        -- {
        --     CLASS = "action.QSBStopMove",
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
                            OPTIONS = {animation = "attack12"}, 
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "heihu_attack12_1_1" , is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "heihu_attack12_1_2" , is_hit_effect = false},
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
                                    OPTIONS = {delay_time = 56/24 },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBHitTarget",
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "heihu_attack12_1_3" , is_hit_effect = false},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "heihu_attack12_1_4" , is_hit_effect = false},
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
                                    OPTIONS = {delay_time = 1 / 24 },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    OPTIONS = {forward_mode = true},
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBArgsIsDirectionLeft",
                                            OPTIONS = {is_attacker = true},
                                        },
                                        {
                                            CLASS = "composite.QSBSelector",
                                            ARGS = 
                                            {   
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 36/24 },
                                                        },
                                                        {
                                                            CLASS = "action.QSBArgsPosition",
                                                            OPTIONS = {is_attackee = true},
                                                        },
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_frame = 0, pass_key = {"pos"}},
                                                        },
                                                        {
                                                            CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                                                            OPTIONS = {move_time = 0.3,offset = {x= 100,y=0}},
                                                        },                                                                                                   
                                                        {
                                                            CLASS = "action.QSBLockTarget",
                                                            OPTIONS = {is_lock_target = false},
                                                        },
                                                        -- {
                                                        --     CLASS = "action.QSBManualMode",
                                                        --     OPTIONS = {exit = true},
                                                        -- },
                                                        {
                                                            CLASS = "action.QSBAttackFinish"
                                                        }, 
                                                    },
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 36/24 },
                                                        },
                                                        {
                                                            CLASS = "action.QSBArgsPosition",
                                                            OPTIONS = {is_attackee = true},
                                                        },
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_frame = 0, pass_key = {"pos"}},
                                                        },
                                                        {
                                                            CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                                                            OPTIONS = {move_time = 0.3,offset = {x= -100,y=0}},
                                                        },                                                                                                   
                                                        {
                                                            CLASS = "action.QSBLockTarget",
                                                            OPTIONS = {is_lock_target = false},
                                                        },
                                                        -- {
                                                        --     CLASS = "action.QSBManualMode",
                                                        --     OPTIONS = {exit = true},
                                                        -- },
                                                        {
                                                            CLASS = "action.QSBAttackFinish"
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
                },
            },
        },
    },
}

return tank_chongfeng