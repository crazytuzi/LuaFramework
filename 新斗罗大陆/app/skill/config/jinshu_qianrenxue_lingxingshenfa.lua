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
                    OPTIONS = {delay_time = 46 /24 },
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
                    OPTIONS = {delay_time = 47 / 24 },
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
                    OPTIONS = {delay_time = 47 / 24 },
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
                                    OPTIONS = {delay_time = 3/24 },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBShakeScreen",
                                            OPTIONS = {amplitude = 12, duration = 0.4, count = 1,},
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
                                    OPTIONS = {delay_time = 140/24 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 9, duration = 0.35, count = 9,},
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
                                    OPTIONS = {delay_time = 196 / 24 },
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
                -----地面花火11点-4点
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 20, y = 520}} ,
                                    {delay_time = 6 / 24 , pos = { x = 1230, y = 150}} ,
                                    {delay_time = 7 / 24 , pos = { x = 88, y = 500}} ,
                                    {delay_time = 7 / 24 , pos = { x = 1164, y = 164}} ,
                                    {delay_time = 8 / 24 , pos = { x = 156, y = 482}} ,
                                    {delay_time = 8 / 24 , pos = { x = 1098, y = 188}} ,
                                    {delay_time = 9 / 24 , pos = { x = 224, y = 464}} ,
                                    {delay_time = 9 / 24 , pos = { x = 1032, y = 212}} ,
                                    {delay_time = 10 / 24 , pos = { x = 292, y = 446}},
                                    {delay_time = 10 / 24 , pos = { x = 964, y = 236}} ,
                                    {delay_time = 11 / 24 , pos = { x = 360, y = 428}},
                                    {delay_time = 11 / 24 , pos = { x = 896, y = 260}},
                                    {delay_time = 12 / 24 , pos = { x = 428, y = 410}} ,
                                    {delay_time = 12 / 24 , pos = { x = 830, y = 284}} ,
                                    {delay_time = 13 / 24 , pos = { x = 496, y = 392}} ,
                                    {delay_time = 13 / 24 , pos = { x = 764, y = 308}} ,
                                    {delay_time = 14 / 24 , pos = { x = 564, y = 374}} ,
                                    {delay_time = 14 / 24 , pos = { x = 698, y = 332}} ,
                                    {delay_time = 15 / 24 , pos = { x = 640, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 4/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_shengyan",
                                        args = 
                                        {
                                            {delay_time = 15 / 24 , pos = { x = 640, y = 355}} ,
                                            {delay_time = 16 / 24,  pos = { x = 698, y = 332}},
                                            {delay_time = 16 / 24,  pos = { x = 564, y = 374}},
                                            {delay_time = 17 / 24,  pos = { x = 764, y = 308}},
                                            {delay_time = 17 / 24,  pos = { x = 496, y = 392}},
                                            {delay_time = 18 / 24,  pos = { x = 830, y = 284}},
                                            {delay_time = 18 / 24,  pos = { x = 428, y = 410}},
                                            {delay_time = 19 / 24,  pos = { x = 896, y = 260}},
                                            {delay_time = 19 / 24,  pos = { x = 360, y = 428}},
                                            {delay_time = 20 / 24,  pos = { x = 964, y = 236}},
                                            {delay_time = 20 / 24,  pos = { x = 292, y = 446}},
                                            {delay_time = 21 / 24,  pos = { x = 1032, y = 212}},
                                            {delay_time = 21 / 24,  pos = { x = 224, y = 464}},
                                            {delay_time = 22 / 24,  pos = { x = 1098, y = 188}},
                                            {delay_time = 22 / 24,  pos = { x = 156, y = 482}},
                                            {delay_time = 23 / 24,  pos = { x = 1164, y = 164}},
                                            {delay_time = 23 / 24,  pos = { x = 88, y = 500}},
                                            {delay_time = 24 / 24,  pos = { x = 1230, y = 150}},
                                            {delay_time = 24 / 24,  pos = { x = 20, y = 520}},
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
                                    OPTIONS = {delay_time = 4/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_xuangao",
                                        args = 
                                        {
                                            {delay_time = 15 / 24 , pos = { x = 640, y = 355}} ,
                                            {delay_time = 16 / 24,  pos = { x = 708, y = 332}},
                                            {delay_time = 16 / 24,  pos = { x = 564, y = 374}},
                                            {delay_time = 17 / 24,  pos = { x = 774, y = 308}},
                                            {delay_time = 17 / 24,  pos = { x = 496, y = 392}},
                                            {delay_time = 18 / 24,  pos = { x = 840, y = 284}},
                                            {delay_time = 18 / 24,  pos = { x = 428, y = 410}},
                                            {delay_time = 19 / 24,  pos = { x = 906, y = 260}},
                                            {delay_time = 19 / 24,  pos = { x = 360, y = 428}},
                                            {delay_time = 20 / 24,  pos = { x = 974, y = 236}},
                                            {delay_time = 20 / 24,  pos = { x = 292, y = 446}},
                                            {delay_time = 21 / 24,  pos = { x = 1042, y = 212}},
                                            {delay_time = 21 / 24,  pos = { x = 224, y = 464}},
                                            {delay_time = 22 / 24,  pos = { x = 1108, y = 188}},
                                            {delay_time = 22 / 24,  pos = { x = 156, y = 482}},
                                            {delay_time = 23 / 24,  pos = { x = 1174, y = 164}},
                                            {delay_time = 23 / 24,  pos = { x = 88, y = 500}},
                                            {delay_time = 24 / 24,  pos = { x = 1240, y = 150}},
                                            {delay_time = 24 / 24,  pos = { x = 20, y = 520}},
                                        },
                                    },
                                },
                            },
                        },
                -----地面神罚11-4点
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 136 / 24 , pos = { x = 20, y = 520}} ,
                                    {delay_time = 136 / 24 , pos = { x = 1230, y = 150}} ,
                                    {delay_time = 139 / 24 , pos = { x = 88, y = 500}} ,
                                    {delay_time = 139 / 24 , pos = { x = 1164, y = 164}} ,
                                    {delay_time = 142 / 24 , pos = { x = 156, y = 482}} ,
                                    {delay_time = 142 / 24 , pos = { x = 1098, y = 188}} ,
                                    {delay_time = 145 / 24 , pos = { x = 224, y = 464}} ,
                                    {delay_time = 145 / 24 , pos = { x = 1032, y = 212}} ,
                                    {delay_time = 148 / 24 , pos = { x = 292, y = 446}},
                                    {delay_time = 148 / 24 , pos = { x = 964, y = 236}} ,
                                    {delay_time = 151 / 24 , pos = { x = 360, y = 428}},
                                    {delay_time = 151 / 24 , pos = { x = 896, y = 260}},
                                    {delay_time = 154 / 24 , pos = { x = 428, y = 410}} ,
                                    {delay_time = 154 / 24 , pos = { x = 830, y = 284}} ,
                                    {delay_time = 157 / 24 , pos = { x = 496, y = 392}} ,
                                    {delay_time = 157 / 24 , pos = { x = 764, y = 308}} ,
                                    {delay_time = 160 / 24 , pos = { x = 564, y = 374}} ,
                                    {delay_time = 160 / 24 , pos = { x = 698, y = 332}} ,
                                    {delay_time = 163 / 24 , pos = { x = 640, y = 355}},
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
                                    {delay_time = 157 / 24 , pos = { x = 496, y = 392}} ,
                                    {delay_time = 157 / 24 , pos = { x = 764, y = 308}} ,
                                    {delay_time = 160 / 24 , pos = { x = 564, y = 374}} ,
                                    {delay_time = 160 / 24 , pos = { x = 698, y = 332}} ,
                                    {delay_time = 163 / 24 , pos = { x = 640, y = 355}},
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
                                    {delay_time = 167 / 24 , pos = { x = 640, y = 355}} ,
                                    {delay_time = 170 / 24,  pos = { x = 698, y = 332}},
                                    {delay_time = 170 / 24,  pos = { x = 564, y = 374}},
                                    {delay_time = 173 / 24,  pos = { x = 764, y = 308}},
                                    {delay_time = 173 / 24,  pos = { x = 496, y = 392}},
                                    {delay_time = 176 / 24,  pos = { x = 830, y = 284}},
                                    {delay_time = 176 / 24,  pos = { x = 428, y = 410}},
                                    {delay_time = 179 / 24,  pos = { x = 896, y = 260}},
                                    {delay_time = 179 / 24,  pos = { x = 360, y = 428}},
                                    {delay_time = 182 / 24,  pos = { x = 964, y = 236}},
                                    {delay_time = 182 / 24,  pos = { x = 292, y = 446}},
                                    {delay_time = 185 / 24,  pos = { x = 1032, y = 212}},
                                    {delay_time = 185 / 24,  pos = { x = 224, y = 464}},
                                    {delay_time = 188 / 24,  pos = { x = 1098, y = 188}},
                                    {delay_time = 188 / 24,  pos = { x = 156, y = 482}},
                                    {delay_time = 191 / 24,  pos = { x = 1164, y = 164}},
                                    {delay_time = 191 / 24,  pos = { x = 88, y = 500}},
                                    {delay_time = 194 / 24,  pos = { x = 1230, y = 150}},
                                    {delay_time = 194 / 24,  pos = { x = 20, y = 520}},
                                },
                            },
                        },
                -----地面花火2点-7点
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 1230, y = 520}} ,
                                    {delay_time = 6 / 24 , pos = { x = 20, y = 150}} ,
                                    {delay_time = 7 / 24 , pos = { x = 1164, y = 500}} ,
                                    {delay_time = 7 / 24 , pos = { x = 88, y = 164}} ,
                                    {delay_time = 8 / 24 , pos = { x = 1098, y = 482}} ,
                                    {delay_time = 8 / 24 , pos = { x = 156, y = 188}} ,
                                    {delay_time = 9 / 24 , pos = { x = 1032, y = 464}} ,
                                    {delay_time = 9 / 24 , pos = { x = 224, y = 212}} ,
                                    {delay_time = 10 / 24 , pos = { x = 964, y = 446}},
                                    {delay_time = 10 / 24 , pos = { x = 292, y = 236}} ,
                                    {delay_time = 11 / 24 , pos = { x = 896, y = 428}},
                                    {delay_time = 11 / 24 , pos = { x = 360, y = 260}},
                                    {delay_time = 12 / 24 , pos = { x = 830, y = 410}} ,
                                    {delay_time = 12 / 24 , pos = { x = 428, y = 284}} ,
                                    {delay_time = 13 / 24 , pos = { x = 764, y = 392}} ,
                                    {delay_time = 13 / 24 , pos = { x = 496, y = 308}} ,
                                    {delay_time = 14 / 24 , pos = { x = 698, y = 374}} ,
                                    {delay_time = 14 / 24 , pos = { x = 564, y = 332}} ,
                                    {delay_time = 15 / 24 , pos = { x = 640, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 4/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_shengyan",
                                        args = 
                                        {
                                            {delay_time = 15 / 24 , pos = { x = 640, y = 355}} ,
                                            {delay_time = 16 / 24,  pos = { x = 564, y = 332}},
                                            {delay_time = 16 / 24,  pos = { x = 698, y = 374}},
                                            {delay_time = 17 / 24,  pos = { x = 496, y = 308}},
                                            {delay_time = 17 / 24,  pos = { x = 764, y = 392}},
                                            {delay_time = 18 / 24,  pos = { x = 428, y = 284}},
                                            {delay_time = 18 / 24,  pos = { x = 830, y = 410}},
                                            {delay_time = 19 / 24,  pos = { x = 360, y = 260}},
                                            {delay_time = 19 / 24,  pos = { x = 896, y = 428}},
                                            {delay_time = 20 / 24,  pos = { x = 292, y = 236}},
                                            {delay_time = 20 / 24,  pos = { x = 964, y = 446}},
                                            {delay_time = 21 / 24,  pos = { x = 224, y = 212}},
                                            {delay_time = 21 / 24,  pos = { x = 1032, y = 464}},
                                            {delay_time = 22 / 24,  pos = { x = 156, y = 188}},
                                            {delay_time = 22 / 24,  pos = { x = 1098, y = 482}},
                                            {delay_time = 23 / 24,  pos = { x = 88, y = 164}},
                                            {delay_time = 23 / 24,  pos = { x = 1164, y = 500}},
                                            {delay_time = 24 / 24,  pos = { x = 20, y = 150}},
                                            {delay_time = 24 / 24,  pos = { x = 1230, y = 520}},
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
                                    OPTIONS = {delay_time = 4/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_xuangao",
                                        args = 
                                        {
                                            {delay_time = 15 / 24 , pos = { x = 640, y = 355}} ,
                                            {delay_time = 16 / 24,  pos = { x = 564, y = 332}},
                                            {delay_time = 16 / 24,  pos = { x = 698, y = 374}},
                                            {delay_time = 17 / 24,  pos = { x = 496, y = 308}},
                                            {delay_time = 17 / 24,  pos = { x = 764, y = 392}},
                                            {delay_time = 18 / 24,  pos = { x = 428, y = 284}},
                                            {delay_time = 18 / 24,  pos = { x = 830, y = 410}},
                                            {delay_time = 19 / 24,  pos = { x = 360, y = 260}},
                                            {delay_time = 19 / 24,  pos = { x = 896, y = 428}},
                                            {delay_time = 20 / 24,  pos = { x = 292, y = 236}},
                                            {delay_time = 20 / 24,  pos = { x = 964, y = 446}},
                                            {delay_time = 21 / 24,  pos = { x = 224, y = 212}},
                                            {delay_time = 21 / 24,  pos = { x = 1032, y = 464}},
                                            {delay_time = 22 / 24,  pos = { x = 156, y = 188}},
                                            {delay_time = 22 / 24,  pos = { x = 1098, y = 482}},
                                            {delay_time = 23 / 24,  pos = { x = 88, y = 164}},
                                            {delay_time = 23 / 24,  pos = { x = 1164, y = 500}},
                                            {delay_time = 24 / 24,  pos = { x = 20, y = 150}},
                                            {delay_time = 24 / 24,  pos = { x = 1230, y = 520}},
                                        },
                                    },
                                },
                            },
                        },
                -----地面神罚2点--7点
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 136 / 24 , pos = { x = 1230, y = 520}} ,
                                    {delay_time = 136 / 24 , pos = { x = 20, y = 150}} ,
                                    {delay_time = 139 / 24 , pos = { x = 1164, y = 500}} ,
                                    {delay_time = 139 / 24 , pos = { x = 88, y = 164}} ,
                                    {delay_time = 142 / 24 , pos = { x = 1098, y = 482}} ,
                                    {delay_time = 142 / 24 , pos = { x = 156, y = 188}} ,
                                    {delay_time = 145 / 24 , pos = { x = 1032, y = 464}} ,
                                    {delay_time = 145 / 24 , pos = { x = 224, y = 212}} ,
                                    {delay_time = 148 / 24 , pos = { x = 964, y = 446}},
                                    {delay_time = 148 / 24 , pos = { x = 292, y = 236}} ,
                                    {delay_time = 151 / 24 , pos = { x = 896, y = 428}},
                                    {delay_time = 151 / 24 , pos = { x = 360, y = 260}},
                                    {delay_time = 154 / 24 , pos = { x = 830, y = 410}} ,
                                    {delay_time = 154 / 24 , pos = { x = 428, y = 284}} ,
                                    {delay_time = 157 / 24 , pos = { x = 764, y = 392}} ,
                                    {delay_time = 157 / 24 , pos = { x = 496, y = 308}} ,
                                    {delay_time = 160 / 24 , pos = { x = 698, y = 374}} ,
                                    {delay_time = 160 / 24 , pos = { x = 564, y = 332}} ,
                                    {delay_time = 163 / 24 , pos = { x = 640, y = 355}},
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
                                    {delay_time = 157 / 24 , pos = { x = 764, y = 392}} ,
                                    {delay_time = 157 / 24 , pos = { x = 496, y = 308}} ,
                                    {delay_time = 160 / 24 , pos = { x = 698, y = 374}} ,
                                    {delay_time = 160 / 24 , pos = { x = 564, y = 332}} ,
                                    {delay_time = 163 / 24 , pos = { x = 640, y = 355}},
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
                                    {delay_time = 167 / 24 , pos = { x = 640, y = 355}} ,
                                    {delay_time = 170 / 24,  pos = { x = 564, y = 332}},
                                    {delay_time = 170 / 24,  pos = { x = 698, y = 374}},
                                    {delay_time = 173 / 24,  pos = { x = 496, y = 308}},
                                    {delay_time = 173 / 24,  pos = { x = 764, y = 392}},
                                    {delay_time = 176 / 24,  pos = { x = 428, y = 284}},
                                    {delay_time = 176 / 24,  pos = { x = 830, y = 410}},
                                    {delay_time = 179 / 24,  pos = { x = 360, y = 260}},
                                    {delay_time = 179 / 24,  pos = { x = 896, y = 428}},
                                    {delay_time = 182 / 24,  pos = { x = 292, y = 236}},
                                    {delay_time = 182 / 24,  pos = { x = 964, y = 446}},
                                    {delay_time = 185 / 24,  pos = { x = 224, y = 212}},
                                    {delay_time = 185 / 24,  pos = { x = 1032, y = 464}},
                                    {delay_time = 188 / 24,  pos = { x = 156, y = 188}},
                                    {delay_time = 188 / 24,  pos = { x = 1098, y = 482}},
                                    {delay_time = 191 / 24,  pos = { x = 88, y = 164}},
                                    {delay_time = 191 / 24,  pos = { x = 1164, y = 500}},
                                    {delay_time = 194 / 24,  pos = { x = 20, y = 150}},
                                    {delay_time = 194 / 24,  pos = { x = 1230, y = 520}},
                                },
                            },
                        },
                ------地面花火2-7点左上
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 640, y = 520}} ,
                                    {delay_time = 7 / 24 , pos = { x = 554, y = 506}} ,
                                    {delay_time = 8 / 24 , pos = { x = 496, y = 492}} ,
                                    {delay_time = 9 / 24 , pos = { x = 428, y = 478}} ,
                                    {delay_time = 10 / 24 , pos = { x = 360, y = 464}} ,
                                    {delay_time = 11 / 24 , pos = { x = 292, y = 446}},
                                    {delay_time = 12 / 24 , pos = { x = 224, y = 428}},
                                    {delay_time = 13 / 24 , pos = { x = 156, y = 410}} ,
                                    {delay_time = 14 / 24 , pos = { x = 88, y = 392}} ,
                                    {delay_time = 15 / 24 , pos = { x = 20, y = 374}} ,
                                    -- {delay_time = 15 / 24 , pos = { x = 0, y = 355}},
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
                                    {delay_time = 6 / 24 , pos = { x = 640, y = 520}} ,
                                    {delay_time = 7 / 24 , pos = { x = 554, y = 506}} ,
                                    {delay_time = 8 / 24 , pos = { x = 496, y = 492}} ,
                                    {delay_time = 9 / 24 , pos = { x = 428, y = 478}} ,
                                    {delay_time = 10 / 24 , pos = { x = 360, y = 464}} ,
                                    {delay_time = 11 / 24 , pos = { x = 292, y = 446}},
                                    {delay_time = 12 / 24 , pos = { x = 224, y = 428}},
                                    {delay_time = 13 / 24 , pos = { x = 156, y = 410}} ,
                                    {delay_time = 14 / 24 , pos = { x = 88, y = 392}} ,
                                    {delay_time = 15 / 24 , pos = { x = 20, y = 374}} ,
                                    -- {delay_time = 15 / 24 , pos = { x = 0, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 4/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_shengyan",
                                        args = 
                                        {
                                            {delay_time = 24 / 24 , pos = { x = 640, y = 520}} ,
                                            {delay_time = 23 / 24 , pos = { x = 554, y = 506}} ,
                                            {delay_time = 22 / 24 , pos = { x = 496, y = 492}} ,
                                            {delay_time = 21 / 24 , pos = { x = 428, y = 478}} ,
                                            {delay_time = 20 / 24 , pos = { x = 360, y = 464}} ,
                                            {delay_time = 19 / 24 , pos = { x = 292, y = 446}},
                                            {delay_time = 18 / 24 , pos = { x = 224, y = 428}},
                                            {delay_time = 17 / 24 , pos = { x = 156, y = 410}} ,
                                            {delay_time = 16 / 24 , pos = { x = 88, y = 392}} ,
                                            {delay_time = 15 / 24 , pos = { x = 20, y = 374}} ,
                                            -- {delay_time = 15 / 24 , pos = { x = 0, y = 355}},
                                        },
                                    },
                                },
                            },
                        },
                ---地面神罚2-7点左上
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 136 / 24 , pos = { x = 640, y = 520}} ,
                                    {delay_time = 139 / 24 , pos = { x = 554, y = 506}} ,
                                    {delay_time = 142 / 24 , pos = { x = 496, y = 492}} ,
                                    {delay_time = 145 / 24 , pos = { x = 428, y = 478}} ,
                                    {delay_time = 148 / 24 , pos = { x = 360, y = 464}} ,
                                    {delay_time = 151 / 24 , pos = { x = 292, y = 446}},
                                    {delay_time = 154 / 24 , pos = { x = 224, y = 428}},
                                    {delay_time = 157 / 24 , pos = { x = 156, y = 410}} ,
                                    {delay_time = 160 / 24 , pos = { x = 88, y = 392}} ,
                                    {delay_time = 163 / 24 , pos = { x = 20, y = 374}} ,
                                    -- {delay_time = 15 / 24 , pos = { x = 0, y = 355}},
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
                                    {delay_time = 194 / 24 , pos = { x = 640, y = 520}} ,
                                    {delay_time = 191 / 24 , pos = { x = 554, y = 506}} ,
                                    {delay_time = 188 / 24 , pos = { x = 496, y = 492}} ,
                                    {delay_time = 185 / 24 , pos = { x = 428, y = 478}} ,
                                    {delay_time = 182 / 24 , pos = { x = 360, y = 464}} ,
                                    {delay_time = 179 / 24 , pos = { x = 292, y = 446}},
                                    {delay_time = 176 / 24 , pos = { x = 224, y = 428}},
                                    {delay_time = 173 / 24 , pos = { x = 156, y = 410}} ,
                                    {delay_time = 170 / 24 , pos = { x = 88, y = 392}} ,
                                    {delay_time = 167 / 24 , pos = { x = 20, y = 374}} ,
                                    -- {delay_time = 15 / 24 , pos = { x = 0, y = 355}},
                                },
                            },
                        },
                -----地面花火11--5点左上
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 640, y = 520}} ,
                                    {delay_time = 7 / 24 , pos = { x = 698, y = 500}} ,
                                    {delay_time = 8 / 24 , pos = { x = 764, y = 482}} ,
                                    {delay_time = 9 / 24 , pos = { x = 830, y = 464}} ,
                                    {delay_time = 10 / 24 , pos = { x = 896, y = 446}},
                                    {delay_time = 11 / 24 , pos = { x = 964, y = 428}},
                                    {delay_time = 12 / 24 , pos = { x = 1032, y = 410}} ,
                                    {delay_time = 13 / 24 , pos = { x = 1098, y = 392}} ,
                                    {delay_time = 14 / 24 , pos = { x = 1164, y = 374}} ,
                                    {delay_time = 15 / 24 , pos = { x = 1230, y = 355}},
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
                                    {delay_time = 6 / 24 , pos = { x = 640, y = 520}} ,
                                    {delay_time = 7 / 24 , pos = { x = 698, y = 500}} ,
                                    {delay_time = 8 / 24 , pos = { x = 764, y = 482}} ,
                                    {delay_time = 9 / 24 , pos = { x = 830, y = 464}} ,
                                    {delay_time = 10 / 24 , pos = { x = 896, y = 446}},
                                    {delay_time = 11 / 24 , pos = { x = 964, y = 428}},
                                    {delay_time = 12 / 24 , pos = { x = 1032, y = 410}} ,
                                    {delay_time = 13 / 24 , pos = { x = 1098, y = 392}} ,
                                    {delay_time = 14 / 24 , pos = { x = 1164, y = 374}} ,
                                    {delay_time = 15 / 24 , pos = { x = 1230, y = 355}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 4/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_shengyan",
                                        args = 
                                        {
                                            {delay_time = 24 / 24 , pos = { x = 640, y = 520}} ,
                                            {delay_time = 23 / 24 , pos = { x = 698, y = 500}} ,
                                            {delay_time = 22 / 24 , pos = { x = 764, y = 482}} ,
                                            {delay_time = 21 / 24 , pos = { x = 830, y = 464}} ,
                                            {delay_time = 20 / 24 , pos = { x = 896, y = 446}},
                                            {delay_time = 19 / 24 , pos = { x = 964, y = 428}},
                                            {delay_time = 18 / 24 , pos = { x = 1032, y = 410}} ,
                                            {delay_time = 17 / 24 , pos = { x = 1098, y = 392}} ,
                                            {delay_time = 16 / 24 , pos = { x = 1164, y = 374}} ,
                                            {delay_time = 15 / 24 , pos = { x = 1230, y = 355}},
                                        },
                                    },
                                },
                            },
                        },
                -----地面神罚11-5
                         {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie2",
                                args = 
                                {
                                    {delay_time = 136 / 24 , pos = { x = 640, y = 520}} ,
                                    {delay_time = 139 / 24 , pos = { x = 698, y = 500}} ,
                                    {delay_time = 142 / 24 , pos = { x = 764, y = 482}} ,
                                    {delay_time = 145 / 24 , pos = { x = 830, y = 464}} ,
                                    {delay_time = 148 / 24 , pos = { x = 896, y = 446}},
                                    {delay_time = 151 / 24 , pos = { x = 964, y = 428}},
                                    {delay_time = 154 / 24 , pos = { x = 1032, y = 410}} ,
                                    {delay_time = 157 / 24 , pos = { x = 1098, y = 392}} ,
                                    {delay_time = 160 / 24 , pos = { x = 1164, y = 374}} ,
                                    {delay_time = 163 / 24 , pos = { x = 1230, y = 355}},
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
                                    {delay_time = 194 / 24 , pos = { x = 640, y = 520}} ,
                                    {delay_time = 191 / 24 , pos = { x = 698, y = 500}} ,
                                    {delay_time = 188 / 24 , pos = { x = 764, y = 482}} ,
                                    {delay_time = 185 / 24 , pos = { x = 830, y = 464}} ,
                                    {delay_time = 182 / 24 , pos = { x = 896, y = 446}},
                                    {delay_time = 179 / 24 , pos = { x = 964, y = 428}},
                                    {delay_time = 176 / 24 , pos = { x = 1032, y = 410}} ,
                                    {delay_time = 173 / 24 , pos = { x = 1098, y = 392}} ,
                                    {delay_time = 170 / 24 , pos = { x = 1164, y = 374}} ,
                                    {delay_time = 167 / 24 , pos = { x = 1230, y = 355}},
                                },
                            },
                        },
                -----地面花火11---5点左下
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 640, y = 164}} ,
                                    {delay_time = 7 / 24 , pos = { x = 572, y = 188}} ,
                                    {delay_time = 8 / 24 , pos = { x = 503, y = 212}} ,
                                    {delay_time = 9 / 24 , pos = { x = 434, y = 236}} ,
                                    {delay_time = 10 / 24 , pos = { x = 365, y = 260}},
                                    {delay_time = 11 / 24 , pos = { x = 296, y = 284}},
                                    {delay_time = 12 / 24 , pos = { x = 227, y = 308}} ,
                                    {delay_time = 13 / 24 , pos = { x = 158, y = 332}} ,
                                    {delay_time = 14 / 24 , pos = { x = 89, y = 356}} ,
                                    {delay_time = 15 / 24 , pos = { x = 20, y = 374}},
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
                                    {delay_time = 6 / 24 , pos = { x = 640, y = 164}} ,
                                    {delay_time = 7 / 24 , pos = { x = 572, y = 188}} ,
                                    {delay_time = 8 / 24 , pos = { x = 503, y = 212}} ,
                                    {delay_time = 9 / 24 , pos = { x = 434, y = 236}} ,
                                    {delay_time = 10 / 24 , pos = { x = 365, y = 260}},
                                    {delay_time = 11 / 24 , pos = { x = 296, y = 284}},
                                    {delay_time = 12 / 24 , pos = { x = 227, y = 308}} ,
                                    {delay_time = 13 / 24 , pos = { x = 158, y = 332}} ,
                                    {delay_time = 14 / 24 , pos = { x = 89, y = 356}} ,
                                    {delay_time = 15 / 24 , pos = { x = 20, y = 374}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 4/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_shengyan",
                                        args = 
                                        {
                                            {delay_time = 24 / 24 , pos = { x = 640, y = 164}} ,
                                            {delay_time = 23 / 24 , pos = { x = 572, y = 188}} ,
                                            {delay_time = 22 / 24 , pos = { x = 503, y = 212}} ,
                                            {delay_time = 21 / 24 , pos = { x = 434, y = 236}} ,
                                            {delay_time = 20 / 24 , pos = { x = 365, y = 260}},
                                            {delay_time = 19 / 24 , pos = { x = 296, y = 284}},
                                            {delay_time = 18 / 24 , pos = { x = 227, y = 308}} ,
                                            {delay_time = 17 / 24 , pos = { x = 158, y = 332}} ,
                                            {delay_time = 16 / 24 , pos = { x = 89, y = 356}} ,
                                            {delay_time = 15 / 24 , pos = { x = 20, y = 374}},
                                        },
                                    },
                                },
                            },
                        },
                -----地面神罚11-5左下
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie1",
                                args = 
                                {
                                    {delay_time = 136 / 24 , pos = { x = 640, y = 164}} ,
                                    {delay_time = 139 / 24 , pos = { x = 572, y = 188}} ,
                                    {delay_time = 142 / 24 , pos = { x = 503, y = 212}} ,
                                    {delay_time = 145 / 24 , pos = { x = 434, y = 236}} ,
                                    {delay_time = 148 / 24 , pos = { x = 365, y = 260}},
                                    {delay_time = 151 / 24 , pos = { x = 296, y = 284}},
                                    {delay_time = 154 / 24 , pos = { x = 227, y = 308}} ,
                                    {delay_time = 157 / 24 , pos = { x = 158, y = 332}} ,
                                    {delay_time = 160 / 24 , pos = { x = 89, y = 356}} ,
                                    {delay_time = 163 / 24 , pos = { x = 20, y = 374}},
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
                                    {delay_time = 194 / 24 , pos = { x = 640, y = 164}} ,
                                    {delay_time = 191 / 24 , pos = { x = 572, y = 188}} ,
                                    {delay_time = 188 / 24 , pos = { x = 503, y = 212}} ,
                                    {delay_time = 185 / 24 , pos = { x = 434, y = 236}} ,
                                    {delay_time = 182 / 24 , pos = { x = 365, y = 260}},
                                    {delay_time = 179 / 24 , pos = { x = 296, y = 284}},
                                    {delay_time = 176 / 24 , pos = { x = 227, y = 308}} ,
                                    {delay_time = 173 / 24 , pos = { x = 158, y = 332}} ,
                                    {delay_time = 170 / 24 , pos = { x = 89, y = 356}} ,
                                    {delay_time = 167 / 24 , pos = { x = 20, y = 374}},
                                },
                            },
                        },
                -----地面花火7-2点左下
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_shengyan",
                                args = 
                                {
                                    {delay_time = 6 / 24 , pos = { x = 640, y = 164}} ,
                                    {delay_time = 7 / 24 , pos = { x = 706, y = 188}} ,
                                    {delay_time = 8 / 24 , pos = { x = 770, y = 206}} ,
                                    {delay_time = 9 / 24 , pos = { x = 836, y = 224}} ,
                                    {delay_time = 10 / 24 , pos = { x = 902, y = 242}},
                                    {delay_time = 11 / 24 , pos = { x = 968, y = 260}},
                                    {delay_time = 12 / 24 , pos = { x = 1034, y = 278}} ,
                                    {delay_time = 13 / 24 , pos = { x = 1098, y = 296}} ,
                                    {delay_time = 14 / 24 , pos = { x = 1164, y = 314}} ,
                                    {delay_time = 15 / 24 , pos = { x = 1230, y = 336}},
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
                                    {delay_time = 6 / 24 , pos = { x = 640, y = 164}} ,
                                    {delay_time = 7 / 24 , pos = { x = 706, y = 188}} ,
                                    {delay_time = 8 / 24 , pos = { x = 770, y = 206}} ,
                                    {delay_time = 9 / 24 , pos = { x = 836, y = 224}} ,
                                    {delay_time = 10 / 24 , pos = { x = 902, y = 242}},
                                    {delay_time = 11 / 24 , pos = { x = 968, y = 260}},
                                    {delay_time = 12 / 24 , pos = { x = 1034, y = 278}} ,
                                    {delay_time = 13 / 24 , pos = { x = 1098, y = 296}} ,
                                    {delay_time = 14 / 24 , pos = { x = 1164, y = 314}} ,
                                    {delay_time = 15 / 24 , pos = { x = 1230, y = 336}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 4/24 },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jinshu_qianrenxue_shengyan",
                                        args = 
                                        {
                                            {delay_time = 24 / 24 , pos = { x = 640, y = 164}} ,
                                            {delay_time = 23 / 24 , pos = { x = 698, y = 188}} ,
                                            {delay_time = 22 / 24 , pos = { x = 764, y = 206}} ,
                                            {delay_time = 21 / 24 , pos = { x = 830, y = 224}} ,
                                            {delay_time = 20 / 24 , pos = { x = 896, y = 242}},
                                            {delay_time = 19 / 24 , pos = { x = 964, y = 260}},
                                            {delay_time = 18 / 24 , pos = { x = 1032, y = 278}} ,
                                            {delay_time = 17 / 24 , pos = { x = 1098, y = 296}} ,
                                            {delay_time = 16 / 24 , pos = { x = 1164, y = 314}} ,
                                            {delay_time = 15 / 24 , pos = { x = 1230, y = 336}},
                                        },
                                    },
                                },
                            },
                        },
                -----地面神罚7--2点左下
                        {
                            CLASS = "action.QSBTrap",  
                            OPTIONS = 
                            { 
                                trapId = "jinshu_qianrenxue_zhongjie1",
                                args = 
                                {
                                    {delay_time = 136 / 24 , pos = { x = 640, y = 164}} ,
                                    {delay_time = 139 / 24 , pos = { x = 706, y = 188}} ,
                                    {delay_time = 142 / 24 , pos = { x = 770, y = 206}} ,
                                    {delay_time = 145 / 24 , pos = { x = 836, y = 224}} ,
                                    {delay_time = 148 / 24 , pos = { x = 902, y = 242}},
                                    {delay_time = 151 / 24 , pos = { x = 968, y = 260}},
                                    {delay_time = 154 / 24 , pos = { x = 1034, y = 278}} ,
                                    {delay_time = 157 / 24 , pos = { x = 1098, y = 296}} ,
                                    {delay_time = 160 / 24 , pos = { x = 1164, y = 314}} ,
                                    {delay_time = 163 / 24 , pos = { x = 1230, y = 336}},
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
                                    {delay_time = 194 / 24 , pos = { x = 640, y = 164}} ,
                                    {delay_time = 191 / 24 , pos = { x = 706, y = 188}} ,
                                    {delay_time = 188 / 24 , pos = { x = 770, y = 206}} ,
                                    {delay_time = 185 / 24 , pos = { x = 836, y = 224}} ,
                                    {delay_time = 182 / 24 , pos = { x = 902, y = 242}},
                                    {delay_time = 179 / 24 , pos = { x = 968, y = 260}},
                                    {delay_time = 176 / 24 , pos = { x = 1034, y = 278}} ,
                                    {delay_time = 173 / 24 , pos = { x = 1098, y = 296}} ,
                                    {delay_time = 170 / 24 , pos = { x = 1164, y = 314}} ,
                                    {delay_time = 167 / 24 , pos = { x = 1230, y = 336}},
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