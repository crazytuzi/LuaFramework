local boss_zhaowuji_zhonglijiya = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        -- {
        --     CLASS = "composite.QSBParallel",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {effect_id = "zhaowuji_attack16_1", is_hit_effect = false}
        --         },
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {effect_id = "zhaowuji_attack16_1_1", is_hit_effect = false},
        --         },
        --     },     
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 37 / 30 },
                },                   
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 5, duration = 0.35, count = 2,},
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_time = 35 / 24 },
                -- }, 
                -- {
                --     CLASS = "action.QSBShakeScreen",
                --     OPTIONS = {amplitude = 15, duration = 0.35, count = 2,},
                -- },
             },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 76 / 30 },
                },
                {
                    CLASS = "action.QSBRoledirection",
                    OPTIONS = {direction = "left"},
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_time = 15 / 30 },
                -- },
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {effect_id = "drunken_fist_1_4" , is_hit_effect = false},
                -- },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 60 / 30 },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 60 / 30 },
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
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
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
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 15 / 30 },
                        },
                        {
                            CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                            OPTIONS = { pos = {x=1020,y=320} , move_time = 0.7},
                        },
                    },
                },                               
            },
        },     
    },
}

return boss_zhaowuji_zhonglijiya