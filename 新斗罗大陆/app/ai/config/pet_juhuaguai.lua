
local pet_juhuaguai = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval=600},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 176},
                },
            },
        },
        {
            CLASS = "action.QAIPETARENA",
        },
        {
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
				
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
            },
        },
		{
            CLASS = "action.QAIAttackByHitlog",
        },
    },
}

return pet_juhuaguai