local tank_chongfeng = 
{
    CLASS = "composite.QSBParallel",
    -- OPTIONS = {forward_mode = true},
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        -- {
        --     CLASS = "action.QSBLockTarget",     --锁定目标
        --     OPTIONS = {is_lock_target = true, revertable = true},
        -- },
---入场动作+震屏
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack09_1"},
                        },                        
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 20 / 24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 12, duration = 0.4, count = 3,},
                        },              
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 50 / 24},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan_yujing",
                                        args = 
                                        {
                                            {delay_time = 1 / 24 , pos = { x = 1175, y = 520}} ,
                                            {delay_time = 3 / 24 , pos = { x = 1175, y = 470}} ,
                                            {delay_time = 5 / 24 , pos = { x = 1175, y = 415}} ,
                                            {delay_time = 7 / 24 , pos = { x = 1175, y = 355}} ,
                                            {delay_time = 9 / 24 , pos = { x = 1175, y = 295}} ,
                                            {delay_time = 11 / 24 , pos = { x = 1175, y = 235}} ,
                                            {delay_time = 13 / 24 , pos = { x = 1175, y = 175}} ,
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan_yujing",
                                        args = 
                                        {
                                            {delay_time = 13 / 24 , pos = { x = 100, y = 520}} ,
                                            {delay_time = 11 / 24 , pos = { x = 100, y = 470}} ,
                                            {delay_time = 9 / 24 , pos = { x = 100, y = 415}} ,
                                            {delay_time = 7 / 24 , pos = { x = 100, y = 355}} ,
                                            {delay_time = 5 / 24 , pos = { x = 100, y = 295}} ,
                                            {delay_time = 3 / 24 , pos = { x = 100, y = 235}} ,
                                            {delay_time = 1 / 24 , pos = { x = 100, y = 175}} ,
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
                            OPTIONS = {delay_time = 218  / 24},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan1",
                                        args = 
                                        {
                                            {delay_time = 1 / 24 , pos = { x = 1175, y = 520}} ,
                                            {delay_time = 3 / 24 , pos = { x = 1175, y = 470}} ,
                                            {delay_time = 5 / 24 , pos = { x = 1175, y = 415}} ,
                                            {delay_time = 7 / 24 , pos = { x = 1175, y = 355}} ,
                                            {delay_time = 9 / 24 , pos = { x = 1175, y = 295}} ,
                                            {delay_time = 11 / 24 , pos = { x = 1175, y = 235}} ,
                                            {delay_time = 13 / 24 , pos = { x = 1175, y = 175}} ,
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan2",
                                        args = 
                                        {
                                            {delay_time = 13 / 24 , pos = { x = 100, y = 520}} ,
                                            {delay_time = 11 / 24 , pos = { x = 100, y = 470}} ,
                                            {delay_time = 9 / 24 , pos = { x = 100, y = 415}} ,
                                            {delay_time = 7 / 24 , pos = { x = 100, y = 355}} ,
                                            {delay_time = 5 / 24 , pos = { x = 100, y = 295}} ,
                                            {delay_time = 3 / 24 , pos = { x = 100, y = 235}} ,
                                            {delay_time = 1 / 24 , pos = { x = 100, y = 175}} ,
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
                            OPTIONS = {delay_time = 230  / 24},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan3",
                                        args = 
                                        {
                                            {delay_time = 1 / 24 , pos = { x = 1175, y = 520}} ,
                                            {delay_time = 3 / 24 , pos = { x = 1175, y = 490}} ,
                                            {delay_time = 5 / 24 , pos = { x = 1175, y = 460}} ,
                                            {delay_time = 7 / 24 , pos = { x = 1175, y = 430}} ,
                                            {delay_time = 9 / 24 , pos = { x = 1175, y = 400}} ,
                                            {delay_time = 11 / 24 , pos = { x = 1175, y = 370}} ,
                                            {delay_time = 13 / 24 , pos = { x = 1175, y = 340}} ,
                                            {delay_time = 15 / 24 , pos = { x = 1175, y = 310}} ,
                                            {delay_time = 17 / 24 , pos = { x = 1175, y = 280}} ,
                                            {delay_time = 19 / 24 , pos = { x = 1175, y = 250}} ,
                                            {delay_time = 21 / 24 , pos = { x = 1175, y = 220}} ,
                                            {delay_time = 23 / 24 , pos = { x = 1175, y = 190}} ,
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan3",
                                        args = 
                                        {
                                            {delay_time = 23 / 24 , pos = { x = 100, y = 520}} ,
                                            {delay_time = 21 / 24 , pos = { x = 100, y = 490}} ,
                                            {delay_time = 19 / 24 , pos = { x = 100, y = 460}} ,
                                            {delay_time = 17 / 24 , pos = { x = 100, y = 430}} ,
                                            {delay_time = 15 / 24 , pos = { x = 100, y = 400}} ,
                                            {delay_time = 13 / 24 , pos = { x = 100, y = 370}} ,
                                            {delay_time = 11 / 24 , pos = { x = 100, y = 340}} ,
                                            {delay_time = 9 / 24 , pos = { x = 100, y = 310}} ,
                                            {delay_time = 7 / 24 , pos = { x = 100, y = 280}} ,
                                            {delay_time = 5 / 24 , pos = { x = 100, y = 250}} ,
                                            {delay_time = 3 / 24 , pos = { x = 100, y = 220}} ,
                                            {delay_time = 1 / 24 , pos = { x = 100, y = 190}} ,
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
                            OPTIONS = {delay_time = 225 / 24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 12, duration = 0.4, count = 1,},
                        },              
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 62 / 24},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan_yujing",
                                        args = 
                                        {
                                            {delay_time = 1 / 24 , pos = { x = 1025, y = 520}} ,
                                            {delay_time = 3 / 24 , pos = { x = 1025, y = 470}} ,
                                            {delay_time = 5 / 24 , pos = { x = 1025, y = 415}} ,
                                            {delay_time = 7 / 24 , pos = { x = 1025, y = 355}} ,
                                            {delay_time = 9 / 24 , pos = { x = 1025, y = 295}} ,
                                            {delay_time = 11 / 24 , pos = { x = 1025, y = 235}} ,
                                            {delay_time = 13 / 24 , pos = { x = 1025, y = 175}} ,
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan_yujing",
                                        args = 
                                        {
                                            {delay_time = 13 / 24 , pos = { x = 250, y = 520}} ,
                                            {delay_time = 11 / 24 , pos = { x = 250, y = 470}} ,
                                            {delay_time = 9 / 24 , pos = { x = 250, y = 415}} ,
                                            {delay_time = 7 / 24 , pos = { x = 250, y = 355}} ,
                                            {delay_time = 5 / 24 , pos = { x = 250, y = 295}} ,
                                            {delay_time = 3 / 24 , pos = { x = 250, y = 235}} ,
                                            {delay_time = 1 / 24 , pos = { x = 250, y = 175}} ,
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
                            OPTIONS = {delay_time = 230 / 24},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan1",
                                        args = 
                                        {
                                            {delay_time = 1 / 24 , pos = { x = 1025, y = 520}} ,
                                            {delay_time = 3 / 24 , pos = { x = 1025, y = 470}} ,
                                            {delay_time = 5 / 24 , pos = { x = 1025, y = 415}} ,
                                            {delay_time = 7 / 24 , pos = { x = 1025, y = 355}} ,
                                            {delay_time = 9 / 24 , pos = { x = 1025, y = 295}} ,
                                            {delay_time = 11 / 24 , pos = { x = 1025, y = 235}} ,
                                            {delay_time = 13 / 24 , pos = { x = 1025, y = 175}} ,
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan2",
                                        args = 
                                        {
                                            {delay_time = 13 / 24 , pos = { x = 250, y = 520}} ,
                                            {delay_time = 11 / 24 , pos = { x = 250, y = 470}} ,
                                            {delay_time = 9 / 24 , pos = { x = 250, y = 415}} ,
                                            {delay_time = 7 / 24 , pos = { x = 250, y = 355}} ,
                                            {delay_time = 5 / 24 , pos = { x = 250, y = 295}} ,
                                            {delay_time = 3 / 24 , pos = { x = 250, y = 235}} ,
                                            {delay_time = 1 / 24 , pos = { x = 250, y = 175}} ,
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
                            OPTIONS = {delay_time = 240 / 24},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan3",
                                        args = 
                                        {
                                            {delay_time = 1 / 24 , pos = { x = 1025, y = 520}} ,
                                            {delay_time = 3 / 24 , pos = { x = 1025, y = 490}} ,
                                            {delay_time = 5 / 24 , pos = { x = 1025, y = 460}} ,
                                            {delay_time = 7 / 24 , pos = { x = 1025, y = 430}} ,
                                            {delay_time = 9 / 24 , pos = { x = 1025, y = 400}} ,
                                            {delay_time = 11 / 24 , pos = { x = 1025, y = 370}} ,
                                            {delay_time = 13 / 24 , pos = { x = 1025, y = 340}} ,
                                            {delay_time = 15 / 24 , pos = { x = 1025, y = 310}} ,
                                            {delay_time = 17 / 24 , pos = { x = 1025, y = 280}} ,
                                            {delay_time = 19 / 24 , pos = { x = 1025, y = 250}} ,
                                            {delay_time = 21 / 24 , pos = { x = 1025, y = 220}} ,
                                            {delay_time = 23 / 24 , pos = { x = 1025, y = 190}} ,
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_daodan3",
                                        args = 
                                        {
                                            {delay_time = 23 / 24 , pos = { x = 250, y = 520}} ,
                                            {delay_time = 21 / 24 , pos = { x = 250, y = 490}} ,
                                            {delay_time = 19 / 24 , pos = { x = 250, y = 460}} ,
                                            {delay_time = 17 / 24 , pos = { x = 250, y = 430}} ,
                                            {delay_time = 15 / 24 , pos = { x = 250, y = 400}} ,
                                            {delay_time = 13 / 24 , pos = { x = 250, y = 370}} ,
                                            {delay_time = 11 / 24 , pos = { x = 250, y = 340}} ,
                                            {delay_time = 9 / 24 , pos = { x = 250, y = 310}} ,
                                            {delay_time = 7 / 24 , pos = { x = 250, y = 280}} ,
                                            {delay_time = 5 / 24 , pos = { x = 250, y = 250}} ,
                                            {delay_time = 3 / 24 , pos = { x = 250, y = 220}} ,
                                            {delay_time = 1 / 24 , pos = { x = 250, y = 190}} ,
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
                            OPTIONS = {delay_time = 240 / 24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 12, duration = 0.4, count = 2,},
                        },              
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 59 / 24 },
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack09_3" , no_stand = true},
                        },                        
                    },
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 89/ 24 },
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack09_4" ,no_stand = true , is_loop = true, is_keep_animation = true},
                        },
                        {
                            CLASS = "action.QSBActorKeepAnimation",
                            OPTIONS = {is_keep_animation = true} ,
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 60 / 24 },
                        },
                        {
                            CLASS = "action.QSBActorKeepAnimation",
                            OPTIONS = {is_keep_animation = false},
                        },                        
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 99 / 24 },
                        },
                         {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {target_random = true,start_pos = {x = 200,y = 250}},
                        },              
                    },
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 99 / 24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 7, duration = 0.35, count = 2,},
                        },            
                    },
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 119 / 24 },
                        },
                         {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {target_random = true,start_pos = {x = 200,y = 250}},
                        },              
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 119 / 24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 7, duration = 0.35, count = 2,},
                        },            
                    },
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 139 / 24 },
                        },
                         {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {target_random = true,start_pos = {x = 200,y = 250}},
                        },              
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 139 / 24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 7, duration = 0.35, count = 2,},
                        },            
                    },
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 159 / 24 },
                        },
                         {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {target_random = true,start_pos = {x = 200,y = 250}},
                        },              
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 159 / 24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 7, duration = 0.35, count = 2,},
                        },            
                    },
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 175 / 24 },
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack09_5" ,no_stand = true },
                        },               
                    },
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 200 / 24 },
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        }, 
                    },
                },  
            },
        },
    },
}

return tank_chongfeng