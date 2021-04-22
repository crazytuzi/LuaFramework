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
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBJumpAppear",
                            OPTIONS = {jump_animation = "attack21"},
                        }, 
                        {
                            CLASS = "action.QSBActorFadeOut",
                            OPTIONS = {duration = 0.1, revertable = true},
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
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 0/24 },
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBTrap", 
                                                    OPTIONS = 
                                                    { 
                                                        trapId = "niumang_ruchang1",
                                                        args = 
                                                        {
                                                            {delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "action.QSBTrap",  
                                                    OPTIONS = 
                                                    { 
                                                        trapId = "niumang_ruchang2",
                                                        args = 
                                                        {
                                                            {delay_time = 0 , relative_pos = { x = 0, y = 135}} ,
                                                            {delay_time = 0 , relative_pos = { x = 0, y = -135}} ,
                                                            {delay_time = 3 / 24 , relative_pos = { x = -220, y = 120}} ,
                                                            {delay_time = 3 / 24, relative_pos = { x = 220, y = -120}} ,
                                                            {delay_time = 6 / 24, relative_pos = { x = -345, y = 50}} ,
                                                            {delay_time = 6 / 24 , relative_pos = { x = 345, y = -50}} ,
                                                            {delay_time = 9 / 24, relative_pos = { x = 345, y = 50}} ,
                                                            {delay_time = 9 / 24, relative_pos = { x = -345, y = -50}},
                                                            {delay_time = 12 / 24, relative_pos = { x = 220, y = 120}} ,
                                                            {delay_time = 12 / 24, relative_pos = { x = -220, y = -120}},
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",    -- 入场魂环
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 40/24 },
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "taitanjuyuan_soul_2" , is_hit_effect = false},
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
                                            CLASS = "action.QSBPlaySound",
                                            OPTIONS = {sound_id ="tianqingniumang_attack15_1"},
                                        },    
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 17/24 },
                                        },
                                        {
                                            CLASS = "action.QSBPlaySound",
                                            OPTIONS = {sound_id ="tianqingniumang_attack21"},
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
                                            CLASS = "action.QSBPlaySound",
                                            OPTIONS = {sound_id ="tianqingniumang_skill"},
                                        },    
                                    },
                                },
                                -- {
                                --     CLASS = "action.QSBJumpAppear",
                                --     OPTIONS = {jump_animation = "attack21"},
                                -- }, 
                                -- {
                                --     CLASS = "action.QSBActorFadeOut",
                                --     OPTIONS = {duration = 0.1, revertable = true},
                                -- },
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
                                                    OPTIONS = {amplitude = 8, duration = 0.35, count = 3,},
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
                                                            OPTIONS = {amplitude = 12, duration = 0.4, count = 3,},
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "action.QSBActorFadeIn",
                                                    OPTIONS = {duration = 1, revertable = true},
                                                },
                                                {
                                                    CLASS = "action.QSBPlayAnimation",
                                                    OPTIONS = {animation = "attack13"},
                                                    -- ARGS = 
                                                    -- {
                                                    --     {
                                                    --         CLASS = "action.QSBHitTarget",
                                                    --     },
                                                    -- },
                                                },
                                                {
                                                    CLASS="composite.QSBSequence",          --spine后用于触发技能特效
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 28 / 30 },
                                                        },
                                                        {
                                                            CLASS = "action.QSBPlayEffect",
                                                            OPTIONS = {effect_id = "tianqingniumang_attack13_6" ,is_hit_effect = false},
                                                        },
                                                    },
                                                },
                                                {
                                                	CLASS="composite.QSBSequence",          --spine后用于触发技能效果
                                                	ARGS = 
                                                	{
                                                		{
                                                			CLASS = "action.QSBDelayTime",
                                                			OPTIONS = {delay_time = 30 / 30 },
                                                		},
                                                		{
                                                			CLASS = "action.QSBHitTarget",
                                                		},
                                                	},
                                                },
                                            },
                                        },                      
                                    },
                                },
                -------   螺旋境界
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 11/24 },
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
                                                            OPTIONS = {delay_time = 6 / 24},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a1y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a1x" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a7y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a7x" , is_hit_effect = false},
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
                                                            OPTIONS = {delay_time = 9 / 24},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a2y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a2x" , is_hit_effect = false},
                                                                },
                                                                   {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a8y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a8x" , is_hit_effect = false},
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
                                                            OPTIONS = {delay_time = 12 / 24},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a3y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a3x" , is_hit_effect = false},
                                                                },
                                                                   {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a9y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a9x" , is_hit_effect = false},
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
                                                            OPTIONS = {delay_time = 15 / 24},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a5y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a5x" , is_hit_effect = false},
                                                                },
                                                                   {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a11y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a11x" , is_hit_effect = false},
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
                                                            OPTIONS = {delay_time = 18 / 24},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a6y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a6x" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a12y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a12x" , is_hit_effect = false},
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
                                                            OPTIONS = {delay_time = 21 / 24},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a1y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a1x" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a7y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a7x" , is_hit_effect = false},
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
                                                            OPTIONS = {delay_time = 24 / 24},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a2y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a2x" , is_hit_effect = false},
                                                                },
                                                                   {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a8y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a8x" , is_hit_effect = false},
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
                                                            OPTIONS = {delay_time = 27 / 24},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a3y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a3x" , is_hit_effect = false},
                                                                },
                                                                   {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a9y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a9x" , is_hit_effect = false},
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
                                                            OPTIONS = {delay_time = 30 / 24},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a5y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a5x" , is_hit_effect = false},
                                                                },
                                                                   {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a11y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a11x" , is_hit_effect = false},
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
                                                            OPTIONS = {delay_time = 33 / 24},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a6y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a6x" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a12y" , is_hit_effect = false},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "senluowanxiang_a12x" , is_hit_effect = false},
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
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 12 / 24},
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