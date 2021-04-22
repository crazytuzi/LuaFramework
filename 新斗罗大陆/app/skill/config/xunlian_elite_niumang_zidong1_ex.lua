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
                    {delay_time = 0 , relative_pos = { x = -100, y = 20}} ,
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
            CLASS = "action.QSBTrap",  
            OPTIONS = 
            { 
                trapId = "niumang_ruchang_shuibo1",
                args = 
                {
                    {delay_time = 81 , relative_pos = { x = 0, y = -135}} ,
                    {delay_time = 84 / 24 , relative_pos = { x = -220, y = -120}} ,
                    {delay_time = 84 / 24, relative_pos = { x = 220, y = -120}} ,
                    {delay_time = 87 / 24, relative_pos = { x = -345, y = -50}} ,
                    {delay_time = 87 / 24 , relative_pos = { x = 345, y = -50}} ,
                    {delay_time = 90 / 24, relative_pos = { x = 345, y = 50}} ,
                    {delay_time = 90 / 24, relative_pos = { x = -345, y = 50}},
                    {delay_time = 93 / 24, relative_pos = { x = 220, y = 120}} ,
                    {delay_time = 93 / 24, relative_pos = { x = -220, y = 120}},
                    {delay_time = 96 / 24, relative_pos = { x = 0, y = 135}},
                    {delay_time = 96 / 24, relative_pos = { x = 0, y = -135}} ,
                    {delay_time = 99 / 24 , relative_pos = { x = -220, y = -120}} ,
                    {delay_time = 99 / 24, relative_pos = { x = 220, y = -120}} ,
                    {delay_time = 102 / 24, relative_pos = { x = -345, y = -50}} ,
                    {delay_time = 102 / 24 , relative_pos = { x = 345, y = -50}} ,
                    {delay_time = 105 / 24, relative_pos = { x = 345, y = 50}} ,
                    {delay_time = 105 / 24, relative_pos = { x = -345, y = 50}},
                    {delay_time = 108 / 24, relative_pos = { x = 220, y = 120}} ,
                    {delay_time = 108 / 24, relative_pos = { x = -220, y = 120}},
                    {delay_time = 111 / 24, relative_pos = { x = 0, y = 135}},
                },
            },
        },
        {
            CLASS = "action.QSBTrap",  
            OPTIONS = 
            { 
                trapId = "niumang_ruchang_shuibo2",
                args = 
                {
                    {delay_time = 81 , relative_pos = { x = 0, y = -135}} ,
                    {delay_time = 84 / 24 , relative_pos = { x = -220, y = -120}} ,
                    {delay_time = 84 / 24, relative_pos = { x = 220, y = -120}} ,
                    {delay_time = 87 / 24, relative_pos = { x = -345, y = -50}} ,
                    {delay_time = 87 / 24 , relative_pos = { x = 345, y = -50}} ,
                    {delay_time = 90 / 24, relative_pos = { x = 345, y = 50}} ,
                    {delay_time = 90 / 24, relative_pos = { x = -345, y = 50}},
                    {delay_time = 93 / 24, relative_pos = { x = 220, y = 120}} ,
                    {delay_time = 93 / 24, relative_pos = { x = -220, y = 120}},
                    {delay_time = 96 / 24, relative_pos = { x = 0, y = 135}},
                    {delay_time = 96 / 24, relative_pos = { x = 0, y = -135}} ,
                    {delay_time = 99 / 24 , relative_pos = { x = -220, y = -120}} ,
                    {delay_time = 99 / 24, relative_pos = { x = 220, y = -120}} ,
                    {delay_time = 102 / 24, relative_pos = { x = -345, y = -50}} ,
                    {delay_time = 102 / 24 , relative_pos = { x = 345, y = -50}} ,
                    {delay_time = 105 / 24, relative_pos = { x = 345, y = 50}} ,
                    {delay_time = 105 / 24, relative_pos = { x = -345, y = 50}},
                    {delay_time = 108 / 24, relative_pos = { x = 220, y = 120}} ,
                    {delay_time = 108 / 24, relative_pos = { x = -220, y = 120}},
                    {delay_time = 111 / 24, relative_pos = { x = 0, y = 135}},
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
	},
}
return boss_niumang_wuxianshuizhu