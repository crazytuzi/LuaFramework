local anqi_yonghengxingyu_zhuli1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBAttackFinish",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsUnderStatus",
                    OPTIONS = {is_attacker = true,status = "yonghenglingyu"},
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
                                    OPTIONS = {buff_id = "anqi_yonghengxingyu_cf2_buff1",teammate_and_self = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "anqi_yonghengxingyu_cf2_buff2",teammate_and_self = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "anqi_yonghengxingyu_huifujiance2",teammate_and_self = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "anqi_yonghengxingyu_cf1_biaoxian1",is_target = false},
                                },
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                                {
                                    CLASS = "action.QSBPlayMountSkillAnimation",
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return anqi_yonghengxingyu_zhuli1
