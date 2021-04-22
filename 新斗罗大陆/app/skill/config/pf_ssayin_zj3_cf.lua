local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_ssayin_zj3_cfbuff1", is_target = false},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "ssayin_zj3_cfbuff2", is_target = false},
        },
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {buff_id = "ssayin_zj_cfeffect", is_target = false},
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsUnderStatus",
                    OPTIONS = {is_attacker = true,status = "ssayin_zj_jt"},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
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
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "pf_ssayin_zj3_jt", is_target = false},
                                },
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                            },
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
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {not_copy_hero = true, highest_force = true, is_teammate = true, include_self = false ,just_hero = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssayin_zj3_cfbuff2", pass_key = {"selectTarget"}},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {is_teammate = true, under_status = "ssayin_sj", args_translate = {selectTarget = "strike_agreementee"}},
                },
                {
                    CLASS = "action.QSBStrikeAgreement",
                    OPTIONS = {is_strike_agreement = true, percent = 0.2,time = 7,hp_threshold = 0.3,pass_key = {"selectTarget"}},
                },                
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsFindTargets",
                    OPTIONS = {teammate_and_self = true, just_hero = true, is_under_status = "ssayin_sj"},
                },
                {
                    CLASS = "action.QSBPlayLinkEffect",
                    OPTIONS = {effect_id = "ssayin_lianjie", dummy = "dummy_center", duration = 7, effect_width = 298},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },                                       
    },
}

return ssqianshitangsan_pugong1