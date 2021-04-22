local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {   
        {
            CLASS = "action.QSBPlayGodSkillAnimation"
        },        
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsUnderStatus",
                    OPTIONS = {is_attacker = true,status = "sspqianrenxue_sj2_jt1"},
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
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {is_target = true, buff_id = "sspqianrenxue_sj2_jt1",no_cancel = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "sspqianrenxue_sj2_jt2", no_cancel = true},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsFindTargets",
                    OPTIONS = {teammate = true},
                },
                {
                    CLASS = "action.QSBStrikeAgreement",
                    OPTIONS = {percent = 0.2,time = 10,hp_threshold = 0.05},
                },
            },
        }, 
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sspqianrenxue_sj2_buff1",teammate_and_self = true},
        }, 
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sspqianrenxue_sj2_buff2",teammate_and_self = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sspqianrenxue_sj2_buff4",teammate_and_self = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sspqianrenxue_sj2_debuff1",enemy = true},
        },
         {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sspqianrenxue_sj2_js1",is_target = false},
        },       
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "sspqianrenxue_shenji_1"},
        }, 
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "sspqianrenxue_shenji_2"},
        },  
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "sspqianrenxue_shenji_3"},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false, effect_id = "sspqianrenxue_shenji_5"},
        },                                                            
    },
}

return ssqianshitangsan_pugong1