local boss_niumang_wuxianshuizhu = 
{
	CLASS = "composite.QSBParallel",
    ARGS = 
    {
         -------------------------------------- 播放攻击动画
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
					ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
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
                    OPTIONS = {delay_time = 86 / 24},
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
                    OPTIONS = {delay_time = 93 / 24},
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
                    OPTIONS = {delay_time = 101 / 24},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        --------------------------------------配合动画帧数进行拉人和伤害判定
  --       {
  --           CLASS = "composite.QSBSequence",
  --           ARGS = 
  --           {
		-- 		{
  --                   CLASS = "action.QSBPlayLoopEffect",
  --                   OPTIONS = {effect_id = "hongquan_niumanglaren",is_hit_effect = false},
  --               },
  --           	{
  --                   CLASS = "action.QSBDelayTime",
  --                   OPTIONS = {delay_frame = 85},
  --               },
  --               {
  --                   CLASS = "action.QSBStopLoopEffect",
  --                   OPTIONS = {effect_id = "hongquan_niumanglaren",is_hit_effect = false},
  --               },
		-- 	},
		-- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "hongquan_niumanglaren"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 85},
                },
                {
                    CLASS = "action.QSBRemoveBuff",     
                    OPTIONS = {buff_id = "hongquan_niumanglaren"},
                },
            },
        },
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
                    {delay_time = 0 , relative_pos = { x = 0, y = -135}} ,
                    {delay_time = 6 / 24 , relative_pos = { x = -220, y = -120}} ,
                    {delay_time = 6 / 24, relative_pos = { x = 220, y = -120}} ,
                    {delay_time = 12 / 24, relative_pos = { x = -345, y = -50}} ,
                    {delay_time = 12 / 24 , relative_pos = { x = 345, y = -50}} ,
                    {delay_time = 18 / 24, relative_pos = { x = 345, y = 50}} ,
                    {delay_time = 18 / 24, relative_pos = { x = -345, y = 50}},
                    {delay_time = 24 / 24, relative_pos = { x = 220, y = 120}} ,
                    {delay_time = 24 / 24, relative_pos = { x = -220, y = 120}},
                    {delay_time = 30 / 24, relative_pos = { x = 0, y = 135}},
                    {delay_time = 56 / 24, relative_pos = { x = 0, y = -135}} ,
                    {delay_time = 62 / 24 , relative_pos = { x = -220, y = -120}} ,
                    {delay_time = 62 / 24, relative_pos = { x = 220, y = -120}} ,
                    {delay_time = 68 / 24, relative_pos = { x = -345, y = -50}} ,
                    {delay_time = 68 / 24 , relative_pos = { x = 345, y = -50}} ,
                    {delay_time = 74 / 24, relative_pos = { x = 345, y = 50}} ,
                    {delay_time = 74 / 24, relative_pos = { x = -345, y = 50}},
                    {delay_time = 80 / 24, relative_pos = { x = 220, y = 120}} ,
                    {delay_time = 80 / 24, relative_pos = { x = -220, y = 120}},
                    {delay_time = 86 / 24, relative_pos = { x = 0, y = 135}},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 86 / 24},
                },
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 12, duration = 0.45, count = 2,},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 86 / 24},
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
                    OPTIONS = {delay_time = 89 / 24},
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
                    OPTIONS = {delay_time = 92 / 24},
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
                    OPTIONS = {delay_time = 95 / 24},
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
                    OPTIONS = {delay_time = 98 / 24},
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
                    OPTIONS = {delay_time = 101 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
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
	},
}
return boss_niumang_wuxianshuizhu