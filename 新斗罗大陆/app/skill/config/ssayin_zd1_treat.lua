local ssqianshitangsan_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {    
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsUnderStatus",
                    OPTIONS = {is_attacker = true,status = "ssayin_zd1_treat_cf"},
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
                                    OPTIONS = {buff_id = "ssayin_zd1_treat", is_target = false},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "ssayin_zd1_qx", is_target = false},
                                },
                                {
                                    CLASS = "action.QSBDecreaseHpByAbsorb",
                                    OPTIONS = {is_attack_percent = true, attack_percent = 3},
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
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "ssayin_zd1_treat_cf", is_target = false},
                                },
                                {
                                    CLASS = "action.QSBDecreaseHpByAbsorb",
                                    OPTIONS = {is_attack_percent = true, attack_percent = 3},
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
    },
}

return ssqianshitangsan_pugong1