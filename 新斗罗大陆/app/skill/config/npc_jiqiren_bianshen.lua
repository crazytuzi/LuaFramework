local jinzhan_tongyong = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        -- },  可能因为重复上了导致免疫失效，所以删掉 2020-3-17
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlaySound"
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack04"}, 
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
                                -- {
                                --     CLASS = "action.QSBHitTarget",
                                -- },
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
                            OPTIONS = {delay_time = 60 /24 },
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "jijia_bianshen"},
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

return jinzhan_tongyong