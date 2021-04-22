
local zudui_kuangbaojiance = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "ddzw"},
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
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "zudui_dadizhiwang_kuangbao_buff"},
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    { 
                        {
                            CLASS = "action.QSBArgsIsUnderStatus",
                            OPTIONS = {is_attacker = true,status = "fhnn"},
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
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_target = false, buff_id = "zudui_fenhongniangniang_kuangbao_buff"},
                                        },
                                        {
                                            CLASS = "action.QSBAttackFinish",
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
            },    
        },
    },               
}

return zudui_kuangbaojiance