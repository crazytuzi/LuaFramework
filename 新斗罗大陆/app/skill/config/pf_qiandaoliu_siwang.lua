local qiandaoliu_siwang = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                {expression = "self:is_copy_hero=false"}
            },
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {    
                {
                    CLASS = "action.QSBRemoveBuffByStatus",
                    OPTIONS = {status = "qiandaoliu_zj", teammate_and_self = true},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return qiandaoliu_siwang