local tank_chongfeng = 
{
    CLASS = "composite.QSBParallel",
    -- OPTIONS = {forward_mode = true},
    ARGS = 
    {
        -- {
        --     CLASS = "action.QSBManualMode",     --进入手动模式
        --     OPTIONS = {enter = true, revertable = true},
        -- },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        -- {
        --     CLASS = "action.QSBStopMove",
        -- },
        -- {
        --     CLASS = "action.QSBLockTarget",     --锁定目标
        --     OPTIONS = {is_lock_target = true, revertable = true},
        -- },
        {
            CLASS = "action.QSBActorFadeOut",
            OPTIONS = {duration = 0.1, revertable = true},
        },
        {
            CLASS = "action.QSBTrap", 
            OPTIONS = 
            { 
                trapId = "dadi_ruchang_xuanwo",
                args = 
                {
                    {delay_time = 0 , pos = { x = 1000, y = 320}} ,
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
                    OPTIONS = {pos = {x = 1000, y = 320}},
                },
            },
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack13", reload_on_cancel = true, revertable = true},
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
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 10, duration = 0.45, count = 1,},
                        }, 
                        {
                            CLASS = "action.QSBHitTarget",
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
                    OPTIONS = {delay_time = 26/24 },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBTrap", 
                            OPTIONS = 
                            { 
                                trapId = "dadi_ruchang_yujing",
                                args = 
                                {
                                    {delay_time = 0 /24 , pos = { x = 50, y = 570}} ,
                                    {delay_time = 0 /24, pos = { x = 50, y = 120}},
                                    {delay_time = 2 /24, pos = { x = 150, y = 540}},
                                    {delay_time = 2 /24, pos = { x = 150, y = 150}},
                                    {delay_time = 4 /24, pos = { x = 220, y = 515}},
                                    {delay_time = 4 /24, pos = { x = 220, y = 175}},
                                    {delay_time = 6 /24, pos = { x = 290, y = 490}},
                                    {delay_time = 6 /24, pos = { x = 290, y = 200}},
                                    {delay_time = 8 /24, pos = { x = 360, y = 465}},
                                    {delay_time = 8 /24, pos = { x = 360, y = 225}},
                                    {delay_time = 10 /24, pos = { x = 430, y = 440}},
                                    {delay_time = 10 /24, pos = { x = 430, y = 250}},
                                    {delay_time = 12 /24, pos = { x = 500, y = 415}},
                                    {delay_time = 12 /24, pos = { x = 500, y = 275}},
                                    {delay_time = 14 /24, pos = { x = 570, y = 390}},
                                    {delay_time = 14 /24, pos = { x = 570, y = 300}},
                                    {delay_time = 16 /24, pos = { x = 640, y = 365}},
                                    {delay_time = 16 /24, pos = { x = 640, y = 325}},
                                    {delay_time = 18 /24, pos = { x = 710, y = 340}},
                                    {delay_time = 20 /24, pos = { x = 640, y = 340}},
                                    {delay_time = 21 /24, pos = { x = 570, y = 340}},
                                    {delay_time = 22 /24, pos = { x = 500, y = 340}},
                                    {delay_time = 23 /24, pos = { x = 430, y = 340}},
                                    {delay_time = 24 /24, pos = { x = 360, y = 340}},
                                    {delay_time = 25 /24, pos = { x = 290, y = 340}},
                                    {delay_time = 26 /24, pos = { x = 220, y = 340}},
                                    {delay_time = 27 /24, pos = { x = 150, y = 340}},
                                    {delay_time = 28 /24, pos = { x = 50, y = 340}},
                                },
                            },
                        }, 
                        {
                            CLASS = "action.QSBTrap", 
                            OPTIONS = 
                            { 
                                trapId = "dadi_ruchang_huozhu",
                                args = 
                                {
                                    {delay_time = 20 /24, pos = { x = 710, y = 340}},
                                    {delay_time = 22 /24, pos = { x = 630, y = 340}},
                                    {delay_time = 24 /24, pos = { x = 550, y = 340}},
                                    {delay_time = 26 /24, pos = { x = 470, y = 340}},
                                    {delay_time = 28 /24, pos = { x = 390, y = 340}},
                                    {delay_time = 30 /24, pos = { x = 310, y = 340}},
                                    {delay_time = 34 /24, pos = { x = 230, y = 340}},
                                    {delay_time = 36 /24, pos = { x = 150, y = 340}},
                                    {delay_time = 38 /24, pos = { x = 70, y = 340}},
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
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBShakeScreen",
                                            OPTIONS = {amplitude = 10, duration = 0.35, count = 3,},
                                        },
                                    },
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
                    OPTIONS = {delay_time = 29/24 },
                },
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = 
                     {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack12", reload_on_cancel = true, revertable = true},
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
                    OPTIONS = {delay_time = 5/24 },
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 1, revertable = true},
                },
            },
        },
        -- {
        --     CLASS = "action.QSBManualMode",
        --     OPTIONS = {exit = true},
        -- },
    },
}

return tank_chongfeng