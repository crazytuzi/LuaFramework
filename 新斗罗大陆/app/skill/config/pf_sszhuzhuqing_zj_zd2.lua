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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 8 / 30},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true},
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsDirectionLeft",
                    OPTIONS = {is_attacker = true},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {   
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 15 / 30},
                                },
                                {
                                    CLASS = "action.QSBSSZhuzhuQingRangeOffset",
                                    OPTIONS = {speed = -1600,duration = 0.25},
                                },
                                {
                                    CLASS = "action.QSBSSZhuzhuQingRangeOffset",
                                    OPTIONS = {speed = 1600,duration = 0.25,offset =  {x = -400, y = 0}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 15 / 30},
                                },
                                {
                                    CLASS = "action.QSBSSZhuzhuQingRangeOffset",
                                    OPTIONS = {speed = 1600,duration = 0.25},
                                },
                                {
                                    CLASS = "action.QSBSSZhuzhuQingRangeOffset",
                                    OPTIONS = {speed = -1600,duration = 0.25,offset =  {x = 400, y = 0}},
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "pf_sszzq_zd2_1", is_hit_effect = false},
        }, 
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 20 / 30},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "sszhuzhuqing_wudi_0.5s"},
                        },                        
                    },
                },
            },
        },
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 29 / 30},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_sszzq_zd2_2", is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                            OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 0, trapId = "pf_sszhuzhuqing_zd2_xuruo"},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {property_promotion = {critical_damage = 0.35 }},
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
                    OPTIONS = {delay_time = 35 / 30},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect", OPTIONS = {effect_id = "pf_sszzq_zd2_2", is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {property_promotion = {critical_damage = 0.35 }},
                        },
                    },
                },
            },
        },
    },
}

return daimubai_pugong1