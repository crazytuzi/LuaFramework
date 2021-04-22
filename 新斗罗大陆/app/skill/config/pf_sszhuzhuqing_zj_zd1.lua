local daimubai_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "pf_sszzq_zd1_1", is_hit_effect = false},
        },
        -- {
        --     CLASS = "action.QSBPlayEffect",
        --     OPTIONS = {effect_id = "pf_sszzq_zd1_2", is_hit_effect = false},
        -- },
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 27 / 30},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_sszzq_zd1_3", is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 1.35},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = 
                                    {
                                        failed_select = 2,
                                        {expression = "self:buff_num:pf_sszhuzhuqing_wuhun_buff1>2", select = 1},                                       
                                    }
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_target = true, buff_id = "pf_sszhuzhuqing_fear"},
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
}

return daimubai_pugong1