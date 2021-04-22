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
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 12},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "qianrenxue_attack11_1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 50},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_qianrenxue02_attack11_3", is_hit_effect = false},
                },   
            },
        },
---入场动作+震屏
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_1"},
                },                        
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 46 /24 },
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 1 / 24, revertable = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 47 /24 },
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 1 / 24, revertable = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 47 /24 },
                },
                {
                    CLASS = "action.QSBTeleportToAbsolutePosition",
                    OPTIONS = {pos = {x = 660, y = 340}},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 48 / 24 },
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_2_1"},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 48 / 24 },
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
                                    OPTIONS = {delay_time = 5/24 },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBShakeScreen",
                                            OPTIONS = {amplitude = 12, duration = 0.45, count = 1,},
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
                        --             OPTIONS = {delay_time = 10/24 },
                        --         },
                        --         {
                        --             CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                        --             OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 0, trapId = "jinshu_qianrenxue_tianshilingyu"},
                        --         },
                        --     },
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 166 /24 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 8, duration = 0.35, count = 20,},
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
                                    OPTIONS = {delay_time = 19 / 24 },
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack14_2", is_loop = true, is_keep_animation = true},
                                },
                                {
                                    CLASS = "action.QSBActorKeepAnimation",
                                    OPTIONS = {is_keep_animation = true}
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 292 / 24 },
                                },
                                {
                                    CLASS = "action.QSBActorKeepAnimation",
                                    OPTIONS = {is_keep_animation = false}
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack14_3"},
                                },
                                {
                                    CLASS = "action.QSBLockTarget",
                                    OPTIONS = {is_lock_target = false},
                                },
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                            },
                        },
                -----地面花火9点-3点--中
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 40, y = 290}} ,
                                    {delay_time = 6 / 24 , pos = { x = 1240, y = 290}} ,
                                    {delay_time = 7 / 24 , pos = { x = 100, y = 290}} ,
                                    {delay_time = 7 / 24 , pos = { x = 1180, y = 290}} ,
                                    {delay_time = 8 / 24 , pos = { x = 160, y = 290}} ,
                                    {delay_time = 8 / 24 , pos = { x = 1120, y = 290}} ,
                                    {delay_time = 9 / 24 , pos = { x = 220, y = 290}} ,
                                    {delay_time = 9 / 24 , pos = { x = 1060, y = 290}} ,
                                    {delay_time = 10 / 24 , pos = { x = 280, y = 290}},
                                    {delay_time = 10 / 24 , pos = { x = 1000, y = 290}} ,
                                    {delay_time = 11 / 24 , pos = { x = 340, y = 290}},
                                    {delay_time = 11 / 24 , pos = { x = 940, y = 290}},
                                    {delay_time = 12 / 24 , pos = { x = 400, y = 290}} ,
                                    {delay_time = 12 / 24 , pos = { x = 880, y = 290}} ,
                                    {delay_time = 13 / 24 , pos = { x = 460, y = 290}} ,
                                    {delay_time = 13 / 24 , pos = { x = 820, y = 290}} ,
                                    {delay_time = 14 / 24 , pos = { x = 520, y = 290}} ,
                                    {delay_time = 14 / 24 , pos = { x = 760, y = 290}} ,
                                    {delay_time = 15 / 24 , pos = { x = 580, y = 290}} ,
                                    {delay_time = 15 / 24 , pos = { x = 700, y = 290}} ,
                                    {delay_time = 16 / 24 , pos = { x = 640, y = 290}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 30 / 24 , pos = { x = 40, y = 290}} ,
                                    {delay_time = 30 / 24 , pos = { x = 1240, y = 290}} ,
                                    {delay_time = 29 / 24 , pos = { x = 100, y = 290}} ,
                                    {delay_time = 29 / 24 , pos = { x = 1180, y = 290}} ,
                                    {delay_time = 28 / 24 , pos = { x = 160, y = 290}} ,
                                    {delay_time = 28 / 24 , pos = { x = 1120, y = 290}} ,
                                    {delay_time = 27 / 24 , pos = { x = 220, y = 290}} ,
                                    {delay_time = 27 / 24 , pos = { x = 1060, y = 290}} ,
                                    {delay_time = 26 / 24 , pos = { x = 280, y = 290}},
                                    {delay_time = 26 / 24 , pos = { x = 1000, y = 290}} ,
                                    {delay_time = 25 / 24 , pos = { x = 340, y = 290}},
                                    {delay_time = 25 / 24 , pos = { x = 940, y = 290}},
                                    {delay_time = 24 / 24 , pos = { x = 400, y = 290}} ,
                                    {delay_time = 24 / 24 , pos = { x = 880, y = 290}} ,
                                    {delay_time = 23 / 24 , pos = { x = 460, y = 290}} ,
                                    {delay_time = 23 / 24 , pos = { x = 820, y = 290}} ,
                                    {delay_time = 22 / 24 , pos = { x = 520, y = 290}} ,
                                    {delay_time = 22 / 24 , pos = { x = 760, y = 290}} ,
                                    {delay_time = 21 / 24 , pos = { x = 580, y = 290}} ,
                                    {delay_time = 21 / 24 , pos = { x = 700, y = 290}} ,
                                    {delay_time = 20 / 24 , pos = { x = 640, y = 290}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_xuangao2",
                                args = 
                                {
                                    {delay_time = 30 / 24 , pos = { x = 40, y = 290}} ,
                                    {delay_time = 30 / 24 , pos = { x = 1240, y = 290}} ,
                                    {delay_time = 29 / 24 , pos = { x = 110, y = 290}} ,
                                    {delay_time = 29 / 24 , pos = { x = 1170, y = 290}} ,
                                    {delay_time = 28 / 24 , pos = { x = 180, y = 290}} ,
                                    {delay_time = 28 / 24 , pos = { x = 1100, y = 290}} ,
                                    {delay_time = 27 / 24 , pos = { x = 250, y = 290}} ,
                                    {delay_time = 27 / 24 , pos = { x = 1030, y = 290}} ,
                                    {delay_time = 26 / 24 , pos = { x = 320, y = 290}},
                                    {delay_time = 26 / 24 , pos = { x = 960, y = 290}} ,
                                    {delay_time = 25 / 24 , pos = { x = 390, y = 290}},
                                    {delay_time = 25 / 24 , pos = { x = 890, y = 290}},
                                    {delay_time = 24 / 24 , pos = { x = 460, y = 290}} ,
                                    {delay_time = 24 / 24 , pos = { x = 820, y = 290}} ,
                                    {delay_time = 23 / 24 , pos = { x = 530, y = 290}} ,
                                    {delay_time = 23 / 24 , pos = { x = 750, y = 290}} ,
                                    {delay_time = 22 / 24 , pos = { x = 600, y = 290}} ,
                                    {delay_time = 22 / 24 , pos = { x = 680, y = 290}} ,
                                    {delay_time = 21 / 24 , pos = { x = 640, y = 290}} ,
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 8/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_zhongjie1",
                                        args = 
                                        {
                                            {delay_time = 222 / 24 , pos = { x = 40, y = 290}} ,
                                            {delay_time = 222 / 24 , pos = { x = 1240, y = 290}} ,
                                            {delay_time = 225 / 24 , pos = { x = 100, y = 290}} ,
                                            {delay_time = 225 / 24 , pos = { x = 1180, y = 290}} ,
                                            {delay_time = 228 / 24 , pos = { x = 160, y = 290}} ,
                                            {delay_time = 228 / 24 , pos = { x = 1120, y = 290}} ,
                                            {delay_time = 231 / 24 , pos = { x = 220, y = 290}} ,
                                            {delay_time = 231 / 24 , pos = { x = 1060, y = 290}} ,
                                            {delay_time = 234 / 24 , pos = { x = 280, y = 290}},
                                            {delay_time = 234 / 24 , pos = { x = 1000, y = 290}} ,
                                            {delay_time = 237 / 24 , pos = { x = 340, y = 290}},
                                            {delay_time = 237 / 24 , pos = { x = 940, y = 290}},
                                            {delay_time = 240 / 24 , pos = { x = 400, y = 290}} ,
                                            {delay_time = 240 / 24 , pos = { x = 880, y = 290}} ,
                                            {delay_time = 243 / 24 , pos = { x = 460, y = 290}} ,
                                            {delay_time = 243 / 24 , pos = { x = 820, y = 290}} ,
                                            {delay_time = 246 / 24 , pos = { x = 520, y = 290}} ,
                                            {delay_time = 246 / 24 , pos = { x = 760, y = 290}} ,
                                            {delay_time = 249 / 24 , pos = { x = 580, y = 290}} ,
                                            {delay_time = 249 / 24 , pos = { x = 700, y = 290}} ,
                                            {delay_time = 252 / 24 , pos = { x = 640, y = 290}},
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
                                    OPTIONS = {delay_time = 8/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_zhongjie1",
                                        args = 
                                        {
                                            {delay_time = 286 / 24 , pos = { x = 40, y = 290}} ,
                                            {delay_time = 286 / 24 , pos = { x = 1240, y = 290}} ,
                                            {delay_time = 283 / 24 , pos = { x = 100, y = 290}} ,
                                            {delay_time = 283 / 24 , pos = { x = 1180, y = 290}} ,
                                            {delay_time = 280 / 24 , pos = { x = 160, y = 290}} ,
                                            {delay_time = 280 / 24 , pos = { x = 1120, y = 290}} ,
                                            {delay_time = 277 / 24 , pos = { x = 220, y = 290}} ,
                                            {delay_time = 277 / 24 , pos = { x = 1060, y = 290}} ,
                                            {delay_time = 274 / 24 , pos = { x = 280, y = 290}},
                                            {delay_time = 274 / 24 , pos = { x = 1000, y = 290}} ,
                                            {delay_time = 271 / 24 , pos = { x = 340, y = 290}},
                                            {delay_time = 271 / 24 , pos = { x = 940, y = 290}},
                                            {delay_time = 268 / 24 , pos = { x = 400, y = 290}} ,
                                            {delay_time = 268 / 24 , pos = { x = 880, y = 290}} ,
                                            {delay_time = 265 / 24 , pos = { x = 460, y = 290}} ,
                                            {delay_time = 265 / 24 , pos = { x = 820, y = 290}} ,
                                            {delay_time = 262 / 24 , pos = { x = 520, y = 290}} ,
                                            {delay_time = 262 / 24 , pos = { x = 760, y = 290}} ,
                                            {delay_time = 259 / 24 , pos = { x = 580, y = 290}} ,
                                            {delay_time = 259 / 24 , pos = { x = 700, y = 290}} ,
                                            {delay_time = 256 / 24 , pos = { x = 640, y = 290}},
                                        },
                                    },
                                },
                            },
                        },
                -----地面花火9点-3点--中
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 40, y = 420}} ,
                                    {delay_time = 6 / 24 , pos = { x = 1240, y = 420}} ,
                                    {delay_time = 7 / 24 , pos = { x = 100, y = 420}} ,
                                    {delay_time = 7 / 24 , pos = { x = 1180, y = 420}} ,
                                    {delay_time = 8 / 24 , pos = { x = 160, y = 420}} ,
                                    {delay_time = 8 / 24 , pos = { x = 1120, y = 420}} ,
                                    {delay_time = 9 / 24 , pos = { x = 220, y = 420}} ,
                                    {delay_time = 9 / 24 , pos = { x = 1060, y = 420}} ,
                                    {delay_time = 10 / 24 , pos = { x = 280, y = 420}},
                                    {delay_time = 10 / 24 , pos = { x = 1000, y = 420}} ,
                                    {delay_time = 11 / 24 , pos = { x = 340, y = 420}},
                                    {delay_time = 11 / 24 , pos = { x = 940, y = 420}},
                                    {delay_time = 12 / 24 , pos = { x = 400, y = 420}} ,
                                    {delay_time = 12 / 24 , pos = { x = 880, y = 420}} ,
                                    {delay_time = 13 / 24 , pos = { x = 460, y = 420}} ,
                                    {delay_time = 13 / 24 , pos = { x = 820, y = 420}} ,
                                    {delay_time = 14 / 24 , pos = { x = 520, y = 420}} ,
                                    {delay_time = 14 / 24 , pos = { x = 760, y = 420}} ,
                                    {delay_time = 15 / 24 , pos = { x = 580, y = 420}} ,
                                    {delay_time = 15 / 24 , pos = { x = 700, y = 420}} ,
                                    {delay_time = 16 / 24 , pos = { x = 640, y = 420}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 30 / 24 , pos = { x = 40, y = 420}} ,
                                    {delay_time = 30 / 24 , pos = { x = 1240, y = 420}} ,
                                    {delay_time = 29 / 24 , pos = { x = 100, y = 420}} ,
                                    {delay_time = 29 / 24 , pos = { x = 1180, y = 420}} ,
                                    {delay_time = 28 / 24 , pos = { x = 160, y = 420}} ,
                                    {delay_time = 28 / 24 , pos = { x = 1120, y = 420}} ,
                                    {delay_time = 27 / 24 , pos = { x = 220, y = 420}} ,
                                    {delay_time = 27 / 24 , pos = { x = 1060, y = 420}} ,
                                    {delay_time = 26 / 24 , pos = { x = 280, y = 420}},
                                    {delay_time = 26 / 24 , pos = { x = 1000, y = 420}} ,
                                    {delay_time = 25 / 24 , pos = { x = 340, y = 420}},
                                    {delay_time = 25 / 24 , pos = { x = 940, y = 420}},
                                    {delay_time = 24 / 24 , pos = { x = 400, y = 420}} ,
                                    {delay_time = 24 / 24 , pos = { x = 880, y = 420}} ,
                                    {delay_time = 23 / 24 , pos = { x = 460, y = 420}} ,
                                    {delay_time = 23 / 24 , pos = { x = 820, y = 420}} ,
                                    {delay_time = 22 / 24 , pos = { x = 520, y = 420}} ,
                                    {delay_time = 22 / 24 , pos = { x = 760, y = 420}} ,
                                    {delay_time = 21 / 24 , pos = { x = 580, y = 420}} ,
                                    {delay_time = 21 / 24 , pos = { x = 700, y = 420}} ,
                                    {delay_time = 20 / 24 , pos = { x = 640, y = 420}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_xuangao2",
                                args = 
                                {
                                    {delay_time = 30 / 24 , pos = { x = 40, y = 420}} ,
                                    {delay_time = 30 / 24 , pos = { x = 1240, y = 420}} ,
                                    {delay_time = 29 / 24 , pos = { x = 110, y = 420}} ,
                                    {delay_time = 29 / 24 , pos = { x = 1170, y = 420}} ,
                                    {delay_time = 28 / 24 , pos = { x = 180, y = 420}} ,
                                    {delay_time = 28 / 24 , pos = { x = 1100, y = 420}} ,
                                    {delay_time = 27 / 24 , pos = { x = 250, y = 420}} ,
                                    {delay_time = 27 / 24 , pos = { x = 1030, y = 420}} ,
                                    {delay_time = 26 / 24 , pos = { x = 320, y = 420}},
                                    {delay_time = 26 / 24 , pos = { x = 960, y = 420}} ,
                                    {delay_time = 25 / 24 , pos = { x = 390, y = 420}},
                                    {delay_time = 25 / 24 , pos = { x = 890, y = 420}},
                                    {delay_time = 24 / 24 , pos = { x = 460, y = 420}} ,
                                    {delay_time = 24 / 24 , pos = { x = 820, y = 420}} ,
                                    {delay_time = 23 / 24 , pos = { x = 530, y = 420}} ,
                                    {delay_time = 23 / 24 , pos = { x = 750, y = 420}} ,
                                    {delay_time = 22 / 24 , pos = { x = 600, y = 420}} ,
                                    {delay_time = 22 / 24 , pos = { x = 680, y = 420}} ,
                                    {delay_time = 21 / 24 , pos = { x = 640, y = 420}} ,
                                },
                            },
                        },      
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 222 / 24 , pos = { x = 40, y = 420}} ,
                                    {delay_time = 222 / 24 , pos = { x = 1240, y = 420}} ,
                                    {delay_time = 225 / 24 , pos = { x = 100, y = 420}} ,
                                    {delay_time = 225 / 24 , pos = { x = 1180, y = 420}} ,
                                    {delay_time = 228 / 24 , pos = { x = 160, y = 420}} ,
                                    {delay_time = 228 / 24 , pos = { x = 1120, y = 420}} ,
                                    {delay_time = 231 / 24 , pos = { x = 220, y = 420}} ,
                                    {delay_time = 231 / 24 , pos = { x = 1060, y = 420}} ,
                                    {delay_time = 234 / 24 , pos = { x = 280, y = 420}},
                                    {delay_time = 234 / 24 , pos = { x = 1000, y = 420}} ,
                                    {delay_time = 237 / 24 , pos = { x = 340, y = 420}},
                                    {delay_time = 237 / 24 , pos = { x = 940, y = 420}},
                                    {delay_time = 240 / 24 , pos = { x = 400, y = 420}} ,
                                    {delay_time = 240 / 24 , pos = { x = 880, y = 420}} ,
                                    {delay_time = 243 / 24 , pos = { x = 460, y = 420}} ,
                                    {delay_time = 243 / 24 , pos = { x = 820, y = 420}} ,
                                    {delay_time = 246 / 24 , pos = { x = 520, y = 420}} ,
                                    {delay_time = 246 / 24 , pos = { x = 760, y = 420}} ,
                                    {delay_time = 249 / 24 , pos = { x = 580, y = 420}} ,
                                    {delay_time = 249 / 24 , pos = { x = 700, y = 420}} ,
                                    {delay_time = 252 / 24 , pos = { x = 640, y = 420}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 286 / 24 , pos = { x = 40, y = 420}} ,
                                    {delay_time = 286 / 24 , pos = { x = 1240, y = 420}} ,
                                    {delay_time = 283 / 24 , pos = { x = 100, y = 420}} ,
                                    {delay_time = 283 / 24 , pos = { x = 1180, y = 420}} ,
                                    {delay_time = 280 / 24 , pos = { x = 160, y = 420}} ,
                                    {delay_time = 280 / 24 , pos = { x = 1120, y = 420}} ,
                                    {delay_time = 277 / 24 , pos = { x = 220, y = 420}} ,
                                    {delay_time = 277 / 24 , pos = { x = 1060, y = 420}} ,
                                    {delay_time = 274 / 24 , pos = { x = 280, y = 420}},
                                    {delay_time = 274 / 24 , pos = { x = 1000, y = 420}} ,
                                    {delay_time = 271 / 24 , pos = { x = 340, y = 420}},
                                    {delay_time = 271 / 24 , pos = { x = 940, y = 420}},
                                    {delay_time = 268 / 24 , pos = { x = 400, y = 420}} ,
                                    {delay_time = 268 / 24 , pos = { x = 880, y = 420}} ,
                                    {delay_time = 265 / 24 , pos = { x = 460, y = 420}} ,
                                    {delay_time = 265 / 24 , pos = { x = 820, y = 420}} ,
                                    {delay_time = 262 / 24 , pos = { x = 520, y = 420}} ,
                                    {delay_time = 262 / 24 , pos = { x = 760, y = 420}} ,
                                    {delay_time = 259 / 24 , pos = { x = 580, y = 420}} ,
                                    {delay_time = 259 / 24 , pos = { x = 700, y = 420}} ,
                                    {delay_time = 256 / 24 , pos = { x = 640, y = 420}},
                                },
                            },
                        },
                ---- 9点至3点火花上
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 40, y = 508}} ,
                                    {delay_time = 6 / 24 , pos = { x = 1240, y = 508}} ,
                                    {delay_time = 7 / 24 , pos = { x = 100, y = 508}} ,
                                    {delay_time = 7 / 24 , pos = { x = 1180, y = 508}} ,
                                    {delay_time = 8 / 24 , pos = { x = 160, y = 508}} ,
                                    {delay_time = 8 / 24 , pos = { x = 1120, y = 508}} ,
                                    {delay_time = 9 / 24 , pos = { x = 220, y = 508}} ,
                                    {delay_time = 9 / 24 , pos = { x = 1060, y = 508}} ,
                                    {delay_time = 10 / 24 , pos = { x = 280, y = 508}},
                                    {delay_time = 10 / 24 , pos = { x = 1000, y = 508}} ,
                                    {delay_time = 11 / 24 , pos = { x = 340, y = 508}},
                                    {delay_time = 11 / 24 , pos = { x = 940, y = 508}},
                                    {delay_time = 12 / 24 , pos = { x = 400, y = 508}} ,
                                    {delay_time = 12 / 24 , pos = { x = 880, y = 508}} ,
                                    {delay_time = 13 / 24 , pos = { x = 460, y = 508}} ,
                                    {delay_time = 13 / 24 , pos = { x = 820, y = 508}} ,
                                    {delay_time = 14 / 24 , pos = { x = 520, y = 508}} ,
                                    {delay_time = 14 / 24 , pos = { x = 760, y = 508}} ,
                                    {delay_time = 15 / 24 , pos = { x = 580, y = 508}} ,
                                    {delay_time = 15 / 24 , pos = { x = 700, y = 508}} ,
                                    {delay_time = 16 / 24 , pos = { x = 640, y = 508}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 30 / 24 , pos = { x = 40, y = 508}} ,
                                    {delay_time = 30 / 24 , pos = { x = 1240, y = 508}} ,
                                    {delay_time = 29 / 24 , pos = { x = 100, y = 508}} ,
                                    {delay_time = 29 / 24 , pos = { x = 1180, y = 508}} ,
                                    {delay_time = 28 / 24 , pos = { x = 160, y = 508}} ,
                                    {delay_time = 28 / 24 , pos = { x = 1120, y = 508}} ,
                                    {delay_time = 27 / 24 , pos = { x = 220, y = 508}} ,
                                    {delay_time = 27 / 24 , pos = { x = 1060, y = 508}} ,
                                    {delay_time = 26 / 24 , pos = { x = 280, y = 508}},
                                    {delay_time = 26 / 24 , pos = { x = 1000, y = 508}} ,
                                    {delay_time = 25 / 24 , pos = { x = 340, y = 508}},
                                    {delay_time = 25 / 24 , pos = { x = 940, y = 508}},
                                    {delay_time = 24 / 24 , pos = { x = 400, y = 508}} ,
                                    {delay_time = 24 / 24 , pos = { x = 880, y = 508}} ,
                                    {delay_time = 23 / 24 , pos = { x = 460, y = 508}} ,
                                    {delay_time = 23 / 24 , pos = { x = 820, y = 508}} ,
                                    {delay_time = 22 / 24 , pos = { x = 520, y = 508}} ,
                                    {delay_time = 22 / 24 , pos = { x = 760, y = 508}} ,
                                    {delay_time = 21 / 24 , pos = { x = 580, y = 508}} ,
                                    {delay_time = 21 / 24 , pos = { x = 700, y = 508}} ,
                                    {delay_time = 20 / 24 , pos = { x = 640, y = 508}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_xuangao2",
                                args = 
                                {
                                    {delay_time = 30 / 24 , pos = { x = 40, y = 508}} ,
                                    {delay_time = 30 / 24 , pos = { x = 1240, y = 508}} ,
                                    {delay_time = 29 / 24 , pos = { x = 110, y = 508}} ,
                                    {delay_time = 29 / 24 , pos = { x = 1170, y = 508}} ,
                                    {delay_time = 28 / 24 , pos = { x = 180, y = 508}} ,
                                    {delay_time = 28 / 24 , pos = { x = 1100, y = 508}} ,
                                    {delay_time = 27 / 24 , pos = { x = 250, y = 508}} ,
                                    {delay_time = 27 / 24 , pos = { x = 1030, y = 508}} ,
                                    {delay_time = 26 / 24 , pos = { x = 320, y = 508}},
                                    {delay_time = 26 / 24 , pos = { x = 960, y = 508}} ,
                                    {delay_time = 25 / 24 , pos = { x = 390, y = 508}},
                                    {delay_time = 25 / 24 , pos = { x = 890, y = 508}},
                                    {delay_time = 24 / 24 , pos = { x = 460, y = 508}} ,
                                    {delay_time = 24 / 24 , pos = { x = 820, y = 508}} ,
                                    {delay_time = 23 / 24 , pos = { x = 530, y = 508}} ,
                                    {delay_time = 23 / 24 , pos = { x = 750, y = 508}} ,
                                    {delay_time = 22 / 24 , pos = { x = 600, y = 508}} ,
                                    {delay_time = 22 / 24 , pos = { x = 680, y = 508}} ,
                                    {delay_time = 21 / 24 , pos = { x = 640, y = 508}} ,
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 214 / 24 , pos = { x = 40, y = 508}} ,
                                    {delay_time = 214 / 24 , pos = { x = 1240, y = 508}} ,
                                    {delay_time = 217 / 24 , pos = { x = 100, y = 508}} ,
                                    {delay_time = 217 / 24 , pos = { x = 1180, y = 508}} ,
                                    {delay_time = 220 / 24 , pos = { x = 160, y = 508}} ,
                                    {delay_time = 220 / 24 , pos = { x = 1120, y = 508}} ,
                                    {delay_time = 223 / 24 , pos = { x = 220, y = 508}} ,
                                    {delay_time = 223 / 24 , pos = { x = 1060, y = 508}} ,
                                    {delay_time = 226 / 24 , pos = { x = 280, y = 508}},
                                    {delay_time = 226 / 24 , pos = { x = 1000, y = 508}} ,
                                    {delay_time = 229 / 24 , pos = { x = 340, y = 508}},
                                    {delay_time = 229 / 24 , pos = { x = 940, y = 508}},
                                    {delay_time = 232 / 24 , pos = { x = 400, y = 508}} ,
                                    {delay_time = 232 / 24 , pos = { x = 880, y = 508}} ,
                                    {delay_time = 235 / 24 , pos = { x = 460, y = 508}} ,
                                    {delay_time = 235 / 24 , pos = { x = 820, y = 508}} ,
                                    {delay_time = 238 / 24 , pos = { x = 520, y = 508}} ,
                                    {delay_time = 238 / 24 , pos = { x = 760, y = 508}} ,
                                    {delay_time = 241 / 24 , pos = { x = 580, y = 508}} ,
                                    {delay_time = 241 / 24 , pos = { x = 700, y = 508}} ,
                                    {delay_time = 244 / 24 , pos = { x = 640, y = 508}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 278 / 24 , pos = { x = 40, y = 508}} ,
                                    {delay_time = 278 / 24 , pos = { x = 1240, y = 508}} ,
                                    {delay_time = 275 / 24 , pos = { x = 100, y = 508}} ,
                                    {delay_time = 275 / 24 , pos = { x = 1180, y = 508}} ,
                                    {delay_time = 272 / 24 , pos = { x = 160, y = 508}} ,
                                    {delay_time = 272 / 24 , pos = { x = 1120, y = 508}} ,
                                    {delay_time = 269 / 24 , pos = { x = 220, y = 508}} ,
                                    {delay_time = 269 / 24 , pos = { x = 1060, y = 508}} ,
                                    {delay_time = 266 / 24 , pos = { x = 280, y = 508}},
                                    {delay_time = 266 / 24 , pos = { x = 1000, y = 508}} ,
                                    {delay_time = 263 / 24 , pos = { x = 340, y = 508}},
                                    {delay_time = 263 / 24 , pos = { x = 940, y = 508}},
                                    {delay_time = 260 / 24 , pos = { x = 400, y = 508}} ,
                                    {delay_time = 260 / 24 , pos = { x = 880, y = 508}} ,
                                    {delay_time = 257 / 24 , pos = { x = 460, y = 508}} ,
                                    {delay_time = 257 / 24 , pos = { x = 820, y = 508}} ,
                                    {delay_time = 254 / 24 , pos = { x = 520, y = 508}} ,
                                    {delay_time = 254 / 24 , pos = { x = 760, y = 508}} ,
                                    {delay_time = 251 / 24 , pos = { x = 580, y = 508}} ,
                                    {delay_time = 251 / 24 , pos = { x = 700, y = 508}} ,
                                    {delay_time = 248 / 24 , pos = { x = 640, y = 508}},
                                },
                            },
                        },
                -----地面火花9-3点下
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 40, y = 170}} ,
                                    {delay_time = 6 / 24 , pos = { x = 1240, y = 170}} ,
                                    {delay_time = 7 / 24 , pos = { x = 100, y = 170}} ,
                                    {delay_time = 7 / 24 , pos = { x = 1180, y = 170}} ,
                                    {delay_time = 8 / 24 , pos = { x = 160, y = 170}} ,
                                    {delay_time = 8 / 24 , pos = { x = 1120, y = 170}} ,
                                    {delay_time = 9 / 24 , pos = { x = 220, y = 170}} ,
                                    {delay_time = 9 / 24 , pos = { x = 1060, y = 170}} ,
                                    {delay_time = 10 / 24 , pos = { x = 280, y = 170}},
                                    {delay_time = 10 / 24 , pos = { x = 1000, y = 170}} ,
                                    {delay_time = 11 / 24 , pos = { x = 340, y = 170}},
                                    {delay_time = 11 / 24 , pos = { x = 940, y = 170}},
                                    {delay_time = 12 / 24 , pos = { x = 400, y = 170}} ,
                                    {delay_time = 12 / 24 , pos = { x = 880, y = 170}} ,
                                    {delay_time = 13 / 24 , pos = { x = 460, y = 170}} ,
                                    {delay_time = 13 / 24 , pos = { x = 820, y = 170}} ,
                                    {delay_time = 14 / 24 , pos = { x = 520, y = 170}} ,
                                    {delay_time = 14 / 24 , pos = { x = 760, y = 170}} ,
                                    {delay_time = 15 / 24 , pos = { x = 580, y = 170}} ,
                                    {delay_time = 15 / 24 , pos = { x = 700, y = 170}} ,
                                    {delay_time = 16 / 24 , pos = { x = 640, y = 170}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 30 / 24 , pos = { x = 40, y = 170}} ,
                                    {delay_time = 30 / 24 , pos = { x = 1240, y = 170}} ,
                                    {delay_time = 29 / 24 , pos = { x = 100, y = 170}} ,
                                    {delay_time = 29 / 24 , pos = { x = 1180, y = 170}} ,
                                    {delay_time = 28 / 24 , pos = { x = 160, y = 170}} ,
                                    {delay_time = 28 / 24 , pos = { x = 1120, y = 170}} ,
                                    {delay_time = 27 / 24 , pos = { x = 220, y = 170}} ,
                                    {delay_time = 27 / 24 , pos = { x = 1060, y = 170}} ,
                                    {delay_time = 26 / 24 , pos = { x = 280, y = 170}},
                                    {delay_time = 26 / 24 , pos = { x = 1000, y = 170}} ,
                                    {delay_time = 25 / 24 , pos = { x = 340, y = 170}},
                                    {delay_time = 25 / 24 , pos = { x = 940, y = 170}},
                                    {delay_time = 24 / 24 , pos = { x = 400, y = 170}} ,
                                    {delay_time = 24 / 24 , pos = { x = 880, y = 170}} ,
                                    {delay_time = 23 / 24 , pos = { x = 460, y = 170}} ,
                                    {delay_time = 23 / 24 , pos = { x = 820, y = 170}} ,
                                    {delay_time = 22 / 24 , pos = { x = 520, y = 170}} ,
                                    {delay_time = 22 / 24 , pos = { x = 760, y = 170}} ,
                                    {delay_time = 21 / 24 , pos = { x = 580, y = 170}} ,
                                    {delay_time = 21 / 24 , pos = { x = 700, y = 170}} ,
                                    {delay_time = 20 / 24 , pos = { x = 640, y = 170}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_xuangao2",
                                args = 
                                {
                                    {delay_time = 30 / 24 , pos = { x = 40, y = 170}} ,
                                    {delay_time = 30 / 24 , pos = { x = 1240, y = 170}} ,
                                    {delay_time = 29 / 24 , pos = { x = 110, y = 170}} ,
                                    {delay_time = 29 / 24 , pos = { x = 1170, y = 170}} ,
                                    {delay_time = 28 / 24 , pos = { x = 180, y = 170}} ,
                                    {delay_time = 28 / 24 , pos = { x = 1100, y = 170}} ,
                                    {delay_time = 27 / 24 , pos = { x = 250, y = 170}} ,
                                    {delay_time = 27 / 24 , pos = { x = 1030, y = 170}} ,
                                    {delay_time = 26 / 24 , pos = { x = 320, y = 170}},
                                    {delay_time = 26 / 24 , pos = { x = 960, y = 170}} ,
                                    {delay_time = 25 / 24 , pos = { x = 390, y = 170}},
                                    {delay_time = 25 / 24 , pos = { x = 890, y = 170}},
                                    {delay_time = 24 / 24 , pos = { x = 460, y = 170}} ,
                                    {delay_time = 24 / 24 , pos = { x = 820, y = 170}} ,
                                    {delay_time = 23 / 24 , pos = { x = 530, y = 170}} ,
                                    {delay_time = 23 / 24 , pos = { x = 750, y = 170}} ,
                                    {delay_time = 22 / 24 , pos = { x = 600, y = 170}} ,
                                    {delay_time = 22 / 24 , pos = { x = 680, y = 170}} ,
                                    {delay_time = 21 / 24 , pos = { x = 640, y = 170}} ,
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 8/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_zhongjie1",
                                        args = 
                                        {
                                            {delay_time = 230 / 24 , pos = { x = 40, y = 170}} ,
                                            {delay_time = 230 / 24 , pos = { x = 1240, y = 170}} ,
                                            {delay_time = 233 / 24 , pos = { x = 100, y = 170}} ,
                                            {delay_time = 233 / 24 , pos = { x = 1180, y = 170}} ,
                                            {delay_time = 236 / 24 , pos = { x = 160, y = 170}} ,
                                            {delay_time = 236 / 24 , pos = { x = 1120, y = 170}} ,
                                            {delay_time = 239 / 24 , pos = { x = 220, y = 170}} ,
                                            {delay_time = 239 / 24 , pos = { x = 1060, y = 170}} ,
                                            {delay_time = 242 / 24 , pos = { x = 280, y = 170}},
                                            {delay_time = 242 / 24 , pos = { x = 1000, y = 170}} ,
                                            {delay_time = 245 / 24 , pos = { x = 340, y = 170}},
                                            {delay_time = 245 / 24 , pos = { x = 940, y = 170}},
                                            {delay_time = 248 / 24 , pos = { x = 400, y = 170}} ,
                                            {delay_time = 248 / 24 , pos = { x = 880, y = 170}} ,
                                            {delay_time = 251 / 24 , pos = { x = 460, y = 170}} ,
                                            {delay_time = 251 / 24 , pos = { x = 820, y = 170}} ,
                                            {delay_time = 254 / 24 , pos = { x = 520, y = 170}} ,
                                            {delay_time = 254 / 24 , pos = { x = 760, y = 170}} ,
                                            {delay_time = 257 / 24 , pos = { x = 580, y = 170}} ,
                                            {delay_time = 257 / 24 , pos = { x = 700, y = 170}} ,
                                            {delay_time = 260 / 24 , pos = { x = 640, y = 170}},
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
                                    OPTIONS = {delay_time = 8/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_zhongjie1",
                                        args = 
                                        {
                                            {delay_time = 294 / 24 , pos = { x = 40, y = 170}} ,
                                            {delay_time = 294 / 24 , pos = { x = 1240, y = 170}} ,
                                            {delay_time = 291 / 24 , pos = { x = 100, y = 170}} ,
                                            {delay_time = 291 / 24 , pos = { x = 1180, y = 170}} ,
                                            {delay_time = 288 / 24 , pos = { x = 160, y = 170}} ,
                                            {delay_time = 288 / 24 , pos = { x = 1120, y = 170}} ,
                                            {delay_time = 285 / 24 , pos = { x = 220, y = 170}} ,
                                            {delay_time = 285 / 24 , pos = { x = 1060, y = 170}} ,
                                            {delay_time = 282 / 24 , pos = { x = 280, y = 170}},
                                            {delay_time = 282 / 24 , pos = { x = 1000, y = 170}} ,
                                            {delay_time = 279 / 24 , pos = { x = 340, y = 170}},
                                            {delay_time = 279 / 24 , pos = { x = 940, y = 170}},
                                            {delay_time = 276 / 24 , pos = { x = 400, y = 170}} ,
                                            {delay_time = 276 / 24 , pos = { x = 880, y = 170}} ,
                                            {delay_time = 273 / 24 , pos = { x = 460, y = 170}} ,
                                            {delay_time = 273 / 24 , pos = { x = 820, y = 170}} ,
                                            {delay_time = 270 / 24 , pos = { x = 520, y = 170}} ,
                                            {delay_time = 270 / 24 , pos = { x = 760, y = 170}} ,
                                            {delay_time = 267 / 24 , pos = { x = 580, y = 170}} ,
                                            {delay_time = 267 / 24 , pos = { x = 700, y = 170}} ,
                                            {delay_time = 264 / 24 , pos = { x = 640, y = 170}},
                                        },
                                    },
                                },
                            },
                        },
                ------地面火花12至6左1
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 40, y = 508}} ,
                                    {delay_time = 6 / 24 , pos = { x = 40, y = 170}} ,
                                    {delay_time = 8 / 24 , pos = { x = 40, y = 477.4}} ,
                                    {delay_time = 8 / 24 , pos = { x = 40, y = 208}} ,
                                    {delay_time = 10 / 24 , pos = { x = 40, y = 446.8}} ,
                                    {delay_time = 10 / 24 , pos = { x = 40, y = 246}} ,
                                    {delay_time = 12 / 24 , pos = { x = 40, y = 420}} ,
                                    {delay_time = 12 / 24 , pos = { x = 40, y = 290}} ,
                                    {delay_time = 14 / 24 , pos = { x = 40, y = 385.4}},
                                    {delay_time = 14 / 24 , pos = { x = 40, y = 322}} ,
                                    {delay_time = 16 / 24 , pos = { x = 40, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 24 / 24 , pos = { x = 40, y = 477.4}} ,
                                    {delay_time = 24 / 24 , pos = { x = 40, y = 208}} ,
                                    {delay_time = 22 / 24 , pos = { x = 40, y = 446.8}} ,
                                    {delay_time = 22 / 24 , pos = { x = 40, y = 246}} ,
                                    {delay_time = 20 / 24 , pos = { x = 40, y = 420}} ,
                                    {delay_time = 20 / 24 , pos = { x = 40, y = 290}} ,
                                    {delay_time = 18 / 24 , pos = { x = 40, y = 385.4}},
                                    {delay_time = 18 / 24 , pos = { x = 40, y = 322}} ,
                                    {delay_time = 16 / 24 , pos = { x = 40, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_xuangao",
                                args = 
                                {
                                    {delay_time = 24 / 24 , pos = { x = 40, y = 477.4}} ,
                                    {delay_time = 24 / 24 , pos = { x = 40, y = 208}} ,
                                    {delay_time = 22 / 24 , pos = { x = 40, y = 446.8}} ,
                                    {delay_time = 22 / 24 , pos = { x = 40, y = 246}} ,
                                    {delay_time = 20 / 24 , pos = { x = 40, y = 420}} ,
                                    {delay_time = 20 / 24 , pos = { x = 40, y = 290}} ,
                                    {delay_time = 18 / 24 , pos = { x = 40, y = 385.4}},
                                    {delay_time = 18 / 24 , pos = { x = 40, y = 322}} ,
                                    {delay_time = 16 / 24 , pos = { x = 40, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie1",
                                args = 
                                {
                                    {delay_time = 178 / 24 , pos = { x = 40, y = 508}} ,
                                    {delay_time = 178 / 24 , pos = { x = 40, y = 170}} ,
                                    {delay_time = 181 / 24 , pos = { x = 40, y = 477.4}} ,
                                    {delay_time = 181 / 24 , pos = { x = 40, y = 208}} ,
                                    {delay_time = 184 / 24 , pos = { x = 40, y = 446.8}} ,
                                    {delay_time = 184 / 24 , pos = { x = 40, y = 246}} ,
                                    {delay_time = 187 / 24 , pos = { x = 40, y = 420}} ,
                                    {delay_time = 187 / 24 , pos = { x = 40, y = 290}} ,
                                    {delay_time = 190 / 24 , pos = { x = 40, y = 385.4}},
                                    {delay_time = 190 / 24 , pos = { x = 40, y = 322}} ,
                                    {delay_time = 193 / 24 , pos = { x = 40, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 211 / 24 , pos = { x = 40, y = 477.4}} ,
                                    {delay_time = 211 / 24 , pos = { x = 40, y = 208}} ,
                                    {delay_time = 208 / 24 , pos = { x = 40, y = 446.8}} ,
                                    {delay_time = 208 / 24 , pos = { x = 40, y = 246}} ,
                                    {delay_time = 205 / 24 , pos = { x = 40, y = 420}} ,
                                    {delay_time = 205 / 24 , pos = { x = 40, y = 290}} ,
                                    {delay_time = 202 / 24 , pos = { x = 40, y = 385.4}},
                                    {delay_time = 202 / 24 , pos = { x = 40, y = 322}} ,
                                    {delay_time = 199 / 24 , pos = { x = 40, y = 355}},
                                },
                            },
                        },
                ------右1
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 1240, y = 508}} ,
                                    {delay_time = 6 / 24 , pos = { x = 1240, y = 170}} ,
                                    {delay_time = 8 / 24 , pos = { x = 1240, y = 477.4}} ,
                                    {delay_time = 8 / 24 , pos = { x = 1240, y = 208}} ,
                                    {delay_time = 10 / 24 , pos = { x = 1240, y = 446.8}} ,
                                    {delay_time = 10 / 24 , pos = { x = 1240, y = 246}} ,
                                    {delay_time = 12 / 24 , pos = { x = 1240, y = 420}} ,
                                    {delay_time = 12 / 24 , pos = { x = 1240, y = 290}} ,
                                    {delay_time = 14 / 24 , pos = { x = 1240, y = 385.4}},
                                    {delay_time = 14 / 24 , pos = { x = 1240, y = 322}} ,
                                    {delay_time = 16 / 24 , pos = { x = 1240, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 24 / 24 , pos = { x = 1240, y = 477.4}} ,
                                    {delay_time = 24 / 24 , pos = { x = 1240, y = 208}} ,
                                    {delay_time = 22 / 24 , pos = { x = 1240, y = 446.8}} ,
                                    {delay_time = 22 / 24 , pos = { x = 1240, y = 246}} ,
                                    {delay_time = 20 / 24 , pos = { x = 1240, y = 420}} ,
                                    {delay_time = 20 / 24 , pos = { x = 1240, y = 290}} ,
                                    {delay_time = 18 / 24 , pos = { x = 1240, y = 385.4}},
                                    {delay_time = 18 / 24 , pos = { x = 1240, y = 322}} ,
                                    {delay_time = 16 / 24 , pos = { x = 1240, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_xuangao",
                                args = 
                                {
                                    {delay_time = 24 / 24 , pos = { x = 1240, y = 477.4}} ,
                                    {delay_time = 24 / 24 , pos = { x = 1240, y = 208}} ,
                                    {delay_time = 22 / 24 , pos = { x = 1240, y = 446.8}} ,
                                    {delay_time = 22 / 24 , pos = { x = 1240, y = 246}} ,
                                    {delay_time = 20 / 24 , pos = { x = 1240, y = 420}} ,
                                    {delay_time = 20 / 24 , pos = { x = 1240, y = 290}} ,
                                    {delay_time = 18 / 24 , pos = { x = 1240, y = 385.4}},
                                    {delay_time = 18 / 24 , pos = { x = 1240, y = 322}} ,
                                    {delay_time = 16 / 24 , pos = { x = 1240, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie1",
                                args = 
                                {
                                    {delay_time = 178 / 24 , pos = { x = 1240, y = 508}} ,
                                    {delay_time = 178 / 24 , pos = { x = 1240, y = 170}} ,
                                    {delay_time = 181 / 24 , pos = { x = 1240, y = 477.4}} ,
                                    {delay_time = 181 / 24 , pos = { x = 1240, y = 208}} ,
                                    {delay_time = 184 / 24 , pos = { x = 1240, y = 446.8}} ,
                                    {delay_time = 184 / 24 , pos = { x = 1240, y = 246}} ,
                                    {delay_time = 187 / 24 , pos = { x = 1240, y = 420}} ,
                                    {delay_time = 187 / 24 , pos = { x = 1240, y = 290}} ,
                                    {delay_time = 190 / 24 , pos = { x = 1240, y = 385.4}},
                                    {delay_time = 190 / 24 , pos = { x = 1240, y = 322}} ,
                                    {delay_time = 193 / 24 , pos = { x = 1240, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 211 / 24 , pos = { x = 1240, y = 477.4}} ,
                                    {delay_time = 211 / 24 , pos = { x = 1240, y = 208}} ,
                                    {delay_time = 208 / 24 , pos = { x = 1240, y = 446.8}} ,
                                    {delay_time = 208 / 24 , pos = { x = 1240, y = 246}} ,
                                    {delay_time = 205 / 24 , pos = { x = 1240, y = 420}} ,
                                    {delay_time = 205 / 24 , pos = { x = 1240, y = 290}} ,
                                    {delay_time = 202 / 24 , pos = { x = 1240, y = 385.4}},
                                    {delay_time = 202 / 24 , pos = { x = 1240, y = 322}} ,
                                    {delay_time = 199 / 24 , pos = { x = 1240, y = 355}},
                                },
                            },
                        },
                ------左2
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 12 / 24 , pos = { x = 390, y = 508}} ,
                                    {delay_time = 12 / 24 , pos = { x = 390, y = 170}} ,
                                    {delay_time = 14 / 24 , pos = { x = 390, y = 477.4}} ,
                                    {delay_time = 14 / 24 , pos = { x = 390, y = 208}} ,
                                    {delay_time = 16 / 24 , pos = { x = 390, y = 446.8}} ,
                                    {delay_time = 16 / 24 , pos = { x = 390, y = 246}} ,
                                    {delay_time = 18 / 24 , pos = { x = 390, y = 420}} ,
                                    {delay_time = 18 / 24 , pos = { x = 390, y = 290}} ,
                                    {delay_time = 20 / 24 , pos = { x = 390, y = 385.4}},
                                    {delay_time = 20 / 24 , pos = { x = 390, y = 322}} ,
                                    {delay_time = 22 / 24 , pos = { x = 390, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 34 / 24 , pos = { x = 390, y = 477.4}} ,
                                    {delay_time = 34 / 24 , pos = { x = 390, y = 208}} ,
                                    {delay_time = 32 / 24 , pos = { x = 390, y = 446.8}} ,
                                    {delay_time = 32 / 24 , pos = { x = 390, y = 246}} ,
                                    {delay_time = 30 / 24 , pos = { x = 390, y = 420}} ,
                                    {delay_time = 30 / 24 , pos = { x = 390, y = 290}} ,
                                    {delay_time = 28 / 24 , pos = { x = 390, y = 385.4}},
                                    {delay_time = 28 / 24 , pos = { x = 390, y = 322}} ,
                                    {delay_time = 26 / 24 , pos = { x = 390, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_xuangao",
                                args = 
                                {
                                    {delay_time = 34 / 24 , pos = { x = 390, y = 477.4}} ,
                                    {delay_time = 34 / 24 , pos = { x = 390, y = 208}} ,
                                    {delay_time = 32 / 24 , pos = { x = 390, y = 446.8}} ,
                                    {delay_time = 32 / 24 , pos = { x = 390, y = 246}} ,
                                    {delay_time = 30 / 24 , pos = { x = 390, y = 420}} ,
                                    {delay_time = 30 / 24 , pos = { x = 390, y = 290}} ,
                                    {delay_time = 28 / 24 , pos = { x = 390, y = 385.4}},
                                    {delay_time = 28 / 24 , pos = { x = 390, y = 322}} ,
                                    {delay_time = 26 / 24 , pos = { x = 390, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 166 / 24 , pos = { x = 390, y = 508}} ,
                                    {delay_time = 166 / 24 , pos = { x = 390, y = 170}} ,
                                    {delay_time = 169 / 24 , pos = { x = 390, y = 477.4}} ,
                                    {delay_time = 169 / 24 , pos = { x = 390, y = 208}} ,
                                    {delay_time = 172 / 24 , pos = { x = 390, y = 446.8}} ,
                                    {delay_time = 172 / 24 , pos = { x = 390, y = 246}} ,
                                    {delay_time = 175 / 24 , pos = { x = 390, y = 420}} ,
                                    {delay_time = 175 / 24 , pos = { x = 390, y = 290}} ,
                                    {delay_time = 178 / 24 , pos = { x = 390, y = 385.4}},
                                    {delay_time = 178 / 24 , pos = { x = 390, y = 322}} ,
                                    {delay_time = 181 / 24 , pos = { x = 390, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 199 / 24 , pos = { x = 390, y = 477.4}} ,
                                    {delay_time = 199 / 24 , pos = { x = 390, y = 208}} ,
                                    {delay_time = 196 / 24 , pos = { x = 390, y = 446.8}} ,
                                    {delay_time = 196 / 24 , pos = { x = 390, y = 246}} ,
                                    {delay_time = 193 / 24 , pos = { x = 390, y = 420}} ,
                                    {delay_time = 193 / 24 , pos = { x = 390, y = 290}} ,
                                    {delay_time = 190 / 24 , pos = { x = 390, y = 385.4}},
                                    {delay_time = 190 / 24 , pos = { x = 390, y = 322}} ,
                                    {delay_time = 187 / 24 , pos = { x = 390, y = 355}},
                                },
                            },
                        },
                -------右2
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 12 / 24 , pos = { x = 890, y = 508}} ,
                                    {delay_time = 12 / 24 , pos = { x = 890, y = 170}} ,
                                    {delay_time = 14 / 24 , pos = { x = 890, y = 477.4}} ,
                                    {delay_time = 14 / 24 , pos = { x = 890, y = 208}} ,
                                    {delay_time = 16 / 24 , pos = { x = 890, y = 446.8}} ,
                                    {delay_time = 16 / 24 , pos = { x = 890, y = 246}} ,
                                    {delay_time = 18 / 24 , pos = { x = 890, y = 420}} ,
                                    {delay_time = 18 / 24 , pos = { x = 890, y = 290}} ,
                                    {delay_time = 20 / 24 , pos = { x = 890, y = 385.4}},
                                    {delay_time = 20 / 24 , pos = { x = 890, y = 322}} ,
                                    {delay_time = 22 / 24 , pos = { x = 890, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 34 / 24 , pos = { x = 890, y = 477.4}} ,
                                    {delay_time = 34 / 24 , pos = { x = 890, y = 208}} ,
                                    {delay_time = 32 / 24 , pos = { x = 890, y = 446.8}} ,
                                    {delay_time = 32 / 24 , pos = { x = 890, y = 246}} ,
                                    {delay_time = 30 / 24 , pos = { x = 890, y = 420}} ,
                                    {delay_time = 30 / 24 , pos = { x = 890, y = 290}} ,
                                    {delay_time = 28 / 24 , pos = { x = 890, y = 385.4}},
                                    {delay_time = 28 / 24 , pos = { x = 890, y = 322}} ,
                                    {delay_time = 26 / 24 , pos = { x = 890, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_xuangao",
                                args = 
                                {
                                    {delay_time = 34 / 24 , pos = { x = 890, y = 477.4}} ,
                                    {delay_time = 34 / 24 , pos = { x = 890, y = 208}} ,
                                    {delay_time = 32 / 24 , pos = { x = 890, y = 446.8}} ,
                                    {delay_time = 32 / 24 , pos = { x = 890, y = 246}} ,
                                    {delay_time = 30 / 24 , pos = { x = 890, y = 420}} ,
                                    {delay_time = 30 / 24 , pos = { x = 890, y = 290}} ,
                                    {delay_time = 28 / 24 , pos = { x = 890, y = 385.4}},
                                    {delay_time = 28 / 24 , pos = { x = 890, y = 322}} ,
                                    {delay_time = 26 / 24 , pos = { x = 890, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 166 / 24 , pos = { x = 890, y = 508}} ,
                                    {delay_time = 166 / 24 , pos = { x = 890, y = 170}} ,
                                    {delay_time = 169 / 24 , pos = { x = 890, y = 477.4}} ,
                                    {delay_time = 169 / 24 , pos = { x = 890, y = 208}} ,
                                    {delay_time = 172 / 24 , pos = { x = 890, y = 446.8}} ,
                                    {delay_time = 172 / 24 , pos = { x = 890, y = 246}} ,
                                    {delay_time = 175 / 24 , pos = { x = 890, y = 420}} ,
                                    {delay_time = 175 / 24 , pos = { x = 890, y = 290}} ,
                                    {delay_time = 178 / 24 , pos = { x = 890, y = 385.4}},
                                    {delay_time = 178 / 24 , pos = { x = 890, y = 322}} ,
                                    {delay_time = 181 / 24 , pos = { x = 890, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 199 / 24 , pos = { x = 890, y = 477.4}} ,
                                    {delay_time = 199 / 24 , pos = { x = 890, y = 208}} ,
                                    {delay_time = 196 / 24 , pos = { x = 890, y = 446.8}} ,
                                    {delay_time = 196 / 24 , pos = { x = 890, y = 246}} ,
                                    {delay_time = 193 / 24 , pos = { x = 890, y = 420}} ,
                                    {delay_time = 193 / 24 , pos = { x = 890, y = 290}} ,
                                    {delay_time = 190 / 24 , pos = { x = 890, y = 385.4}},
                                    {delay_time = 190 / 24 , pos = { x = 890, y = 322}} ,
                                    {delay_time = 187 / 24 , pos = { x = 890, y = 355}},
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