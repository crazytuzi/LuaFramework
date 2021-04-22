local jump_appear = 
{
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = 
    {
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {    
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },          
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBJumpAppear",
                            OPTIONS = {jump_animation = "attack21"},
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
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_ruchang_qianyin1",
                                        args = 
                                        {
                                            -- {delay_time = 0 , pos = { x = 1200, y = 400}} ,
                                            -- {delay_time = 1 / 24, pos = { x = 1100, y = 350}} ,
                                            -- {delay_time = 2 / 24 , pos = { x = 1000, y = 300}} ,
                                            -- {delay_time = 3 / 24, pos = { x = 900, y = 250}} ,
                                            -- {delay_time = 4 / 24, pos = { x = 800, y = 200}} ,
                                            -- {delay_time = 5 / 24 , pos = { x = 700, y = 150}} ,
                                            {delay_time = 0 , pos = { x = 950, y = 400}} ,
                                            {delay_time = 1 / 24, pos = { x = 850, y = 350}} ,
                                            {delay_time = 2 / 24 , pos = { x = 750, y = 300}} ,
                                            {delay_time = 3 / 24, pos = { x = 650, y = 250}} ,
                                            {delay_time = 4 / 24, pos = { x = 550, y = 200}} ,
                                            {delay_time = 5 / 24 , pos = { x = 450, y = 150}} ,
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
                            OPTIONS = {delay_time = 4 / 24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_ruchang_yujing",
                                        args = 
                                        {
                                            -- {delay_time = 0 , pos = { x = 1200, y = 400}} ,
                                            -- {delay_time = 1 / 24, pos = { x = 1100, y = 350}} ,
                                            -- {delay_time = 2 / 24 , pos = { x = 1000, y = 300}} ,
                                            -- {delay_time = 3 / 24, pos = { x = 900, y = 250}} ,
                                            -- {delay_time = 4 / 24, pos = { x = 800, y = 200}} ,
                                            -- {delay_time = 5 / 24 , pos = { x = 700, y = 150}} ,
                                            {delay_time = 0 , pos = { x = 950, y = 400}} ,
                                            {delay_time = 1 / 24, pos = { x = 850, y = 350}} ,
                                            {delay_time = 2 / 24 , pos = { x = 750, y = 300}} ,
                                            {delay_time = 3 / 24, pos = { x = 650, y = 250}} ,
                                            {delay_time = 4 / 24, pos = { x = 550, y = 200}} ,
                                            {delay_time = 5 / 24 , pos = { x = 450, y = 150}} ,

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
                            OPTIONS = {delay_time = 9 / 24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_ruchang_qianyin2",
                                        args = 
                                        {
                                            -- {delay_time = 0 , pos = { x = 600, y = 200}} ,
                                            -- {delay_time = 1 / 24, pos = { x = 500, y = 250}} ,
                                            -- {delay_time = 2 / 24 , pos = { x = 400, y = 300}} ,
                                            -- {delay_time = 3 / 24, pos = { x = 300, y = 350}} ,
                                            -- {delay_time = 4 / 24, pos = { x = 200, y = 400}} ,
                                            -- {delay_time = 5 / 24 , pos = { x = 100, y = 450}} ,
                                            -- {delay_time = 0 , pos = { x = 1200, y = 200}} ,
                                            -- {delay_time = 1 / 24, pos = { x = 1100, y = 250}} ,
                                            -- {delay_time = 2 / 24 , pos = { x = 1000, y = 300}} ,
                                            -- {delay_time = 3 / 24, pos = { x = 900, y = 350}} ,
                                            -- {delay_time = 4 / 24, pos = { x = 800, y = 400}} ,
                                            -- {delay_time = 5 / 24 , pos = { x = 700, y = 450}} ,
                                            {delay_time = 0 , pos = { x = 950, y = 200}} ,
                                            {delay_time = 1 / 24, pos = { x = 850, y = 250}} ,
                                            {delay_time = 2 / 24 , pos = { x = 750, y = 300}} ,
                                            {delay_time = 3 / 24, pos = { x = 650, y = 350}} ,
                                            {delay_time = 4 / 24, pos = { x = 550, y = 400}} ,
                                            {delay_time = 5 / 24 , pos = { x = 450, y = 450}} ,
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
                            OPTIONS = {delay_time = 11 / 24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_ruchang_yujing",
                                        args = 
                                        {
                                            -- {delay_time = 0 , pos = { x = 600, y = 200}} ,
                                            -- {delay_time = 1 / 24, pos = { x = 500, y = 250}} ,
                                            -- {delay_time = 2 / 24 , pos = { x = 400, y = 300}} ,
                                            -- {delay_time = 3 / 24, pos = { x = 300, y = 350}} ,
                                            -- {delay_time = 4 / 24, pos = { x = 200, y = 400}} ,
                                            -- {delay_time = 5 / 24 , pos = { x = 100, y = 450}} ,
                                            -- {delay_time = 0 , pos = { x = 1200, y = 200}} ,
                                            -- {delay_time = 1 / 24, pos = { x = 1100, y = 250}} ,
                                            -- {delay_time = 2 / 24 , pos = { x = 1000, y = 300}} ,
                                            -- {delay_time = 3 / 24, pos = { x = 900, y = 350}} ,
                                            -- {delay_time = 4 / 24, pos = { x = 800, y = 400}} ,
                                            -- {delay_time = 5 / 24 , pos = { x = 700, y = 450}} ,
                                            {delay_time = 0 , pos = { x = 950, y = 200}} ,
                                            {delay_time = 1 / 24, pos = { x = 850, y = 250}} ,
                                            {delay_time = 2 / 24 , pos = { x = 750, y = 300}} ,
                                            {delay_time = 3 / 24, pos = { x = 650, y = 350}} ,
                                            {delay_time = 4 / 24, pos = { x = 550, y = 400}} ,
                                            {delay_time = 5 / 24 , pos = { x = 450, y = 450}} ,
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
                            OPTIONS = {delay_time = 84 / 24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 20, duration = 0.4, count = 2,},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 84 / 24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_ruchang_jiguang",
                                        args = 
                                        {
                                            -- {delay_time = 0 , pos = { x = 1200, y = 400}} ,
                                            -- {delay_time = 1 / 24 , pos = { x = 1100, y = 350}} ,
                                            -- {delay_time = 2 / 24, pos = { x = 1000, y = 300}} ,
                                            -- {delay_time = 3 / 24, pos = { x = 900, y = 250}} ,
                                            -- {delay_time = 4 / 24 , pos = { x = 800, y = 200}} ,
                                            -- {delay_time = 5 / 24, pos = { x = 700, y = 150}} ,
                                            {delay_time = 0 , pos = { x = 950, y = 400}} ,
                                            {delay_time = 1 / 24, pos = { x = 850, y = 350}} ,
                                            -- {delay_time = 2 / 24 , pos = { x = 750, y = 300}} ,
                                            {delay_time = 3 / 24, pos = { x = 650, y = 250}} ,
                                            {delay_time = 4 / 24, pos = { x = 550, y = 200}} ,
                                            {delay_time = 5 / 24 , pos = { x = 450, y = 150}} ,
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBTrap",  
                                    OPTIONS = 
                                    { 
                                        trapId = "jiqiren_ruchang_jiguang",
                                        args = 
                                        {
                                            -- {delay_time = 6 /24 , pos = { x = 600, y = 200}} ,
                                            -- {delay_time = 7 / 24, pos = { x = 500, y = 250}} ,
                                            -- {delay_time = 8 / 24 , pos = { x = 400, y = 300}} ,
                                            -- {delay_time = 9 / 24, pos = { x = 300, y = 350}} ,
                                            -- {delay_time = 10 / 24, pos = { x = 200, y = 400}} ,
                                            -- {delay_time = 11 / 24 , pos = { x = 100, y = 450}} ,
                                            -- {delay_time = 0 , pos = { x = 1200, y = 200}} ,
                                            -- {delay_time = 1 / 24, pos = { x = 1100, y = 250}} ,
                                            -- {delay_time = 2 / 24 , pos = { x = 1000, y = 300}} ,
                                            -- {delay_time = 3 / 24, pos = { x = 900, y = 350}} ,
                                            -- {delay_time = 4 / 24, pos = { x = 800, y = 400}} ,
                                            -- {delay_time = 5 / 24 , pos = { x = 700, y = 450}} ,
                                            {delay_time = 0 , pos = { x = 950, y = 200}} ,
                                            {delay_time = 1 / 24, pos = { x = 850, y = 250}} ,
                                            -- {delay_time = 2 / 24 , pos = { x = 750, y = 300}} ,
                                            {delay_time = 3 / 24, pos = { x = 650, y = 350}} ,
                                            {delay_time = 4 / 24, pos = { x = 550, y = 400}} ,
                                            {delay_time = 5 / 24 , pos = { x = 450, y = 450}} ,
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
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 6 / 24},
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return jump_appear