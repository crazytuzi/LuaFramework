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
        {
            CLASS = "action.QSBLockTarget",     --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true},
        },
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
                            OPTIONS = {animation = "attack05_1"},
                        },                        
                    },
                },
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
                -----淡出
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 33 /24 },
                        },
                        {
                            CLASS = "action.QSBActorFadeOut",
                            OPTIONS = {duration = 5 / 24, revertable = true},
                        },
                    },
                }, 
            },
        },
----火焰路径1
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {      
                {
                    CLASS = "action.QSBTrap",  
                    OPTIONS = 
                    { 
                        trapId = "diliepo_yujing6",
                        args = 
                        {
                            {delay_time = 19 / 24 , pos = { x = 660, y = 520}} ,
                            {delay_time = 20 / 24 , pos = { x = 597, y = 496}} ,
                            {delay_time = 21 / 24 , pos = { x = 534, y = 471}} ,
                            {delay_time = 22 / 24 , pos = { x = 471, y = 446}} ,
                            {delay_time = 23 / 24 , pos = { x = 408, y = 421}} ,
                            {delay_time = 24 / 24 , pos = { x = 345, y = 396}} ,
                            {delay_time = 25 / 24 , pos = { x = 282, y = 372}} ,
                            {delay_time = 26 / 24 , pos = { x = 220, y = 350}} ,
                        },
                    },
                },
                {
                    CLASS = "action.QSBTrap",  
                    OPTIONS = 
                    { 
                        trapId = "diliepo_yujing6",
                        args = 
                        {
                            {delay_time = 19 / 24 , pos = { x = 660, y = 520}} ,
                            {delay_time = 20 / 24 , pos = { x = 723, y = 496}} ,
                            {delay_time = 21 / 24 , pos = { x = 789, y = 471}} ,
                            {delay_time = 22 / 24 , pos = { x = 852, y = 446}} ,
                            {delay_time = 23 / 24 , pos = { x = 915, y = 421}} ,
                            {delay_time = 24 / 24 , pos = { x = 978, y = 396}} ,
                            {delay_time = 25 / 24 , pos = { x = 1041, y = 372}} ,
                            {delay_time = 26 / 24 , pos = { x = 1100, y = 350}} ,
                        },
                    },
                },
                {
                    CLASS = "action.QSBTrap",  
                    OPTIONS = 
                    { 
                        trapId = "diliepo_yujing6",
                        args = 
                        {
                            {delay_time = 19 / 24 , pos = { x = 660, y = 150}} ,
                            {delay_time = 20 / 24 , pos = { x = 723, y = 179}} ,
                            {delay_time = 21 / 24 , pos = { x = 789, y = 208}} ,
                            {delay_time = 22 / 24 , pos = { x = 852, y = 237}} ,
                            {delay_time = 23 / 24 , pos = { x = 915, y = 266}} ,
                            {delay_time = 24 / 24 , pos = { x = 978, y = 295}} ,
                            {delay_time = 25 / 24 , pos = { x = 1041, y = 324}} ,
                            {delay_time = 26 / 24 , pos = { x = 1100, y = 350}} ,
                        },
                    },
                },
                {
                    CLASS = "action.QSBTrap",  
                    OPTIONS = 
                    { 
                        trapId = "diliepo_yujing6",
                        args = 
                        {
                            {delay_time = 19 / 24 , pos = { x = 660, y = 150}} ,
                            {delay_time = 20 / 24 , pos = { x = 597, y = 179}} ,
                            {delay_time = 21 / 24 , pos = { x = 534, y = 208}} ,
                            {delay_time = 22 / 24 , pos = { x = 471, y = 237}} ,
                            {delay_time = 23 / 24 , pos = { x = 408, y = 266}} ,
                            {delay_time = 24 / 24 , pos = { x = 345, y = 295}} ,
                            {delay_time = 25 / 24 , pos = { x = 282, y = 324}} ,
                            {delay_time = 26 / 24 , pos = { x = 220, y = 350}} ,
                        },
                    },
                },
                {
                    CLASS = "action.QSBTrap",  
                    OPTIONS = 
                    { 
                        trapId = "diliepo_yujing7",
                        args = 
                        {
                            {delay_time = 19 / 24 , pos = { x = 660, y = 520}} ,
                            {delay_time = 20 / 24 , pos = { x = 597, y = 496}} ,
                            {delay_time = 21 / 24 , pos = { x = 534, y = 471}} ,
                            {delay_time = 22 / 24 , pos = { x = 471, y = 446}} ,
                            {delay_time = 23 / 24 , pos = { x = 408, y = 421}} ,
                            {delay_time = 24 / 24 , pos = { x = 345, y = 396}} ,
                            {delay_time = 25 / 24 , pos = { x = 282, y = 372}} ,
                        },
                    },
                },
                {
                    CLASS = "action.QSBTrap",  
                    OPTIONS = 
                    { 
                        trapId = "diliepo_yujing7",
                        args = 
                        {
                            {delay_time = 19 / 24 , pos = { x = 660, y = 520}} ,
                            {delay_time = 20 / 24 , pos = { x = 723, y = 496}} ,
                            {delay_time = 21 / 24 , pos = { x = 789, y = 471}} ,
                            {delay_time = 22 / 24 , pos = { x = 852, y = 446}} ,
                            {delay_time = 23 / 24 , pos = { x = 915, y = 421}} ,
                            {delay_time = 24 / 24 , pos = { x = 978, y = 396}} ,
                            {delay_time = 25 / 24 , pos = { x = 1041, y = 372}} ,
                            {delay_time = 26 / 24 , pos = { x = 1100, y = 350}} ,
                        },
                    },
                },
                {
                    CLASS = "action.QSBTrap",  
                    OPTIONS = 
                    { 
                        trapId = "diliepo_yujing7",
                        args = 
                        {
                            {delay_time = 19 / 24 , pos = { x = 660, y = 150}} ,
                            {delay_time = 20 / 24 , pos = { x = 723, y = 179}} ,
                            {delay_time = 21 / 24 , pos = { x = 789, y = 208}} ,
                            {delay_time = 22 / 24 , pos = { x = 852, y = 237}} ,
                            {delay_time = 23 / 24 , pos = { x = 915, y = 266}} ,
                            {delay_time = 24 / 24 , pos = { x = 978, y = 295}} ,
                            {delay_time = 25 / 24 , pos = { x = 1041, y = 324}} ,
                            {delay_time = 26 / 24 , pos = { x = 1100, y = 350}} ,
                        },
                    },
                },
                {
                    CLASS = "action.QSBTrap",  
                    OPTIONS = 
                    { 
                        trapId = "diliepo_yujing7",
                        args = 
                        {
                            {delay_time = 19 / 24 , pos = { x = 660, y = 150}} ,
                            {delay_time = 20 / 24 , pos = { x = 597, y = 179}} ,
                            {delay_time = 21 / 24 , pos = { x = 534, y = 208}} ,
                            {delay_time = 22 / 24 , pos = { x = 471, y = 237}} ,
                            {delay_time = 23 / 24 , pos = { x = 408, y = 266}} ,
                            {delay_time = 24 / 24 , pos = { x = 345, y = 295}} ,
                            {delay_time = 25 / 24 , pos = { x = 282, y = 324}} ,
                            {delay_time = 26 / 24 , pos = { x = 220, y = 350}} ,
                        },
                    },
                },
                {
                    CLASS = "action.QSBTrap",  
                    OPTIONS = 
                    { 
                        trapId = "diliepo_yujing8",
                        args = 
                        {
                            {delay_time = 26 / 24 , pos = { x = 220, y = 350}} ,
                        },
                    },
                },
                {
                    CLASS = "action.QSBTrap",  
                    OPTIONS = 
                    { 
                        trapId = "diliepo_yujing8",
                        args = 
                        {
                            {delay_time = 26 / 24 , pos = { x = 1100, y = 350}} ,
                        },
                    },
                },
            },
        },
--------火焰路径2
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 5 / 24 },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "diliepo_yujing6",
                                args = 
                                {
                                    {delay_time = 30 / 24 , pos = { x = 220, y = 350}} ,
                                    {delay_time = 31 / 24 , pos = { x = 282, y = 350}} ,
                                    {delay_time = 32 / 24 , pos = { x = 345, y = 350}} ,
                                    {delay_time = 33 / 24 , pos = { x = 408, y = 350}} ,
                                    {delay_time = 34 / 24 , pos = { x = 471, y = 350}} ,
                                    {delay_time = 35 / 24 , pos = { x = 534, y = 350}} ,
                                    {delay_time = 36 / 24 , pos = { x = 597, y = 350}} ,
                                    {delay_time = 37 / 24 , pos = { x = 660, y = 350}} ,
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "diliepo_yujing6",
                                args = 
                                {
                                    {delay_time = 30 / 24 , pos = { x = 1100, y = 350}} ,
                                    {delay_time = 31 / 24 , pos = { x = 1038, y = 350}} ,
                                    {delay_time = 32 / 24 , pos = { x = 976, y = 350}} ,
                                    {delay_time = 33 / 24 , pos = { x = 914, y = 350}} ,
                                    {delay_time = 34 / 24 , pos = { x = 852, y = 350}} ,
                                    {delay_time = 35 / 24 , pos = { x = 790, y = 350}} ,
                                    {delay_time = 36 / 24 , pos = { x = 728, y = 350}} ,
                                    {delay_time = 37 / 24 , pos = { x = 660, y = 350}} ,
                                },
                            },
                        },
                    },
                },
            },
        },
---------落地后激光2
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 165/ 24 },
                },
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 22, duration = 0.4, count = 2},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 167/ 24 },
                },
                {
                    CLASS = "action.QSBSummonMonsters",
                    OPTIONS = {wave = -1,attacker_level = false},
                },
                {
                    CLASS = "action.QSBLockTarget",
                    OPTIONS = {is_lock_target = false},
                },
            },
        },
        {
            CLASS = "action.QSBTrap",  
            OPTIONS = 
            { 
                trapId = "diliepo_jiguang2",
                args = 
                {
                    {delay_time = 179 / 24 , pos = { x = 220, y = 350}} ,
                    {delay_time = 179 / 24 , pos = { x = 1100, y = 350}} ,
                },
            },
        },
        {
            CLASS = "action.QSBTrap",  
            OPTIONS = 
            { 
                trapId = "diliepo_jiguang2",
                args = 
                {
                    {delay_time = 165 / 24 , pos = { x = 660, y = 520}} ,
                    {delay_time = 167 / 24 , pos = { x = 597, y = 496}} ,
                    {delay_time = 169 / 24 , pos = { x = 534, y = 471}} ,
                    {delay_time = 171 / 24 , pos = { x = 471, y = 446}} ,
                    {delay_time = 173 / 24 , pos = { x = 408, y = 421}} ,
                    {delay_time = 175 / 24 , pos = { x = 345, y = 396}} ,
                    {delay_time = 177 / 24 , pos = { x = 282, y = 372}} ,
                    -- {delay_time = 179 / 24 , pos = { x = 220, y = 350}} ,
                },
            },
        },
        {
            CLASS = "action.QSBTrap",  
            OPTIONS = 
            { 
                trapId = "diliepo_jiguang2",
                args = 
                {
                    -- {delay_time = 165 / 24 , pos = { x = 660, y = 520}} ,
                    {delay_time = 167 / 24 , pos = { x = 723, y = 496}} ,
                    {delay_time = 169 / 24 , pos = { x = 789, y = 471}} ,
                    {delay_time = 171 / 24 , pos = { x = 852, y = 446}} ,
                    {delay_time = 173 / 24 , pos = { x = 915, y = 421}} ,
                    {delay_time = 175 / 24 , pos = { x = 978, y = 396}} ,
                    {delay_time = 177 / 24 , pos = { x = 1041, y = 372}} ,
                    -- {delay_time = 172 / 24 , pos = { x = 1100, y = 350}} ,
                },
            },
        },
        {
            CLASS = "action.QSBTrap",  
            OPTIONS = 
            { 
                trapId = "diliepo_jiguang2",
                args = 
                {
                    {delay_time = 165 / 24 , pos = { x = 660, y = 150}} ,
                    {delay_time = 167 / 24 , pos = { x = 723, y = 179}} ,
                    {delay_time = 169 / 24 , pos = { x = 789, y = 208}} ,
                    {delay_time = 171 / 24 , pos = { x = 852, y = 237}} ,
                    {delay_time = 173 / 24 , pos = { x = 915, y = 266}} ,
                    {delay_time = 175 / 24 , pos = { x = 978, y = 295}} ,
                    {delay_time = 177 / 24 , pos = { x = 1041, y = 324}} ,
                    -- {delay_time = 179 / 24 , pos = { x = 1100, y = 350}} ,
                },
            },
        },
        {
            CLASS = "action.QSBTrap",  
            OPTIONS = 
            { 
                trapId = "diliepo_jiguang2",
                args = 
                {
                    -- {delay_time = 165 / 24 , pos = { x = 660, y = 150}} ,
                    {delay_time = 167 / 24 , pos = { x = 597, y = 179}} ,
                    {delay_time = 169 / 24 , pos = { x = 534, y = 208}} ,
                    {delay_time = 171 / 24 , pos = { x = 471, y = 237}} ,
                    {delay_time = 173 / 24 , pos = { x = 408, y = 266}} ,
                    {delay_time = 175 / 24 , pos = { x = 345, y = 295}} ,
                    {delay_time = 177 / 24 , pos = { x = 282, y = 324}} ,
                    -- {delay_time = 172 / 24 , pos = { x = 220, y = 350}} ,
                },
            },
        },
-------中心落点预警
        {
            CLASS = "action.QSBTrap",  
            OPTIONS = 
            { 
                trapId = "daimubai_hongquan",
                args = 
                {
                    {delay_time = 46 / 24 , pos = { x = 660, y = 350}} ,
                },
            },
        },
        {
            CLASS = "action.QSBTrap",  
            OPTIONS = 
            { 
                trapId = "diliepo_yujing1",
                args = 
                {
                    {delay_time = 41 / 24 , pos = { x = 660, y = 350}} ,
                },
            },
        },
        {
            CLASS = "action.QSBTrap",  
            OPTIONS = 
            { 
                trapId = "diliepo_yujing2",
                args = 
                {
                    {delay_time = 46 / 24 , pos = { x = 660, y = 350}} ,
                },
            },
        },
-----淡出
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 36 /24 },
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 2 / 24, revertable = true},
                },
            },
        },
----落地
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 36 /24 },
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
                                    OPTIONS = {delay_time = 42 /24 },
                                },
                                {
                                    CLASS = "action.QSBTeleportToAbsolutePosition",
                                    OPTIONS = {pos = {x = 770, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 64 /24 },
                                },
                                {
                                    CLASS = "action.QSBRoledirection",
                                    OPTIONS = {direction = "left"},       
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 66/ 24 },
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack05_2"},
                                }, 
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 24/ 24 },
                                },
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
                                    OPTIONS = {delay_time = 77/ 24 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 20, duration = 0.35, count = 1},
                                },
                            },
                        }, 
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 97/ 24 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 20, duration = 0.35, count = 1},
                                },
                            },
                        }, 
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 97/ 24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "diliepo_zhongxin",
                                        args = 
                                        {
                                            {delay_time = 0 / 24 , pos = { x = 660, y = 350}} ,
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
                                    OPTIONS = {delay_time = 66 /24 },
                                },
                                {
                                    CLASS = "action.QSBActorFadeIn",
                                    OPTIONS = {duration = 1 / 24, revertable = true},
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