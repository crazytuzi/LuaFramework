local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
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
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 5},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "qianrenxue_attack14_1b", is_hit_effect = false},
                        },               
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS =
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 40},
                        },               
                        {
                            CLASS = "action.QSBHitTarget",
                        },                     
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_time = 1.5},
                        -- },
                        {
                            CLASS = "action.QSBAttackByBuffNum",
                            OPTIONS = {buff_id = "qianrenxue_zidong2_buff",min_num = 0,max_num = 5,num_pre_stack_count = 1,trigger_skill_id = 287,target_type = "enemy"},
                        },
                        -- {
                        --     CLASS = "action.QSBAttackFinish",
                        -- },          
                    },  
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 30/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 8, duration = 0.3, count = 3,},
                                },
                            },
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