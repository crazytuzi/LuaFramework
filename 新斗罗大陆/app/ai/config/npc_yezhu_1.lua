 
 local npc_yezhu_1 = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 6, first_interval=6},
                },
                {
                    CLASS = "action.QAIAttackByHitlog",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50153},
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
    },
}

return npc_yezhu_1