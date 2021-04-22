local boss_zhaowuji_zhonglijiya = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 145 / 24 },
                },                   
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 12, duration = 0.35, count = 2,},
                },
            },
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
                            OPTIONS = {animation = "attack17"},
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="jixiezhizhu_attack17"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 42 / 24 },
                                },
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0.1, attacker_face = false,attacker_underfoot = true,count = 1, distance = 0, trapId = "jixiezhizhu_dianjiang"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 24 / 24 },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                                            OPTIONS = { pos = {x=100,y=280} , move_time = 15 / 24},
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 14 / 24 },
                                                },                   
                                                {
                                                    CLASS = "action.QSBShakeScreen",
                                                    OPTIONS = {amplitude = 6, duration = 0.25, count = 1,},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 16 / 24 },
                                                },                   
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {effect_id = "jinshuboss2_attack20_4" , is_hit_effect = false},
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
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 55 / 24 },
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
                                    CLASS = "action.QSBRoledirection",
                                    OPTIONS = {direction = "right"},       
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
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = "boss_liuerlong_huoyanbo_hongkuang", is_target = false},
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
                                            CLASS = "action.QSBPlayAnimation",
                                            OPTIONS = {animation = "attack13"},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 21 / 24 },
                                        },
                                        {
                                            CLASS = "action.QSBShakeScreen",
                                            OPTIONS = {amplitude = 8, duration = 0.35, count = 2,},
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
                                    OPTIONS = {delay_time = 44 / 24 },
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
                                                    CLASS = "action.QSBPlayAnimation",
                                                    OPTIONS = {animation = "attack19_1"},
                                                },
                                                {
                                                    CLASS = "action.QSBPlaySound",
                                                    OPTIONS = {sound_id ="jixiezhizhu_attack19",is_loop = true},
                                                },  
                                                {
                                                    CLASS = "action.QSBPlayAnimation",
                                                    OPTIONS = {animation = "attack19_2", is_loop = true, is_keep_animation = true},
                                                },
                                                {
                                                    CLASS = "action.QSBActorKeepAnimation",
                                                    OPTIONS = {is_keep_animation = true}
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
                                                    CLASS = "action.QSBHeroicalLeap",
                                                    OPTIONS = {distance = 1350, move_time = 24/24, interval_time = 1 / 24, is_hit_target = true, bound_height = 50},
                                                },
                                                {
                                                    CLASS = "action.QSBActorKeepAnimation",
                                                    OPTIONS = {is_keep_animation = false},
                                                },
                                                {
                                                    CLASS = "action.QSBStopSound",
                                                    OPTIONS = {sound_id ="jixiezhizhu_attack19"},
                                                },
                                                {
                                                    CLASS = "action.QSBStopMove",
                                                },
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_time = 12 / 24 },
                                                },
                                                {
                                                    CLASS = "action.QSBAttackFinish",
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
                                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                                    OPTIONS = {interval_time = 0.125, attacker_face = false,attacker_underfoot = true,count = 8, distance = 190, trapId = "jixiezhizhu_dianjiang"},
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

return boss_zhaowuji_zhonglijiya