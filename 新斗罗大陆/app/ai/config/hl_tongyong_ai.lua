
local hl_tongyong_ai = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "action.QAIElf",
        },
        {
            CLASS = "action.QAIAttackByHatred",
               OPTIONS = {is_get_max = true},
        },
        {
             CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAIBeatBack",
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
            },
        },
    },
}
return hl_tongyong_ai