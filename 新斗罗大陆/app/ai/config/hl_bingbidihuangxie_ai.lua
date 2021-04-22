
local hl_tongyong_ai = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsOutOfDistance",
                    OPTIONS = {distance = 550},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 31006}, --跳
                },
            },
        },
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