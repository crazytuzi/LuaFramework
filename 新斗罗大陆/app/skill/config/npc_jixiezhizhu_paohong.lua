local shifa_tongyong = 
{
    CLASS = "composite.QSBSequence",
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
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    -- ARGS = 
                    -- {
                    --     {
                    --         CLASS = "composite.QSBParallel",
                    --         ARGS = 
                    --         {  
                    --             {
                    --                 CLASS = "action.QSBPlayEffect",
                    --                 OPTIONS = {is_hit_effect = true},
                    --             },
                    --             {
                    --                 CLASS = "action.QSBHitTarget",
                    --             },
                    --         },
                    --     },
                    -- },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 24/24 },
                        }, 
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 12/24 },
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="jixiezhizhu_attack14",is_loop = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2},
                        },
                        {
                            CLASS = "action.QSBStopSound",
                            OPTIONS = {sound_id ="jixiezhizhu_attack14"},
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong