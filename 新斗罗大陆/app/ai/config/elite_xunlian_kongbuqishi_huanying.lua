local elite_xunlian_kongbuqishi_huanying = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
      	{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0.8},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53086},          --冲锋
                },
            },
        }, 
    },
    {
        CLASS = "action.QAIAttackByHitlog",
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
}

return elite_xunlian_kongbuqishi_huanying