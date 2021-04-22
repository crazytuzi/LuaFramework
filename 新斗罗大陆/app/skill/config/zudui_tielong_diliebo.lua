local zudui_tielong_diliebo = 
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
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 40},
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
        --------------------------------------配合动画帧数进行拉人和伤害判定
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
                    CLASS = "action.QSBPlayLoopEffect",
                    OPTIONS = {effect_id = "diliebo_yujing",is_hit_effect = false},
                },
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 65},
                },
                {
                    CLASS = "action.QSBStopLoopEffect",
                    OPTIONS = {effect_id = "diliebo_yujing",is_hit_effect = false},
                },
			},
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 27 / 24 },
                },                   
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 15, duration = 0.25, count = 2,},
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 27 / 24},
        --         },
        --         {
        --             CLASS = "composite.QSBParallel",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBPlayEffect",
        --                     OPTIONS = {effect_id = "diliebo_2" , is_hit_effect = false},
        --                 },
        --             },
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 31 / 24},
        --         },
        --         {
        --             CLASS = "composite.QSBParallel",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBPlayEffect",
        --                     OPTIONS = {effect_id = "diliebo_3" , is_hit_effect = false},
        --                 },                    
        --             },
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 35 / 24},
        --         },
        --         {
        --             CLASS = "composite.QSBParallel",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBPlayEffect",
        --                     OPTIONS = {effect_id = "diliebo_4" , is_hit_effect = false},
        --                 },                    
        --             },
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 39 / 24},
        --         },
        --         {
        --             CLASS = "composite.QSBParallel",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBPlayEffect",
        --                     OPTIONS = {effect_id = "diliebo_5" , is_hit_effect = false},
        --                 },                    
        --             },
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 43 / 24},
        --         },
        --         {
        --             CLASS = "composite.QSBParallel",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBPlayEffect",
        --                     OPTIONS = {effect_id = "diliebo_6" , is_hit_effect = false},
        --                 },                    
        --             },
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 47 / 24},
        --         },
        --         {
        --             CLASS = "composite.QSBParallel",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBPlayEffect",
        --                     OPTIONS = {effect_id = "diliebo_7" , is_hit_effect = false},
        --                 },                    
        --             },
        --         },
        --     },
        -- },
    },
}
return zudui_tielong_diliebo